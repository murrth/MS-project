clear;

addpath('functions/');

tabpath = '../tab/';

% get file list and number of files
fileList = dir(sprintf('%s*.tab',tabpath));
nFiles = length(fileList);

% predefine subject initials
subjCounter(1) = 1;
subjInitial{1} = fileList(1).name(1:2);
subjSession(1) = 1;

% open file for subject data
subfid = fopen('subjectList_Saccade.txt','w');
fprintf(subfid,'ID\tInitial\tnSession\tsaccDir\ttransPos\ttransOri\n');

for f = 2:nFiles
    subjInitial{f} = fileList(f).name(1:2); %#ok<*SAGROW>
    if strcmp(subjInitial{f},subjInitial{f-1})
        subjSession(f) = subjSession(f-1) + 1;
        subjCounter(f) = subjCounter(f-1);
    else
        subjSession(f) = 1;
        subjCounter(f) = subjCounter(f-1) + 1;
    end
    if subjSession(f) == 1 && f<nFiles
        % print out subject counter, initials, and number of sessions
        fprintf(subfid,'%i\t%s\t%i\t',subjCounter(f-1),char(subjInitial{f-1}),subjSession(f-1));
        
        % load first session's data to identify experimental condition
        sessData = load(sprintf('%s%s',tabpath,fileList(f-subjSession(f-1)).name));
        if isempty(sessData)
            stiOriF = NaN;
        else
            stiOriF = sessData(1,10);    % stimulus orientation (first session)
        end
        
        % load last session's data to identify experimental condition
        sessData = load(sprintf('%s%s',tabpath,fileList(f-1).name));
        tarPosL = sessData(1, 7);    % saccade direction (1=down, 2=right)
        stiOriL = sessData(1,10);    % stimulus orientation (last session)
        stiPosL = sessData(1,13);    % transfer location (1=remapped, 2=control, 3=trained)
        
        % determine saccade direction
        switch tarPosL
            case 0
                saccDir = ' none';
            case 1
                saccDir = ' down';
            case 2
                saccDir = 'right';
            otherwise
                saccDir = 'undef';
        end
        % determine position during transfer phase
        switch stiPosL
            case 1
                transPos = 'remap';
            case 2
                transPos = 'contr';
            case 3
                transPos = 'train';
            otherwise
                transPos = 'undef';
        end
        % determine orientation during transfer phase
        if round(stiOriF/pi*180) - round(stiOriL/pi*180)==0
            transOri = 'same';
        else
            transOri = 'diff';
        end
        % add experimental condition to output
        fprintf(subfid,'%s\t%s\t%s\n',saccDir,transPos,transOri);
    elseif f==nFiles
        % print out subject counter, initials, and number of sessions
        fprintf(subfid,'%i\t%s\t%i\t',subjCounter(f),char(subjInitial{f}),subjSession(f));

        % load first session's data to identify experimental condition
        sessData = load(sprintf('%s%s',tabpath,fileList(f-subjSession(f)+1).name));
        tarPosF = sessData(1, 7);    % saccade direction (1=down, 2=right)
        stiOriF = sessData(1,10);    % stimulus orientation (first session)
        
        % load last session's data to identify experimental condition
        sessData = load(sprintf('%s%s',tabpath,fileList(f).name));
        stiOriL = sessData(1,10);    % stimulus orientation (last session)
        stiPosL = sessData(1,13);    % transfer location (1=remapped, 2=control, 3=trained)
        
        % determine saccade direction
        switch tarPosF
            case 0
                saccDir = ' none';
            case 1
                saccDir = ' down';
            case 2
                saccDir = 'right';
            otherwise
                saccDir = 'undef';
        end
        % determine position during transfer phase
        switch stiPosL
            case 1
                transPos = 'remap';
            case 2
                transPos = 'contr';
            case 3
                transPos = 'train';
            otherwise
                transPos = 'undef';
        end
        % determine orientation during transfer phase
        if round(stiOriF/pi*180) - round(stiOriL/pi*180)==0
            transOri = 'same';
        else
            transOri = 'diff';
        end
        % add experimental condition to output
        fprintf(subfid,'%s\t%s\t%s\n',saccDir,transPos,transOri);
    end
end
fclose(subfid);
