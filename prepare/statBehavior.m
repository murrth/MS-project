% Clear any loaded files/variables
clear all;

% Close any open figures
close all;

% Load Data
dat = load('data.txt');
%dat = load('dataNoToneSmallCue.txt');
%dat = load('dataOnsetCue.txt');

% Subjects
sIni = {'TA' 'OM' 'LR' 'GS' 'CL' 'JG' 'HK' 'NW' 'AA' 'TG' 'TS'}; % Hannah, Talulah, Nick, Alex
%sIni = {'EP' 'BM'};
% Label Data Columns
sub             = dat(:,1);
ses             = dat(:,2);
block           = dat(:,3);
trial           = dat(:,4);
cond            = dat(:,5);
trialType       = dat(:,6);
trialISI        = dat(:,7);
targetLoc       = dat(:,8);
targetEcc       = dat(:,9); 
cueEcc          = dat(:,10);

gapSize         = dat(:,11);
gapLocT         = dat(:,12);

tedfFix          = dat(:,13);
tedfpreCueON    = dat(:,14);
tedfpreISIOn    = dat(:,15);
tedfstimOn      = dat(:,16);
tedfpostISIOn   = dat(:,17); %same as tedfstimOff
tedfrespToneOn  = dat(:,18);
%tedfClr         = dat(:,19);

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

%delay = trialISI
ISI1 = trialISI == 70;
ISI2 = trialISI == 175;
ISI3 = trialISI == 400;
ISI4 = trialISI == 650;
ISI5 = trialISI == 950;

% Condition
valid = trialType == 1;
invalid = trialType == 2;
neutral = trialType == 3;

% Subjects
numSub = length(unique(sub));
%numSub = 9;

% Stimuli
%targLeft = targLoc ==1;
%targRight = targLoc == 2;

uniqueTrial = sacNum == 0 | sacNum == 1;  

totalTrial = sum(uniqueTrial)
totalCor = sum(cor(uniqueTrial))
totalCor/totalTrial

%% Percent Correct Valid, Invalid, Neutral

near = targetEcc == 2.5;
far = targetEcc == 5.0;

%use = near;
use =  far;
%use = near | far;
i = 0;
counter = 0;
figure

for i=1:numSub    
    counter = counter + 1;

    vTotalTrial = sum(uniqueTrial & sub==i & valid & use);  
    vTotalCor = sum(cor(uniqueTrial & sub==i & valid & use));    
    perCor(counter,1) = vTotalCor/vTotalTrial; % get mean rate for interval for t-test
    
    iTotalTrial = sum(uniqueTrial & sub==i & invalid & use); 
    iTotalCor = sum(cor(uniqueTrial & sub==i & invalid & use));    
    perCor(counter,2) = iTotalCor/iTotalTrial; % get mean rate for interval for t-test
    
    nTotalTrial = sum(uniqueTrial & sub==i & neutral & use);
    nTotalCor = sum(cor(uniqueTrial & sub==i & neutral & use));    
    perCor(counter,3) = nTotalCor/nTotalTrial; % get mean rate for interval for t-test
    
%     subplot(numSub+1,1,counter)
% 
%     plot(perCor(counter,:), '-or', 'LineWidth', 1); 
%     axis([.5,3.5, .65, 1]);
% 
%     xlabel('Condition (Valid, Invalid, Neutral)');
%     ylabel('Percent Correct');
%     title(i);
end

if numSub>1
figure
perCorMean = mean(perCor)
perCorSem = std(perCor)/sqrt(length(perCor)) % standard error of the mean
barwitherr(perCorSem, perCorMean)
axis([.5,3.5, .65, 1]);
xlabel('Condition (Valid, Invalid, Neutral)');
ylabel('Percent Correct');
end

anova_rm(perCor)

% Percent Correct Across ISI

i = 0;

counter = 0;
figure

for i=1:numSub  
    counter = counter + 1;

    vTotalTrial100 = sum(uniqueTrial & sub==i & valid & use & ISI1);
    vTotalCor100 = sum(cor(uniqueTrial & sub==i & valid & use & ISI1));    
    vPerCor(counter,1) = vTotalCor100/vTotalTrial100; % get mean rate for interval for t-test
    
    vTotalTrial200 = sum(uniqueTrial & sub==i & valid & use & ISI2);
    vTotalCor200 = sum(cor(uniqueTrial & sub==i & valid & use & ISI2));    
    vPerCor(counter,2) = vTotalCor200/vTotalTrial200; % get mean rate for interval for t-test
    
    vTotalTrial400 = sum(uniqueTrial & sub==i & valid & use & ISI3);
    vTotalCor400 = sum(cor(uniqueTrial & sub==i & valid & use & ISI3));    
    vPerCor(counter,3) = vTotalCor400/vTotalTrial400; % get mean rate for interval for t-test
    
    vTotalTrial675 = sum(uniqueTrial & sub==i & valid & use & ISI4);
    vTotalCor675 = sum(cor(uniqueTrial & sub==i & valid & use & ISI4));    
    vPerCor(counter,4) = vTotalCor675/vTotalTrial675; % get mean rate for interval for t-test
    
    vTotalTrial950 = sum(uniqueTrial & sub==i & valid & use & ISI5);
    vTotalCor950 = sum(cor(uniqueTrial & sub==i & valid & use & ISI5));    
    vPerCor(counter,5) = vTotalCor950/vTotalTrial950; % get mean rate for interval for t-test
    
    
    iTotalTrial100 = sum(uniqueTrial & sub==i & invalid & use & ISI1);
    iTotalCor100 = sum(cor(uniqueTrial & sub==i & invalid & use & ISI1));    
    iPerCor(counter,1) = iTotalCor100/iTotalTrial100; % get mean rate for interval for t-test
    
    iTotalTrial200 = sum(uniqueTrial & sub==i & invalid & use & ISI2);
    iTotalCor200 = sum(cor(uniqueTrial & sub==i & invalid & use & ISI2));    
    iPerCor(counter,2) = iTotalCor200/iTotalTrial200; % get mean rate for interval for t-test
    
    iTotalTrial400 = sum(uniqueTrial & sub==i & invalid & use & ISI3);
    iTotalCor400 = sum(cor(uniqueTrial & sub==i & invalid & use & ISI3));    
    iPerCor(counter,3) = iTotalCor400/iTotalTrial400; % get mean rate for interval for t-test
    
    iTotalTrial675 = sum(uniqueTrial & sub==i & invalid & use & ISI4);
    iTotalCor675 = sum(cor(uniqueTrial & sub==i & invalid & use & ISI4));    
    iPerCor(counter,4) = iTotalCor675/iTotalTrial675; % get mean rate for interval for t-test
    
    iTotalTrial950 = sum(uniqueTrial & sub==i & invalid & use & ISI5);
    iTotalCor950 = sum(cor(uniqueTrial & sub==i & invalid & use & ISI5));    
    iPerCor(counter,5) = iTotalCor950/iTotalTrial950; % get mean rate for interval for t-test
   
    
    nTotalTrial100 = sum(uniqueTrial & sub==i & neutral & use & ISI1);
    nTotalCor100 = sum(cor(uniqueTrial & sub==i & neutral & use & ISI1));    
    nPerCor(counter,1) = nTotalCor100/nTotalTrial100; % get mean rate for interval for t-test
    
    nTotalTrial200 = sum(uniqueTrial & sub==i & neutral & use & ISI2);
    nTotalCor200 = sum(cor(uniqueTrial & sub==i & neutral & use & ISI2));    
    nPerCor(counter,2) = nTotalCor200/nTotalTrial200; % get mean rate for interval for t-test
    
    nTotalTrial400 = sum(uniqueTrial & sub==i & neutral & use & ISI3);
    nTotalCor400 = sum(cor(uniqueTrial & sub==i & neutral & use & ISI3));    
    nPerCor(counter,3) = nTotalCor400/nTotalTrial400; % get mean rate for interval for t-test
    
    nTotalTrial675 = sum(uniqueTrial & sub==i & neutral & use & ISI4);
    nTotalCor675 = sum(cor(uniqueTrial & sub==i & neutral & use & ISI4));    
    nPerCor(counter,4) = nTotalCor675/nTotalTrial675; % get mean rate for interval for t-test
    
    nTotalTrial950 = sum(uniqueTrial & sub==i & neutral & use & ISI5);
    nTotalCor950 = sum(cor(uniqueTrial & sub==i & neutral & use & ISI5));    
    nPerCor(counter,5) = nTotalCor950/nTotalTrial950; % get mean rate for interval for t-test
    
    %subplot(numSub,1,counter)
    figure
    plot(vPerCor(counter,:), '-og', 'LineWidth', 1); 
    hold on;
    plot(iPerCor(counter,:), '-or', 'LineWidth', 1); 
    hold on;
    plot(nPerCor(counter,:), '-ob', 'LineWidth', 1); % NEUTRAL
    axis([0.75,5.25, .5, 1]);
    set(gca, 'XTick', [1, 2, 3, 4, 5])
    set(gca, 'XTickLabel', [120, 225, 450, 700, 1000])
    %set(gca, 'XTickLabel', [70, 175, 400, 650, 950])
 
    xlabel('SOA');
    ylabel('% Correct');    
    title(i);
    legend('Valid', 'Invalid', 'Neutral');
    
end

[a,b] = ttest(vPerCor(:,1), iPerCor(:,1), 0.05, 'right') % one tailed test

% Percent Correct Overall

if numSub>1

% Mean by SOAs
figure
vPerCorISIMean = mean(vPerCor);
iPerCorISIMean = mean(iPerCor);
nPerCorISIMean = mean(nPerCor);

vPerCorISISem = std(vPerCor)/sqrt(length(vPerCor)) % standard error of the mean
errorbar(vPerCorISIMean, vPerCorISISem, '-og')
hold on;
iPerCorISISem = std(iPerCor)/sqrt(length(iPerCor)) % standard error of the mean
errorbar(iPerCorISIMean, iPerCorISISem, '-or')
hold on;
nPerCorISISem = std(nPerCor)/sqrt(length(nPerCor)) % standard error of the mean
errorbar(nPerCorISIMean, nPerCorISISem, '-ob')
hold on;
axis([0.75,5.25, .50, 1]);
set(gca, 'XTick', [1, 2, 3, 4, 5])
set(gca, 'XTickLabel', [120, 225, 450, 700, 1000]) % SOA
%set(gca, 'XTickLabel', [70, 175, 400, 650, 950]) % ISI
xlabel('SOA');
title('Percent Correct');
legend('Valid', 'Invalid', 'Neutral');
    
end




%%  Key RT

useRT =  keyRT < 1500;
%use = keyRT < 600;

i = 0;
counter = 0;

figure

for i=1:numSub    
    counter = counter + 1;

    vRTAll = mean((keyRT(sub==i & valid & uniqueTrial & useRT)));    
    RT(counter,1) = vRTAll; % get mean rate for interval for t-test
    
    vRT1 = mean((keyRT(sub==i & valid & uniqueTrial & useRT & ISI1)));    
    vRT(counter,1) = vRT1; % get mean rate for interval for t-test
    
    vRT2 = mean((keyRT(sub==i & valid & uniqueTrial & useRT & ISI2)));    
    vRT(counter,2) = vRT2; % get mean rate for interval for t-test
    
    vRT3 = mean((keyRT(sub==i & valid & uniqueTrial & useRT & ISI3)));    
    vRT(counter,3) = vRT3; % get mean rate for interval for t-test
    
    vRT4 = mean((keyRT(sub==i & valid & uniqueTrial & useRT & ISI4)));    
    vRT(counter,4) = vRT4; % get mean rate for interval for t-test
    
    vRT5 = mean((keyRT(sub==i & valid & uniqueTrial & useRT & ISI5)));    
    vRT(counter,5) = vRT5; % get mean rate for interval for t-test
    
    
    iRTAll = mean((keyRT(sub==i & invalid & uniqueTrial & useRT)));    
    RT(counter,2) = iRTAll; % get mean rate for interval for t-test
    
    iRT1 = mean((keyRT(sub==i & invalid & uniqueTrial & useRT & ISI1)));    
    iRT(counter,1) = iRT1; % get mean rate for interval for t-test
    
    iRT2 = mean((keyRT(sub==i & invalid & uniqueTrial & useRT & ISI2)));    
    iRT(counter,2) = iRT2; % get mean rate for interval for t-test
    
    iRT3 = mean((keyRT(sub==i & invalid & uniqueTrial & useRT & ISI3)));    
    iRT(counter,3) = iRT3; % get mean rate for interval for t-test
    
    iRT4 = mean((keyRT(sub==i & invalid & uniqueTrial & useRT & ISI4)));    
    iRT(counter,4) = iRT4; % get mean rate for interval for t-test
    
    iRT5 = mean((keyRT(sub==i & invalid & uniqueTrial & useRT & ISI5)));    
    iRT(counter,5) = iRT5; % get mean rate for interval for t-test

    
    nRTAll = mean((keyRT(sub==i & neutral & uniqueTrial & useRT)));    
    RT(counter,3) = nRTAll; % get mean rate for interval for t-test
    
    nRT1 = mean((keyRT(sub==i & neutral & uniqueTrial & useRT & ISI1)));    
    nRT(counter,1) = nRT1; % get mean rate for interval for t-test
    
    nRT2 = mean((keyRT(sub==i & neutral & uniqueTrial & useRT & ISI2)));    
    nRT(counter,2) = nRT2; % get mean rate for interval for t-test
    
    nRT3 = mean((keyRT(sub==i & neutral & uniqueTrial & useRT & ISI3)));    
    nRT(counter,3) = nRT3; % get mean rate for interval for t-test
    
    nRT4 = mean((keyRT(sub==i & neutral & uniqueTrial & useRT & ISI4)));    
    nRT(counter,4) = nRT4; % get mean rate for interval for t-test
    
    nRT5 = mean((keyRT(sub==i & neutral & uniqueTrial & useRT & ISI5)));    
    nRT(counter,5) = nRT5; % get mean rate for interval for t-test
    
    subplot(numSub,1,counter)

    plot(vRT(counter,:), '-og', 'LineWidth', 1); 
    hold on;
    plot(iRT(counter,:), '-or', 'LineWidth', 1); 
    hold on;
%   plot(nRT(counter,:), '-ob', 'LineWidth', 1);  % NEUTRAL
    axis([0.75,5.25, 0, 500]);
    set(gca, 'XTick', [1, 2, 3, 4, 5])
    set(gca, 'XTickLabel', [120, 225, 450, 700, 1000])
    %set(gca, 'XTickLabel', [70, 175, 400, 650, 950]) 
    xlabel('SOA');    
    ylabel('Mean RT (msec)');
    title(i);
    legend('Valid', 'Invalid', 'Neutral');

end

%% Key RT All

if numSub>1
figure

% Collapsed Mean
RTMean = mean(RT)
RTSem = std(RT)/sqrt(length(RT(:,1))) % standard error of the mean
barwitherr(RTSem, RTMean)
axis([.5,3.5, 100, 300]);

xlabel('Condition (Valid, Invalid, Neutral)');
ylabel('Mean RT');

% Mean by ISIs
figure
vRTISIMean = mean(vRT);
iRTISIMean = mean(iRT);
nRTISIMean = mean(nRT);

vRTISISem = std(vRT)/sqrt(length(vRT)) % standard error of the mean
errorbar(vRTISIMean, vRTISISem, '-og')
hold on;
iRTISISem = std(iRT)/sqrt(length(iRT)) % standard error of the mean
errorbar(iRTISIMean, iRTISISem, '-or')
hold on;
nRTISISem = std(nRT)/sqrt(length(nRT)) % standard error of the mean
%errorbar(nRTISIMean, nRTISISem, '-ob') % NEUTRAL
hold on;
axis([0.75,5.25, 0, 500]);
set(gca, 'XTick', [1, 2, 3, 4, 5])
set(gca, 'XTickLabel', [120, 225, 450, 700, 1000])
%set(gca, 'XTickLabel', [70, 175, 400, 650, 950]) 
xlabel('SOA');
ylabel('Mean RT (msec)');
title('Reaction Time');
legend('Valid', 'Invalid', 'Neutral');
    
end

% %%
% % Inverse Efficiency
% 
% vInvEff = vRT./vPerCor
% iInvEff = iRT./iPerCor
% nInvEff = nRT./nPerCor
% 
% 
% vInvEffSem = std(vInvEff)/sqrt(length(vInvEff));
% iInvEffSem = std(iInvEff)/sqrt(length(iInvEff));
% nInvEffSem = std(nInvEff)/sqrt(length(nInvEff));% standard error of the mean
% 
% 
% 
% figure
% errorbar(mean(vInvEff), vInvEffSem, '-og')
% hold on;
% errorbar(mean(iInvEff), iInvEffSem, '-or')
% hold on;
% errorbar(mean(nInvEff), nInvEffSem, '-ob')
% hold on;
% 
% 
% axis([0.75,5.25, 100, 340]);
% set(gca, 'XTick', [1, 2, 3, 4, 5])
% set(gca, 'XTickLabel', [120, 225, 450, 700, 1000])
% %set(gca, 'XTickLabel', [70, 175, 400, 650, 950]) 
% xlabel('SOA');
% ylabel('Inverse Efficiency');
% title('Inverse Efficiency (RT/Prop Cor');
% legend('Valid', 'Invalid', 'Neutral');


%% Percent Correct Eccentricity

near = targetEcc == 2.5;
far = targetEcc == 5.0;

i = 0;
counter = 0;

for i=1:numSub    
    counter = counter + 1;

    vTotalTrialNear = sum(uniqueTrial & sub==i & valid & near & useRT );
    vTotalCorNear = sum(cor(uniqueTrial & sub==i & valid & near & useRT ));    
    perCorEccN(counter,1) = vTotalCorNear/vTotalTrialNear; % get mean rate for interval for t-test       

    iTotalTrialNear = sum(uniqueTrial & sub==i & invalid & near & useRT );
    iTotalCorNear = sum(cor(uniqueTrial & sub==i & invalid & near & useRT));    
    perCorEccN(counter,2) = iTotalCorNear/iTotalTrialNear; % get mean rate for interval for t-test
    
    nTotalTrialNear = sum(uniqueTrial & sub==i & neutral & near & useRT );
    nTotalCorNear = sum(cor(uniqueTrial & sub==i & neutral & near & useRT ));    
    perCorEccN(counter,3) = nTotalCorNear/nTotalTrialNear; % get mean rate for interval for t-test
    
    
    vTotalTrialFar = sum(uniqueTrial & sub==i & valid & far & useRT);
    vTotalCorFar = sum(cor(uniqueTrial & sub==i & valid & far & useRT));    
    perCorEccF(counter,1) = vTotalCorFar/vTotalTrialFar; % get mean rate for interval for t-test       

    iTotalTrialFar = sum(uniqueTrial & sub==i & invalid & far & useRT);
    iTotalCorFar = sum(cor(uniqueTrial & sub==i & invalid & far & useRT));    
    perCorEccF(counter,2) = iTotalCorFar/iTotalTrialFar; % get mean rate for interval for t-test
    
    nTotalTrialNear = sum(uniqueTrial & sub==i & neutral & far & useRT);
    nTotalCorNear = sum(cor(uniqueTrial & sub==i & neutral & far & useRT));    
    perCorEccF(counter,3) = nTotalCorNear/nTotalTrialNear; % get mean rate for interval for t-test
        
    
end

figure

subplot(1, 2, 1)
perCorEccNSem = std(perCorEccN)/sqrt(length(perCorEccN)); % standard error of the mean
perCorEccFSem = std(perCorEccF)/sqrt(length(perCorEccF)); % standard error of the mean
barwitherr(perCorEccNSem, mean(perCorEccN))
hold on;
axis([0.5, 3.50, .5, 1]);
title('Near Eccentricity');
xlabel('Condition (Valid, Invalid, Neutral)');
ylabel('Percent Correct');

subplot(1, 2, 2)
barwitherr(perCorEccFSem, mean(perCorEccF))
hold on;
axis([0.5, 3.50, .5, 1]);
title('Far Eccentricity');
xlabel('Condition (Valid, Invalid, Neutral)');




%% RT Eccentricity

i = 0;
counter = 0;


for i=1:numSub    
    counter = counter + 1;

    vRTnear = mean((keyRT(sub==i & valid & uniqueTrial & near & useRT)));    
    eccRTNear(counter,1) = vRTnear; % get mean rate for interval for t-test
     
    iRTnear = mean((keyRT(sub==i & invalid & uniqueTrial & near & useRT)));    
    eccRTNear(counter,2) = iRTnear; % get mean rate for interval for t-test
    
    nRTnear = mean((keyRT(sub==i & neutral & uniqueTrial & near & useRT)));    
    eccRTNear(counter,3) = nRTnear; % get mean rate for interval for t-test
   
    vRTfar = mean((keyRT(sub==i & valid & uniqueTrial & far & useRT)));    
    eccRTFar(counter,1) = vRTfar; % get mean rate for interval for t-test
     
    iRTfar = mean((keyRT(sub==i & invalid & uniqueTrial & far & useRT)));    
    eccRTFar(counter,2) = iRTfar; % get mean rate for interval for t-test
    
    nRTfar = mean((keyRT(sub==i & neutral & uniqueTrial & far & useRT)));    
    eccRTFar(counter,3) = nRTfar; % get mean rate for interval for t-test
    
   
end



%%
figure

subplot(1, 2, 1)
eccRTNSem = std(eccRTNear)/sqrt(length(eccRTNear)); % standard error of the mean
eccRTFSem = std(eccRTFar)/sqrt(length(eccRTFar)); % standard error of the mean
barwitherr(eccRTNSem, mean(eccRTNear))
hold on;
axis([0.5, 3.50, 0, 500]);
title('Near Eccentricity');
xlabel('Condition (Valid, Invalid, Neutral)');
ylabel('Mean RT (msec)');

subplot(1, 2, 2)
barwitherr(eccRTFSem, mean(eccRTFar))
hold on;
axis([0.5, 3.50, 0, 500]);
title('Far Eccentricity');
xlabel('Condition (Valid, Invalid, Neutral)');

%% ANOVAS

%anova_rm(perCor)
%anova_rm(thrGap)
%anova_rm(RT)




