%%SIMPLE HMM DEMO
%demo the HMM on one whale's prh file

%% Prep the table
%want the ID, and the averaged pitch, roll, heading, depth, and speed

columnNames={'ID', 'avg_pitch', 'avg_roll', 'avg_heading', 'avg_depth', 'avg_speed'};
varTypes={'string', 'double', 'double', 'double', 'double', 'double'};
demo_data=table('Size', [height(AllWhales_chunk), 6 ],'VariableNames', columnNames, 'VariableTypes', varTypes );

demo_data.ID=AllWhales_chunk.ID;
demo_data.avg_pitch=AllWhales_chunk.Avg_Pitch;
demo_data.avg_roll=AllWhales_chunk.Avg_Roll;
demo_data.avg_heading=AllWhales_chunk.Avg_Heading;
demo_data.avg_depth=AllWhales_chunk.Avg_Depth;
demo_data.avg_speed=AllWhales_chunk.Avg_Speed;

%now save the table as a csv file
filename = 'mn200219-55_chunkavg.csv';
writetable(demo_data, filename);

%% Probability distributions of variables
%DEPTH
histogram(demo_data.avg_depth, 'Normalization', 'probability')
%PITCH
histogram(demo_data.avg_pitch, 'Normalization', 'probability')
%ROLL
histogram(demo_data.avg_roll, 'Normalization', 'probability')
%heading
%PITCH
histogram(demo_data.avg_heading, 'Normalization', 'probability')

