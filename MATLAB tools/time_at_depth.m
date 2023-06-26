%Time spent at depth
%how long the whale spends at different depths

%depth zone A is <5 m, depth zone B =5-10 m, depth zone C >10 m

%I have the pressure at different indices, I can convertt indices into
%seconds because it samples 10x per second, 

depthA_indx=find(p<5);
depthB_indx=find((5<p) & (p<10));
depthC_indx=find(p>10);

%total length of time spent at each depth
min_depthA=length(depthA_indx)/fs/60;
min_depthB=length(depthB_indx)/fs/60;
min_depthC=length(depthC_indx)/fs/60;

%percentages of time deployment spent at each depth
pct_A=(length(depthA_indx)/length(p))*100
pct_B=(length(depthB_indx)/length(p))*100
pct_C=(length(depthC_indx)/length(p))*100

%should I save this as a column in the prh file? could just write it in the
%calf tag guide to keep track for now

