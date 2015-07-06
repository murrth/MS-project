% xanaEyeMovements.m
%
% Input:
% 1. subject.tab
% 2. subject.dat
%
% Output:
% 2. subject.rea - info about saccadic responses
% 3. subject.btr - info about exclusion criteria for each trial
%
% last update: 24.03.2015 by Martin Rolfs

clear;
home;

addpath('functions/');

% determine files to be processed for eye movement data
% (here, all for which a dat file is in the raw/ data folder)
datpath = 'raw/';

% plot single trial data?
plotData  = 1;              % show figure with raw data for each trial

% parameters of the experimental setup
exp.scrDist   = 114;         % distance of stimulus screen [cm]
exp.scrWidth  = 40;         % physical width of the stimulus screen [cm]
exp.sampRate  = 1000;       % sampling rate of the eye tracker

% time window for saccade detection 
sac.aftRefSac = 500;        % time after reference, i.e., maximum latency for saccade detection (400 ms was the criterion during the exp.)
sac.aftRefFix = 200;        % time after reference, i.e., maximum latency for saccade detection (400 ms was the criterion during the exp.)
sac.befRef    = 100;        % time window to be analysed before onset of saccade target

% saccade detection parameters
sac.velSD     = 5;          % threshold lambda for microsaccade detection (SD)
sac.minDur    = 8;          % threshold duration for microsaccade detection (ms)
sac.velType   = 2;          % velocity type for saccade detection
sac.maxMSAmp  = 1;          % maximum microsaccade amplitude (dva)
sac.mergeInt  = 10;         % merge interval for subsequent saccadic events (ms)

% spatial fixation criterion
sac.tarRad    = 2.0;        % radius for eye position around target (deg)

% generate list of files to be processed
fileList = dir(sprintf('%smicro*.dat',datpath));
nFiles = length(fileList);

ntAll = 0;ntGoodAll = 0;
for f = 1:nFiles
    % subject code
    subCode = fileList(f).name(1:4);
    
    % process this file
    [nt, ntGood, exclude, plotData] = anaEyeMovements(subCode,exp,sac,plotData);
    
    % count numbers of trials
    ntAll     = ntAll     + nt;
    ntGoodAll = ntGoodAll + ntGood;
end

fprintf(1,'\n\nA total of %i trials (of %i) survived the rejection criteria!',ntGoodAll,ntAll);

fprintf(1,'\n\nOK!!\n');
