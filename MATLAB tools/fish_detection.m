%% Fish detection
%finds the number of fish detections and if they were eating skin
%also finds the number of times urine or feces was seen

%Create the master table with all the whales' information
%varTypes={'cellstr','cellstr',  'double',      'double',  'double',    'double',   'double'};
%varNames=["whale_ID","class", "num_fish", "rate_fish", "eating_pct", "num_feces", "num_urine"];
%fish_whales= table('Size',[50 7],'VariableTypes', varTypes,'VariableNames',varNames);
%save('fish_whales.mat','fish_whales','-mat')

%CHANGE FOR EVERY NEW WHALE
rowIndex=24;

load('fish_whales.mat');

%load the whale's BORIS files (dont think I need the prh)
[filenames,fileloc]=uigetfile('*.csv*', 'select ALL the BORIS files','MultiSelect','on');

%[filenames2,fileloc2]=uigetfile('*.mat*', 'select the PRH file','MultiSelect','on'); 
%load([fileloc2 filenames2]);

%% Number of fish seen

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

ALL_boris=vertcat(ALL_boris, BORISfile);

end

fish_whales(rowIndex,1)={BORISfile.ObservationId{1}(1:11)};

%finds the total number of fish observations seen
i_fish=find(strcmp(ALL_boris.Behavior,'fish present'));
fish_whales(rowIndex, 3)=table(length(i_fish));

%find the number of fish observations per minute
total_obs_dur=sum(unique(ALL_boris.ObservationDuration));
total_obs_dur_mins=total_obs_dur/60;
fish_permin=length(i_fish)/total_obs_dur_mins;
fish_whales(rowIndex,4)={fish_permin};

%percentage of fish sightings where they are definitely eating
i_fish_eat=find(strcmp(ALL_boris.Behavior,'fish present')& strcmp(ALL_boris.Modifier_1,'skin') & strcmp(ALL_boris.Modifier_2,'taking food into their mouths'));
fish_whales(rowIndex, 5)=table(length(i_fish_eat)/length(i_fish));

%% Urine and feces
i_feces=find(strcmp(ALL_boris.Behavior,'excrement') & strcmp(ALL_boris.Modifier_1,'feces'));
fish_whales(rowIndex, 6)=table(length(i_feces));

i_urine=find(strcmp(ALL_boris.Behavior,'excrement') & strcmp(ALL_boris.Modifier_1,'urine'));
fish_whales(rowIndex, 7)=table(length(i_urine));

%% Save before the next iteration

save('fish_whales.mat','fish_whales','-mat')


%% Post analysis
 i=~isnan(fish_whales.eating_pct);
mean(fish_whales.eating_pct(i))





