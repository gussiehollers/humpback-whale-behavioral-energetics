%% Identify nursing cues
% Augmented from David Cade & James Fahlbusch (SimpleNursingDetection.m)
% version 1.0.0
% Marine Mammal Research Program
% University of Hawaii at Manoa

%% 1. Create All_boris File with nursing times 
% Plots the accelerometer signal from all the nursing events in a
% deployment 

clear; % clears the workspace

%load the whale's prh and BORIS files
[filenames2,fileloc2]=uigetfile('*.csv*', 'select ALL the BORIS files','MultiSelect','on');

[filename,fileloc]=uigetfile('*.mat*', 'select the PRH file','MultiSelect','on'); 
load([fileloc filename]);

%creates a table with all the behavioral events from the deployment 
ALL_boris=table();
for a=1:length(filenames2)
   
    BORISfile = readtable([fileloc2 filenames2{a}]);

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

i_nurse=find(strcmp(ALL_boris.Behavior,'nursing'));
length(i_nurse) %use this to create the dimensions of the subplot
nursing_events=ALL_boris(i_nurse,:); %all the nursing events

%% 2. Setup Data For Vizualization
%Start where you left off?
atLast = true; %this will look for a variable called progressIndex
M = 6; % number of minutes
% Variables that will be saved in the Nursing file
notes = '';
creator = 'SS';
primary_cue = 'roll';


cf = pwd; 
%[filename,fileloc]=uigetfile('*.*', 'the PRH file to analyze'); 
%cd(fileloc);
%disp('Loading Data, will take some time'); 
%load([fileloc filename(1:end-3) 'mat']); 
whaleName = INFO.whaleName;
    ii = strfind(filename,' ');
    clear NurseI NurseDN NurseC NurseDepth % clears lunge data in case a previous file was still loaded
    lungename = [filename(1:ii-1) '_nurses.mat'];
    load([fileloc filename]);
    try load([fileloc lungename]); catch; end
    try
        speedFN = speed.FN;
        speedFN(isnan(speedFN)) = min(speedFN); speedFN = runmean(speedFN,round(fs/2)); speedFN(isnan(speed.FN)) = nan;
    catch; speedFN = nan(size(p));
    end
    if ~exist('head', 'var')
        head = nan(size(p));
    end
    speedJJ = speed.JJ;
    speedJJ(isnan(speedJJ)) = min(speedJJ); speedJJ = runmean(speedJJ,round(fs/2)); speedJJ(isnan(speed.JJ)) = nan;
    J = njerk(Aw,fs); J(end+1) = J(end);
    if exist('NurseDN','var')
        N = NurseDN;
        NI = NurseI;
        if exist('NurseC', 'var')
            NC = NurseC;
        else
            NC = nan(length(NI));
        end
    elseif exist('time','var');
        N = time;
        for ii = 1:length(N)
            [~,NI(ii)] = min(abs(DN-N(ii)));
        end
        if size(NI,2)>1;
            NI = NI';
        end
                if exist('NurseC', 'var')
            NC = NurseC;
        else
            NC = nan(length(NI));
        end

    else
        N = nan(0,0);
        NI = nan(0,0);
        NC = nan(0,0);
    end
    disp(['TagTurnedOn: ' datestr(DN(1),'mm/dd/yy HH:MM:SS.fff')]);
    disp(['TagOnAnimal: ' datestr(DN(find(tagon,1)),'mm/dd/yy HH:MM:SS.fff')]);
    disp(['EndData: ' datestr(DN(end),'mm/dd/yy HH:MM:SS.fff')]);
    disp(['TagOffAnimal: ' datestr(DN(find(tagon,1,'last')),'mm/dd/yy HH:MM:SS.fff')]);

disp('Section 1 finished: Data Loaded');
    
%% 3. Plot and Process
    % Check to see if we should start at beginning or at a saved index (i)
    M = 6; 
    if strcmp(primary_cue,'speedFN'); speedJJ = speedFN; end
%     speedJJ = ones(size(p)); speedFN = speedJJ;
    if ~exist('progressIndex','var') || ~atLast
        i = find(tagon,1);
    else
        i = progressIndex;
    end
    %
    for iii = 1
    instructions = sprintf('Controls:\nLeftClick: High Confidence\nL: Likely a Nursing\nM: Maybe a Nursing\nControlClick: Delete Point\n1-9: Change Zoom(x10)\nB: Move Back\nEnter: Move Forward\nS: Save');
    while i<find(tagon,1,'last')
        figure(101); clf
        annotation('textbox', [0, 0.5, 0, 0], 'string', instructions,'FitBoxToText','on')
        e = min(find(p(i+M*60*fs:end)<10,1,'first')+i+(M+1)*60*fs-1,length(p));
        if isempty(e)||isnan(e); e = length(p); end
        I = max(i-60*fs,1):e;
        tagonI = false(size(p)); tagonI(I) = true;
        tagonI = tagon&tagonI;
        s1 = subplot(3,1,1);
        [ax1,~,h2] = plotyy(DN(I),p(I),DN(I),J(I));
        set(ax1(1),'ydir','rev','nextplot','add','ylim',[-5 max(p(tagonI))]);
        ylabel('Jerk','parent',ax1(2));
        ylabel('Depth','parent',ax1(1));
        set(ax1(2),'ycolor','m','ylim',[0 1.2*max(J(tagonI))]);
        set(h2,'color','m');
        set(ax1,'xlim',[DN(I(1)) DN(I(end))]);
        set(ax1,'xticklabel',datestr(get(gca,'xtick'),'mm/dd HH:MM:SS'));
        title(getWhaleID(filename));
        %xline(DN(nursing_events.timeIndex(:)));
        s2 = subplot(3,1,2);
        uistack(ax1(1));
        set(ax1(1), 'Color', 'none');
        set(ax1(2), 'Color', 'w')
        [ax2,h1,h2] = plotyy(DN(I),pitch(I)*180/pi,DN(I),roll(I)*180/pi); set(ax2(2),'nextplot','add','ycolor','k','ylim',[-180 180]);
        ylabel('Roll and Head','parent',ax2(2));
        %plot(ax2(2),DN(I),head(I)*180/pi,'b.','markersize',4);
        set(ax2(1),'ycolor','g','nextplot','add','ylim',[-90 90]);
        ylabel('pitch','parent',ax2(1));
        set(h1,'color','g'); set(h2,'color','r','linestyle','-','markersize',4);
        set(ax2,'xlim',[DN(I(1)) DN(I(end))]);
        set(ax2,'xticklabel',datestr(get(gca,'xtick'),'HH:MM:SS'));
        %xline(DN(nursing_events.timeIndex(:)));
        s3 = subplot(3,1,3);
        ax3 = plot(DN(I),speedJJ(I),'b',DN(I),speedFN(I),'g');
        set(s3,'nextplot','add');
        %xline(DN(nursing_events.timeIndex(:)));
        marks = nan(1,3);
        if ~isempty(N)
            %change color based on confidence
            colors = 'rbk';
            for c=1:3
                II = find(NC==c);
                if ~isempty(II)
                    marks(1) = plot(ax1(1),N(II),p(NI(II)),[colors(c) 's'],'markerfacecolor',colors(c));
                    marks(2) = plot(ax2(1),N(II),roll(NI(II))*180/pi,[colors(c) 's'],'markerfacecolor',colors(c));
                    marks(3) = plot(s3,N(II),speedJJ(NI(II)),[colors(c) 's'],'markerfacecolor',colors(c));
                end
            end 
        end
        set(s3,'xlim',[DN(I(1)) DN(I(end))]);
        set(s3,'ylim',[0 1.1*max(speedJJ(tagonI))],'xlim',[DN(I(1)) DN(I(end))]);
        set(s3,'xticklabel',datestr(get(gca,'xtick'),'HH:MM:SS'));
        ylabel('Speed');
        
        button = 1;
        redraw = false;
        close2lunge = 15;
        if strcmp(whaleName(1:2),'bb'); close2lunge = 5; end
        
        while ~isempty(button)
            redraw = false;
            if ishandle(ax2)
                [x,~,button] = ginput(1);
                if isempty(button); continue; end
                switch button
                    case 1
                        [~,xI] = min(abs(DN-x));
                        [~,mI] = max(speedJJ(max(xI-5*fs,1):xI+5*fs)); %find the max within 5 seconds
                        mI = xI;
%                         mI = mI+xI-5*fs-1;
%                         if any(abs(NI-xI)<close2lunge*fs); %if it's close, change one that exists
%                             [~,delI] = min(abs(N-x));
%                             N(delI) = []; NI(delI) = []; NC(delI) = [];
%                             NC = [NC;3];
%                             [N,II] = sort([N; x]);   
%                             NI = sort([NI;xI]);
%                             NC = NC(II);
%                         else
                             NC = [NC; 3];
                             [N,II] = sort([N;DN(mI)]); NI = sort([NI;mI]); NC = NC(II);
%                         end
                    case 108 %l selected - likely lunge
                        [~,xI] = min(abs(DN-x));
                        [~,mI] = max(speedJJ(xI-5*fs:xI+5*fs)); %find the max within 5 seconds
                        mI = xI;
%                         mI = mI+xI-5*fs-1;
%                         if any(abs(NI-xI)<close2lunge*fs); %if it's close, change one that exists
%                             [~,delI] = min(abs(N-x));
%                             N(delI) = []; NI(delI) = []; NC(delI) = [];
%                             NC = [NC;2];
%                             [N,II] = sort([N; x]);   
%                             NI = sort([NI;xI]);
%                             NC = NC(II);
%                         else
                             NC = [NC; 2];
                             [N,II] = sort([N;DN(mI)]); NI = sort([NI;mI]); NC = NC(II);
%                         end
                    case 109 %m selected - maybe lunge
                        [~,xI] = min(abs(DN-x));
                        [~,mI] = max(speedJJ(xI-5*fs:xI+5*fs)); %find the max within 5 seconds
                        mI = xI;
%                         mI = mI+xI-5*fs-1;
%                         if any(abs(NI-xI)<close2lunge*fs); %if it's close, change one that exists
%                             [~,delI] = min(abs(N-x));
%                             N(delI) = []; NI(delI) = []; NC(delI) = [];
%                             NC = [NC;1];
%                             [N,II] = sort([N; x]);   
%                             NI = sort([NI;xI]);
%                             NC = NC(II);
%                         else
                             NC = [NC;1];
                             [N,II] = sort([N;DN(mI)]); NI = sort([NI;mI]); NC = NC(II);
%                         end
                    case 3 % delete an x
                        [~,delI] = min(abs(N-x));
                        N(delI) = []; NI(delI) = []; NC(delI) = [];
                          redraw = true; button = [];           

                    case 98 %if b, go backwards
                        i = max(find(tagon,1),i-M*60*fs);
                        redraw = true; button = [];
                    case num2cell(49:57) %if you press a number, change drawing to 10*that number
                        M = 10*(button-48);
                        redraw = true; button = [];
                    case 115 %s selected - save progress
                        % set the created on date vector
                        d1 = datevec(now());
                        created_on = [d1(2) d1(3) d1(1)];
                        clearvars d1;
                        % store temp variables to lunge file 
                        starttime = DN(1);
                        prh_fs = fs;
                        NurseDN = N;
                        depth = p(NI);
                        time = N;
                        NurseI = NI;
                        NurseC = NC;
                        NurseDepth = depth;
                        progressIndex = i;
                        save([fileloc getWhaleID(filename) '_lunges.mat'],'NurseDN','NurseI','NurseDepth','NurseC','creator','primary_cue','prh_fs','starttime','created_on', 'progressIndex', 'notes');
                end
                if ~isempty(N)
                    try delete(marks); catch; end
                    %change color base on confidence
                    colors = 'rbk';
                    for c=1:3
                        II = find(NC==c);
                        if ~isempty(II)
                            marks(1) = plot(ax1(1),N(II),p(NI(II)),[colors(c) 's'],'markerfacecolor',colors(c));
                            marks(2) = plot(ax2(1),N(II),roll(NI(II))*180/pi,[colors(c) 's'],'markerfacecolor',colors(c));
                            marks(3) = plot(s3,N(II),speedJJ(NI(II)),[colors(c) 's'],'markerfacecolor',colors(c));
                        end
                    end 
                end
            end
        end
        if redraw
            continue;
        else
            i = e;
        end
    end
    % set the created on date vector
    d1 = datevec(now());
    created_on = [d1(2) d1(3) d1(1)];
    clearvars d1;
    % store temp variables to lunge file 
    starttime = DN(1);
    prh_fs = fs;
    NurseDN = N;
    depth = p(NI);
    time = N;
    NurseI = NI;
    NurseC = NC;
    NurseDepth = depth;
    progressIndex = i;
    save([fileloc getWhaleID(filename) '_nursing.mat'],'NurseDN','NurseI','NurseDepth','NurseC','creator','primary_cue','prh_fs','starttime','created_on', 'progressIndex', 'notes');
    try aa = strfind(fileloc,'CATS\tag_data\');
        save([fileloc(1:aa+13) 'prhnursing\' getWhaleID(filename) '_nursing.mat'],'NurseDN','NurseI','NurseDepth','NurseC','creator','primary_cue','prh_fs','starttime','created_on', 'progressIndex', 'notes');
        disp('File saved in fileloc and prhnursingfolder');
    catch; disp('File saved, but prhnursing folder not found');
    end
    end