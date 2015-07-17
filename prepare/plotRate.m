
% Clear any loaded files/variables
clear all;

% Close any open figures
close all;

% Load Data
dat = load('dataAnalyze.txt');


% Subjects
sIni = {'AD' 'ID' 'BL' 'RD' 'CS' 'CT'};

% Label Data Columns
sub             = dat(:,1);
ses             = dat(:,2);
block           = dat(:,3);
trial           = dat(:,4);
cond            = dat(:,5);
targetLoc       = dat(:,6);
targetEcc       = dat(:,7); 
gapSize         = dat(:,8);
gapLocT         = dat(:,9);

tedfFix         = dat(:,10);
tedfpreCueON    = dat(:,11);
tedfpreISIOn    = dat(:,12);
tedfstimOn      = dat(:,13);
tedfpostISIOn   = dat(:,14); %same as tedfstimOff
tedfrespToneOn  = dat(:,15);
tedfClr         = dat(:,16);

tSac            = dat(:,17);
keyRT           = dat(:,18);
resp            = dat(:,19);
cor             = dat(:,20);
sacReq          = dat(:,21);
stairCase       = dat(:,22);

trial2          = dat(:,23);
sacNum          = dat(:,24);
sacType         = dat(:,25);

sacOn           = dat(:,26);
sacOff          = dat(:,27);
sacDur          = dat(:,28);
sacVPeak        = dat(:,29);

sacDist         = dat(:,30); %rho
sacAngle1       = dat(:,31); %theta
sacAmp          = dat(:,32);
sacAngle2       = dat(:,33);

sacxOnset       = dat(:,34);
sacyOnset       = dat(:,35);
sacxOffset      = dat(:,36);
sacyOffset      = dat(:,37);


%% Various Variables 

% Condition
sac = cond == 1;
neu = cond == 2;
att = cond == 3;

% Subjects
numSub = length(unique(sub));

% Interval
minimum = 1;
maximum = 1750;

% Microsaccades
amp = sacAmp > 0.05 & sacAmp <=1.5; 
use = sacDur>=6 & sacDur<40 & amp & sacVPeak <=100 & sacOn >= minimum & sacOn <= maximum;  

totalMicro = length(sacOn(use));


%% Calculate Rata for Individual Observers

% Set Parameters for Rate Calculation

wbLock = minimum; % earliest time point
waLock = maximum; % latest time point

ww = 50; % window width
sw = 10; % sliding window


% Calculate Rate and Plot
i = 0;
counter = 0;
figure

for i=1:numSub
    
counter = counter + 1

% Saccade
msOns = sacOn(sac & use & sub==i); 
nt = length(trial((sacNum == 0 | sacNum ==1) & sac & sub==i)); 
[rate, scale] = gausRate(msOns,wbLock,waLock,nt);

sacRate(counter,:) = rate'; %save data for each subject in a matrix
subplot(numSub,1,counter)

plot(scale, rate, '-r', 'LineWidth', 1); 
axis([minimum, maximum, 0, 5]);

xlabel('Time (ms)');
ylabel('Rate (1/sec)');
title(i);

line([500,500], [0, 2], 'Color' ,[0 0 0]);
text(500, 3, 'preCue', 'Color', [0 0 0]);

line([1600, 1600], [0, 2], 'Color' ,[0 0 0]);
text(1600, 3, 'landolt', 'Color', [0 0 0]);

line([2300,2300], [0, 2], 'Color' ,[0 0 0]);
text(2300, 3, 'respTone', 'Color', [0 0 0]);

hold on;

% Neutral
msOns = sacOn(neu & use & sub==i); 
nt = length(trial((sacNum == 0 | sacNum ==1) & neu & sub==i  )); 
[rate, scale] = gausRate(msOns,wbLock,waLock,nt);

neuRate(counter,:) = rate'; %save data for each subject in a matrix
plot(scale, rate, '-b', 'LineWidth', 1); 

hold on;

% Attention
msOns = sacOn(att & use & sub==i); 
nt = length(trial((sacNum == 0 | sacNum ==1) & att & sub==i  )); 
[rate, scale] = gausRate(msOns,wbLock,waLock,nt);

attRate(counter,:) = rate'; %save data for each subject in a matrix
plot(scale, rate, '-g', 'LineWidth', 1); 


end


%% Plot Average Microsaccade Rates

sRate = nanmean(sacRate);
nRate = nanmean(neuRate);
aRate = nanmean(attRate);


% Saccade V Attention
figure
subplot(3,1,1)
plot(scale, sRate, '-r', 'LineWidth', 1);
hold on;
plot(scale, aRate, '-g', 'LineWidth', 1);
legend('Saccade', 'Attention');
axis([minimum, maximum, 0, 4]);
xlabel('Time (ms)');
ylabel('Microsaccade Rate (1/sec)');

hold on;
 
sSem=nanstd(sacRate)/sqrt(length(sacRate(:,1))); 
boundedline(scale, sRate, sSem, '-r', 'transparency', .3, 'alpha');

aSem=nanstd(attRate)/sqrt(length(attRate(:,1))); 
boundedline(scale, aRate, aSem, '-g', 'transparency', .3, 'alpha');
 
line([500,500], [0, 2], 'Color' ,[0 0 0]);
text(500, 2.10, 'preCue', 'Color', [0 0 0]);

line([1600, 1600], [0, 2], 'Color' ,[0 0 0]);
text(1600, 2.10, 'landolt', 'Color', [0 0 0]);

line([2300,2300], [0, 2], 'Color' ,[0 0 0]);
text(2300, 2.10, 'respTone', 'Color', [0 0 0]);

% Saccade V Neutral
subplot(3,1,2)
plot(scale, sRate, '-r', 'LineWidth', 1);
hold on;
plot(scale, nRate, '-b', 'LineWidth', 1);
legend('Saccade', 'Neutral');
axis([minimum, maximum, 0, 4]);
xlabel('Time (ms)');
ylabel('Microsaccade Rate (1/sec)');

hold on;
 
sSem=nanstd(sacRate)/sqrt(length(sacRate(:,1))); 
boundedline(scale, sRate, sSem, '-r', 'transparency', .3, 'alpha');

nSem=nanstd(neuRate)/sqrt(length(neuRate(:,1))); 
boundedline(scale, nRate, nSem, '-b', 'transparency', .3, 'alpha');

line([500,500], [0, 2], 'Color' ,[0 0 0]);
text(500, 2.10, 'preCue', 'Color', [0 0 0]);

line([1600, 1600], [0, 2], 'Color' ,[0 0 0]);
text(1600, 2.10, 'landolt', 'Color', [0 0 0]);

line([2300,2300], [0, 2], 'Color' ,[0 0 0]);
text(2300, 2.10, 'respTone', 'Color', [0 0 0]);

% Attention V Neutral
subplot(3,1,3)
plot(scale, aRate, '-g', 'LineWidth', 1);
hold on;
plot(scale, nRate, '-b', 'LineWidth', 1);
legend('Attention', 'Neutral');
axis([minimum, maximum, 0, 4]);
xlabel('Time (ms)');
ylabel('Microsaccade Rate (1/sec)');

hold on;
 
aSem=nanstd(attRate)/sqrt(length(attRate(:,1))); 
boundedline(scale, aRate, aSem, '-g', 'transparency', .3, 'alpha');

nSem=nanstd(neuRate)/sqrt(length(neuRate(:,1))); 
boundedline(scale, nRate, nSem, '-b', 'transparency', .3, 'alpha');

line([500,500], [0, 2], 'Color' ,[0 0 0]);
text(500, 2.10, 'preCue', 'Color', [0 0 0]);

line([1600, 1600], [0, 2], 'Color' ,[0 0 0]);
text(1600, 2.10, 'landolt', 'Color', [0 0 0]);

line([2311,2311], [0, 2], 'Color' ,[0 0 0]);
text(2300, 2.10, 'respTone', 'Color', [0 0 0]);








