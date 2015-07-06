% xmsg2tab.m for GainAdapt
%
% Creates tab-File containing information specified
% for a certain trial.
%
% tab-Files have the following columns
% (predefined by defNaNVariables.m):

clear;

addpath('functions/');

msgpath = '../raw/';
tabpath = '../tab/';

%subfid = fopen('subjects.noFirstRun.all','r')
subfid = fopen('subjects.all','r')
cnt = 1;
while cnt ~= 0
    [vpcode, cnt] = fscanf(subfid,'%s',1);
    if cnt ~= 0
        msgstr = sprintf('%s%s.msg',msgpath,vpcode);
        msgfid = fopen(msgstr,'r');

        fprintf(1,'\nprocessing ... %s.msg',vpcode);
        stillTheSameSubject = 1;
        tab = [];
        while stillTheSameSubject
            % predefine critical variables
            defNaNVariables;

            stillTheSameTrial = 1;
            while stillTheSameTrial

                line = fgetl(msgfid);
                if ~ischar(line)    % end of file
                    stillTheSameSubject = 0;
                    break;
                end

                if ~isempty(line) && stillTheSameSubject % skip empty lines
                    la = strread(line,'%s'); % array of strings in line

  
                    if length(la) >= 3
                        switch char(la(3))
                            case 'TRIAL_START'
                                trial = str2double(char(la(4)));
                            case 'EVENT_FixationDot'
                                tedfFix = str2double(char(la(2)));
                            case 'EVENT_preCueOn'
                                tedfpreCueOn = str2double(char(la(2)));
                            case 'EVENT_preISIOn'
                                tedfpreISIOn = str2double(char(la(2)));
                            case 'EVENT_stimOn'
                                tedfstimOn = str2double(char(la(2)));  
                            case 'EVENT_stimOff'
                                tedfstimOff = str2double(char(la(2)));      
                            case 'EVENT_respToneOn'
                                tedfrespToneOn  = str2double(char(la(2)));
                            case 'EVENT_ClearScreen'
                                tedfClr = str2double(char(la(2)));
                            case 'TRIAL_END'
                                trial2 = str2double(char(la(4)));
                            case 'TrialData'
                                  
                                block       = str2double(char(la(4)));
                                trial3      = str2double(char(la(5)));                                
                                condition   = str2double(char(la(6)));
                                trialType   = str2double(char(la(7)));
                                trialDelay  = str2double(char(la(8)));
                                targetLoc   = str2double(char(la(9))); 
                                targetEcc   = str2double(char(la(10))); 
                                cueEcc      = str2double(char(la(11)));
 
                                gapSize     = str2double(char(la(12))); 
                                gapLocT     = str2double(char(la(13)));
                               
                                sacReq      = str2double(char(la(14)));
                                resp        = str2double(char(la(15))); 
                                cor         = str2double(char(la(16))); 
                                keyRT       = str2double(char(la(17))); 
                                stairCase   = str2double(char(la(18))); 
                                
                                tFix        = str2double(char(la(19)));
                                tpreCueOn   = str2double(char(la(20)));
                                tpreISIOn   = str2double(char(la(21)));
                                tStimOn     = str2double(char(la(22)));
                                tStimOff    = str2double(char(la(23)));
                                trespToneOn = str2double(char(la(24)));

                                tSac         = str2double(char(la(25)));
                                tRes         = 0;
                                %tRes        = str2double(char(la(26)));
                                %tClr        = str2double(char(la(27)));
                                
                                stillTheSameTrial = 0;
                        end
                    end
                end
            end

            %tedfClr% 
            % check if trial ok and all messages available
            if trial==trial3 && sum(isnan([trial trial3 tedfFix tedfpreCueOn tedfpreISIOn tedfstimOn tedfstimOff tedfrespToneOn ]))==0
                everythingAvailable = 1;
            else
                everythingAvailable = 0; 
            end

            if everythingAvailable
                
                tedfpreCueOn    = tedfpreCueOn - tedfFix;
                tedfpreISIOn    = tedfpreISIOn - tedfFix;
                tedfstimOn      = tedfstimOn - tedfFix;
                tedfstimOff     = tedfstimOff - tedfFix;
                tedfrespToneOn  = tedfrespToneOn  - tedfFix;
                %tedfClr        = tedfClr - tedfFix;
                
                % information concerning a trial
                %tab = [tab; block trial condition trialType trialDelay targetLoc targetEcc cueEcc gapSize gapLocT tedfFix tedfpreCueOn tedfpreISIOn tedfstimOn tedfstimOff tedfrespToneOn tSac keyRT resp cor sacReq stairCase];
                tab = [tab; block trial condition trialType trialDelay targetLoc targetEcc cueEcc gapSize gapLocT tedfFix tedfpreCueOn tedfpreISIOn tedfstimOn tedfstimOff tedfrespToneOn tSac keyRT resp cor sacReq stairCase];
            
            elseif trial~=trial2
                %fprintf(1,'\nMissing Message between TRIALID %i and trialData %i (ignore if last trial)',trial,trial2);
            end
        end
        fclose(msgfid);

        outname = sprintf('%s%s.tab',tabpath,vpcode);
        fout = fopen(outname,'w');
        fprintf(fout,'%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\n',tab');  %22
    end
end
fclose(subfid);
fprintf(1,'\n\nOK!!\n');
