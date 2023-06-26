%Specific acceleration demo/comparison
%compare MSA to ODBA to OSA gyro method of Martin Lopez 2016

%first clean 

%ODBA
A=Aw;
sampling_rate=fs;
fh=0.25/2; %stroking frequency for adult humpback whale, should probably figure out the stroke frequency for my calves
method='fir';
n=1;
e=ODBA(A,sampling_rate,fh,method,n);
odba_ms2=e*9.81;

%MSA
ref=1;
m=MSA(A,ref);
msa_ms2=m*9.81;

%Gyro SA
fs=10;    
fc=0.4*0.25; 
pryMag = magnet_rot(Mw,fs,fc) ;     % predict BR using magnetometer method
saMag = acc_sa(Aw,pryMag,fs,fc) ;   % predict SA using magnetometer BRs
pryGyro = gyro_rot(Gw,fs,fc) ;      % predict BR using gyroscope method
saGyro = acc_sa(Aw,pryGyro,fs,fc) ; % predict SA using gyroscope BRs

%plot them to compare
figure
subplot(311),plot(odba_ms2),grid
subplot(312),plot(msa_ms2),grid
subplot(313),plot(saGyro),grid

%so the MSA is the lowest measurement, this makes sense because it is the
%minimum. ODBA is lower than the gyro SA, but Martin Lopez paper describes
%it as being an underestimate for large whales? 

