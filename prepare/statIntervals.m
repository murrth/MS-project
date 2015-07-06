% Clear any loaded files/variables
clear all;


% Close any open figures
close all;

% Load Data
%dat = load('dataDR10SD06.txt');
dat = load('dataDR10SD07.txt');

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

plotMeans = 0

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

%minimum = 500;
%maximum = 1000;

amp = sacAmp > 0.05 & sacAmp <=1.5; 

% Microsaccade Use
use = sacDur>=6 & sacDur<40 & amp & sacVPeak <=100 & sacOn >= minimum & sacOn <= maximum; 

%% Get Microsaccade Count 
%totalMicro = length(sacOn(use))
%totalMicroNeutral = length(sacOn(use & neutral))
%totalMicroValid = length(sacOn(use & valid))

%% Get Microssacade Rate Data 

j = 0
%width = 150;
width = 100;
%interval = 0:200:1200;
%interval = [400, 1450];
interval = 400;

sacMnRateINT = zeros(6,1); %numSub, numInt
attMnRateINT = zeros(6,1);
neuMnRateINT = zeros(6,1);

for j = 1:length(interval)

    minimum = interval(j)
    maximum = interval(j)+ width-1
    
    %Microsaccade Use
    use = sacDur>=6 & sacDur<40 & amp & sacVPeak <=100 & sacOn >= minimum & sacOn <= maximum; 
    ww = 50;
    sw = 5;

    wbLock = minimum;
    waLock = maximum;

    %%Saccade Condition
    i = 0;
    counter = 0;
        for i=1:numSub
        counter = counter + 1;
        msOns = sacOn(use & sub==i & sac);
        nt = length(trial((sacNum == 0 | sacNum ==1) & sub==i & sac));
        [rate, scale] = gausRate(msOns,wbLock,waLock,nt);
        sacRate(counter,:) = rate'; %save data for each subject in a matrix
        sacMnRate(counter,:) = mean(rate); % get mean rate for interval for t-test       
        end
        
        sacMnRateINT(:,j) = sacMnRate;
    
    %%Attention Condition
    i = 0;
    counter = 0;
        for i=1:numSub
        counter = counter + 1;
        msOns = sacOn(use & sub==i & att);
        nt = length(trial((sacNum == 0 | sacNum ==1) & sub==i & att));
        [rate, scale] = gausRate(msOns,wbLock,waLock,nt);
        attRate(counter,:) = rate'; %save data for each subject in a matrix
        attMnRate(counter,:) = mean(rate); % get mean rate for interval for t-test       
        end
        
        attMnRateINT(:,j) = attMnRate;
        
    %%Neutral Condition
    i = 0;
    counter = 0;
        for i=1:numSub
        counter = counter + 1;
        msOns = sacOn(use & sub==i & neu);
        nt = length(trial((sacNum == 0 | sacNum ==1) & sub==i & neu));
        [rate, scale] = gausRate(msOns,wbLock,waLock,nt);
        neuRate(counter,:) = rate'; %save data for each subject in a matrix
        neuMnRate(counter,:) = mean(rate); % get mean rate for interval for t-test       
        end
        
        neuMnRateINT(:,j) = neuMnRate;    
        
end

%% Get STATS on INTERVALS

% ANOVA
all= [sacMnRateINT, attMnRateINT, neuMnRateINT]
anova_rm(all)

% ttests
for i = 1:length(interval)

%tests
[h, p, ci, stats] = ttest(sacMnRateINT(:,i), attMnRateINT(:,i), .05, 'left') %alpha, tail
[h, p, ci, stats] = ttest(sacMnRateINT(:,i), neuMnRateINT(:,i), .05, 'left') %alpha, tail
[h, p, ci, stats] = ttest(neuMnRateINT(:,i), attMnRateINT(:,i)) %alpha, tail

%[h,p,ci,stats] = ttest(vMnRateINT(:,i), nMnRateINT(:,i)) %2 sample ttest
%[p,h,stats] = ranksum(sacMnRateINT, attMnRateINT, .05, 'left') % wilcoxon

end


%% Plot Means and SEs of Intervals

if plotMeans
    
figure
plot(interval, mean(sacMnRateINT(:,:)), 'r-o', interval, mean(attMnRateINT(:,:)), 'g-o', interval, mean(neuMnRateINT(:,:)), 'b-o' )

sacSEM=std(sacMnRateINT(:,:))/sqrt(length(sacMnRateINT(:,1)));
attSEM=std(attMnRateINT(:,:))/sqrt(length(attMnRateINT(:,1)));
neuSEM=std(neuMnRateINT(:,:))/sqrt(length(neuMnRateINT(:,1)));

errorbar(mean(sacMnRateINT(:,:)), sacSEM, 'r-o')
hold on;
errorbar(mean(attMnRateINT(:,:)), attSEM, 'g-o')
hold on;
errorbar(mean(neuMnRateINT(:,:)), neuSEM, 'b-o')

legend('Saccade', 'Attention', 'Neutral');
xlabel('Time (ms)');
ylabel('Mean Microsaccade Rate (1/sec)');

end






