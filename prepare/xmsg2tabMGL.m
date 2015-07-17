%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Get Timing Info from EDF File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
clear;

maxTrial = 48 %2 blocks of 24

addpath('functions/');

msgpath = '../raw/';
tabpath = '../tab/';    

subfid = fopen('subjects.all,'r');
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

                if ~isempty(line) && stillTheSameSubject   % skip empty lines
                    la = strread(line,'%s');    % array of strings in line

                    if length(la) >= 5
                        switch char(la(5))
                            case 'TRIAL'  %TRIAL_START                                
                                trialNum = str2double(char(la(6)));
                                tedfStart = str2double(char(la(2)));
                               case 'SEGMENT'
                                    switch char(la(6))
                                        case '1'
                                            tedfSEG1 = str2double(char(la(2)));
                                        case '2'
                                            tedfSEG2 = str2double(char(la(2)));
                                        case '3'
                                            tedfSEG3 = str2double(char(la(2)));
                                        case '4'
                                            tedfSEG4 = str2double(char(la(2)));
                                        case '5'
                                            tedfSEG5 = str2double(char(la(2)));
                                        case '6'
                                            tedfSEG6 = str2double(char(la(2)));
                                        case '7'
                                            tedfSEG7 = str2double(char(la(2)));
                                        case '8'
                                            tedfSEG8 = str2double(char(la(2)));
                                        case '9'
                                            tedfSEG9 = str2double(char(la(2)));
                                     stillTheSameTrial = 0;
                                    end 
                        end
                    end
                end
            end %while stillTheSameTrial
            
            tedfSEG1 = tedfSEG1 - tedfStart;
            tedfSEG2 = tedfSEG2 - tedfStart;
            tedfSEG3 = tedfSEG3 - tedfStart;
            tedfSEG4 = tedfSEG4 - tedfStart;
            tedfSEG5 = tedfSEG5 - tedfStart;
            tedfSEG6 = tedfSEG6 - tedfStart;
            tedfSEG7 = tedfSEG7 - tedfStart;
            tedfSEG8 = tedfSEG8 - tedfStart;
            tedfSEG9 = tedfSEG9 - tedfStart;
        
            tab = [tab; tedfStart, tedfSEG1,tedfSEG2,tedfSEG3,tedfSEG4,tedfSEG5,tedfSEG6,tedfSEG7,tedfSEG8,tedfSEG9];
                  
        end %while stillTheSameSubject
        
        tab = tab(1:maxTrial,:); %Cut off junk at end of file  
        fclose(msgfid);

        outname = sprintf('%s%sEDF.tab',tabpath,vpcode);
        fout = fopen(outname,'w');
        fprintf(fout,'%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\n',tab');
        fclose(fout);
    end
end


fclose(subfid);
fprintf(1,'\n\nOK!!\n');
