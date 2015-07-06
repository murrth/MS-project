% Let's look at individual subject

% Clear any loaded files/variables
%clear all;

% Close any open figures
%close all;

% Load Data
dat = load('dataSD6.txt');

% Subjects
sIni = {'JC', 'KLM', 'KP', 'RG', 'ASA', 'CLC', 'YC', 'ZK2', 'AD', 'BA', 'DK', 'YH', 'CC', 'RP', 'TLR', 'ZK'};


sub             = dat(:,1);
ses             = dat(:,2);
block           = dat(:,3);
trial           = dat(:,4);
diag            = dat(:,5);
targLoc         = dat(:,6);
gapSizeLev      = dat(:,7);
gapSize         = dat(:,8);
gapLocT         = dat(:,9);
gapLocD         = dat(:,10);
resp            = dat(:,11);
cor             = dat(:,12);
keyRT           = dat(:,13);
tFix            = dat(:,14);
tpreCueOn       = dat(:,15);
tpreISIOn       = dat(:,16);

tStimON         = dat(:,17);
tStimOff        = dat(:,18);
tpostCueOn      = dat(:,19);
trespToneOn     = dat(:,20);

tRes            = dat(:,21);
tClr            = dat(:,22);
tedFix          = dat(:,23);
tedfpreCueON    = dat(:,24);
tedfpreISIOn    = dat(:,25);
tedfstimOn      = dat(:,26);
tedfpostISIOn   = dat(:,27);
tedfpostCueOn   = dat(:,28);
tedfpostcueOff  = dat(:,29);
tedfClr         = dat(:,30);

trial2          = dat(:,31);
sacNum          = dat(:,32);
sacType         = dat(:,33);

sacOn           = dat(:,34);
sacOff          = dat(:,35);
sacDur          = dat(:,36);
sacVPeak        = dat(:,37);

sacDist         = dat(:,38); %rho
sacAngle1       = dat(:,39); %theta
sacAmp          = dat(:,40);
sacAngle2       = dat(:,41);

sacxOnset       = dat(:,42);
sacyOnset       = dat(:,43);
sacxOffset      = dat(:,44);
sacyOffset      = dat(:,45);

microTarg        = dat(:,34)-590;

%% Various Variables 

% Condition
valid = sub < 9;
neutral = sub >=9;

% Stimuli
targLeft = targLoc ==1;
targRight = targLoc == 2;

diagLeft = diag ==1; 
diagRight = diag == 2;

trainDiag1 = (sub>0 & sub<=4) | (sub>=9 & sub<=12);
trainDiag2 = (sub>=5 & sub<=8) | (sub>=13 & sub<=16);
trnsfer = trainDiag1 & diag==2 | trainDiag2 & diag==1;


% Intervals 
%minimum = 490;
%maximum = 640;

minimum = 1;
maximum = 2000;


%nPolar = 500

% Session = ses ==5;
%session = ses > 1 & ses <5;
session = ses == 5;  

amp = sacAmp > 0.05 & sacAmp <=1.5; 
%amp = sacAmp > 0.05 & sacAmp <=.5; % short
%amp = sacAmp > .5 & sacAmp <=1; % medium
%amp = sacAmp > 1 & sacAmp <=1.5; % long


% Microsaccade Use
use = sacDur>=6 & sacDur<40 & amp & sacVPeak <=100 & sacOn >= minimum & sacOn <= maximum & session; 

% Response
response = tRes-tFix;     
respMN = mean(response( (sacNum == 0 | sacNum ==1) & use));

% Get Microsaccade Count 
totalMicro = length(sacOn(use))
totalMicroNeutral = length(sacOn(use & neutral))
totalMicroValid = length(sacOn(use & valid))


%PERFORMANCE FIELDS VALDI
% correct
i = 0;
counter = 0;
subVALID = 1:8;

figure

for i=min(subVALID):max(subVALID)   

counter = counter + 1

targ1 = diag == 2 & targLoc == 2 & (sacNum==0 | sacNum==1) & sub==i;
targ2 = diag == 1 & targLoc == 2 & (sacNum==0 | sacNum==1) & sub==i;
targ3 = diag == 2 & targLoc == 1 & (sacNum==0 | sacNum==1) & sub==i;
targ4 = diag == 1 & targLoc == 1 & (sacNum==0 | sacNum==1) & sub==i;

corTarg1 = sum(targ1 & cor & sub==i)/sum(targ1)
corTarg2 = sum(targ2 & cor & sub==i)/sum(targ2)
corTarg3 = sum(targ3 & cor & sub==i)/sum(targ3)
corTarg4 = sum(targ4 & cor & sub==i)/sum(targ4)

RHO = [corTarg1, corTarg2, corTarg3, corTarg4];  %corTarg1]
THETA = [.79, 5.50, 3.93, 2.36]; 

rhoV(counter,:) = RHO; %save data for each subject in a matrix
%thetaV(counter,:) = THETA

subplot(length(subVALID), 1, counter)
h = polar(THETA, rhoV(counter,:), 'o')
set( findobj(h, 'Type', 'line'), 'LineWidth',.5, 'MarkerEdgeColor','k', ...
'MarkerFaceColor',[0 1 0], 'MarkerSize',8);


end


%PERFORMANCE FIELDS NEUTRAL
% correct
i = 0;
counter = 0;
subNEUTRAL = 9:16;

figure

for i=min(subNEUTRAL):max(subNEUTRAL)   

counter = counter + 1

targ1 = diag == 2 & targLoc == 2 & (sacNum==0 | sacNum==1) & sub==i;
targ2 = diag == 1 & targLoc == 2 & (sacNum==0 | sacNum==1) & sub==i;
targ3 = diag == 2 & targLoc == 1 & (sacNum==0 | sacNum==1) & sub==i;
targ4 = diag == 1 & targLoc == 1 & (sacNum==0 | sacNum==1) & sub==i;

corTarg1 = sum(targ1 & cor  & sub==i)/sum(targ1)
corTarg2 = sum(targ2 & cor & sub==i)/sum(targ2)
corTarg3 = sum(targ3 & cor & sub==i)/sum(targ3)
corTarg4 = sum(targ4 & cor & sub==i)/sum(targ4)

RHO = [corTarg1, corTarg2, corTarg3, corTarg4];  %corTarg1]
THETA = [.79, 5.50, 3.93, 2.36]; %transformed from degrees to radians

rhoN(counter,:) = RHO; %save data for each subject in a matrix
%thetaV(counter,:) = THETA

subplot(length(subNEUTRAL), 1, counter)
h = polar(THETA, rhoN(counter,:), 'o')
set( findobj(h, 'Type', 'line'), 'LineWidth',.5, 'MarkerEdgeColor','k', ...
'MarkerFaceColor',[1 0 0], 'MarkerSize',8);


end

%Mean Valid

figure

polar(pi, 1)

hold on
RHOV= mean(rhoV)
RHON = mean(rhoN)

h = polar(THETA, RHOV, 'o')
set( findobj(h, 'Type', 'line'), 'LineWidth',.5, 'MarkerEdgeColor','k', ...
'MarkerFaceColor',[0 1 0], 'MarkerSize',8);

hold on

h = polar(THETA, RHON, 'o')
set( findobj(h, 'Type', 'line'), 'LineWidth',.5, 'MarkerEdgeColor','k', ...
'MarkerFaceColor',[1 0 0], 'MarkerSize',8);


% Microsaccade Direction 


%Hemifields
microLeft = sacAngle1 > 1.57 | sacAngle1 < -1.57; 
microRight = sacAngle1 <= 1.57 & sacAngle1 >= -1.57; 
congL = (microLeft & targLeft); 
congR = (microRight & targRight);

%Quadrants
microUR = sacAngle1 <= 1.57 & sacAngle1 > 0; %1
microLR = sacAngle1 <=0 & sacAngle1 > -1.57; %2
microLL = sacAngle1 <=-1.57 & sacAngle1 >= -3.14; %3
microUL = sacAngle1 <= 3.14 & sacAngle1 > 1.57; %4

%Target Location
targUR = targRight & diagRight;
targLR = targRight & diagLeft;
targLL = targLeft & diagRight;
targUL = targLeft & diagLeft;
 
%Congruent Microsaccades
congUR = microUR & targUR;
congLR = microLR & targLR;
congLL = microLL & targLL;
congUL = microUL & targUL;

%Incongruent (Opposite) Microsaccades
OPcongUR = microLL & targUR;
OPcongLR = microUL & targLR;
OPcongLL = microUR & targLL;
OPcongUL = microLR & targUL;
incg = OPcongUR | OPcongLR | OPcongLL | OPcongUL;

cong = congUR | congLR | congLL | congUL;

congU = congUL | congUR;

congL = congLL | congLR;

numCongU = length(sacAngle1(use & congU))
numCongL = length(sacAngle1(use & congL))
numCong = length(sacAngle1(use & (congU | congL) ) )





nPolar = 25

subplot(4,2,1)
polar(pi, nPolar);
hold on;
h=rose(sacAngle1(use & valid & congUL),20);  % & diagLeft & microLeft & targLeft & 
title('Valid: Upper Left');
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'g');
hold on;
h=rose(sacAngle1(use & valid & OPcongUL),20);  % & diagLeft & microLeft & targLeft & 
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'w');

subplot(4,2,2)
polar(pi, nPolar);
hold on;
h=rose(sacAngle1(use & valid & congUR),20);  % & diagLeft & microLeft & targLeft & 
title('Valid: Upper Right');
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'g');
hold on;
h=rose(sacAngle1(use & valid & OPcongUR),20);  % & diagLeft & microLeft & targLeft & 
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'w');

subplot(4,2,3)
polar(pi, nPolar);
hold on;
h=rose(sacAngle1(use & valid & congLL),20);  % & diagLeft & microLeft & targLeft & 
title('Valid: Lower Left');
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'g');
hold on;
h=rose(sacAngle1(use & valid & OPcongLL),20);  % & diagLeft & microLeft & targLeft & 
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'w');

subplot(4,2,4)
polar(pi, nPolar);
hold on;
h=rose(sacAngle1(use & valid & congLR),20);  % & diagLeft & microLeft & targLeft & 
title('Valid: Lower Right');
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'g');
hold on;
h=rose(sacAngle1(use & valid & OPcongLR),20);  % & diagLeft & microLeft & targLeft & 
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'w');

subplot(4,2,5)
polar(pi, nPolar);
hold on;
h=rose(sacAngle1(use & neutral & congUL),20);  % & diagLeft & microLeft & targLeft & 
title('Neutral: Upper Left');
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'r');
hold on;
h=rose(sacAngle1(use & neutral & OPcongUL),20);  % & diagLeft & microLeft & targLeft & 
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'w');

subplot(4,2,6)
polar(pi, nPolar);
hold on;
h=rose(sacAngle1(use & neutral & congUR),20);  % & diagLeft & microLeft & targLeft & 
title('Neutral: Upper Right');
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'r');
hold on;
h=rose(sacAngle1(use & neutral & OPcongUR),20);  % & diagLeft & microLeft & targLeft & 
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'w');

subplot(4,2,7)
polar(pi, nPolar);
hold on;
h=rose(sacAngle1(use & neutral & congLL),20);  % & diagLeft & microLeft & targLeft & 
title('Neutral: Lower Left');
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'r');
hold on;
h=rose(sacAngle1(use & neutral & OPcongLL),20);  % & diagLeft & microLeft & targLeft & 
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'w');

subplot(4,2,8)
polar(pi, nPolar);
hold on;
h=rose(sacAngle1(use & neutral & congLR),20);  % & diagLeft & microLeft & targLeft & 
title('Neutral: Lower Right');
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'r');
hold on;
h=rose(sacAngle1(use & neutral & OPcongLR),20);  % & diagLeft & microLeft & targLeft & 
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'w');


%
%Moving Average of Amplitude Data
% On = sacOn(use);
% Amp = sacAmp(use);
% data = [On, Amp];
% [Y,I]=sort(data(:,1));
% dataSort= data(I,:);
% ampMVA = moving_average(dataSort(:,2), 200);
% %ampMVAS = smooth_maverage(ampMVA, 100)
% figure;
% scatter(On, Amp);
% hold on;
% plot(dataSort(:,1), ampMVA, '-red', 'LineWidth', 2);
% %hold on;
% %plot(dataSort(:,1), ampMVAS, '-black', 'LineWidth', 2);
%

% Get Microssacade Rate Data 

