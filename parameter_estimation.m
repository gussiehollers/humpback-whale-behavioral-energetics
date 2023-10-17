%% Parameter estimation
%get the times that the whales are traveling and resting
%get the distributions of the average speed, mean resultant length, minimum
%specific acceleration, and maximum depth

%get the BORIS and prh files uploaded
[filenames,fileloc]=uigetfile('*.csv*', 'select ALL the BORIS files','MultiSelect','on');

[filenames2,fileloc2]=uigetfile('*.mat*', 'select the PRH file','MultiSelect','on'); 
load([fileloc2 filenames2]);
%% Find the times of every period of traveling and resting

ALL_boris=table();
for a=1:length(filenames)
   
    BORISfile = readtable([fileloc filenames{a}]);

    %get rid of all the columns I don't need
    BORISfile.ImageFilePath=[];
    BORISfile.ImageIndex=[];
    BORISfile.Comment=[];
    BORISfile.Source=[];
    BORISfile.Subject=[];
    BORISfile.BehavioralCategory=[];
    BORISfile.Description=[];
    BORISfile.ObservationType=[];
    
    BORISVidNumber = str2double(BORISfile.ObservationId{1}(19:20));
    BORISfile.timeDN = (BORISfile.Time/86400)+vidDN(BORISVidNumber);
    BORISfile.timehms=datetime(BORISfile.timeDN, 'Format', 'HH:mm:ss.S', 'ConvertFrom', 'datenum');
    BORISfile.timehmsstr=string(BORISfile.timehms);

ALL_boris=vertcat(ALL_boris, BORISfile);

end

i_travel=find(strcmp(ALL_boris.Behavior,'travel'));
i_tstart=find(strcmp(ALL_boris.Behavior,'travel') & strcmp(ALL_boris.BehaviorType,'START'));
i_tstop=find(strcmp(ALL_boris.Behavior,'travel') & strcmp(ALL_boris.BehaviorType,'STOP'));
%travel_dur_s=sum(ALL_boris.Time(i_tstop)-ALL_boris.Time(i_tstart));

i_rest=find(strcmp(ALL_boris.Behavior,'rest'));
i_rstart=find(strcmp(ALL_boris.Behavior,'rest') & strcmp(ALL_boris.BehaviorType,'START'));
i_rstop=find(strcmp(ALL_boris.Behavior,'rest') & strcmp(ALL_boris.BehaviorType,'STOP'));
%rest_dur_s=sum(ALL_boris.Time(i_rstop)-ALL_boris.Time(i_rstart));

restperiods=table();
for a=1:length(i_rstop)
    start_date=ALL_boris.timeDN(i_rstart(a));
    end_date=ALL_boris.timeDN(i_rstop(a));
    i_period=find(DN >= start_date & DN <= end_date);
    i_period=table(i_period);

restperiods=vertcat(restperiods,i_period);
end

travelperiods=table();
for a=1:length(i_tstop)
    start_date=ALL_boris.timeDN(i_tstart(a));
    end_date=ALL_boris.timeDN(i_tstop(a));
    i_periodt=find(DN >= start_date & DN <= end_date);
    i_periodt=table(i_periodt);

travelperiods=vertcat(travelperiods,i_periodt);
end

total_indices = 1:length(roll);
% Create logical masks for traveling and resting indices
travel_mask = false(size(total_indices));
tpi=table2array(travelperiods);
travel_mask(tpi) = true;

rest_mask = false(size(total_indices));
rpi=table2array(restperiods);
rest_mask(rpi) = true;

otherperiods=find(~(travel_mask | rest_mask));
otherperiods=array2table(otherperiods');

%now I have tables of the indices of the time periods when the whale is
%traveling and resting!!

%% Chunk each traveling period into 5 minute chunks and get the variables for each chunk

%for each i_tstart to i_tstop make a table of the raw variables
columnNames={'time','speed', 'Awx', 'Awy', 'Awz', 'heading', 'depth'};
varTypes={'double','double', 'double', 'double', 'double', 'double', 'double'};
whale_data=table('Size', [length(pitch), 7 ], 'VariableNames', columnNames, 'VariableTypes', varTypes);

tabletime=table(DN);
whale_data(:, 'time') = tabletime;

tableAwx=table(Aw(:,1));
whale_data(:, 'Awx') = tableAwx;
tableAwy=table(Aw(:,2));
whale_data(:, 'Awy') = tableAwy;
tableAwz=table(Aw(:,3));
whale_data(:, 'Awz') = tableAwz;

%heading
tablehead=table(head);
whale_data(:, 'heading') = tablehead;

%depth (turns negatives into 0)
tabledepth=table(p);
condition=tabledepth.p<0;
tabledepth.p(condition)=0;
whale_data(:, 'depth') = tabledepth;

%have to find the best speed measurement
%first value after the NaNs
nonNaNIndices = find(~isnan(speed.JJr2), 1);
JJr2_value = speed.JJr2(nonNaNIndices);
FNr2_value = speed.FNr2(nonNaNIndices);

if JJr2_value> FNr2_value
    tableSpeed=table(speed.JJ);
else
    tableSpeed=table(speed.FN);
end

whale_data(:, 'speed') = tableSpeed;

travel_data=whale_data(tpi,:);
rest_data=whale_data(rpi,:);
other_data=whale_data(table2array(otherperiods),:);

%get rid of NaN values
t_nonNaNi=~isnan(travel_data.Awx) & ~isnan(travel_data.heading) & ~isnan(travel_data.Awy) & ~isnan(travel_data.Awz) & ~isnan(travel_data.speed);
travel_filt=travel_data(t_nonNaNi, :);

r_nonNaNi=~isnan(rest_data.Awx) & ~isnan(rest_data.heading) & ~isnan(rest_data.Awy) & ~isnan(rest_data.Awz) & ~isnan(rest_data.speed);
rest_filt=rest_data(r_nonNaNi, :);

o_nonNaNi=~isnan(other_data.Awx) & ~isnan(other_data.heading) & ~isnan(other_data.Awy) & ~isnan(other_data.Awz) & ~isnan(other_data.speed);
other_filt=other_data(o_nonNaNi, :);

%% Chunk each resting period into 5 minute chunks and get the variables for each chunk

segment_length=60*5;
data=travel_filt;
[t_avg_time, t_avg_speed, t_mean_resultant_length, t_min_specific_accel, t_max_depth]=hmm_dataprep(data, segment_length);
t_chunk=[t_avg_time, t_avg_speed, t_mean_resultant_length, t_min_specific_accel, t_max_depth];

data=rest_filt;
[r_avg_time, r_avg_speed, r_mean_resultant_length, r_min_specific_accel, r_max_depth]=hmm_dataprep(data, segment_length);
r_chunk=[r_avg_time, r_avg_speed, r_mean_resultant_length, r_min_specific_accel, r_max_depth];

data=other_filt;
[o_avg_time, o_avg_speed, o_mean_resultant_length, o_min_specific_accel, o_max_depth]=hmm_dataprep(data, segment_length);
o_chunk=[o_avg_time, o_avg_speed, o_mean_resultant_length, o_min_specific_accel, o_max_depth];
%% repeat for each whale and Concatenate into a traveling table and a resting table

%all_travel=t_chunk;
all_travel=vertcat(all_travel,t_chunk);

%all_rest=r_chunk;
all_rest=vertcat(all_rest,r_chunk);

%all_other=o_chunk;
all_other=vertcat(all_other,o_chunk);
%all_other_hms=table(datetime(all_other(:,1), 'ConvertFrom','datenum'));
%all_other=all_other(1:61,:);

save('all_travel.mat','all_travel','-mat')
save('all_rest.mat','all_rest','-mat')
save('all_other.mat','all_other','-mat')

filename1 = 'all_travel.csv';
writematrix(all_travel, filename1);

filename2 = 'all_rest.csv';
writematrix(all_rest, filename2);

filename3 = 'all_other.csv';
writematrix(all_other, filename3);

%% Distribution and parameter estimation 


