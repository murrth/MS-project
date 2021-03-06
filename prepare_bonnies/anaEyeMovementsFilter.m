%remove data.txt if present
delete('data.txt')
tabfold='../tab/';
datfold='../raw/';
fileList=dir(sprintf('%s*.dat',datfold));
% sfid = fopen('subjects.all','r');
   
%%
if plotData
    sl = 5;     % box side length
    fp = 0.6;   % fixation point width
    ec = 10.0;  % eccentricity
    cl = 0.2;   % cue length
    
    cout = [0.3 0.3 0.3];
    cbac = [1.0 1.0 1.0];
    
    close all;
    figure;
    set(gcf,'pos',[100 100 1000 500],'color',cbac);
    ax(1) = axes('pos',[0 0 0.5 1]);
    ax(2) = axes('pos',[0.5 0.5 0.5 0.5]);
    ax(3) = axes('pos',[0.5 0.0 0.5 0.5]);
end
%%

ntGoodAll = 0;
ntBadAll = 0;

cnt = 1;
exsubject = '';
sub = 0;
ses = 0;
%nSac = 0;

while cnt ~= 0  % Schleife ueber alle VPs (All Subjects)
    [vpcode, cnt] = fscanf(sfid,'%s',1);
    if cnt ~= 0
                       
        subject = vpcode(13:14);               
        
        if ~strcmp(subject,exsubject)
            sub = sub+1;
            ses = 1;
        else
            ses = ses + 1;        
        end
        
        % create file strings
        tabfile = sprintf('../tab/%s.tab',vpcode);
        datfile = sprintf('../raw/%s.dat',vpcode);
        
        if ~exist(tabfile,'file')
            fprintf(1,'\n\tDatei %s existiert nicht!',tabfile);
        end
        if ~exist(datfile,'file')
            fprintf(1,'\n\tDatei %s existiert nicht!',datfile);
        end
        
        fprintf(1,'\n\n\tloading %s ...',vpcode);
        
        tab = load(tabfile);
        dat = load(datfile);
                
        fprintf(1,' preparing\n');
       
        % counting variables
        nt   = 0;   % number of trials
        ntGood=0;   % number of good trials
        
        % exclusion criteria (for up to 100 response saccades)
        ex.sbrs = zeros(1,100);   % saccades > 1 deg before response saccade
        ex.mbrs = zeros(1,100);   % Missing before saccade (blinks)
        ex.nors = zeros(1,100);   % no response saccade
        ex.samp = zeros(1,  1);   % sampling rate error
        ex.loss = zeros(1,  1);   % Data loss before saccade (blinks)
                
        for t = 1:size(tab,1) % Schleife ueber alle Trials der VP (All Trials per Subject)
            nt = nt + 1;
            
            block           = tab(t,1);
            trial           = tab(t,2);            
            tFixOnEDF       = tab(t,8); %trial start
            tEDFpreCueOn    = tFixOnEDF+tab(t,9);    
%             tEDFpreISIOn    = tFixOnEDF+tab(t,10); removed!
            tEDFstimOn      = tFixOnEDF+tab(t,10);
            tEDFstimOff     = tFixOnEDF+tab(t,11);
            tEDFrespTone    = tFixOnEDF+tab(t,12);
            tEDFClr         = tFixOnEDF+tab(t,13);
            
            sacReq = 0;%1; %(maybe change to checkMicroSaccade)
            nRS = 0; %1; %size(tarPos,1)-1; % nRS is 0 if no saccade required
            
            % reset all rejection criteria
            if nRS > 0
                sbrs = zeros(1,nRS);
                mbrs = zeros(1,nRS);
                resp = zeros(1,nRS);
                loss = zeros(1,1);
                samp = zeros(1,1);
            else
                sbrs = zeros(1,1);
                mbrs = zeros(1,1);
                resp = zeros(1,1);
                loss = zeros(1,1);
                samp = zeros(1,1);
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Analysis of saccadic response times %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%% get data in response time interval %%%%%%%%%
            
            if sacReq == 1
                idxrs = find(dat(:,1)>=tFixOnEDF & dat(:,1)<=tEDFClr); %trial marker
            end
            
            timers = dat(idxrs,1);	% time stamp
            
            % actual sampling rate in recorded data
            samrat = round(1000/mean(diff(timers)));
            minsam = minDur*samrat/1000;
            
            if length(timers)<length(tFixOnEDF:SAMPRATE/samrat:tEDFClr) %trial marker
                loss = 1;
                ex.loss = ex.loss + 1;
            else
                % determine sampling rate (differs across trials if something went wrong)
                if ~mod(length(timers),2)   % delete last sample if even number
                    timers(end) = [];
                    idxrs(end)  = [];
                end
                if 0 %samrat<SAMPRATE
                    samp = 1;
                    ex.samp = ex.samp+1;
                end
                
                %% if ~samp
                xrsf = DPP*([dat(idxrs,2)-scrCen(1) -(dat(idxrs,3)-scrCen(2))]); % eye position
                
                %%%%%%%%% filter eye movement data %%%%%%%%%              
                clear xrs;
                xrs(:,1) = filtfilt(fir1(35,0.05*SAMPRATE/samrat),1,xrsf(:,1));% zero phase digital filter & FIR (gaussian) 
                xrs(:,2) = filtfilt(fir1(35,0.05*SAMPRATE/samrat),1,xrsf(:,2));
                
                %%%%%%%%% derive velocity %%%%%%%%%
                vrs = vecvel(xrs, samrat, VELTYPE); %filtered
                vrsf= vecvel(xrsf, samrat, VELTYPE);%unfiltered

                %%%%%%%%% search for microsaccades %%%%%%%%%
                mrs = microsaccMerge(xrs,vrs,velSD,minsam,mergeInt);% loops through all possible saccades in a trial
                mrs = saccpar(mrs);% calculate onset,offset, duration, vPeak, dist, angd, ampl, anga
 
                if size(mrs,1)>0                    
                    onset = mrs(:,1);
                    offset = mrs(:,2);
                    duration = mrs(:,3);
                    vPeak = mrs(:,4);
                    amp = mrs(:,7);
                    mrs = mrs(amp<=maxMSAmp,:);%take microsaccades                                                
                end
                
                %%%%%%%%% total number of microsaccades per trial %%%%%%%%%
                nSac = size(mrs,1);
                
                %%
                if plotData
                    axes(ax(1));
                    hold off;
                    xs = 0 + [-sl -sl sl sl -sl]/2;
                    ys = 0 + [-sl sl sl -sl -sl]/2;
                    line(xs,ys,'color',cout,'linewidth',2);
                    hold on;
                    
                    [x,y] = pol2cart(0:pi:pi,ec);
                    
                    for i = 1:length(x)
                        xs = x(i) + [-sl -sl sl sl -sl]/2;
                        ys = y(i) + [-sl sl sl -sl -sl]/2;
                        
                        line(xs,ys,'color',cout,'linewidth',2);
                    end
                    
                    sxrs = smoothdata(xrs); %smooth data calls vecvel
                    plot(sxrs(:,1),sxrs(:,2),'k-','color',[0.5 0.5 0.5]);

                    %Plot Eye Position (left half of plot)
                    for i = 1:size(mrs,1)
                        plot(sxrs(mrs(i,1):mrs(i,2),1),sxrs(mrs(i,1):mrs(i,2),2),'r-','linewidth',2);
                    end
                    if ~isempty(mrs)
                        plot([sxrs(mrs(:,1),1) sxrs(mrs(:,2),1)]',[sxrs(mrs(:,1),2) sxrs(mrs(:,2),2)]','r.');
                    end
                    
                    %Plot filtered and unfiltered horizontal velocity traces
                    axes(ax(2));
                    plot(timers-tFixOnEDF,vrsf(:,1),'k-','color',[0.6 0.6 0.6]); %trial marker
                    hold on;
                    plot(timers-tFixOnEDF,vrs(:,1),'g-'); %trial marker
                    for i = 1:size(mrs,1)
                        plot(timers(mrs(i,1):mrs(i,2))-tFixOnEDF,vrs(mrs(i,1):mrs(i,2),1)','r-','linewidth',2); %trial marker
                    end
                    hold off;
                    xlim(timers([1 end])-tFixOnEDF); %trial marker
                    ylim([-1000 1000]);
                    
                    %Plot filtered and unfiltered vertical velocity traces
                    axes(ax(3));
                    plot(timers-tFixOnEDF,vrsf(:,2),'k-','color',[0.6 0.6 0.6]); %trial marker
                    hold on;
                    plot(timers-tFixOnEDF,vrs(:,2),'g-'); %trial marker
                    for i = 1:size(mrs,1)
                        plot(timers(mrs(i,1):mrs(i,2))-tFixOnEDF,vrs(mrs(i,1):mrs(i,2),2)','r-','linewidth',2); %trial marker
                    end
                    hold off;
                    xlim(timers([1 end])-tFixOnEDF); %trial marker
                    ylim([-1000 1000]);
                end
                
            end %length(timers)<length(tFixOnEDF:SAMPRATE/samrat:tProOnEDF) %bl
            %%
            
            %%%%%%%%% loop over all microsaccades (nSac) in a trial %%%%%%%%% 
            s = 0;
            nRS = nSac; %BL
            
            if nRS ==0 && ~loss %if no microsaccade
                
                rs=1;
                reaSacNumber = 0;
                sacType    = 0;    % 0 = no response; 1 = microsaccade; 2 = large saccade; 3 = no saccade task
                sacOnset   = 0;
                sacOffset  = 0;
                sacDur     = 0;
                sacVPeak   = 0;
                sacDist    = 0;
                sacAngle1  = 0;
                sacAmp     = 0;
                sacAngle2  = 0;
                sacxOnset  = 0;
                sacyOnset  = 0;
                sacxOffset = 0;
                sacyOffset = 0;
                sacRT      = 0;    
                
                sacRT = sacOnset;
                    
                reaSac(rs,:) = [reaSacNumber sacType sacOnset sacOffset sacDur, ...
                    sacVPeak sacDist sacAngle1 sacAmp sacAngle2 sacxOnset, ...
                    sacyOnset sacxOffset sacyOffset];
                
                %include trial information here from tab
                data = horzcat(sub, ses, tab(t,:), t, reaSac(rs,:));  %<<<<,add block # here
                
                %rea = [repmat(tab(t,:),nRS,1) reaSac];
                
                dlmwrite('data.txt', data, '-append', 'delimiter', '\t', 'precision', 8)
                
            end
            
            if sacReq == 1 && ~loss
                for rs = 1:nRS % (for each microsaccade detected...)
                    
                    reaSacNumber = rs;
                    resp(rs) = 1;
                 
                     s = s+1;
                     %onset = timers(mrs(s,1))-tProOnEDF;
                     onset = timers(mrs(s,1))-tFixOnEDF; %tStanOnEDF; %BL 
                     xBeg  = xrs(mrs(s,1),1); % initial eye position x
                     yBeg  = xrs(mrs(s,1),2); % initial eye position y
                     xEnd  = xrs(mrs(s,2),1); % final eye position x
                     yEnd  = xrs(mrs(s,2),2); % final eye position y

                    
                    %%
                    if plotData
                        axes(ax(1));
                        if resp(rs)
                            plot([xBeg xEnd],[yBeg yEnd],'ko','color',[0 0 0],'markersize',8,'linewidth',2);
                        end
                    end
                    %%
                                        
                    % compile reaSac data
                    sacType    = 1; % 0 = no response; 1 = microsaccade; 2 = large saccade; 3 = second large saccade
                    sacOnset   = timers(mrs(reaSacNumber,1))-tFixOnEDF; %trial marker
                    sacOffset  = timers(mrs(reaSacNumber,2))-tFixOnEDF; %trial marker
                    sacDur     = mrs(reaSacNumber,3)*1000/samrat;
                    sacVPeak   = mrs(reaSacNumber,4);
                    sacDist    = mrs(reaSacNumber,5);
                    sacAngle1  = mrs(reaSacNumber,6);
                    sacAmp     = mrs(reaSacNumber,7);
                    sacAngle2  = mrs(reaSacNumber,8);
                    sacxOnset  = xrs(mrs(reaSacNumber,1),1);
                    sacyOnset  = xrs(mrs(reaSacNumber,1),2);
                    sacxOffset = xrs(mrs(reaSacNumber,2),1);
                    sacyOffset = xrs(mrs(reaSacNumber,2),2);
 
                    sacRT = sacOnset;
                    
                    reaSac(rs,:) = [reaSacNumber sacType sacOnset sacOffset sacDur, ...
                        sacVPeak sacDist sacAngle1 sacAmp sacAngle2 sacxOnset, ...
                        sacyOnset sacxOffset sacyOffset];
                    
                    %WILL WANT TO INCLUDE  trial information here from tab
                    
                    data = horzcat(sub, ses, tab(t,:), t, reaSac(rs,:));
                    %data = horzcat(sub, t, reaSac(rs,:))
                    dlmwrite('data.txt', data, '-append', 'delimiter', '\t', 'precision', 8)

                    
                end
                
            elseif ~loss
                rs = NaN;
                reaSacNumber = 0;
                sacType    = 3;    % 0 = no response; 1 = microsaccade; 2 = large saccade; 3 = no saccade task
                sacOnset   = NaN;
                sacOffset  = NaN;
                sacDur     = NaN;
                sacVPeak   = NaN;
                sacDist    = NaN;
                sacAngle1  = NaN;
                sacAmp     = NaN;
                sacAngle2  = NaN;
                sacxOnset  = NaN;
                sacyOnset  = NaN;
                sacxOffset = NaN;
                sacyOffset = NaN;
                sacRT      = NaN;
                
                reaSac = [reaSacNumber sacType sacOnset sacOffset sacDur, ...
                    sacVPeak sacDist sacAngle1 sacAmp sacAngle2 sacxOnset, ...
                    sacyOnset sacxOffset sacyOffset];
                
                %include trial information here from tab
                %data = horzcat(sub, t, reaSac(rs,:))
                data = horzcat(sub, ses, tab(t,:), t, reaSac(rs,:));
                dlmwrite('data.txt', data, '-append', 'delimiter', '\t', 'precision', 8)

            
            end % if sacReq == 1 && ~loss
            
            %%
            if plotData
                axes(ax(1));
                hold on;
                xlim([-15 15]);
                ylim([-15 15]);
                text(-14,-14,sprintf('Trial %i',trial),'Fontsize',14,'hor','left','ver','bottom');
                
                switch sacReq
                    case 1
                        condStr = 'Saccade';
                    case 0
                        condStr = 'Covert';
                    case -1
                        condStr = 'Neutral';
                end
                
                if sum(sbrs)==0 && sum(mbrs)==0 && sum(resp)==nRS % && samp==0
                    text(0,-14,sprintf('%s: good',condStr),'Fontsize',14,'hor','center','ver','bottom');
                else
                    text(0,-14,sprintf('%s: bad',condStr),'Fontsize',14,'hor','center','ver','bottom');
                end
                
                set(gca,'visible','off');
                if waitforbuttonpress
                    plotData = 0;
                end
                cla;
            end
            %% end % this would be the end for if ~samp

        end  %for t = 1:size(tab,1) 
                
        exsubject = subject;
               
    end %if cnt ~= 0  
end %while cnt ~= 0 




