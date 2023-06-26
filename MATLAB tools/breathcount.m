 %% BEHAVIOR COUNT
 %

 %import the BORIS files from one whale's deployment and the prh file
[filenames,fileloc]=uigetfile('*.csv*', 'select ALL the BORIS files','MultiSelect','on');

[filenames2,fileloc2]=uigetfile('*.mat*', 'select the PRH file','MultiSelect','on'); 
load([fileloc2 filenames2]);

%import a list with the body lengths and body conditions
[filenames3,fileloc3]=uigetfile('*.csv*', 'select the animal size file','MultiSelect','on');
WhaleSizes=readtable([fileloc3 filenames3]);
%% BREATHS

%this loop creates a table that has all the times of the breaths for one
%whale
BREATHS=table();
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

    %get rid of the behaviors that are not breaths
    i_bth=find(strcmp(BORISfile.Behavior,'breath'));
    BORISfilebreaths=BORISfile(i_bth, :);
    
    BORISVidNumber = str2double(BORISfilebreaths.ObservationId{1}(19:20));
    BORISfilebreaths.timeDN = (BORISfilebreaths.Time/86400)+vidDN(BORISVidNumber);
    BORISfilebreaths.timehms=datetime(BORISfilebreaths.timeDN, 'Format', 'HH:mm:ss.S', 'ConvertFrom', 'datenum');
    BORISfilebreaths.timehmsstr=string(BORISfilebreaths.timehms);
    
BREATHS=vertcat(BREATHS, BORISfilebreaths);

end

%add a column that is just the animal ID without the video
whaleID=BREATHS.ObservationId{1}(1:11);
whaleID=convertCharsToStrings(whaleID);
BREATHS.whaleID(:)=whaleID;

%add columns that have the absolute length, relative length, and body
%condition index
WhaleSizes.ID=string(WhaleSizes.CATS_Tag_No); %adds a column with the whale ID in string format
matchindex=find(whaleID==WhaleSizes.ID); %compare the whale ID from the breaths file to the whale size file
BREATHS.Drone_Filename(:)=string(WhaleSizes.Drone_Filename(matchindex));
BREATHS.Role(:)=string(WhaleSizes.Role(matchindex));
BREATHS.Total_length(:)=WhaleSizes.Total_length(matchindex);
BREATHS.Rel_length(:)=WhaleSizes.Rel_length(matchindex);
BREATHS.BCI(:)=WhaleSizes.BCI(matchindex);

%saves all the breaths from one whale 
name=append(whaleID, "_breaths");
save(name, "BREATHS")

%next I should write some code that would combine the breaths from multiple
%whales

%also should measure the breath rate (breaths per minute) 
%count all the breaths (could just do the height of the table) and then add
%all the observation durations together (and divide by 60) to get the total
%minutes of the video 

%% BREACHES!
 
%maybe I could add a way for matlab to search if there are any breaches,
%and then do this code only if there are?

%maybe have the code display 'no breaches found' so I know if there are any

BREACHES=table();
for a=1:length(filenames)
   
    BORISfile = readtable([fileloc filenames{a}]);

    %get rid of all the columns I don't need
    BORISfile.ImageFilePath=[];
    BORISfile.Comment=[];
    BORISfile.Source=[];
    BORISfile.Subject=[];
    BORISfile.BehavioralCategory=[];
    BORISfile.Description=[];
    BORISfile.ObservationType=[];

    %get rid of the behaviors that are not breaches
    i_bch=find(strcmp(BORISfile.Behavior,'Breach'));
    BORISfilebreach=BORISfile(i_bch, :);

    BORISVidNumber = str2double(BORISfilebreach.ObservationId{1}(19:20));
    BORISfilebreach.timeDN = (BORISfilebreach.Time/86400)+vidDN(BORISVidNumber);
    BORISfilebreach.timehms=datetime(BORISfilebreach.timeDN, 'Format', 'HH:mm:ss.S', 'ConvertFrom', 'datenum');
    BORISfilebreach.timehmsstr=string(BORISfilebreach.timehms);
    
BREACHES=vertcat(BREACHES, BORISfilebreach);

end

%add a column that is just the animal ID without the video
whaleID=BREACHES.ObservationId{1}(1:11);
whaleID=convertCharsToStrings(whaleID);
BREACHES.whaleID(:)=whaleID;

%add columns that have the absolute length, relative length, and body
%condition index
WhaleSizes.ID=string(WhaleSizes.CATS_Tag_No); %adds a column with the whale ID in string format
matchindex=find(whaleID==WhaleSizes.ID); %compare the whale ID from the breaths file to the whale size file
BREACHES.Drone_Filename(:)=string(WhaleSizes.Drone_Filename(matchindex));
BREACHES.Role(:)=string(WhaleSizes.Role(matchindex));
BREACHES.Total_length(:)=WhaleSizes.Total_length(matchindex);
BREACHES.Rel_length(:)=WhaleSizes.Rel_length(matchindex);
BREACHES.BCI(:)=WhaleSizes.BCI(matchindex);

%saves all the breaches from one whale 
name2=append(whaleID, "_breaches");
save(name2, "BREACHES")

%% Behavioral state times
% Measures the duration of time spent in different behavioral states
% (traveling and resting)

%make a table with all the whales behaviors together
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

%makes a list of just the travel events
i_tvl=find(strcmp(ALL_boris.Behavior,'travel'));
BORISfile_travel=ALL_boris(i_tvl, :);

%find the duration of the traveling events
t_start=BORISfile_travel.timehms(1:2:end,:);
t_stop=BORISfile_travel.timehms(2:2:end,:);
total_travel=sum(t_stop-t_start);
minutes(total_travel)

%makes a list of just the REST events
i_rst=find(strcmp(ALL_boris.Behavior,'rest'));
BORISfile_rest=ALL_boris(i_rst, :);

%find the duration of the RESTING events
r_start=BORISfile_rest.timehms(1:2:end,:);
r_stop=BORISfile_rest.timehms(2:2:end,:);
total_rest=sum(r_stop-r_start);
minutes(total_rest)

%% BREATHS with lunge detector
%finding the breath rate per minute using the lunge detector

%load the lunges file from the whale
load('mn200219-55lunges.mat')

bad_index=find(LungeC==1); %finds the FAKE breaths where the breath signatures were not clear enough, so we want to get rid of them
bad_times=LungeI(bad_index);
bad_start=bad_times(1:2:end,:);
bad_end=bad_times(2:2:end,:);
bad_total=sum(bad_end-bad_start); %total number of indices I want to cut out
total_time=LungeI(length(LungeI))-LungeI(1);
good_total=total_time-bad_total;
good_mins=good_total/10/60

breath_index=find(LungeC==3);
breath_total=length(breath_index)
breath_rate=breath_total/good_mins %gives the breath rate in number of breaths per minute!



