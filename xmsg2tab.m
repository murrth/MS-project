% xmsg2tab.m for GainAdapt
%
% Creates tab-File containing design and stimulus information for a given 
% trial.
%
% 26.03.2015 by Martin Rolfs

clear;

addpath('functions/');
fDir='prepare/';
msgpath = 'raw/';
tabpath = 'tab/';

% predefine column variables
defNaNVariables;

% get file list and number of files
fileList = dir(sprintf('%sN*.msg',msgpath));
nFiles = length(fileList);
for f = 1:nFiles
    subCode = fileList(f).name(1:2);
    msgstr = sprintf('%s%s',msgpath,fileList(f).name);
    msgfid = fopen(msgstr,'r');
    
    fprintf(1,'\nprocessing ... %s\n',fileList(f).name);
    stillTheSameSession = 1;
    tab = [];
    while stillTheSameSession
        
        % predefine critical variables
        defNaNVariables;
        
        stillTheSameTrial = 1;
        while stillTheSameTrial
            
            line = fgetl(msgfid);
            if ~ischar(line)    % end of file
                stillTheSameSession = 0;
                break;
            end
            
            if ~isempty(line) && stillTheSameSession   % skip empty lines
                la = strread(line,'%s');    % array of strings in line
                
                if length(la) >= 3
                    switch char(la(3))
                        case 'TRIALID'
                            trial0 = str2double(char(la(4)));
                        case 'TRIAL_START'
                            trial1 = str2double(char(la(4)));
                        case 'EVENT_FixationDot'
                            tedfFix = str2double(char(la(2)));
                        case 'EVENT_preCueOn'
                            tedfPQ  = str2double(char(la(2)));
                        case 'EVENT_stimOn'
                            tedfSOn = str2double(char(la(2)));
                        case 'EVENT_stimOff'
                            tedfSoff  = str2double(char(la(2)));
                        case 'EVENT_respToneOn'
                            tedfrTone = str2double(char(la(2)));
                        case 'EVENT_ClearScreen'
                            tedfClr = str2double(char(la(2)));
                        case 'TRIAL_ENDE'
                            trial2 = str2double(char(la(4)));
                        case 'TrialData'
                            block  = str2double(char(la(4)));
                            trial3 = str2double(char(la(5)));
                            
                            cond = str2double(char(la(6)));
                            ttype = str2double(char(la(7)));
                            delay = str2double(char(la(8)));
                            tarLoc = str2double(char(la(9)));
                            tarEcc = str2double(char(la(10)));
                            cueEcc = str2double(char(la(11)));
                            gapSz = str2double(char(la(12)));
                            gapLoc = str2double(char(la(13)));
                            sacReq = str2double(char(la(14)));
                            
                            resp = str2double(char(la(15)));                            
                            rCorr  = str2double(char(la(16)));
                            keyR  = str2double(char(la(17)));
                            stairC   = str2double(char(la(18)));
                            
                            tFix    = str2double(char(la(19)));
                            tPQ   = str2double(char(la(20)));
                            tpI   = str2double(char(la(21)));
                            tSOn   = str2double(char(la(22)));
                            tSOf   = str2double(char(la(23)));
                            tRtone   = str2double(char(la(24)));
                            tSac   = str2double(char(la(25)));
                            tRes   = str2double(char(la(26)));
                            tClr  = str2double(char(la(27)));
                            
                            stillTheSameTrial = 0;
                    end
                end
            end
        end
        
        % check if trial ok and all messages available
        if (trial0==trial3 || trial1==trial3) && sum(isnan([(trial0 || trial1) trial3 tedfFix tedfSoff tedfClr]))==0
            everythingAvailable = 1;
        else
            everythingAvailable = 0;
        end
        
        if everythingAvailable
            tedfFix = tedfFix - tedfPQ; % ~-800:-600ms  
            tedfPQ = tedfPQ - tedfSOn; % ~ 
            tedfSoff = tedfSoff - tedfSOn; % ~100ms
            tedfrTone = tedfrTone - tedfSOn; % ~ 600 ms
%             tedfSac = tedfSac - tedfSOn;
            tedfRes = tedfClr - 200 - tedfSOn;
            tedfClr = tedfClr - tedfSOn;
            
            % create uniform data matrix containing any potential
            % information concerning a trial
            tab = [tab; block trial3 cond fixpoy delay tarLoc tarEcc cueEcc gapSz gapLoc sacReq resp rCorr keyR stairC tFix tPQ tpI tSOn tSOf tRtone tSac tRes tedfPQ tedfFix tedfSOn tedfSoff tedfrTone  tedfSac tedfClr tClr keyRT resTil scNum sacReq];
        elseif trial0~=trial3 && trial1~=trial3
            if trial3>0
                fprintf(1,'\nMissing Message between TRIAL_START %i and trialData %i (ignore if last trial)',trial1,trial3);
            end
        end
    end
    fclose(msgfid);
    
    % create tab file if any trial data could be found
    if ~isempty(tab)
        outname = sprintf('%s%s1.tab',tabpath,subCode);
        while 
            
        fout = fopen(outname,'w');
        fprintf(fout,'%i\t%i\t%.2f\t%.2f\t%i\t%i\t%i\t%i\t%i\t%.4f\t%.4f\t%.4f\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\n',tab');
        fclose(fout);
    end
    
    % move file into folder processed/
    unix(sprintf('mv %s %s',msgstr,sprintf('%sprocessed/%s.msg',msgpath,subCode)));
end
fprintf(1,'\n\nOK!!\n');
