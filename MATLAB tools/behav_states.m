%% Behavioral states
% experimenting with finding the parameters to define different behavioral
% states: resting, traveling, and other 

%use the states from the videos

[filenames,fileloc]=uigetfile('*.csv*', 'select ALL the BORIS files','MultiSelect','on');

[filenames2,fileloc2]=uigetfile('*.mat*', 'select the PRH file','MultiSelect','on'); 
load([fileloc2 filenames2]);

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

total_obs_dur=sum(unique(ALL_boris.ObservationDuration));

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

%ok this doesn't really work, the percentages don't add up to 100 
