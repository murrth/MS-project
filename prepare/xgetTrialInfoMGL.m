%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Get TRIAL INFORMATION FROM MGL EXPERIMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function xgetTrialInfoMGL (subInit, year, month, date, blockNum, subNum, sessNum, matfile)  

load(matfile)

vpcode = strcat(subInit, year, month, date, blockNum);

subNum = str2num(subNum);
blockNum = str2num(blockNum);
sessNum = str2num(sessNum);

tab=[];

e = getTaskParameters(myscreen, task);

%Get Stimulus Parameters
stimParam = [e.randVars.contrast; e.randVars.ExoCueCondition; e.randVars.targetLocation; e.randVars.targetOrientation;...
    e.randVars.distractorOrientation1; e.randVars.distractorOrientation2; e.randVars.distractorOrientation3];

stimParam = stimParam';

%Get Stimulus Timing
%seg = [e.trials(1,1:length(e.trials)).segtime]

%Reshape Seg Matrix (9 X 24)
%seg = reshape(seg, 9,length(e.trials))
%seg = seg'

%Get Orientation Response 
resOrient = e.response;
resOrient = resOrient';

%Get Orientation Response RT 
resOrientRT = e.reactionTime;
resOrientRT = resOrientRT';

%Combine Matrices
%info = [stimParam, resOrient, resOrientRT, seg]

%Add sub, trial, block information


subNum = repmat(subNum, length(e.trials), 1);

sessNum = repmat(sessNum, length(e.trials), 1);

trialNum = 1:length(e.trials);
trialNum = trialNum';
blockNum = repmat(blockNum, length(e.trials), 1);
info = [subNum, sessNum, blockNum, trialNum, stimParam, resOrient, resOrientRT];

%Save info to tab file
tab = info;
tabpath = '../tab/';   

%cont, cue, targLoc, targOrient, disOrient1, disOrient2, disOrient3, resOrient, resOrientRT

outname = sprintf('%s%sMGL.tab', tabpath, vpcode);
        fout = fopen(outname,'w');
        fprintf(fout,'%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%.4f\n',tab');
        fclose(fout);

