%BEHAVIORAL ENERGETICS TOOL 
%main tool to calculate the behavioral variables for each whale and save
%them in a big table

%Create the master table with all the whales' information
%varTypes={'cellstr','cellstr',  'double',     'double',     'double',       'double',   'datetime','datetime', 'double',      'double',       'double',          'double',           'double',       'double',       'double',  'double', 'double', 'double',      'double'};
%varNames=["whale_ID","class","abs_length","pct_length","body_condition","body_volume", "tag_on", "tag_off", "resp_rate", "num_breaches", "pct_time_depthA", "pct_time_depthB", "pct_time_depthC", "total_roll", "stroke_rate", "MSA", "gyro_SA", "suckling_rate", "suckling_time"];
%All_whales= table('Size',[50 19],'VariableTypes', varTypes,'VariableNames',varNames);
%save('All_whales.mat','All_whales','-mat')

%CHANGE FOR EVERY NEW WHALE
rowIndex=16;

load('All_whales.mat');

%load the whale's prh and BORIS files
[filenames,fileloc]=uigetfile('*.csv*', 'select ALL the BORIS files','MultiSelect','on');

[filenames2,fileloc2]=uigetfile('*.mat*', 'select the PRH file','MultiSelect','on'); 
load([fileloc2 filenames2]);

All_whales(rowIndex,1)={INFO.whaleName};

%% 1 Body size
% imports the body size measurements and matches them to the correct whale

%import a list with the body lengths and body conditions
[filenames3,fileloc3]=uigetfile('*.csv*', 'select the animal size file','MultiSelect','on');
WhaleSizes=readtable([fileloc3 filenames3]);

i=find(strcmp(WhaleSizes.CATS_Tag_No,INFO.whaleName)==1); %finds the correct row of the WhaleSizes file
All_whales(rowIndex,2)=WhaleSizes.Role(4);

abs_length=WhaleSizes.Total_length(i);
All_whales(rowIndex,3)={abs_length};

pct_length=WhaleSizes.Rel_length(i);
All_whales(rowIndex,4)={pct_length};

BCI=WhaleSizes.BCI(i);
All_whales(rowIndex,5)={BCI};

%body_vol=
%All_whales(rowIndex,6)=body_vol;

%% 2 TAG ON and TAG OFF
% puts the tag on and tag off time from the prh file into the all_whales
% table

j=find(tagon==1);
tagon_DN=DN(j);
tagon_datetime=datetime(tagon_DN(1),'ConvertFrom','datenum','Format','HH:mm:ss.SSS');
tagoff_datetime=datetime(tagon_DN(length(tagon_DN)),'ConvertFrom','datenum','Format','HH:mm:ss.SSS');

All_whales(rowIndex,7)={tagon_datetime};
All_whales(rowIndex,8)={tagoff_datetime};

%% 3 Respiration rate
% calculates the number of breaths per minute from the BORIS files
%IF NO BORIS FILES (no videos) could use the surfacing script to find an
%approximate breath rate

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
    %BORISfile.timeDN = (BORISfile.Time/86400)+vidDN(BORISVidNumber);
    %BORISfile.timehms=datetime(BORISfile.timeDN, 'Format', 'HH:mm:ss.S', 'ConvertFrom', 'datenum');
    %BORISfile.timehmsstr=string(BORISfile.timehms);

ALL_boris=vertcat(ALL_boris, BORISfile);

end

%finds the index of all the breath events
i_breath=find(strcmp(ALL_boris.Behavior,'breath'));

% greatest time between breaths (breatholding ability)
breath_seconds=ALL_boris.Time(i_breath);
breath_diffs=table();
for b=1:(length(i_breath)-1)
    breath_diffs(b,:)=table(breath_seconds(b+1)-breath_seconds(b));
end

%need to add up the lengths of the video durations, 
total_obs_dur=sum(unique(ALL_boris.ObservationDuration));
total_obs_dur_mins=total_obs_dur/60;
breath_permin=length(i_breath)/total_obs_dur_mins;
All_whales(rowIndex,9)={breath_permin};

%% 4 Breaches
% Counts the number of breaches in the deployment

%finds the index of all the breach events
i_breach=find(strcmp(ALL_boris.Behavior,'Breach'));

All_whales(rowIndex,10)={length(i_breach)};

%% 5 Time dpent at different depths
% calculates the percentage of the deployment spent at different depths
%depth zone A < 5m below the surface
%depth zone B is between 5 and 10 m deep
%depth zone C is >10 m below the surface

depthA_indx=find(p<5);
depthB_indx=find((5<p) & (p<10));
depthC_indx=find(p>10);

%total length of time spent at each depth
min_depthA=length(depthA_indx)/fs/60;
min_depthB=length(depthB_indx)/fs/60;
min_depthC=length(depthC_indx)/fs/60;

pct_A=(length(depthA_indx)/length(p))*100;
All_whales(rowIndex,11)={pct_A};

pct_B=(length(depthB_indx)/length(p))*100;
All_whales(rowIndex,12)={pct_B};

pct_C=(length(depthC_indx)/length(p))*100;
All_whales(rowIndex,13)={pct_C};

%% 6 Total roll
% DONT KNOW HOW TO DO THIS YET
All_whales(rowIndex,14)={};

%% 7 Stroke Rate
% Ask Will how to do this
Aw_nonan=Aw(~isnan(Aw(:,1)),1);
InertialData = Aw_nonan;
Depth=p;
SurfaceThresh=2;
%DurThresh,HeightThresh,MagThresh,ClarityThresh
[FlukingOverlay, Tailbeats] = TailbeatDetect(InertialData,fs,Depth,SurfaceThresh); % need switch to tell if gyro or accl for InertialData

%Do I want the stroke rate? total number of beats per minute when
%underwater?
surfthresh_indx=find(p>2);
minutes_2m=length(surfthresh_indx)/fs/60;
secs_2m=length(surfthresh_indx)/fs;
stroke_permin=height(Tailbeats)/minutes_2m;
stroke_persec=height(Tailbeats)/secs_2m;
%or do I want to oscilatory frequency?
avg_beatOsFreq=mean(Tailbeats(:,3));

All_whales(rowIndex,15)=avg_beatOsFreq;

%% 8 Minimum Specific Acceleration
% calculates the minimum specific acceleration over the deployment

ref=1;
msa=MSA(Aw,ref);
msa_ms2=msa*9.81;

%saves the whole MSA in its own folder
folderpath='C:\Users\Gussie\Documents\humpback-whale-behavioral-energetics\humpback MSA';
name=append(INFO.whaleName, "_msa");
filepath=fullfile(folderpath,name);
save(filepath, "msa_ms2")

%get the average MSA over the deployment, I don't really know if this means
%anything tbh
nonNaNValues = msa_ms2(~isnan(msa_ms2));
lengthWithoutNaN = length(nonNaNValues);
avg_msa=sum(nonNaNValues)/length(nonNaNValues);
All_whales(rowIndex,16)={avg_msa};

%% 9 Specific acceleration from gyroscope
% calculates the specific acceleration from the gyroscope method 
fc=0.4*0.25; 
Az_dtag=Aw(:,3)*-1;
Aw_dtag=[Aw(:,1), Aw(:,2), Az_dtag];

Gz_dtag=Gw(:,3)*-1;
Gw_dtag=[Gw(:,1), Gw(:,2), Gz_dtag];

pryGyro = gyro_rot(Gw_dtag,fs,fc) ;      % predict BR using gyroscope method
saGyro = acc_sa(Aw_dtag,pryGyro,fs,fc) ;
%ok should I take the absolute value of the square root of the axes
%squared?
sa_norm = abs(sqrt(sum(saGyro.^2, 2)));

nonNaNValues2 = sa_norm(~isnan(sa_norm));
lengthWithoutNaN2 = length(nonNaNValues2);
avg_sagyro=sum(nonNaNValues2)/length(nonNaNValues2);
All_whales(rowIndex,17)={avg_sagyro};


%% 10 Suckling rate
% calculates the number of suckling events per hour and the total time
% spent suckling 

i_nurse=find(strcmp(ALL_boris.Behavior,'nursing'));
total_obs_dur_hrs=total_obs_dur_mins/60;
suck_rate=(length(i_nurse)/2)/total_obs_dur_hrs;
All_whales(rowIndex,18)={suck_rate};

i_start=find(strcmp(ALL_boris.Behavior,'nursing') & strcmp(ALL_boris.BehaviorType,'START'));
i_stop=find(strcmp(ALL_boris.Behavior,'nursing') & strcmp(ALL_boris.BehaviorType,'STOP'));

nurse_dur_s=sum(ALL_boris.Time(i_stop)-ALL_boris.Time(i_start));
All_whales(rowIndex,19)={nurse_dur_s};
%% Time spent resting and traveling
% calculate the porportion of time spent resting and traveling from the
% BORIS data

i_travel=find(strcmp(ALL_boris.Behavior,'travel'));
i_tstart=find(strcmp(ALL_boris.Behavior,'travel') & strcmp(ALL_boris.BehaviorType,'START'));
i_tstop=find(strcmp(ALL_boris.Behavior,'travel') & strcmp(ALL_boris.BehaviorType,'STOP'));
travel_dur_s=sum(ALL_boris.Time(i_tstop)-ALL_boris.Time(i_tstart));
pct_travel=travel_dur_s/total_obs_dur;

i_rest=find(strcmp(ALL_boris.Behavior,'rest'));
i_rstart=find(strcmp(ALL_boris.Behavior,'rest') & strcmp(ALL_boris.BehaviorType,'START'));
i_rstop=find(strcmp(ALL_boris.Behavior,'rest') & strcmp(ALL_boris.BehaviorType,'STOP'));
rest_dur_s=sum(ALL_boris.Time(i_rstop)-ALL_boris.Time(i_rstart));
pct_rest=rest_dur_s/total_obs_dur;

%% Save updated All_whales table
% after saving the data from the current whale, you can clear the workspace
% and begin the next whale!

save('All_whales.mat','All_whales','-mat')

%% GRAPHS

%calf respiration rate
i_calf=find(strcmp(All_whales.class,'Calf'));
calves=All_whales(i_calf,:);
figure
scatter(calves.abs_length, calves.resp_rate, 'filled')
resprate_length_lm=fitlm(calves.abs_length, calves.resp_rate)

figure
scatter(calves.pct_length, calves.resp_rate, 'filled')
resprate_rellength_lm=fitlm(calves.pct_length, calves.resp_rate)

%calves and mothers time at depths
depths=[mean(calves.pct_time_depthA), mean(calves.pct_time_depthB), mean(calves.pct_time_depthC)];
figure
pie(depths)

i_mom=find(strcmp(All_whales.class,'Mother'));
moms=All_whales(i_mom,:);
momdepth=[moms.pct_time_depthA, moms.pct_time_depthB, moms.pct_time_depthC];
figure
pie(momdepth)

figure
boxplot(All_whales.resp_rate,All_whales.class)
title('Respiration rate in mothers and calves')
xlabel('Age class')
ylabel('Breaths per minute')




%MSA comparison
figure
scatter(calves.abs_length, calves.MSA, 'filled')
MSA_length_lm=fitlm(calves.abs_length, calves.MSA)

figure
scatter(calves.pct_length, calves.MSA, 'filled')
MSA_pctlength_lm=fitlm(calves.pct_length, calves.MSA)

figure
scatter(calves.pct_length, calves.pct_time_depthA, 'filled')
depthA_length_lm=fitlm(calves.abs_length, calves.pct_time_depthA)

figure
scatter(calves.pct_length, calves.suckling_rate, 'filled')

suck_calves=calves;
suck_calves(6,:) = [];
figure
scatter(suck_calves.pct_length, suck_calves.suckling_rate, 'filled')
fitlm(suck_calves.pct_length, suck_calves.suckling_rate)

figure
scatter(All_whales.abs_length(1:15), All_whales.stroke_rate(1:15), 'filled')
All_whales.abs_length(13)=12;