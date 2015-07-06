% Clear any loaded files/variables
clear all;

% Close any open figures
close all;

% Load Data
dat = load('dataAnalyze.txt');

%dat = load('data.txt');
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

tedFix          = dat(:,10);
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
att =  cond == 3;

% Subjects
numSub = length(unique(sub));

% Stimuli
targLeft = targetLoc ==1;
targRight = targetLoc == 2;

minimum = 10;
maximum = 1750;

% Microsaccade Use
amp = sacAmp > 0.05 & sacAmp <=1.5; 
use = sacDur>=6 & sacDur<40 & amp & sacVPeak <=100 & sacOn >= minimum & sacOn <= maximum; 


%% Microsaccade Direction 

% Horizontal Congruency: Hemifields

microLeft = sacAngle1 > 1.57 | sacAngle1 < -1.57; 
microRight = sacAngle1 <= 1.57 & sacAngle1 >= -1.57; 

congL = (microLeft & targLeft); 
congR = (microRight & targRight);
 
incgL = (microLeft & targRight);
incgR = (microRight & targLeft);

cong = congL | congR;
incg = incgL | incgR;


%% Get Microssacade Rate Data 

wbLock = minimum;
waLock = maximum;

ww = 50;
sw = 5;

%figure

%%%Valid Subjects%%%
i = 0;
counter = 0;

for i=min(sub):max(sub)   
counter = counter + 1

%Saccade Congruent
msOnsCongS = sacOn(use & sub==i & sac & cong ); 
nt = length(trial((sacNum == 0 | sacNum ==1) & sub==i & sac )); 
[rate, scale] = gausRate(msOnsCongS,wbLock,waLock,nt);
%rate = (rate-min(rate))/(max(rate)-min(rate)); %min/max normalization
rateCongS(counter,:) = rate'; %save data for each subject in a matrix

%Saccade Incongruent
msOnsIncgS = sacOn(use & sub==i & sac & incg );
nt = length(trial((sacNum == 0 | sacNum ==1) & sub==i & sac)); 
[rate, scale] = gausRate(msOnsIncgS,wbLock,waLock,nt);
%rate = (rate-min(rate))/(max(rate)-min(rate)); %min/max normalization
rateIncgS(counter,:) = rate'; %save data for each subject in a matrix

%Neutral Congruent
msOnsCongN = sacOn(use & sub==i & neu & cong ); 
nt = length(trial((sacNum == 0 | sacNum ==1) & sub==i & neu)); 
[rate, scale] = gausRate(msOnsCongN,wbLock,waLock,nt);
%rate = (rate-min(rate))/(max(rate)-min(rate)); %min/max normalization
rateCongN(counter,:) = rate'; %save data for each subject in a matrix

%Neutral Incongruent
msOnsIncgN = sacOn(use & sub==i & neu & incg );%& transfer
nt = length(trial((sacNum == 0 | sacNum ==1) & sub==i & neu));
[rate, scale] = gausRate(msOnsIncgN,wbLock,waLock,nt);
%rate = (rate-min(rate))/(max(rate)-min(rate)); %min/max normalization
rateIncgN(counter,:) = rate'; %save data for each subject in a matrix

%Attention Congruent
msOnsCongA = sacOn(use & sub==i & att & cong ); 
nt = length(trial((sacNum == 0 | sacNum ==1) & sub==i & att)); 
[rate, scale] = gausRate(msOnsCongA,wbLock,waLock,nt);
%rate = (rate-min(rate))/(max(rate)-min(rate)); %min/max normalization
rateCongA(counter,:) = rate'; %save data for each subject in a matrix

%Attention Incongruent
msOnsIncgA = sacOn(use & sub==i & att & incg );%& transfer
nt = length(trial((sacNum == 0 | sacNum ==1) & sub==i & att)); 
[rate, scale] = gausRate(msOnsIncgA,wbLock,waLock,nt);
%rate = (rate-min(rate))/(max(rate)-min(rate)); %min/max normalization
rateIncgA(counter,:) = rate'; %save data for each subject in a matrix


end


%SACCADE
rateMnCongS = mean(rateCongS); 
rateSeCongS = std(rateCongS)/sqrt(length(rateCongS(:,1))); %SE = standard deviation/sqrt(n)

rateMnIncgS = mean(rateIncgS); 
rateSeIncgS = std(rateIncgS)/sqrt(length(rateIncgS(:,1))); %SE = standard deviation/sqrt(n)

%NEUTRAL
rateMnCongN = mean(rateCongN); 
rateSeCongN = std(rateCongN)/sqrt(length(rateCongN(:,1))); %SE = standard deviation/sqrt(n)

rateMnIncgN = mean(rateIncgN); 
rateSeIncgN = std(rateIncgN)/sqrt(length(rateIncgN(:,1))); %SE = standard deviation/sqrt(n)

%ATTENTION
rateMnCongA = mean(rateCongA); 
rateSeCongA = std(rateCongA)/sqrt(length(rateCongA(:,1))); %SE = standard deviation/sqrt(n)

rateMnIncgA = mean(rateIncgA); 
rateSeIncgA = std(rateIncgA)/sqrt(length(rateIncgA(:,1))); %SE = standard deviation/sqrt(n)


figure

% SACCADE CONDITION

% Plot Rate of Congruent and Incongruent Microsaccades
subplot(3,1,1)
plot(scale, rateMnCongS, 'r', 'LineWidth', 1)
hold on
plot(scale, rateMnIncgS, 'k', 'LineWidth', 1)
hold on;
xlabel('Time (ms)');
ylabel('Microsaccade Rate (1/sec)');
legend('Congruent', 'Incongruent');
axis([minimum, maximum, 0, 2]);
boundedline(scale, rateMnCongS, rateSeCongS, 'transparency', .7, 'alpha', '-r');
hold on;
boundedline(scale, rateMnIncgS, rateSeIncgS, 'transparency', .5, 'alpha', '-k');
title('SACCADE CONDITION')
line([500,500], [0, .6], 'Color' ,[0 0 0]);
text(500, .65, 'preCue', 'Color', [0 0 0]);
line([1600, 1600], [0, .6], 'Color' ,[0 0 0]);
text(1600, .65, 'landolt', 'Color', [0 0 0]);

% ATTENTION CONDITION

% Plot Rate of Congruent and Incongruent Microsaccades
subplot(3,1,2)
plot(scale, rateMnCongA, '-g', 'LineWidth', 1)
hold on
plot(scale, rateMnIncgA, '-k', 'LineWidth', 1)
hold on;
xlabel('Time (ms)');
ylabel('Microsaccade Rate (1/sec)');
legend('Congruent', 'Incongruent');
axis([minimum, maximum, 0, 2]);
boundedline(scale, rateMnCongA, rateSeCongA, 'transparency', .7, 'alpha', '-g');
hold on;
boundedline(scale, rateMnIncgA, rateSeIncgA, 'transparency', .5, 'alpha', '-k');
title('ATTENTION CONDITION')
line([500,500], [0, .6], 'Color' ,[0 0 0]);
text(500, .65, 'preCue', 'Color', [0 0 0]);
line([1600, 1600], [0, .6], 'Color' ,[0 0 0]);
text(1600, .65, 'landolt', 'Color', [0 0 0]);

%  NEUTRAL CONDITION

% Plot Rate of Congruent and Incongruent Microsaccades
subplot(3,1,3)
plot(scale, rateMnCongN, '-b', 'LineWidth', 1)
hold on
plot(scale, rateMnIncgN, '-k', 'LineWidth', 1)
hold on;
xlabel('Time (ms)');
ylabel('Microsaccade Rate (1/sec)');
legend('Congruent', 'Incongruent');
axis([minimum, maximum, 0, 2]);
boundedline(scale, rateMnCongN, rateSeCongN, 'transparency', .7, 'alpha', '-b');
hold on;
boundedline(scale, rateMnIncgN, rateSeIncgN, 'transparency', .5, 'alpha', '-k');
title('NEUTRAL CONDITION')
line([500,500], [0, .6], 'Color' ,[0 0 0]);
text(500, .65, 'preCue', 'Color', [0 0 0]);
line([1600, 1600], [0, .6], 'Color' ,[0 0 0]);
text(1600, .65, 'landolt', 'Color', [0 0 0]);



