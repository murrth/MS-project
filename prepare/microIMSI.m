% Clear any loaded files/variables
clear all;

% Close any open figures
close all;

% Load Data
dat = load('dataDR10SD07.txt');

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

% Microsaccade Use
minimum = 1;
maximum = 1750;

amp = sacAmp > 0.05 & sacAmp <=1.5; 

use = sacDur>=8 & sacDur<40 & amp & sacVPeak <=100 & sacOn >= minimum & sacOn <= maximum; 

%% Get Microsaccade Count 
totalMicro = length(sacOn(use))


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

%dat = [dat, trial(use), rep];
dat = [dat, rep];


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

%% Flag Last Microsaccade in Trial
last = zeros(1, length(dat))';

for i = 1:length(dat)-1
    
    if dat(i,39)>=dat(i+1,39)        
      last(i)=1;
      %rep(i+1)=1;
    
    end       
end

dat = [dat, last];


%% Get repetition RTs
repRT=zeros(1, length(dat))'; 
%repRT=NaN(1, length(dat))'; % NaNs - could also make zeros!

for i = 2:length(dat)-1
    
    if repNum(i) > 1 % beyond first of sequence of microsaccades
    repRT(i) = dat(i,26) - dat(i-1, 26); % get ISMI
    end  
    
end

dat = [dat, repRT]; 

%% Plot data

%repRT(finalRepNum>1)

nbins = 500

figure

%subplot(4,1,1)
hist(repRT(repRT>0), nbins);  %Martinez-Conde (2014) removes <20ms ISMI
%axis([0, 1000, 0, 100]);
[nelements, centers] = hist(repRT, nbins);
xlabel('IMSI Duration [ms]');
ylabel('Frequency');

% subplot(4,1,2)
% hist(repRT(repRT>0 & repNum==2), nbins);
% %axis([0, 1000, 0, 100]);
% [nelements, centers] = hist(repRT, nbins);
% xlabel('IMSI Duration [ms], Second');
% ylabel('Frequency');
% 
% subplot(4,1,3)
% hist(repRT(repRT>0 & repNum==3), nbins);
% %axis([0, 1000, 0, 100]);
% [nelements, centers] = hist(repRT, nbins);
% xlabel('IMSI Duration [ms], Third');
% ylabel('Frequency');
% 
% subplot(4,1,4)
% hist(repRT(repRT>0 & repNum==4), nbins);
% %axis([0, 1000, 0, 100]);
% [nelements, centers] = hist(repRT, nbins);
% xlabel('IMSI Duration [ms], Fourth');
% ylabel('Frequency');

%subplot(2,1,2)

figure
relfNelements = nelements/sum(nelements);
semilogy(centers, relfNelements, 'o')
scatter(centers, log10(relfNelements), 'o')
hold on;
lsline
xlabel('IMSI Duration [ms]');
ylabel('Relative Frequency');



%% Save DAT

save microIMSI.out dat -ASCII









