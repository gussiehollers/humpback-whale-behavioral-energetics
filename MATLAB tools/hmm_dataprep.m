function [avg_time, avg_speed, mean_resultant_length, min_specific_accel, max_depth] = hmm_dataprep(data, segment_length)
    % data: a struct with fields for speed, heading, accelerometer, and depth data
    % segment_length: duration of each segment in seconds

    % Extract data from the input struct
    time_data=data.time;
    speed_data = data.speed;
    heading_data = data.heading;
    accelerometer_data = data(:,2:4);
    depth_data = data.depth;

    % Calculate the number of segments
    num_segments = floor(length(speed_data) / (segment_length * 10)); % Assuming data is sampled at 10 Hz

    % Initialize variables to store results
    avg_time=zeros(num_segments, 1);
    avg_speed = zeros(num_segments, 1);
    mean_resultant_length = zeros(num_segments, 1);
    min_specific_accel = zeros(num_segments, 1);
    max_depth = zeros(num_segments, 1);

    % Loop through segments
    for i = 1:num_segments
        % Define the start and end indices for the current segment
        start_idx = (i - 1) * segment_length * 10 + 1;
        end_idx = i * segment_length * 10;

        % Extract data for the current segment
        segment_time=time_data(start_idx:end_idx);
        segment_speed = speed_data(start_idx:end_idx);
        segment_heading = heading_data(start_idx:end_idx);
        segment_accelerometer = accelerometer_data(start_idx:end_idx, :);
        segment_depth = depth_data(start_idx:end_idx);

        % Calculate average time for the segment
        avg_time(i) = mean(segment_time);

        % Calculate average speed for the segment
        avg_speed(i) = mean(segment_speed);

        % Calculate the mean resultant length of heading for the segment
        %complex_heading = exp(1i * segment_heading);
        %mean_complex = mean(complex_heading);
        %mean_resultant_length(i) = abs(mean_complex);
        r=circ_r(segment_heading); %this does the same thing but is already a function!
        mean_resultant_length(i) = r;

        % Calculate the minimum specific acceleration
        ref=1;
        msa=MSA(segment_accelerometer,ref);
        min_specific_accel(i)=mean(msa.sum*9.81);

        % Calculate the maximum depth for the segment
        max_depth(i) = max(segment_depth);
    end
end
