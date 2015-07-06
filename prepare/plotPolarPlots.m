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

% Stimuli
targLeft = targetLoc ==1;
targRight = targetLoc == 2;

minimum = 1;
maximum = 1750;

amp = sacAmp > 0.05 & sacAmp <=1.5; 
% Microsaccade Use
use = sacDur>=8 & sacDur<40 & amp & sacVPeak <=100 & sacOn >= minimum & sacOn <= maximum; 


% Response
%response = tRes-tFix;     
%respMN = mean(response( (sacNum == 0 | sacNum ==1) & use));

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

nPolar = 200

%%%%SACCADE%%%%
% 1:2500
minimum = 1
maximum = 1750
int = sacOn >= minimum & sacOn <= maximum; 
subplot(3,4,1)
polar(pi, 500);
hold on;
h=rose(sacAngle1(use & int & sac),40);  
%title('SACCADE');
text(0, -nPolar-550,['Interval= ',int2str(0), ' : ', int2str(maximum)], 'FontSize',14);
set(h,'LineWidth',1,'Color','r')
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'r');


% %POLAR PLOT
figure
[nelements, centers] = hist(sacAngle1(use & int & sac & cong), 60);
rate = nelements/sum(nelements);
polar(centers, rate, '-r');
hold on;
[nelements, centers] = hist(sacAngle1(use & int & incg), 60);
rate = nelements/sum(nelements);
polar(centers, rate, '-k');

hold on;

% 1:500
minimum = 1
maximum = 500
int = sacOn >= minimum & sacOn <= maximum; 
subplot(3,4,2)
polar(pi, 200);
hold on;
h=rose(sacAngle1(use & int & cong & sac),40);  
%title('SACCADE');
text(0, -nPolar-100,['Interval= ',int2str(0), ' : ', int2str(maximum)], 'FontSize',14);
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'r');
hold on;
h=rose(sacAngle1(use & int & incg & sac),40);  
%x = get(h,'Xdata');
%y = get(h,'Ydata');
%patch(x,y, 'w');
set(h,'LineWidth',1.05,'Color',[.15 .15 .15])

%500:1000
minimum = 500;
maximum = 1000;
int = sacOn >minimum & sacOn <= maximum; 

subplot(3,4,3)

polar(pi, nPolar);
hold on;
h=rose(sacAngle1(use & int & cong & sac),40);  
%title('SACCADE');
text(0, -nPolar-100,['Interval= ',int2str(500), ' : ', int2str(maximum)], 'FontSize',14);
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'r');
hold on;
h=rose(sacAngle1(use & int & incg & sac),40);  
%x = get(h,'Xdata');
%y = get(h,'Ydata');
%patch(x,y, 'w');
set(h,'LineWidth',1.05,'Color',[.15 .15 .15])


%1800:2200
minimum = 1250;
maximum = 1750;
int = sacOn > minimum & sacOn <= maximum; 

subplot(3,4,4)
polar(pi, nPolar);
hold on;
h=rose(sacAngle1(use & int & cong & sac),40);  
%title('SACCADE');
text(0, -nPolar-100,['Interval= ',int2str(1250), ' : ', int2str(maximum)], 'FontSize',14);
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'r');
hold on;
h=rose(sacAngle1(use & int & incg & sac),40);  
%x = get(h,'Xdata');
%y = get(h,'Ydata');
%patch(x,y, 'w');
set(h,'LineWidth',1.05,'Color',[.15 .15 .15])



%%%%ATTENTION%%%%
% 1:2500
minimum = 1
maximum = 1750
int = sacOn >= minimum & sacOn <= maximum; 
subplot(3,4,5)
polar(pi, 500);
hold on;
h=rose(sacAngle1(use & int & att),40);  
%title('SACCADE');
text(0, -nPolar-550,['Interval= ',int2str(0), ' : ', int2str(maximum)], 'FontSize',14);
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'g');
hold on;

% 1:500
minimum = 1
maximum = 500
int = sacOn >= minimum & sacOn <= maximum; 
subplot(3,4,6)
polar(pi, 200);
hold on;
h=rose(sacAngle1(use & int & cong & att),40);  
%title('SACCADE');
text(0, -nPolar-100,['Interval= ',int2str(0), ' : ', int2str(maximum)], 'FontSize',14);
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'g');
hold on;
h=rose(sacAngle1(use & int & incg & att),40);  
% x = get(h,'Xdata');
% y = get(h,'Ydata');
% patch(x,y, 'w');
set(h,'LineWidth',1.05,'Color',[.15 .15 .15])


%500:1000
minimum = 500;
maximum = 1000;
int = sacOn >minimum & sacOn <= maximum; 

subplot(3,4,7)

polar(pi, nPolar);
hold on;
h=rose(sacAngle1(use & int & cong & att),40);  
%title('SACCADE');
text(0, -nPolar-100,['Interval= ',int2str(500), ' : ', int2str(maximum)], 'FontSize',14);
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'g');
hold on;
h=rose(sacAngle1(use & int & incg & att),40);  
% x = get(h,'Xdata');
% y = get(h,'Ydata');
% patch(x,y, 'w');
set(h,'LineWidth',1.05,'Color',[.15 .15 .15])



%1800:2200
minimum = 1250;
maximum = 1750;
int = sacOn > minimum & sacOn <= maximum; 

subplot(3,4,8)
polar(pi, nPolar);
hold on;
h=rose(sacAngle1(use & int & cong & att),40);  
%title('SACCADE');
text(0, -nPolar-100,['Interval= ',int2str(1250), ' : ', int2str(maximum)], 'FontSize',14);
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'g');
hold on;
h=rose(sacAngle1(use & int & incg & att),40);  
% x = get(h,'Xdata');
% y = get(h,'Ydata');
% patch(x,y, 'w');
set(h,'LineWidth',1.05,'Color',[.15 .15 .15])






%%%%NEUTRAL%%%%
% 1:2500
minimum = 1
maximum = 1750
int = sacOn >= minimum & sacOn <= maximum; 
subplot(3,4,9)
polar(pi, 500);
hold on;
h=rose(sacAngle1(use & int & neu),40);  
%title('SACCADE');
text(0, -nPolar-550,['Interval= ',int2str(0), ' : ', int2str(maximum)], 'FontSize',14);
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'b');
hold on;

% 1:500
minimum = 1
maximum = 500
int = sacOn >= minimum & sacOn <= maximum; 
subplot(3,4,10)
polar(pi, 200);
hold on;
h=rose(sacAngle1(use & int & cong & neu),40);  
%title('SACCADE');
text(0, -nPolar-100,['Interval= ',int2str(0), ' : ', int2str(maximum)], 'FontSize',14);
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'b');
hold on;
h=rose(sacAngle1(use & int & incg & neu),40);  
% x = get(h,'Xdata');
% y = get(h,'Ydata');
% patch(x,y, 'w');
set(h,'LineWidth',1.05,'Color',[.15 .15 .15])





%500:1000
minimum = 500;
maximum = 1000;
int = sacOn >minimum & sacOn <= maximum; 

subplot(3,4,11)

polar(pi, nPolar);
hold on;
h=rose(sacAngle1(use & int & cong & neu),40);  
%title('SACCADE');
text(0, -nPolar-100,['Interval= ',int2str(500), ' : ', int2str(maximum)], 'FontSize',14);
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'b');
hold on;
h=rose(sacAngle1(use & int & incg & neu),40);  
% x = get(h,'Xdata');
% y = get(h,'Ydata');
% patch(x,y, 'w');
set(h,'LineWidth',1.05,'Color',[.15 .15 .15])




%1800:2200
minimum = 1250;
maximum = 1750;
int = sacOn > minimum & sacOn <= maximum; 

subplot(3,4,12)
polar(pi, nPolar);
hold on;
h=rose(sacAngle1(use & int & cong & neu),40);  
%title('SACCADE');
text(0, -nPolar-100,['Interval= ',int2str(1250), ' : ', int2str(maximum)], 'FontSize',14);
x = get(h,'Xdata');
y = get(h,'Ydata');
patch(x,y, 'b');
hold on;
h=rose(sacAngle1(use & int & incg & neu),40);  
% x = get(h,'Xdata');
% y = get(h,'Ydata');
% patch(x,y, 'w');
set(h,'LineWidth',1.05,'Color',[.15 .15 .15])




