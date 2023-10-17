% Hidden Markov Model data prep

%load the prh file of the whale you want
[filenames2,fileloc2]=uigetfile('*.mat*', 'select the PRH file','MultiSelect','on'); 
load([fileloc2 filenames2]);

%create an empty table that is the correct dimensions (9 columns and
%length(pitch) number of rows
columnNames={'ID', 'rel_length', 'hour', 'timeDN', 'pitch', 'roll', 'heading', 'depth', 'speed'};
varTypes={'string', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double'};
HMMtable=table('Size', [length(pitch), 9], 'VariableNames', columnNames, 'VariableTypes', varTypes);

%1st column the whale's name
whaleID=string(INFO.whaleName);
strCellArray = repmat({whaleID}, length(pitch), 1);

HMMtable(:, 'ID') = strCellArray;

%2nd column the relative length of the calf, or the absolute
%length of the mother
[filenames3,fileloc3]=uigetfile('*.csv*', 'select the animal size file','MultiSelect','on');
WhaleSizes=readtable([fileloc3 filenames3]);
i=find(strcmp(WhaleSizes.CATS_Tag_No,INFO.whaleName)==1);
pct_length=WhaleSizes.Rel_length(i);
pct_length_rep=repmat(pct_length, length(pitch), 1);
pct_length_rep=table(pct_length_rep);

HMMtable(:, 'rel_length') = pct_length_rep;

%3rd column is the hour of the day, this might be tricky
timeHMS=datetime(DN,'ConvertFrom','datenum','Format','HH:mm:ss.SSS');
timestr=string(timeHMS);

numRows = length(timestr);
All_hr=table(zeros(numRows, 1), 'VariableNames', {'HourColumn'});
for a = 1:numRows
    All_hr.HourColumn(a) = str2double(timestr{a}(1:2));
end

HMMtable(:, 'hour') = All_hr;

%4th column is DN
tableDN=table(DN);
HMMtable(:, 'timeDN') = tableDN;

%5th is pitch
tablepitch=table(pitch);
HMMtable(:, 'pitch') = tablepitch;

%6th is roll
tableroll=table(roll);
HMMtable(:, 'roll') = tableroll;

%7th is heading
tablehead=table(head);
HMMtable(:, 'heading') = tablehead;

%8th is depth
tabledepth=table(p);
HMMtable(:, 'depth') = tabledepth;

%9th is speed
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

HMMtable(:, 'speed') = tableSpeed;

%% CHUNK and Average the data

%take out the rows with NaN values
nonNaNi=~isnan(HMMtable.pitch);
HMMtable_filt=HMMtable(nonNaNi, :);

% Sample data and constants
sampleRate = 10;  % Sampling rate in Hz
chunkSize = 20;   % Chunk size in seconds

% Create a time vector
timeVector = (0:(height(HMMtable_filt)-1)) / sampleRate;

% Determine the number of chunks
numChunks = floor(max(timeVector) / chunkSize);

% Initialize arrays to store chunk averages
chunkAverages = zeros(numChunks, 5);  % 5 columns for pitch, roll, heading, depth, speed

% Iterate over chunks and calculate averages
for chunkIdx = 1:numChunks
    startTime = (chunkIdx - 1) * chunkSize;
    endTime = chunkIdx * chunkSize;
    
    % Find rows within the current chunk
    rowsInChunk = timeVector >= startTime & timeVector < endTime;
    
    % Calculate the average for each column
    chunkAverages(chunkIdx, :) = mean(HMMtable_filt{rowsInChunk, {'pitch', 'roll', 'heading', 'depth', 'speed'}});
end

% Create a new table with chunk averages
chunkAverageTable = array2table(chunkAverages, 'VariableNames', {'Avg_Pitch', 'Avg_Roll', 'Avg_Heading', 'Avg_Depth', 'Avg_Speed'});
HMMtable_20s=chunkAverageTable;
HMMtable_20s(:, 'ID') = HMMtable_filt(1,1);

%% 




%first time do it like this
%AllWhales_HMMtable= HMMtable;
%then do it like this
AllWhales_HMMtable=vertcat(AllWhales_HMMtable, HMMtable);

save('AllWhales_HMMtable.mat','HMMtable','-mat')
save('filtered_HMMtable.mat','HMMtable_filt','-mat')

%% Save to csv

%now save the table as a csv file
filename = 'mn200219-98_HMM.csv';
writetable(HMMtable, filename);


%% Probability distribution testing
% trying to get the probability distributions and parameters for my
% variables

rows_without_nan = find(~isnan(AllWhales_HMMtable.pitch));
HMMnoNaN=AllWhales_HMMtable(rows_without_nan, :);

pd = fitdist(HMMnoNaN.pitch, 'Normal');
x_values = linspace(min(HMMnoNaN.pitch), max(HMMnoNaN.pitch), 100);
y_values = pdf(pd, x_values);

%DEPTH
histogram(HMMnoNaN.depth, 'Normalization', 'probability')
%PITCH
histogram(HMMnoNaN.pitch, 'Normalization', 'probability')
%ROLL
histogram(HMMnoNaN.roll, 'Normalization', 'probability')
%heading
%PITCH
histogram(HMMnoNaN.heading, 'Normalization', 'probability')




xlabel('Depth')
ylabel('Probability')
title('Histogram with Fitted Normal Distribution')
legend('Data', 'Fitted Normal')

%I know it's not really the normal distribution, so I will try some other
%ones. 

% Fit various distributions
distributions = {'tLocationScale', 'Normal', 'generalizedExtremeValue', 'logistic'};
best_dist_name = '';
best_dist_params = [];
best_dist_aic = Inf;

pitch_data=HMMnoNaN.pitch;

for i = 1:length(distributions)
    dist_name = distributions{i};
    
    % Fit the distribution
    pd = fitdist(pitch_data, dist_name);
    
    % Calculate the log-pdf and sum it to get the log likelihood
    loglik_value = sum(log(pdf(pd, pitch_data)));
    
    % Calculate the AIC (Akaike Information Criterion)
    aic = 2 * numel(pd.ParameterValues) - 2 * loglik_value;
    
    % Update the best distribution if the AIC is smaller
    if aic < best_dist_aic
        best_dist_aic = aic;
        best_dist_name = dist_name;
        best_dist_params = pd.ParameterValues;
    end
end

disp(['Best distribution: ' best_dist_name]);
disp(['Best distribution parameters: ' num2str(best_dist_params)]);
%so it looks like the logistic distribution is the best 

% Fit the logistic distribution to your data
pd_logistic = fitdist(pitch_data, 'Logistic');

% Perform Kolmogorov-Smirnov (KS) test
[h_ks, p_ks, ks_stat] = kstest(pitch_data, 'CDF', pd_logistic);

% Perform Anderson-Darling (AD) test
[h_ad, p_ad, ad_stat] = adtest(pitch_data, 'Distribution', pd_logistic);

% Display results
disp('Kolmogorov-Smirnov Test:');
disp(['Hypothesis H0 (data follows the logistic distribution) rejected: ' num2str(h_ks)]);
disp(['p-value: ' num2str(p_ks)]);
disp(['KS statistic: ' num2str(ks_stat)]);
disp('');

disp('Anderson-Darling Test:');
disp(['Hypothesis H0 (data follows the logistic distribution) rejected: ' num2str(h_ad)]);
disp(['p-value: ' num2str(p_ad)]);
disp(['AD statistic: ' num2str(ad_stat)]);







