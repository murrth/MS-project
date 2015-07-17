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
%targLeft = targLoc ==1;
%targRight = targLoc == 2;

minimum = 10;
maximum = 1750;

amp = sacAmp > 0.05 & sacAmp <=1.5; 
% Microsaccade Use
use = sacDur>=8 & sacDur<40 & amp & sacVPeak <=100 & sacOn >= minimum & sacOn <= maximum; 

% Get Microsaccade Count 
totalMicro = length(sacOn(use))
totalMicroSac = length(sacOn(use & sac))
totalMicroAtt = length(sacOn(use & att))
totalMicroNeu = length(sacOn(use & neu))

totalMicroAll = [totalMicroSac, totalMicroAtt, totalMicroNeu]



%% MAIN SEQUENCE 

figure

subplot(2,3,1)
plot(sacAmp((use)), sacVPeak((use)), 'o', 'MarkerEdgeColor', 'k',  'MarkerSize', 1);
xlabel('Amplitude (deg)');
ylabel('Peak Velocity (deg/sec)');
title('MAIN SEQUENCE')
axis([0, 1.5, 0, 100])
%plot(sacAmp((use & att)), sacVPeak((use & att)), 'o', 'MarkerEdgeColor', 'g',  'MarkerSize', 1.75);
%hold on;
%plot(sacAmp((use & neu)), sacVPeak((use & neu)), 'o', 'MarkerEdgeColor', 'k',  'MarkerSize', 1.75);
%hold on;
%plot(sacAmp((use & sac)), sacVPeak((use & sac)), 'o', 'MarkerEdgeColor', 'r',  'MarkerSize', 1.75);

subplot(2,3,2)

vPeak = (sacVPeak((use)));
hist(vPeak, 20);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','k','EdgeColor','w')
xlabel('Peak Velocity (deg/sec)');
ylabel('Frequency');
title('VELOCITY')
axis([0, 80, 0, 5000])
%axis([0, 100, 0, 1500])
line([mean(sacVPeak(use)),mean(sacVPeak(use))], [0, 1000], 'Color' ,[1 0 0]);

subplot(2,3,4)
amp = sacAmp((use));
hist(amp, 20);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','k','EdgeColor','w')
xlabel('Amplitude (deg)');
ylabel('Frequency');
title('AMPLITUDE')
axis([0, 1.5, 0, 5000])
%axis([0, 1.5, 0, 1500])
line([mean(sacAmp(use)),mean(sacAmp(use))], [0, 1000], 'Color' ,[1 0 0]);

subplot(2,3,5)  
hist(sacDur((use)),30);
axis([10, 40, 0, 1000])
%axis([10, 40, 0, 500])
h = findobj(gca,'Type','patch');
set(h,'FaceColor','k','EdgeColor','w')
xlabel('Duration (msec)');
ylabel('Frequency');
title('DURATION')
line([mean(sacDur(use)),mean(sacDur(use))], [0, 200], 'Color' ,[1 0 0]);

subplot(2,3,3)  
bar(totalMicroAll, 'k')

xlabel('Condition');
ylabel('Frequency');
title('CONDITION')
axis([0, 4, 4000, 7000])

%Polar Plot

subplot(2,3,6) %polar plot
polar(pi, 2000);
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
    sacVP = sacVPeak(use & sub==i & sac);
    VP(counter,1) = mean(sacVP); % get mean rate for interval for t-test
    
    attVP = sacVPeak(use & sub==i & att);
    VP(counter,2) = mean(attVP); % get mean rate for interval for t-test
    
    neuVP = sacVPeak(use & sub==i & neu);
    VP(counter,3) = mean(neuVP); % get mean rate for interval for t-test
end

anova_rm(VP)

%%Amplitude
i = 0;
counter = 0;

for i=1:numSub
    counter = counter + 1;
    sacAMP = sacAmp(use & sub==i & sac);
    AMP(counter,1) = mean(sacAMP); % get mean rate for interval for t-test
    
    attAMP = sacAmp(use & sub==i & att);
    AMP(counter,2) = mean(attAMP); % get mean rate for interval for t-test
    
    neuAMP = sacAmp(use & sub==i & neu);
    AMP(counter,3) = mean(neuAMP); % get mean rate for interval for t-test
end

anova_rm(AMP)

%%Duration
i = 0;
counter = 0;

for i=1:numSub
    counter = counter + 1;
    sacDUR = sacDur(use & sub==i & sac);
    DUR(counter,1) = mean(sacDUR); % get mean rate for interval for t-test
    
    attDUR = sacDur(use & sub==i & att);
    DUR(counter,2) = mean(attDUR); % get mean rate for interval for t-test
    
    neuDUR = sacDur(use & sub==i & neu);
    DUR(counter,3) = mean(neuDUR); % get mean rate for interval for t-test
end

anova_rm(DUR)

        
%% Overall Microsaccade Count
i = 0;
counter = 0;
uniqueTrial = sacNum == 0 | sacNum == 1;

for i=1:numSub    
    counter = counter + 1;

    microSacTotalTrial = sum(use & sub==i & sac);  
    sacTotalTrial = sum(uniqueTrial & sub==i & sac);
    microTotal(counter,1) = microSacTotalTrial; % /sacTotalTrial; % get mean rate for interval for t-test
    
    microAttTotalTrial = sum(use & sub==i & att);       
    attTotalTrial = sum(uniqueTrial & sub==i & att);
    microTotal(counter,2) = microAttTotalTrial; %/attTotalTrial; % get mean rate for interval for t-test
    
    microNeuTotalTrial = sum(use & sub==i & neu);       
    neuTotalTrial = sum(uniqueTrial & sub==i & neu);
    microTotal(counter,3) = microNeuTotalTrial; %/neuTotalTrial; % get mean rate for interval for t-test

end

anova_rm(microTotal)




