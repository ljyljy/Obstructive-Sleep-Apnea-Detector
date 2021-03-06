close all;
clear all;
[hdr, record] = edfread('a1.edf');
%le=input('Enter No. of samples ');
%tb=input('Enter sampling time');
le=120000; % no. of samples.
tb=0.01;
%le=3000;
Fs=100;
tb=0.01;
time=tb:tb:le/Fs;
%main=cell2mat(raw(1:le,1));
figure(1);
plot(time,record);
xlabel('Time in seconds');
ylabel('Magnitude in volts.');
xlim([0 le/Fs]);
title('ECG signal')
grid;
max=[];              % Empty matrices
pos=[];
distance=[];    % Empty matrices
c=1;
%Thresh=1.07;
Thresh=input('Enter threshold point (check Graph)'); % Input the threshold value from the ecg signal
max(c)=record(c);
pos(c)=time(c);
for i=1:le-1  %% Adaptive thresholding technique
if record(i)>=Thresh
if max(c)< record(i)
max(c)=record(i);
pos(c)=time(i);
end
if (record(i+1)<=Thresh);
c=c+1;
max(c)=-1000;
pos(c)=-1000;
end
end
end
%d=le+1;
max(c)=0;
pos(c)=0;
c=c-1;
for i=1:c-1
distance(i)=pos(i+1)-pos(i);
end
avg = mean(distance);
SD = std(distance);
%var = var(distance);
%med = median(distance);

RR_Interval=distance;  % Stores the RR intervals
x=RR_Interval;

t0=1200/length(RR_Interval):1200/length(RR_Interval):1200;
figure();
plot(t0,RR_Interval);
title('RR Interval');
ylabel('RR intervak in sec');
xlabel('time in sec');
N = length(RR_Interval);
fs=N/1200;

%RR_interval=QRS_array_i;    

RR_mean = mean(RR_Interval);
normalizedRR =(RR_Interval-RR_mean)./RR_mean;  % Normalized RR Intervals
%nfft = 2^(nextpow2(length(normalizedRR)));

Pxx = abs(fft(normalizedRR)).^2/(fs*N);
%psd=dspdata.psd(Pxx(1:length(Pxx)/2),'Fs',1/RR_mean)
%figure
%plot(psd)
PSD=Pxx(1:length(Pxx));
%PSD=Pxx(1:32);



xdft = fft(RR_Interval);
xdft = xdft(1:N/2+1);
%xdft = xdft(1:N/2+1);
%N= length(xdft);
freq = 0:fs/N:fs/2;
%freq = fs/(2*N):fs/(2*N):fs/2;
psdx = (1/(fs*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);  % Calculating the PSD 
%freq = fs/(2*N):fs/(2*N):fs/2;

figure();
plot(freq,psdx);
title('Power Spectral Density Using FFT')
xlabel('Frequency (Hz)')
xlim([0 fs/2]);
ylabel('Power/Frequency (sec2/Hz)') 
ylim([0 0.75])
%ylim([0 1]);

figure();
plot(freq,10*log10(psdx));      % PSD in decibels
title('Periodogram Using FFT')
xlabel('Frequency (Hz)');
xlim([0 fs/2]);
ylabel('Power/Frequency (dB/Hz)')
% [lfhf] =  calc_lfhf(Fx,Px);
% Calculates a the LF/HF-ratio for a given (linear) PSD Px over 
% a given linear frequency range Fx
% Also:
% [lfhf lf hf] =  calc_lfhf(Fx,Px);

format long e

% check if defaults are changed
if nargin < 2
  error('frequency and power required: [lfhf lf hf] =  calc_lfhf(Fx,Px)')
end

%%%%%%%%%% set general defaults 
LF_lo = 0.04;
LF_hi = 0.15;
HF_lo = 0.15; 
HF_hi = 0.4;
LF = 0.095;
HF = 0.275;

%%%Integration (Area under the curve for LF power and HF power)

% bin size of the PSD so that we can calculate the LF and HF metrics
binsize=fs/N;          %%frequency interval

% find the indexes corresponding to the LF and HF regions
indl = find( (freq>=LF_lo) & (freq<=LF_hi) );
indh = find( (freq>=HF_lo) & (freq<=HF_hi) );

% calculate metrics area under the curves
lf   = binsize*abs(sum(psdx(indl)));
hf   = binsize*abs(sum(psdx(indh)));
lfhf_Ratio =lf/hf; % the LF/HF ratio

figure();
periodogram(x,rectwin(length(x)),length(x),fs);


%{
PSD = find_PSD(RR_Interval,fs);
freq = 0:fs/length(PSD):fs/2;
[lfhf_Ratio, lf, hf] =  calc_lfhf(freq,PSD);


[fn,pn]=uiputfile('*.xls','Give a Name');
fileID = fopen([pn,fn],'w');
fprintf(fileID,'%5f\t\n ',distance);
fclose(fileID);
%}


