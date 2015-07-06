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

tedfFix          = dat(:,12);
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

% Condition
valid   = trialType == 1;
invalid = trialType == 2;


% Subjects
numSub = length(unique(sub));

% Stimuli
targLeft    = targetLoc ==1;
targRight   = targetLoc == 2;

cueLeft    = (targetLoc == 1 & valid) | (targetLoc==2 & invalid)
cueRight   = (targetLoc == 2 & valid) | (targetLoc==1 & invalid)

delay = trialDelay==950;

minimum = 500;
maximum = 2000;

near        = targetEcc == 2.5; 
far         = targetEcc == 5.0; 

ecc = near
amp = sacAmp > 0.05 & sacAmp <=1.5; 

% Microsaccade Use
use = sacDur>=6 & sacDur<40 & amp & sacVPeak <=100 & sacOn >= minimum & sacOn <= maximum & delay & ecc; % & delay & cor==0 & far;  

% Response
%response = tRes-tFix;     
%respMN = mean(response( (sacNum == 0 | sacNum ==1) & use));

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

%%%%%% rateCongV(:,1300:1400)
% can get the mean rate and se acros subjects for the interval


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

%VALID Congruent
msOnsCongV = sacOn(use & sub==i & valid & cong & delay & ecc); 
nt = length(trial((sacNum == 0 | sacNum ==1) & sub==i & valid & delay & ecc)); 
[rate, scale] = gausRate(msOnsCongV,wbLock,waLock,nt);
%rate = (rate-min(rate))/(max(rate)-min(rate)); %min/max normalization
rateCongV(counter,:) = rate'; %save data for each subject in a matrix

%VALID Incongruent
msOnsIncgV = sacOn(use & sub==i & valid & incg & delay & ecc);
nt = length(trial((sacNum == 0 | sacNum ==1) & sub==i & valid & delay & ecc)); 
[rate, scale] = gausRate(msOnsIncgV,wbLock,waLock,nt);
%rate = (rate-min(rate))/(max(rate)-min(rate)); %min/max normalization
rateIncgV(counter,:) = rate'; %save data for each subject in a matrix

%Invalid Congruent
msOnsCongI = sacOn(use & sub==i & invalid & cong & delay & ecc); 
nt = length(trial((sacNum == 0 | sacNum ==1) & sub==i & invalid & delay & ecc)); 
[rate, scale] = gausRate(msOnsCongI,wbLock,waLock,nt);
%rate = (rate-min(rate))/(max(rate)-min(rate)); %min/max normalization
rateCongI(counter,:) = rate'; %save data for each subject in a matrix

%Invalid Incongruent
msOnsIncgI = sacOn(use & sub==i & invalid & incg & delay & ecc);%& transfer
nt = length(trial((sacNum == 0 | sacNum ==1) & sub==i & invalid & delay & ecc));
[rate, scale] = gausRate(msOnsIncgI,wbLock,waLock,nt);
%rate = (rate-min(rate))/(max(rate)-min(rate)); %min/max normalization
rateIncgI(counter,:) = rate'; %save data for each subject in a matrix


end

%Valid
rateMnCongV = mean(rateCongV); 
rateSeCongV = std(rateCongV)/sqrt(length(rateCongV(:,1))); %SE = standard deviation/sqrt(n)

rateMnIncgV = mean(rateIncgV); 
rateSeIncgV = std(rateIncgV)/sqrt(length(rateIncgV(:,1))); %SE = standard deviation/sqrt(n)

%Invalid
rateMnCongI = mean(rateCongI); 
rateSeCongI = std(rateCongI)/sqrt(length(rateCongI(:,1))); %SE = standard deviation/sqrt(n)

rateMnIncgI = mean(rateIncgI); 
rateSeIncgI = std(rateIncgI)/sqrt(length(rateIncgI(:,1))); %SE = standard deviation/sqrt(n)




figure

% VALID CONDITION

% Plot Rate of Congruent and Incongruent Microsaccades
subplot(3,2,1)
plot(scale, rateMnCongV, 'g', 'LineWidth', 1)
hold on
plot(scale, rateMnIncgV, 'k', 'LineWidth', 1)
hold on;
xlabel('Time (ms)');
ylabel('Microsaccade Rate (1/sec)');
legend('Congruent', 'Incongruent');
axis([minimum, maximum, 0, 2]);
boundedline(scale, rateMnCongV, rateSeCongV, 'transparency', .7, 'alpha', '-g');
hold on;
boundedline(scale, rateMnIncgV, rateSeIncgV, 'transparency', .5, 'alpha', '-k');
title('VALID')
line([550,550], [0, .6], 'Color' ,[0 0 0]);
text(550, .65, 'preCue', 'Color', [0 0 0]);
%line([1600, 1600], [0, .6], 'Color' ,[0 0 0]);
%text(1600, .65, 'landolt', 'Color', [0 0 0]);

line([620, 620], [0, 1], 'Color' ,[0 0 0]);
line([725, 725], [0, 1], 'Color' ,[0 0 0]);
line([950, 950], [0, 1], 'Color' ,[0 0 0]);
line([1200, 1200], [0, 1], 'Color' ,[0 0 0]);
line([1500, 1500], [0, 1], 'Color' ,[0 0 0]);

% Plot Difference
subplot(3,2,2)
diffMnV = rateMnCongV - rateMnIncgV;
diffSeV = sqrt( var(rateCongV)/(length(rateCongV(:,1))) + var(rateIncgV)/(length(rateIncgV(:,1))) ); %SED = sqrt[(sd^2/n)+(sd^2/n)]     
plot(scale, diffMnV, '-black', 'LineWidth', 1); 
axis([minimum, maximum, -0.5, 1.5]);
boundedline(scale, diffMnV, diffSeV, 'transparency', .6, 'alpha', '-k');
xlabel('Time (ms)');
ylabel('Congruent - Incongruent');
title('VALID')
legend('Difference');
line([minimum,maximum], [0,0], 'Color', [0 0 0]);
line([550,550], [0, .6], 'Color' ,[0 0 0]);
text(550, .65, 'preCue', 'Color', [0 0 0]);
%line([1600, 1600], [0, .6], 'Color' ,[0 0 0]);
%text(1600, .65, 'landolt', 'Color', [0 0 0]);

line([620, 620], [-1, 1], 'Color' ,[0 1 0]);
line([725, 725], [-1, 1], 'Color' ,[0 1 0]);
line([950, 950], [-1, 1], 'Color' ,[0 1 0]);
line([1200, 1200], [-1, 1], 'Color' ,[0 1 0]);
line([1500, 1500], [-1, 1], 'Color' ,[0 1 0]);

% INVALID CONDITION

% Plot Rate of Congruent and Incongruent Microsaccades
subplot(3,2,3)
plot(scale, rateMnCongI, 'r', 'LineWidth', 1)
hold on
plot(scale, rateMnIncgI, 'k', 'LineWidth', 1)
hold on;
xlabel('Time (ms)');
ylabel('Microsaccade Rate (1/sec)');
legend('Congruent', 'Incongruent');
axis([minimum, maximum, 0, 2]);
boundedline(scale, rateMnCongI, rateSeCongI, 'transparency', .7, 'alpha', '-r');
hold on;
boundedline(scale, rateMnIncgI, rateSeIncgI, 'transparency', .5, 'alpha', '-k');
title('INVALID')
line([550,550], [0, .6], 'Color' ,[0 0 0]);
text(550, .65, 'preCue', 'Color', [0 0 0]);
%line([1600, 1600], [0, .6], 'Color' ,[0 0 0]);
%text(1600, .65, 'landolt', 'Color', [0 0 0]);


% Plot Difference
subplot(3,2,4)
diffMnI = rateMnCongI - rateMnIncgI;
diffSeI = sqrt( var(rateCongI)/(length(rateCongI(:,1))) + var(rateIncgI)/(length(rateIncgI(:,1))) ); %SED = sqrt[(sd^2/n)+(sd^2/n)]     
plot(scale, diffMnI, '-black', 'LineWidth', 1); 
axis([minimum, maximum, -0.5, 1.5]);
boundedline(scale, diffMnI, diffSeI, 'transparency', .6, 'alpha', '-k');
xlabel('Time (ms)');
ylabel('Congruent - Incongruent');
title('INVALID')
legend('Difference');
line([minimum,maximum], [0,0], 'Color', [0 0 0]);
line([550,550], [0, .6], 'Color' ,[0 0 0]);
text(550, .65, 'preCue', 'Color', [0 0 0]);
%line([1600, 1600], [0, .6], 'Color' ,[0 0 0]);
%text(1600, .65, 'landolt', 'Color', [0 0 0]);

line([620, 620], [-1, 1], 'Color' ,[1 0 0]);
line([725, 725], [-1, 1], 'Color' ,[1 0 0]);
line([950, 950], [-1, 1], 'Color' ,[1 0 0]);
line([1200, 1200], [-1, 1], 'Color' ,[1 0 0]);
line([1500, 1500], [-1, 1], 'Color' ,[1 0 0]);

