%% NURSING ACCELEROMETER VISUALIZATION
% Plots the accelerometer signal from all the nursing events in a
% deployment 

%load the whale's prh and BORIS files
[filenames,fileloc]=uigetfile('*.csv*', 'select ALL the BORIS files','MultiSelect','on');

[filenames2,fileloc2]=uigetfile('*.mat*', 'select the PRH file','MultiSelect','on'); 
load([fileloc2 filenames2]);
%% 

%creates a table with all the behavioral events from the deployment 
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
    %BORISfile.window1=BORISfile.timeDN-(300/86400);
    %BORISfile.window2=BORISfile.timeDN+(300/86400); %makes a window of 60 seconds around each behavior time

ALL_boris=vertcat(ALL_boris, BORISfile);

end

for i = 1:length(ALL_boris.timeDN);
    [~, ALL_boris.timeIndex(i)] = min(abs(DN - ALL_boris.timeDN(i)));
end

%% Finds and plots the nursing events

i_nurse=find(strcmp(ALL_boris.Behavior,'nursing'));

length(i_nurse) %use this to create the dimensions of the subplot
nursing_events=ALL_boris(i_nurse,:); %all the of the nursing events
i_nstart=find(strcmp(nursing_events.BehaviorType,'START'));
i_nstop=find(strcmp(nursing_events.BehaviorType,'STOP'));


%% 

figure
    tic;
  sp1 = subplot(9,1,1:3); %subplot divides figure into grid
     plot(DN, -Aw(:,:)); hold on;
     set(gca,'ydir','rev','xticklabel',datestr(get(gca,'xtick'),'HH:MM:SS'));

  sp2= subplot(9,1,4:6);
    plot(DN,p,'g'); 
    set(gca,'ydir','rev','xticklabel',datestr(get(gca,'xtick'),'HH:MM:SS'));

 sp3 = subplot(9,1,7:9);
    [ax,h1,h2] = plotyy(DN,pitch*180/pi,DN,roll*180/pi); hold on;
    set(ax,'nextplot','add'); plot(ax(2),DN,head*180/pi,'b');
    set(h1,'color','g');
    set(h2,'color','r');
    set(gca,'xticklabel',datestr(get(gca,'xtick'),'HH:MM:SS'));
    linkaxes([sp1 sp2 sp3],'x');

recessionPeriods=[nursing_events.timeDN(i_nstart), nursing_events.timeDN(i_nstop)];
recessionplot('axes',sp1 ,'recessions',recessionPeriods)
recessionplot('axes',sp2 ,'recessions',recessionPeriods)
recessionplot('axes',sp3 ,'recessions',recessionPeriods)


