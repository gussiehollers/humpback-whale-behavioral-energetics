%% BEHAVIORAL STATE DEMO
% experimenting with dividing up deployment into behavioral states 

[filenames,fileloc]=uigetfile('*.csv*', 'select ALL the BORIS files','MultiSelect','on');

[filenames2,fileloc2]=uigetfile('*.mat*', 'select the PRH file','MultiSelect','on'); 
load([fileloc2 filenames2]);

%break the deployment up into 1 minute segments
samplesPerChunk=600; % 600 indices is one minute
totalChunks = floor(numel(DN) / samplesPerChunk);


%% Heading changes
% calculate the change in the value of the heading for each segment. 
chunkedHeading = reshape(head(1:samplesPerChunk * totalChunks), samplesPerChunk, totalChunks);

%counting the number of 360 degree turns the whale makes each minute
% Access individual chunks
numTurns=zeros(602,2);
for chunkIndex = 1:totalChunks
    chunk = chunkedHeading(:, chunkIndex);
   % Threshold for considering a full revolution
   threshold = 2*pi;  

    % Convert direction data to the range -2*pi to 2*pi
    directionDataWrapped = wrapTo2Pi(chunk);

    totalChange = 0;
    numRevolutions = 0;

  for i = 2:length(directionDataWrapped)
    change = directionDataWrapped(i) - directionDataWrapped(i-1);
    totalChange = totalChange + change;
    
    if totalChange >= threshold
        numRevolutions = numRevolutions + 1;
        totalChange = totalChange - threshold;
    elseif totalChange <= -threshold
        numRevolutions = numRevolutions - 1;
        totalChange = totalChange + threshold;
    end

end

numTurns(chunkIndex,1)=totalChange;
numTurns(chunkIndex,2)=numRevolutions;

end

%ok idk if that really worked