####process_whale_data function turns the prh data into averaged chunks

library(data.table)

prh_file<-"mn200219-55 10Hzprh.mat"

process_whale_data <- function(prh_file, size_file, sample_rate, chunk_size) {
  
  # Load the PRH file
  load(prh_file)
  
  # Prepare data for averaging
  data_list <- list(
    timeDN = DN,
    pitch = pitch,
    roll = roll,
    heading = head,
    depth = p,
    speed = ifelse(speed$JJr2 > speed$FNr2, speed$JJ, speed$FN)
  )
  
  # Create a data table
  table2chunk <- as.data.table(data_list)
  
  # Replace negative depth values with 0
  table2chunk[depth < 0, depth := 0]
  
  # Remove rows with NaN values
  table_filt <- table2chunk[!is.na(pitch) & !is.na(heading) & !is.na(roll)]
  
  # Average over specified time chunks
  time_vector <- (0:(nrow(table_filt) - 1)) / sample_rate
  num_chunks <- floor(max(time_vector) / chunk_size)
  
  # Initialize a data table to store chunk averages
  chunk_averages <- data.table(
    Avg_time = numeric(num_chunks),
    Avg_Pitch = numeric(num_chunks),
    Avg_Roll = numeric(num_chunks),
    Avg_Heading = numeric(num_chunks),
    Avg_Depth = numeric(num_chunks),
    Avg_Speed = numeric(num_chunks)
  )
  
  # Iterate over chunks and calculate averages
  for (chunk_idx in 1:num_chunks) {
    start_time <- (chunk_idx - 1) * chunk_size
    end_time <- chunk_idx * chunk_size
    
    # Find rows within the current chunk
    rows_in_chunk <- time_vector >= start_time & time_vector < end_time
    
    # Calculate the average for each column
    chunk_averages[chunk_idx, c(
      'Avg_time', 'Avg_Pitch', 'Avg_Roll', 'Avg_Heading', 'Avg_Depth', 'Avg_Speed'
    ) := lapply(table_filt[rows_in_chunk, .(mean(timeDN), mean(pitch), mean(roll), mean(heading), mean(depth), mean(speed))], as.numeric)]
  }
  
  # Add ID, relative length, and hour of the day
  whale_id <- as.character(INFO$whaleName)
  chunk_averages[, ID := whale_id]
  
  # Load animal size data
  whale_sizes <- fread(size_file)
  
  # Get relative length
  i <- which(whale_sizes$CATS_Tag_No == INFO$whaleName)
  pct_length <- whale_sizes$Rel_length[i]
  chunk_averages[, rel_length := pct_length]
  
  # Get hour of the day
  chunk_averages[, hour := as.numeric(substr(Avg_time, 1, 2))]
  
  return(chunk_averages)
}

# Usage example:
# result <- process_whale_data("your_prh_file.mat", "your_size_file.csv", sample_rate = 10, chunk_size = 20)
# write.csv(result, "output.csv", row.names = FALSE)




