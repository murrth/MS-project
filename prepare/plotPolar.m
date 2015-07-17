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

minimum = 1;
maximum = 1750;

% Microsaccades
amp = sacAmp > 0.05 & sacAmp <=1.5; 

use = sacDur>=8 & sacDur<40 & amp & sacVPeak <=100 & sacOn >= minimum & sacOn <= maximum; 


%% Microsaccade Direction 

% Horizontal Congruency: Hemifields

microLeft = sacAngle1 > 1.57 | sacAngle1 <= -1.57; 
microRight = sacAngle1 <= 1.57 & sacAngle1 > -1.57; 

congL = (microLeft & targLeft); 
congR = (microRight & targRight);
 
incgL = (microLeft & targRight);
incgR = (microRight & targLeft);

cong = congL | congR;
incg = incgL | incgR;

% Polar Plots by Time Interval

figure
nPolar = 200;

%%%%SACCADE%%%%

% 1:1750 ms
minimum = 1
maximum = 1750
int = sacOn >= minimum & sacOn <= maximum; 

subplot(3,4,1)
polar(pi, 500);
hold on;
[nelements, centers] = hist(sacAngle1(use & int & sac), 60);
rate = nelements %/sum(nelements);
polar(centers, rate, '-r');


hold on;

% 1:500
minimum = 1
maximum = 500
int = sacOn >= minimum & sacOn <= maximum; 

subplot(3,4,2)
polar(pi, nPolar);
hold on;
[nelements, centers] = hist(sacAngle1(use & int & sac & cong), 40);
rate = nelements %/sum(nelements);
polar(centers, rate, '-r');
hold on;
[nelements, centers] = hist(sacAngle1(use & int & sac & incg), 40);
rate = nelements %/sum(nelements);
polar(centers, rate, '-k');


%500:1000
minimum = 500;
maximum = 1000;
int = sacOn >minimum & sacOn <= maximum; 

subplot(3,4,3)
polar(pi, nPolar);
hold on;
[nelements, centers] = hist(sacAngle1(use & int & sac & cong), 40);
rate = nelements %/sum(nelements);
polar(centers, rate, '-r');
hold on;
[nelements, centers] = hist(sacAngle1(use & int & sac & incg), 40);
rate = nelements %/sum(nelements);
polar(centers, rate, '-k');


%1800:1750
minimum = 1250;
maximum = 1750;
int = sacOn > minimum & sacOn <= maximum; 

subplot(3,4,4)
polar(pi, nPolar);
hold on;
[nelements, centers] = hist(sacAngle1(use & int & sac & cong), 40);
rate = nelements %/sum(nelements);
polar(centers, rate, '-r');
hold on;
[nelements, centers] = hist(sacAngle1(use & int & sac & incg), 40);
rate = nelements %/sum(nelements);
polar(centers, rate, '-k');


%%%%ATTENTION%%%%

% 1:1750 ms
minimum = 1
maximum = 1750
int = sacOn >= minimum & sacOn <= maximum; 

subplot(3,4,5)
polar(pi, 500);
hold on;
[nelements, centers] = hist(sacAngle1(use & int & att), 60);
rate = nelements %/sum(nelements);
polar(centers, rate, '-g');
%hold on;
%[nelements, centers] = hist(sacAngle1(use & int & att), 60);
%rate = nelements %/sum(nelements);
%polar(centers, rate, '-k');

hold on;

% 1:500
minimum = 1
maximum = 500
int = sacOn >= minimum & sacOn <= maximum; 

subplot(3,4,6)
polar(pi, nPolar);
hold on;
[nelements, centers] = hist(sacAngle1(use & int & att & cong), 40);
rate = nelements %/sum(nelements);
polar(centers, rate, '-g');
hold on;
[nelements, centers] = hist(sacAngle1(use & int & att & incg), 40);
rate = nelements %/sum(nelements);
polar(centers, rate, '-k');


%500:1000
minimum = 500;
maximum = 1000;
int = sacOn >minimum & sacOn <= maximum; 

subplot(3,4,7)
polar(pi, nPolar);
hold on;
[nelements, centers] = hist(sacAngle1(use & int & att & cong), 40);
rate = nelements %/sum(nelements);
polar(centers, rate, '-g');
hold on;
[nelements, centers] = hist(sacAngle1(use & int & att & incg), 40);
rate = nelements %/sum(nelements);
polar(centers, rate, '-k');


%1800:1750
minimum = 1250;
maximum = 1750;
int = sacOn > minimum & sacOn <= maximum; 

subplot(3,4,8)
polar(pi, nPolar);
hold on;
[nelements, centers] = hist(sacAngle1(use & int & att & cong), 40);
rate = nelements %/sum(nelements);
polar(centers, rate, '-g');
hold on;
[nelements, centers] = hist(sacAngle1(use & int & att & incg), 40);
rate = nelements %/sum(nelements);
polar(centers, rate, '-k');


%%%%NEUTRAL%%%%

% 1:1750 ms
minimum = 1
maximum = 1750
int = sacOn >= minimum & sacOn <= maximum; 

subplot(3,4,9)
polar(pi, 500);
hold on;
[nelements, centers] = hist(sacAngle1(use & int & neu), 60);
rate = nelements %/sum(nelements);
polar(centers, rate, '-b');
%hold on;
%[nelements, centers] = hist(sacAngle1(use & int & neu), 60);
%rate = nelements %/sum(nelements);
%polar(centers, rate, '-k');

hold on;

% 1:500
minimum = 1
maximum = 500
int = sacOn >= minimum & sacOn <= maximum; 

subplot(3,4,10)
polar(pi, nPolar);
hold on;
[nelements, centers] = hist(sacAngle1(use & int & neu & cong), 40);
rate = nelements %/sum(nelements);
polar(centers, rate, '-b');
hold on;
[nelements, centers] = hist(sacAngle1(use & int & neu & incg), 40);
rate = nelements %/sum(nelements);
polar(centers, rate, '-k');


%500:1000
minimum = 500;
maximum = 1000;
int = sacOn >minimum & sacOn <= maximum; 

subplot(3,4,11)
polar(pi, nPolar);
hold on;
[nelements, centers] = hist(sacAngle1(use & int & neu & cong), 40);
rate = nelements %/sum(nelements);
polar(centers, rate, '-b');
hold on;
[nelements, centers] = hist(sacAngle1(use & int & neu & incg), 40);
rate = nelements %/sum(nelements);
polar(centers, rate, '-k');


%1800:1750
minimum = 1250;
maximum = 1750;
int = sacOn > minimum & sacOn <= maximum; 

subplot(3,4,12)
polar(pi, nPolar);
hold on;
[nelements, centers] = hist(sacAngle1(use & int & neu & cong), 40);
rate = nelements %/sum(nelements);
polar(centers, rate, '-b');
hold on;
[nelements, centers] = hist(sacAngle1(use & int & neu & incg), 40);
rate = nelements %/sum(nelements);
polar(centers, rate, '-k');