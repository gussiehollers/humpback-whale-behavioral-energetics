%draft of a script to work with the BORIS data and corresponding
%accelerometer data
%FOR ONE VIDEO AT A TIME

%Import Boris data (have to figure out how to automatically import the csvs
%the way I want them)

%combine all the csvs from one whale into one file

%make an array of behavior times
videocsv=mn22020499video4GH; %gives a list of the behaviors %change based on your file name
bi=find(videocsv.Behavior=='nursing'); %creates a list of the indices where the behavior is the breath, could also change it to nursing 
bi2=find(videocsv.Behavior=='nursing'&videocsv.Status=='START');
bt=videocsv(bi2,'Time'); %creates a table of the times when the whale breathes
btfracdays=table2array(bt)/86400; %creates an array of the times put into fractions of a day

%then import the PRH file 
% 
% movieTimes.mat file want the movie times (I think I can overwrite the vidDN and vidDurs
%variables because I think they're the same)

%vidDN is the absolute time that each movie started 
vidDN(4) %serial date number of when this movie started (CHANGE BASED ON MOVIE)
btimeabs=btfracdays+vidDN(4); %getting the times of the behavior in serial date time form (change based on movie number)
btwindow=[btimeabs-(60/86400),btimeabs+(60/86400)]; %makes a window of 60 seconds around each behavior time
btwindowhms=datetime(btwindow,'ConvertFrom','datenum','Format','HH:mm:ss.SSS');
DNhms=datetime(DN,'ConvertFrom','datenum','Format','HH:mm:ss.SSS');

%DN is the absolute time of each index, want that v. accelerometer
%b1=find((btwindow(1,1)<DN)&(DN<btwindow(1,2))); %finds the indices of the datenum when it is within the breath time window
%plot(DN(b1),At(b1,:)) %plots the triaxal accelerometer 60 seconds before and after the breath!! yay!

%now I want to make a for loop so that it will give me a plot of every
%breath 

for i=1:length(btwindow)
    w=find((btwindow(i,1)<DN)&(DN<btwindow(i,2)));
    plot(DN(w),At(w,:))
    subplot(4,2,i); hold on; %change the dimensions of the subplot based on how many behaviors you have
end

for i=1:length(btwindowhms)
    w=find((btwindowhms(i,1)<DNhms)&(DNhms<btwindowhms(i,2)));
    plot(DNhms(w),At(w,:))
    subplot(2,2,i); hold on; %change the dimensions of the subplot based on how many behaviors you have
end





