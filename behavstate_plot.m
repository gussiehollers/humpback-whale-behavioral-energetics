%% Behavioral state plots

%I want to make graphs for each whale that show the depth profile
%deployment and have color coded bars or the line is colored based on
%traveling or resting

%I have the calf_states, which is a list of resting (1) or traveling (2)
%I have AllWhales_chunk which has also the same 900 chunks 
%add the state to the AllWhales
AllWhales_chunk.state=calfstates.State;
AllWhales_chunk.state3=calf3states.State;

%Now I need the time or index that all these chunks started at
%load the prh file of the first calf
[filenames2,fileloc2]=uigetfile('*.mat*', 'select the PRH file','MultiSelect','on'); 
load([fileloc2 filenames2]);

%and each chunk should be a standard number of indices!!! 10 times per
%second, 60 seconds, 5 minutes= 3000 indices is a 5 minute segment
%find all the chunks that are this whale's
i=find(strcmp(AllWhales_chunk.ID,'mn200224-56'));
calf_states1=calfstates.State(i);

% Repeat the calf_states values
expanded_states = repelem(calf_states1, 3000, 1);
% Create a new table
plot_calf1 = table(DN(1:length(expanded_states)), p(1:length(expanded_states)), speed.JJ(1:length(expanded_states)), head(1:length(expanded_states)), roll(1:length(expanded_states)), pitch(1:length(expanded_states)), expanded_states, 'VariableNames', {'Time','Depth','Speed','Heading', 'Roll', 'Pitch','State'});
plot_calf1.Time=datetime(plot_calf1.Time,'ConvertFrom','datenum','Format','HH:mm');

%% Breaths from BORIS
%I want to get the times of all the breaths from the BORIS files and add
%them to the graph

[filenames,fileloc]=uigetfile('*.csv*', 'select ALL the BORIS files','MultiSelect','on');

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

i_breath=find(strcmp(ALL_boris.Behavior,'breath'));

%% Whole dive profile plot

% Create a scatter plot with different colors for each state
figure;
subplot(3,1,1);
scatter(plot_calf1.Time, -plot_calf1.Depth, 2, plot_calf1.State, 'filled');
colormap(lines(2));  % Use different colors for each state (1 and 2)

% Scatter plot for breath markers
hold on;
breath_times = ALL_boris.timehms(i_breath);
breath_depths = -plot_calf1.Depth(ismember(plot_calf1.Time, breath_times));
scatter(breath_times, breath_depths, 50, 'k', 'x', 'DisplayName', 'Breath');
% Customize the plot
title(['Depth versus time for Whale mn210220-55']);
xlabel('Time (hours)');
ylabel('Depth (meters)');
% Add a color legend
legend('Resting', 'Breath');
grid on;

%now add another subplot that has the speed 
subplot(3,1,2);
scatter(plot_calf1.Time, plot_calf1.Speed, 2, plot_calf1.State, 'filled');
colormap(lines(2));
title('Speed vs. Time');
xlabel('Time (hours)');
ylabel('Speed (m/s)');
grid on;

%add heading
subplot(3,1,3);
scatter(plot_calf1.Time, plot_calf1.Heading, 2, plot_calf1.State, 'filled');
colormap(lines(2));
title('Heading vs. Time');
xlabel('Time (hours)');
ylabel('radians');
grid on;

%add roll
%subplot(4,1,4);
%scatter(plot_calf1.Time, plot_calf1.Roll, 2, plot_calf1.State, 'filled');
%colormap(lines(2));
%title('Roll vs. Time');
%xlabel('Time (hours)');
%ylabel('radians');
%grid on;

% Get handles to the axes
ax1 = subplot(3,1,1);
ax2 = subplot(3,1,2);
ax3 = subplot(3,1,3);
%ax4 = subplot(4,1,4);
% Link the x-axes of the two subplots
linkaxes([ax1, ax2, ax3, ax4], 'x');

% Adjust the subplots for better layout
set(gcf, 'Position', [100, 100, 800, 600]);

%% Plot the averages from each chunk

% Get unique IDs
uniqueIDs = unique(AllWhales_chunk.ID);

% Number of subplots
numWhales = numel(uniqueIDs);

for i = 1:numWhales
    % Extract data for the current whale (based on ID)
    currentWhaleData = AllWhales_chunk(AllWhales_chunk.ID == uniqueIDs(i), :);

    % Plot the data for the current whale
    figure;

    % Create subplots
    subplot(3, 1, 1);
    scatter(1:numel(currentWhaleData.avg_speed), currentWhaleData.avg_speed, 30, currentWhaleData.state3, 'filled');
    colormap(jet); % You can choose a colormap
    colorbar;
    title(['Average Speed for Whale ID ' num2str(uniqueIDs(i))]);
    xlabel('Time Period');
    ylabel('Average Speed');

    subplot(3, 1, 2);
    scatter(1:numel(currentWhaleData.mrl), currentWhaleData.mrl, 30, currentWhaleData.state3, 'filled');
    colormap(jet); % You can choose a colormap
    colorbar;
    title(['Mean Resultant Length for Whale ID ' num2str(uniqueIDs(i))]);
    xlabel('Time Period');
    ylabel('Mean Resultant Length');

   subplot(3, 1, 3);
    scatter(1:numel(currentWhaleData.max_depth), currentWhaleData.max_depth, 30, currentWhaleData.state3, 'filled');
    colormap(jet); % You can choose a colormap
    colorbar;
    title(['Max Depth for Whale ID ' num2str(uniqueIDs(i))]);
    xlabel('Time Period');
    ylabel('Max Depth');

end

%% Plot the prh data based on the behavioral state

% Create a scatter plot with different colors for each state
figure;
subplot(4,1,1);
scatter(plot_calf1.Time, -plot_calf1.Depth, 2, plot_calf1.State, 'filled');
colormap(lines(2));  % Use different colors for each state (1 and 2)

% Customize the plot
title(['Depth versus time for Whale mn210220-55']);
xlabel('Time (hours)');
ylabel('Depth (meters)');
% Add a color legend
legend('Resting', 'Movement');
grid on;

%now add another subplot that has the pitch 
subplot(4,1,2);
scatter(plot_calf1.Time, plot_calf1.Pitch, 2, plot_calf1.State, 'filled');
colormap(lines(2));
title('Pitch vs. Time');
xlabel('Time (hours)');
ylabel('Speed (m/s)');
grid on;

%add heading
subplot(4,1,3);
scatter(plot_calf1.Time, plot_calf1.Heading, 2, plot_calf1.State, 'filled');
colormap(lines(2));
title('Heading vs. Time');
xlabel('Time (hours)');
ylabel('radians');
grid on;

%add roll
subplot(4,1,4);
scatter(plot_calf1.Time, plot_calf1.Roll, 2, plot_calf1.State, 'filled');
colormap(lines(2));
title('Roll vs. Time');
xlabel('Time (hours)');
ylabel('radians');
grid on;

% Get handles to the axes
ax1 = subplot(4,1,1);
ax2 = subplot(4,1,2);
ax3 = subplot(4,1,3);
ax4 = subplot(4,1,4);
% Link the x-axes of the two subplots
linkaxes([ax1, ax2, ax3, ax4], 'x');



