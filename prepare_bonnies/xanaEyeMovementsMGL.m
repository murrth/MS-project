% xanaEyeMovements.m
%
% Input:
% 1. vpcode.tab
% 2. vpcode.dat
%
% Output:
% 2. vpcode.rea - Infos zu sakkadischen Antworten
% 3. vpcode.btr - Infos zu Ausschlusskriterien (welche pro Trial erfuellt)
%
% last update: 07.12.2009 by Martin Rolfs

clear;
home;

addpath('functions/');

plotData  = 1;          % show figure with raw data

% sampling rate
SAMPRATE  = 1000;       % Sampling rate des Eye Trackers

% microsaccade parameters
velSD     = 6;          % Schwelle lambda fuer Mikrosakkaden-Detektion
minDur    = 8;          % Schwelle duration fuer Mikrosakkaden-Detektion (ms) % was 6
maxMSAmp  = 1.5;        % maximum microsaccade amplitude

VELTYPE   = 2;          % velocity type for saccade detection
crit_cols = [2 3];      % kritische Spalten in dat files, um Missings zu suchen
mergeInt  = 10;         % merge interval for subsequent saccadic events
     
% visual display
ABSTAND   = 57;         % Abstand zum Monitor in cm %Monitor distance in cm
MO_WIDE   = 1024;       % x-Aufloesung des Stimulus-Screens (1280X960)
MO_PHYS   = 40;         % x Monitor Breite in cm (40X30 cm)

scrCen = [512 384];  % screen center (intial fixation position)  %1024*768
DPP = pix2deg(MO_WIDE,MO_PHYS,ABSTAND,1); % degrees per pixel
PPD = deg2pix(MO_WIDE,MO_PHYS,ABSTAND,1); % pixels per degree

anaEyeMovementsFilterMGL;

fprintf(1,'\n\nOK!!\n');

%%
