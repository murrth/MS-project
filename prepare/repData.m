% Clear any loaded files/variables
clear all;

% Close any open figures
close all;

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

microTarg       = dat(:,34)-590;

%% Various Variables 

% Condition
valid = sub < 9;
neutral = sub >=9;

% Stimuli
targLeft = targLoc ==1;
targRight = targLoc == 2;

diagLeft = diag ==1; 
diagRight = diag == 2;

% Intervals 
minimum = 1;
maximum = 2000;

% Amplitude
amp = sacAmp > 0.05 & sacAmp <=1.5; 

% Session
session = ses>1 & ses <5

% Microsaccade Use
use = sacDur>=6 & sacDur<40 & amp & sacVPeak <=100 & sacOn > minimum & sacOn <= maximum & session; 

%% Select Usable Data
dat = dat(use,:);

%% Flag Microsaccade Repetitions (1)
rep=zeros(1, length(dat))';

for i = 1:length(dat)-1
    
    if dat(i,4)==dat(i+1,4)        
      rep(i)=1;
      rep(i+1)=1;
    
    end       
end

dat = [dat, trial(use), rep];
%dat = [dat, rep];

%% Select String of Repetitions Only
%  dat = dat(rep > 0,:);

%% Label Repetition Number
repNum = ones(1, length(dat))';

for i = 1:length(dat)-1
    
    if (dat(i,4)==dat(i+1,4))    
        
      repNum(i+1) = repNum(i)+1;
    end   
        
end

dat = [dat, repNum];

%% Get repetition RTs
repRT=sacOn(use); %zeros(1, length(dat))'; f
%repRT=NaN(1, length(dat))'; % NaNs - could also make zeros!

for i = 2:length(dat)-1
    
    if repNum(i) > 1 % beyond first of sequence of microsaccades
    repRT(i) = dat(i,34) - dat(i-1, 34); % get ISMI
    end  
    
end

dat = [dat, repRT]; 

%% Label New Columns

repTrial        = dat(:,46);
repFlag         = dat(:,47); % 1 = included in a sequence of microsaccades
repNum          = dat(:,48);
repRT           = dat(:,49); % for rep == 1; RT is not, by definition, a repeat 











