% Clear any loaded files/variables
clear all;

% Close any open figures
close all;

% Load Data
dat = load('data.txt');

% Subjects
% Subjects
sIni = {'TS' 'LR' 'HK' 'MA'}; 

% Label Data Columns
sub             = dat(:,1);
ses             = dat(:,2);
block           = dat(:,3);
trial           = dat(:,4);
cond            = dat(:,5);
trialType       = dat(:,6);
trialDelay      = dat(:,7);
targetLoc       = dat(:,8);
targetEcc       = dat(:,9); 
gapSize         = dat(:,10);
gapLocT         = dat(:,11);

tedfFix         = dat(:,12);
tedfpreCueON    = dat(:,13);
tedfpreISIOn    = dat(:,14);
tedfstimOn      = dat(:,15);
tedfpostISIOn   = dat(:,16); %same as tedfstimOff
tedfrespToneOn  = dat(:,17);
tedfClr         = dat(:,18);

tSac            = dat(:,19);
keyRT           = dat(:,20);
resp            = dat(:,21);
cor             = dat(:,22);
sacReq          = dat(:,23);
stairCase       = dat(:,24);

trial2          = dat(:,25);
sacNum          = dat(:,26);
sacType         = dat(:,27);

sacOn           = dat(:,28);
sacOff          = dat(:,29);
sacDur          = dat(:,30);
sacVPeak        = dat(:,31);

sacDist         = dat(:,32); %rho
sacAngle1       = dat(:,33); %theta
sacAmp          = dat(:,34);
sacAngle2       = dat(:,35);

sacxOnset       = dat(:,36);
sacyOnset       = dat(:,37);
sacxOffset      = dat(:,38);
sacyOffset      = dat(:,39);


%% Various Variables 

uniqueTrial = sacNum == 0 | sacNum == 1;  

totalTrial = sum(uniqueTrial)

% Condition
valid   = trialType == 1;
invalid = trialType == 2;

% Subjects
numSub = length(unique(sub));

% Stimuli
targLeft    = targetLoc == 1;
targRight   = targetLoc == 2;

near        = targetEcc == 2.5; 
far         = targetEcc == 5.0; 

minimum = 1;
maximum = 2000;

%minimum = 1600;
%maximum = 1800;

amp = sacAmp > 0.05 & sacAmp <=1.5; 

%delay = trialDelay==950;


% Horizontal Congruency: Hemifields

microLeft = sacAngle1 > 1.57 | sacAngle1 < -1.57; 
microRight = sacAngle1 <= 1.57 & sacAngle1 >= -1.57; 

congL = (microLeft & targLeft); 
congR = (microRight & targRight);
 
incgL = (microLeft & targRight);
incgR = (microRight & targLeft);

cong = congL | congR; 
incg = incgL | incgR;




ecc = near; 
% Microsaccade Use
use = sacDur>=6 & sacDur<40 & amp & sacVPeak <=100 & sacOn >= minimum & sacOn <= maximum;  

% Microsaccade Direction 



% Set up parameters for averaging
wbLock = -300;
waLock = 199;

%wbLock = -150;
%waLock = 100;

ww = 50; %was 50
sw = 5;


%% Near & Far // Valid, Invalid, Neutral

i = 0;
counter = 0;

figure

for i=1:numSub
    
counter = counter + 1

% Do we care if it's the first microsaccade?

% Valid:  Target Onset Relative to Microsaccade Onset (tOnRelMs)
% For trials w/ Microsaccades
tOnRelMsValid = (trialDelay(sub==i & use &  valid & ecc)+550)-dat(sub==i & use  & valid & ecc, 28); % target onset - micro onset
resCorValid = cor(use & sub==i & valid & ecc );
tOnRelMsValid = [tOnRelMsValid resCorValid];

[rate, scale, nt] = propCorr(tOnRelMsValid,wbLock,waLock,ww,sw);
allRateValid(counter,:) = rate'; %save data for each subject in a matrix
allNtValid(counter,:) = nt';

% Valid:  pCorrect for trials w/o Microsaccades
allCorValid = length(trial(sub==i & sacNum==0 & cor & valid & ecc));
allTotalValid = length(trial(sub==i & sacNum==0 & valid & ecc ));
allMeanCorValid(counter,:) = allCorValid/allTotalValid;

% Invalid:  Target Onset Relative to Microsaccade Onset (tOnRelMs)
% For trials w/ Microsaccades
tOnRelMsInvalid = (trialDelay(sub==i & use & invalid & ecc )+550)-dat(sub==i & use & invalid & ecc , 28); % target onset - micro onset
resCorInvalid = cor(use & sub==i & invalid & ecc );
tOnRelMsInvalid = [tOnRelMsInvalid resCorInvalid];

[rate, scale, nt] = propCorr(tOnRelMsInvalid,wbLock,waLock,ww,sw);
allRateInvalid(counter,:) = rate'; %save data for each subject in a matrix
allNtInvalid(counter,:) = nt';

% Invalid:  pCorrect for trials w/o Microsaccades
allCorInvalid = length(trial(sub==i & sacNum==0 & cor & invalid & ecc));
allTotalInvalid = length(trial(sub==i & sacNum==0 & invalid & ecc));
allMeanCorInvalid(counter,:) = allCorInvalid/allTotalInvalid;




end

allMeanCorValid = mean(allMeanCorValid);
allMeanCorInvalid = mean(allMeanCorInvalid);



%%
% Plot
figure

subplot(2,3,1)
plot(scale, nanmean(allRateValid), '-g');
hold on;
axis([wbLock, waLock, .25, 1]);
xlabel('Time (ms) of target onset relative to microsaccade');
ylabel('Proportion Correct');
title('ALL')
line([0,0], [0, .95], 'Color' ,[0 0 0]);
text(-20, .98, 'Microsaccade', 'Color', [0 0 0]);
line([wbLock, waLock], [allMeanCorValid,allMeanCorValid], 'Color' ,'g', 'LineWidth', 1.5);

allSe=nanstd(allRateValid)/sqrt(length(allRateValid(:,1))); 
legend('Valid')
hold on;

boundedline(scale, nanmean(allRateValid), allSe, '-g', 'transparency', .50, 'alpha');

subplot(2,3,4)
plot(scale, nanMean(allNtValid), '-g');
hold on;
axis([wbLock, waLock, 0, 40]);
xlabel('Time (ms) of target onset relative to microsaccade');
ylabel('Mean # of Trials');
%title('ALL')
line([0,0], [0, 10], 'Color' ,[0 0 0]);
text(-20, 12, 'Microsaccade', 'Color', [0 0 0]);

subplot(2,3,2)
plot(scale, nanmean(allRateInvalid), '-r');
hold on;
axis([wbLock, waLock, .25, 1]);
xlabel('Time (ms) of target onset relative to microsaccade');
ylabel('Proportion Correct');
title('ALL')
line([0,0], [0, .95], 'Color' ,[0 0 0]);
text(-20, .98, 'Microsaccade', 'Color', [0 0 0]);
line([wbLock, waLock], [allMeanCorInvalid,allMeanCorInvalid], 'Color' ,'r', 'LineWidth', 1.5);

allSe=nanstd(allRateInvalid)/sqrt(length(allRateInvalid(:,1))); 
legend('Invalid')
hold on;

boundedline(scale, nanmean(allRateInvalid), allSe, '-r', 'transparency', .50, 'alpha');

subplot(2,3,5)
plot(scale, nanMean(allNtInvalid), '-r');
hold on;
axis([wbLock, waLock, 0, 40]);
xlabel('Time (ms) of target onset relative to microsaccade');
ylabel('Mean # of Trials');
%title('ALL')
line([0,0], [0, 10], 'Color' ,[0 0 0]);
text(-20, 12, 'Microsaccade', 'Color', [0 0 0]);





%%
Fs = 180;       % Sampling frequency (90 samples in 500 ms)
T = 1/Fs;       % Sample time
L = 90;         % Length of signal
t = (0:L-1)*T;  % Time vector (could also use scale)

figure

%%VALID
subplot(3, 3, 1)
y = nanmean(allRateValid);
plot(scale, y, '-g')
axis([wbLock, waLock, 0.5, 1]);
title('Raw Signal')
xlabel('Time (msec)')
ylabel('Proportion Correct');
line([0,0], [0, .95], 'Color' ,[0 0 0]);
legend('Valid')
% detrend 
subplot(3, 3, 4)
y = detrend(y);
plot(scale, y, '-g')
axis([wbLock, waLock, -0.25, .25]);
title('Detrended Signal')
xlabel('Time (msec)')
%ylabel('Proportion Correct');
line([0,0], [-1, 1], 'Color' ,[0 0 0]);

NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

% Plot single-sided amplitude spectrum.
subplot(3, 3, 7)
plot(f(2:length(f)),2*abs(Y(2:NFFT/2+1)), '-g') 
axis([0, 50, 0, .075]);
title('Single-Sided Amplitude Spectrum')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')

%%INVALID
subplot(3, 3, 2)
y = nanmean(allRateInvalid);
plot(scale, y, '-r')
axis([wbLock, waLock, 0.5, 1]);
title('Raw Signal')
xlabel('Time (msec)')
ylabel('Proportion Correct');
line([0,0], [0, .95], 'Color' ,[0 0 0]);
legend('Invalid')
% detrend 
subplot(3, 3, 5)
y = detrend(y);
plot(scale, y, '-r')
axis([wbLock, waLock, -0.25, .25]);
title('Detrended Signal')
xlabel('Time (msec)')
%ylabel('Proportion Correct');
line([0,0], [-1, 1], 'Color' ,[0 0 0]);

NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

% Plot single-sided amplitude spectrum.
subplot(3, 3, 8)
plot(f(2:length(f)),2*abs(Y(2:NFFT/2+1)), '-r') 
axis([0, 50, 0, .075]);
title('Single-Sided Amplitude Spectrum')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')












