% Clear any loaded files/variables
clear all;

% Close any open figures
close all;

% Load Data
dat = load('microIMSI.out');

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

microBool       = dat(:,38);
microNum        = dat(:,39);
microLast       = dat(:,40);
microIMSI       = dat(:,41);

%% Various Variables 

% Condition
sac = cond == 1;
neu = cond == 2;
att =  cond == 3;

% Subjects
numSub = length(unique(sub));

% Microsaccade Use
minimum = 1;
maximum = 1750;

amp = sacAmp > 0.05 & sacAmp <=1.5; 

use = sacDur>=8 & sacDur<40 & amp & sacVPeak <=100 & sacOn >= minimum & sacOn <= maximum; 

%% Get Microsaccade Count 
totalMicro = length(sacOn(use))



%% Last Micro RT and SacRT
early = mean(tSac(sacOn<=250 & microLast & sac))
middle = mean(tSac(sacOn>750 & sacOn<=1000 & microLast & sac))
late = mean(tSac(sacOn>1500 & sacOn<=1750 & microLast & sac))

%% Calculate for individual subjects

i = 0;
counter = 0;

for i=1:numSub    
    counter = counter + 1;
    
    early = mean(tSac(sacOn<=250 & microLast & sac & sub==i))
    microInt(counter,1)=early;
    
    middle = mean(tSac(sacOn>750 & sacOn<=1000 & microLast & sac & sub==i))
    microInt(counter,2)=middle;
    
    late = mean(tSac(sacOn>1500 & sacOn<=1750 & microLast & sac & sub==i))
    microInt(counter,3)=late;
    

    
end

microIntMean = mean(microInt)
microIntSem = std(microInt)/sqrt(length(microInt)) % standard error of the mean
anova_rm(microInt)

    
figure
barwitherr(microIntSem, microIntMean)
xlabel('Time Interval w/ Last Microsaccade');
ylabel('Saccade RT (mean)');











