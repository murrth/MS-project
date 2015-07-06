
% Clear any loaded files/variables
clear all;

% Close any open figures
close all;

% Load Data
dat = load('data.txt');

% Subjects
sIni = {'TS' 'LR' 'HK'}; 



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
valid = trialType == 1;
invalid = trialType == 2;

% Subjects
numSub = length(unique(sub));


% Eccentricity
near = targetEcc == 2.5
far = targetEcc == 5.0

minimum = 1;
maximum = 2000;

%minimum = 300;
%maximum = 600;

amp = sacAmp > 0.05 & sacAmp <=1.5; 

% Microsaccade Use
use = sacDur>=6 & sacDur<40 & amp & sacVPeak <=100 & sacOn >= minimum & sacOn <= maximum ;  

% Response
%response = tRes-tFix;     
%respMN = mean(response( (sacNum == 0 | sacNum ==1) & use));

% Get Microsaccade Count 
totalMicro = length(sacOn(use));
totalMicroValid = length(sacOn(use & valid))
totalMicroInValid = length(sacOn(use & invalid))


totalMicroAll = [totalMicroValid, totalMicroInValid];

%% MAIN SEQUENCE 

figure

subplot(2,3,1)
plot(sacAmp((use)), sacVPeak((use)), 'o', 'MarkerEdgeColor', 'k',  'MarkerSize', 1);
xlabel('Amplitude (deg)');
ylabel('Peak Velocity (deg/sec)');
title('MAIN SEQUENCE')
axis([0, 1.5, 0, 100])
plot(sacAmp((use & valid)), sacVPeak((use & valid)), 'o', 'MarkerEdgeColor', 'g',  'MarkerSize', 1.75);
hold on;
plot(sacAmp((use & invalid)), sacVPeak((use & invalid)), 'o', 'MarkerEdgeColor', 'r',  'MarkerSize', 1.75);

subplot(2,3,2)

vPeak = (sacVPeak((use)));
hist(vPeak, 20);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','k','EdgeColor','w')
xlabel('Peak Velocity (deg/sec)');
ylabel('Frequency');
title('VELOCITY')
axis([0, 80, 0, 8000])
%axis([0, 100, 0, 1500])
line([mean(sacVPeak(use)),mean(sacVPeak(use))], [0, 1000], 'Color' ,[1 0 0]);

subplot(2,3,3)  
bar(totalMicroAll, 'k')
xlabel('Condition');
ylabel('Frequency');
title('CONDITION')
axis([0, 4, 0, 8000])

subplot(2,3,4)
amp = sacAmp((use));
hist(amp, 20);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','k','EdgeColor','w')
xlabel('Amplitude (deg)');
ylabel('Frequency');
title('AMPLITUDE')
axis([0, 1.5, 0, 5000])
line([mean(sacAmp(use)),mean(sacAmp(use))], [0, 1000], 'Color' ,[1 0 0]);

subplot(2,3,5)  
hist(sacDur((use)),30);
axis([10, 40, 0, 1000])
h = findobj(gca,'Type','patch');
set(h,'FaceColor','k','EdgeColor','w')
xlabel('Duration (msec)');
ylabel('Frequency');
title('DURATION')
line([mean(sacDur(use)),mean(sacDur(use))], [0, 200], 'Color' ,[1 0 0]);

subplot(2,3,6) %polar plot
polar(pi, 500);
hold on;
h=rose(sacAngle1(use),30);  
title('DIRECTION');
%text(0, -nPolar-100,['Interval= ',int2str(minimum), ' : ', int2str(maximum)], 'FontSize',14);
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'w');

%% Get Microssacade Rate Data 
plotMeans = 0


%%Velocity
i = 0;
counter = 0;

for i=1:numSub
    counter = counter + 1;
    validVP = sacVPeak(use & sub==i & valid);
    VP(counter,1) = mean(validVP); % get mean rate for interval for t-test
    
    invalidVP = sacVPeak(use & sub==i & invalid);
    VP(counter,2) = mean(invalidVP); % get mean rate for interval for t-test
    
    
end

anova_rm(VP)

%%Amplitude
i = 0;
counter = 0;

for i=1:numSub
    counter = counter + 1;
    validAMP = sacAmp(use & sub==i & valid);
    AMP(counter,1) = mean(validAMP); % get mean rate for interval for t-test
    
    invalidAMP = sacAmp(use & sub==i & invalid);
    AMP(counter,2) = mean(invalidAMP); % get mean rate for interval for t-test
    
    
end

anova_rm(AMP)

%%Duration
i = 0;
counter = 0;

for i=1:numSub
    counter = counter + 1;
    validDUR = sacDur(use & sub==i & valid);
    DUR(counter,1) = mean(validDUR); % get mean rate for interval for t-test
    
    invalidDUR = sacDur(use & sub==i & invalid);
    DUR(counter,2) = mean(invalidDUR); % get mean rate for interval for t-test
    
    
end

anova_rm(DUR)

        
%% Overall Microsaccade Count
i = 0;
counter = 0;
uniqueTrial = sacNum == 0 | sacNum == 1;

for i=1:numSub    
    counter = counter + 1;

    validTotalMicro = sum(use & sub==i & valid & far);  
    validTotalTrial = sum(uniqueTrial & sub==i & valid & far);
    microTotal(counter,1) = validTotalMicro; % /sacTotalTrial; % get mean rate for interval for t-test
    
    invalidTotalMicro = sum(use & sub==i & invalid & far);  
    invalidTotalTrial = sum(uniqueTrial & sub==i & invalid & far);
    microTotal(counter,2) = invalidTotalMicro; % /sacTotalTrial; % get mean rate for interval for t-test
    
   

end

anova_rm(microTotal)







