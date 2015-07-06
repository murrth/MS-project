% Clear any loaded files/variables
clear all;

% Close any open figures
close all;

% Load Data
dat = load('data.txt');
%dat = load('dataDR10SD07.txt');
%dat = load('dataDR08SD06.txt');
%dat = load('data.txt');

% Subjects
sIni = {'TS' 'LR' 'HK'}; 


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
valid = trialType == 1;
invalid = trialType == 2;

% Subjects
numSub = length(unique(sub));

% Stimuli
targLeft = targetLoc ==1;
targRight = targetLoc == 2;

minimum = 1;
maximum = 2000;

amp = sacAmp > 0.05 & sacAmp <=1.5; 

delay = trialDelay>=70;

% Microsaccade Use
use = sacDur>=6 & sacDur<40 & amp & sacVPeak <=100 & sacOn >= minimum & sacOn <= maximum & delay; % & delay % & sub>1;  

% Response
%response = tRes-tFix;     
%respMN = mean(response( (sacNum == 0 | sacNum ==1) & use));

% Get Microsaccade Count 
totalMicro = length(sacOn(use));
totalMicroValid = length(sacOn(use & valid))
totalMicroInValid = length(sacOn(use & invalid))


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

%% Get Microsaccade Count 
totalMicro = length(sacOn(use))

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

% Polar Plots
figure
nPolar = 100;
cond = {'Valid', 'Neutral'};

%%% Valid %%%

% 1:2000
minimum = 1
maximum = 2000
int = sacOn >= minimum & sacOn <= maximum; 
subplot(3,4,1)
polar(pi, 100);

[nelements, centers] = hist(sacAngle1(use & int & valid & cong), 40);
rate = nelements %/sum(nelements);
h1 = polar(centers, rate);
set(h1,'color','g','linewidth',1.5)
hold on;
[nelements, centers] = hist(sacAngle1(use & int & valid & incg), 40);
rate = nelements %/sum(nelements);
h2 = polar(centers, rate);
set(h2,'color','k','linewidth',1)
text(0, -nPolar-250,['Interval= ',int2str(0), ' : ', int2str(maximum)], 'FontSize',14);

% 1:500
minimum = 1
maximum = 500
int = sacOn >= minimum & sacOn <= maximum; 
subplot(3,4,2)
polar(pi, nPolar);

[nelements, centers] = hist(sacAngle1(use & int & valid & cong), 40);
rate = nelements %/sum(nelements);
h1 = polar(centers, rate);
set(h1,'color','g','linewidth',1.5)
hold on;
[nelements, centers] = hist(sacAngle1(use & int & valid & incg), 40);
rate = nelements %/sum(nelements);
h2 = polar(centers, rate);
set(h2,'color','k','linewidth',1)
text(0, -nPolar-75,['Interval= ',int2str(minimum), ' : ', int2str(maximum)], 'FontSize',14);

% 500:1250
minimum = 500
maximum = 1250
int = sacOn >= minimum & sacOn <= maximum; 
subplot(3,4,3)
polar(pi, nPolar);

[nelements, centers] = hist(sacAngle1(use & int & valid & cong), 40);
rate = nelements %/sum(nelements);
h1 = polar(centers, rate);
set(h1,'color','g','linewidth',1.5)
hold on;
[nelements, centers] = hist(sacAngle1(use & int & valid & incg), 40);
rate = nelements %/sum(nelements);
h2 = polar(centers, rate);
set(h2,'color','k','linewidth',1)
text(0, -nPolar-75,['Interval= ',int2str(minimum), ' : ', int2str(maximum)], 'FontSize',14);

% 1250:2000
minimum = 1250
maximum = 2000
int = sacOn >= minimum & sacOn <= maximum; 
subplot(3,4,4)
polar(pi, nPolar);

[nelements, centers] = hist(sacAngle1(use & int & valid & cong), 40);
rate = nelements %/sum(nelements);
h1 = polar(centers, rate);
set(h1,'color','g','linewidth',1.5)
hold on;
[nelements, centers] = hist(sacAngle1(use & int & valid & incg), 40);
rate = nelements %/sum(nelements);
h2 = polar(centers, rate);
set(h2,'color','k','linewidth',1)
text(0, -nPolar-75,['Interval= ',int2str(minimum), ' : ', int2str(maximum)], 'FontSize',14);

nPolar = 100;

%%% Invalid %%%


% 1:2000
minimum = 1
maximum = 2000
int = sacOn >= minimum & sacOn <= maximum; 
subplot(3,4,5)
polar(pi, 200);

[nelements, centers] = hist(sacAngle1(use & int & invalid & cong), 40);
rate = nelements %/sum(nelements);
h1 = polar(centers, rate);
set(h1,'color','r','linewidth',1.5)
hold on;
[nelements, centers] = hist(sacAngle1(use & int & invalid & incg), 40);
rate = nelements %/sum(nelements);
h2 = polar(centers, rate);
set(h2,'color','k','linewidth',1)
text(0, -nPolar-250,['Interval= ',int2str(0), ' : ', int2str(maximum)], 'FontSize',14);

% 1:500
minimum = 1
maximum = 500
int = sacOn >= minimum & sacOn <= maximum; 
subplot(3,4,6)
polar(pi, nPolar);

[nelements, centers] = hist(sacAngle1(use & int & invalid & cong), 40);
rate = nelements %/sum(nelements);
h1 = polar(centers, rate);
set(h1,'color','r','linewidth',1.5)
hold on;
[nelements, centers] = hist(sacAngle1(use & int & invalid & incg), 40);
rate = nelements %/sum(nelements);
h2 = polar(centers, rate);
set(h2,'color','k','linewidth',1)
text(0, -nPolar-75,['Interval= ',int2str(minimum), ' : ', int2str(maximum)], 'FontSize',14);

% 500:1250
minimum = 500
maximum = 1250
int = sacOn >= minimum & sacOn <= maximum; 
subplot(3,4,7)
polar(pi, nPolar);

[nelements, centers] = hist(sacAngle1(use & int & invalid & cong), 40);
rate = nelements %/sum(nelements);
h1 = polar(centers, rate);
set(h1,'color','r','linewidth',1.5)
hold on;
[nelements, centers] = hist(sacAngle1(use & int & invalid & incg), 40);
rate = nelements %/sum(nelements);
h2 = polar(centers, rate);
set(h2,'color','k','linewidth',1)
text(0, -nPolar-75,['Interval= ',int2str(minimum), ' : ', int2str(maximum)], 'FontSize',14);

% 1250:2000
minimum = 1250
maximum = 2000
int = sacOn >= minimum & sacOn <= maximum; 
subplot(3,4,8)
polar(pi, nPolar);

[nelements, centers] = hist(sacAngle1(use & int & invalid & cong), 40);
rate = nelements %/sum(nelements);
h1 = polar(centers, rate);
set(h1,'color','r','linewidth',1.5)
hold on;
[nelements, centers] = hist(sacAngle1(use & int & invalid & incg), 40);
rate = nelements %/sum(nelements);
h2 = polar(centers, rate);
set(h2,'color','k','linewidth',1)
text(0, -nPolar-75,['Interval= ',int2str(minimum), ' : ', int2str(maximum)], 'FontSize',14);

