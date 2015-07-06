function [nt,ntGood,exclude,plotData] = anaEyeMovements(subCode,exp,sac,plotData)
%
% function [nt,ntGood] = anaEyeMovements(subCode,exp,sac,plotData)
%
% Note that anaEyeMovements. is a multiple purpose function, which is
% adapted for each experiment at some critical places. It is more powerful
% than necessary for any given experiment (allowing for multiple response
% saccades, multiple possible saccade target locations, etc.).
%
% 24. March 2015, by Martin Rolfs

% define exclusion criteria
crit_cols = [2 3];      % columns containing blink information (i.e., -1.0)

%%
if plotData==1
    cout = [0.3 0.3 0.3];
    
    close all;
    figure;
    set(gcf,'pos',[100 100 500 250],'color','w');
    ax(1) = axes('pos',[0.00 0.00 0.50 1.00]);
    ax(2) = axes('pos',[0.58 0.55 0.40 0.35]);
    ax(3) = axes('pos',[0.58 0.15 0.40 0.35]);
end
%%

% create file strings
tabfile = sprintf('tab/%s.tab',subCode);
datfile = sprintf('raw/%s.dat',subCode);
reafile = sprintf('rea/%s.rea',subCode);
btrfile = sprintf('btr/%s.btr',subCode);

% where to move processed dat file
prcfile = sprintf('../raw/processed/%s.dat',subCode);

% WATCH OUT: We define an exception for BF01!!
switch subCode
    case 'BF01'
        exp.scrCen    = [800 540];  % screen center (intial fixation position)
        exp.scrResX   = 1600;
    otherwise
        exp.scrCen    = [640 480];  % screen center (intial fixation position)
        exp.scrResX   = 1280;
end
DPP = pix2deg(exp.scrResX,exp.scrWidth,exp.scrDist,1); % degrees per pixel

% counting variables (output of the function)
nt   = 0;   % number of trials
ntGood=0;   % number of good trials

% exclusion criteria (for up to 100 response saccades)
exclude.sbrs = zeros(1,100);   % saccades > 1 deg before response saccade
exclude.mbrs = zeros(1,100);   % missing data before saccade (blinks)
exclude.nors = zeros(1,100);   % no response saccade
exclude.samp = zeros(1,  1);   % sampling rate error

if exist(tabfile,'file') && exist(datfile,'file')
    fprintf(1,'\n\n\tloading %s ...',subCode);

    dat = load(datfile);
    tab = load(tabfile);
    
    fprintf(1,' preparing\n');
    frea = fopen(reafile,'w');
    fbtr = fopen(btrfile,'w');
    
    for t = 1:size(tab,1) % loop over all trials of this subject
        nt = nt + 1;
        
        % get relevant information from tab file
        block  = tab(t, 1);                 % block number
        trial  = tab(t, 2);                 % trial number
        timRef = tab(t,24);                 % reference time (saccade target onset), t = 0
        fixPos = tab(t,3:4).*[1 -1];        % fixation position
        stiPos = tab(t,8:9).*[1 -1]*DPP;    % stimulus position
        sacReq = tab(t,end);
        if sacReq
            tarPos = [fixPos;[1 -1].*(tab(t,5:6)-exp.scrCen)*DPP];
            aftRef = sac.aftRefSac;
        else
            tarPos = fixPos;
            aftRef = sac.aftRefFix;
        end
        
        % number of response saccades required in this experiment
        nRS = size(tarPos,1)-1;
        
        % reset all rejection criteria
        if nRS > 0
            sbrs = zeros(1,nRS);    % saccades > sac.maxMSAmp before response saccade
            mbrs = zeros(1,nRS);    % missing data points before response saccade
            resp = zeros(1,nRS);    % response saccade detected
            samp = zeros(1,1);      % abnormal sampling rate (normal is exp.sampRate)
        else
            sbrs = zeros(1,1);
            mbrs = zeros(1,1);
            resp = zeros(1,1);
            samp = zeros(1,1);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Analysis of saccadic response times %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        t1 = timRef-sac.befRef;
        t2 = timRef+    aftRef;
        
        % get data in response saccade interval
        idxrs = find(dat(:,1)>=t1 & dat(:,1)<=t2);
        timers = dat(idxrs,1);	% time stamp
        
        % determine sampling rate (differs across
        % trials if something went wrong)
        if ~mod(length(timers),2)   % delete last sample if even number
            timers(end) = [];
            idxrs(end)  = [];
        end
        sampRate = round(1000/mean(diff(timers)));  % sampling rate of recording
        minSampN = sac.minDur*sampRate/1000;            % minimum number of samples
        
        % does sampling rate of recording differ from intended sampling rate?
        if sampRate~=exp.sampRate
            samp = 1;
            exclude.samp = exclude.samp+1;
        end
        
        % get gaze positions, transform them to deg of visual angle, flip y
        xrs = DPP*([dat(idxrs,2)-exp.scrCen(1) -(dat(idxrs,3)-exp.scrCen(2))]);
        
        % compute velocities (with smoothing defined in sac.velType)
        vrs = vecvel(xrs , sampRate, sac.velType);   % velocities
        
        % detect all saccades in the interval, including microsaccades
        mrs = microsaccMerge(xrs,vrs,sac.velSD,minSampN,sac.mergeInt);
        mrs = saccpar(mrs);
        
        % find all potential response saccades (i.e., larger than sac.maxMSAmp)
        if size(mrs,1)>0
            mrs = mrs(mrs(:,7)>sac.maxMSAmp,:);
        end
        nSac = size(mrs,1);
        %%
        if plotData==1
            axes(ax(1));
            cla;
            hold on;
            
            % draw background
            fill([-11 -11 11 11],[-11 11 11 -11],[0.9 0.9 0.9],'EdgeColor','k');
            
            % draw fixation and saccade targets
            x = [tarPos(:,1); stiPos(1)];
            y = [tarPos(:,2); stiPos(2)];
            for i = 1:length(x)
                xs = x(i) + sac.tarRad*cos(-pi:pi/360:pi);
                ys = y(i) + sac.tarRad*sin(-pi:pi/360:pi);
                
                line(xs,ys,'color',cout,'linewidth',1,'linestyle','--');
            end
            
            % turn smooth velocity signal into
            sxrs = smoothdata(xrs);
            plot(sxrs(:,1),sxrs(:,2),'k-','color',[0.5 0.5 0.5]);
            for i = 1:size(mrs,1)
                plot(sxrs(mrs(i,1):mrs(i,2),1),sxrs(mrs(i,1):mrs(i,2),2),'r-','linewidth',2);
            end
            if ~isempty(mrs)
                plot([sxrs(mrs(:,1),1) sxrs(mrs(:,2),1)]',[sxrs(mrs(:,1),2) sxrs(mrs(:,2),2)]','r.');
            end
            
            axes(ax(2));
            cla;
            hold on;
            plot(timers-timRef,vrs(:,1),'k-');
            for i = 1:size(mrs,1)
                plot(timers(mrs(i,1):mrs(i,2))-timRef,vrs(mrs(i,1):mrs(i,2),1)','r-','linewidth',2);
            end
            xlim([-sac.befRef aftRef]);
            ylim([-100 400]);
            ylabel('x velocity [\\circ/s]');
            set(gca,'XTickLabel',{});
            
            axes(ax(3));
            cla;
            hold on;
            plot(timers-timRef,vrs(:,2),'k-');
            for i = 1:size(mrs,1)
                plot(timers(mrs(i,1):mrs(i,2))-timRef,vrs(mrs(i,1):mrs(i,2),2)','r-','linewidth',2);
            end
            xlim([-sac.befRef aftRef]);
            ylim([-100 400]);
            xlabel('Time re. target onset [ms]')
            ylabel('y velocity [\\circ/s]')
        end
        %%
        
        % loop over all response saccades required in this experiment and find
        % the actual response saccade for each one
        s = 0;
        if sacReq
            for rs = 1:nRS
                fixRec = repmat(tarPos(rs  ,:),1,2)+[-sac.tarRad -sac.tarRad sac.tarRad sac.tarRad];
                tarRec = repmat(tarPos(rs+1,:),1,2)+[-sac.tarRad -sac.tarRad sac.tarRad sac.tarRad];
                
                % check for response saccade
                reaSacNumber = 0;
                if s<nSac
                    while ~resp(rs) && s<nSac
                        s = s+1;
                        xBeg  = xrs(mrs(s,1),1);    % initial eye position x
                        yBeg  = xrs(mrs(s,1),2);	% initial eye position y
                        xEnd  = xrs(mrs(s,2),1);    % final eye position x
                        yEnd  = xrs(mrs(s,2),2);	% final eye position y
                        
                        % is saccade out of fixation area?
                        if ~resp(rs)
                            fixedFix = isincircle(xBeg,yBeg,fixRec);
                            fixedTar = isincircle(xEnd,yEnd,tarRec);
                            if fixedTar && fixedFix
                                reaSacNumber = s;   % which saccade after cue went to target
                                reaLoc = fixedTar;  % which target location did saccade go to (if multiple)
                                resp(rs) = 1;
                            end
                        end
                        
                        %%
                        if plotData==1
                            if resp(rs)
                                axes(ax(1));
                                plot([xBeg xEnd],[yBeg yEnd],'ko','color',[0 0 0],'markersize',8,'linewidth',2);
                                axes(ax(2));
                                plot(timers(mrs(s,1:2))-timRef,vrs(mrs(s,1:2),1),'ko','color',[0 0 0],'markersize',8,'linewidth',2);
                                axes(ax(3));
                                plot(timers(mrs(s,1:2))-timRef,vrs(mrs(s,1:2),2),'ko','color',[0 0 0],'markersize',8,'linewidth',2);
                            end
                        end
                        %%
                    end
                end
                
                if ~resp(rs)
                    exclude.nors(rs) = exclude.nors(rs) + 1;
                    
                    sacType    = 0;    % 0 = no response; 1 = microsaccade; 2 = large saccade; 3 = no saccade task
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
                else
                    % compile reaSac data
                    sacType    = rs+1; % 0 = no response; 1 = microsaccade; 2 = large saccade; 3 = second large saccade; ...
                    sacOnset   = timers(mrs(reaSacNumber,1))-timRef;
                    sacOffset  = timers(mrs(reaSacNumber,2))-timRef;
                    sacDur     = mrs(reaSacNumber,3)*1000/sampRate;
                    sacVPeak   = mrs(reaSacNumber,4);
                    sacDist    = mrs(reaSacNumber,5);
                    sacAngle1  = mrs(reaSacNumber,6);
                    sacAmp     = mrs(reaSacNumber,7);
                    sacAngle2  = mrs(reaSacNumber,8);
                    sacxOnset  = xrs(mrs(reaSacNumber,1),1);
                    sacyOnset  = xrs(mrs(reaSacNumber,1),2);
                    sacxOffset = xrs(mrs(reaSacNumber,2),1);
                    sacyOffset = xrs(mrs(reaSacNumber,2),2);
                    if rs>1
                        sacRT = sacOnset-reaSac(rs-1,5);
                    else
                        sacRT = sacOnset;
                    end
                end
                
                reaSac(rs,:) = [sacRT reaSacNumber sacType sacOnset sacOffset sacDur, ...
                    sacVPeak sacDist sacAngle1 sacAmp sacAngle2 sacxOnset, ...
                    sacyOnset sacxOffset sacyOffset];
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % saccades before current response saccade %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if reaSacNumber>rs
                    sbrs(rs) = 1;
                    exclude.sbrs(rs) = exclude.sbrs(rs)+1;
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % missings before current response saccade %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if resp(rs)
                    if rs == 1
                        t1 = timRef-sac.befRef;     % stimulus onset (ans some time before)
                        t2 = timRef+sacRT+sacDur;   % end of saccade period
                    else
                        t1 = timRef+reaSac(rs-1,5); % offset of last saccade
                        t2 = t1+sacRT+sacDur;       % end of saccade period
                    end
                    
                    % get index for current data period
                    idx = dat(:,1)>=t1 & dat(:,1)<t2;
                    
                    % Trials with missings from fixein to response go
                    idxmbrs = dat(idx,crit_cols)==-1;
                    if sum(idxmbrs)>0
                        mbrs(rs) = 1;
                        exclude.mbrs(rs) = exclude.mbrs(rs) + 1;
                    end
                end
            end
        elseif ~sacReq
            sacType    = 3;    % 0 = no response; 1 = microsaccade; 2 = large saccade; 3 = no saccade task
            reaSacNumber = NaN;
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
            
            reaSac = [sacRT reaSacNumber sacType sacOnset sacOffset sacDur, ...
                sacVPeak sacDist sacAngle1 sacAmp sacAngle2 sacxOnset, ...
                sacyOnset sacxOffset sacyOffset];
            
            % saccades in the critical time window
            if nSac>0
                sbrs = 1;
                exclude.sbrs(1) = exclude.sbrs(1)+1;
            end
            
            % Missings in the critical time window
            idxmbrs = dat(idxrs,crit_cols)==-1;
            if sum(idxmbrs)>0
                mbrs = 1;
                exclude.mbrs(1) = exclude.mbrs(1) + 1;
            end
        end
        
        %%
        if plotData==1
            axes(ax(1));
            hold on;
            xlim([-12 12]);
            ylim([-12 12]);
            text(-10,9,sprintf('Block %i, Trial %i',block,trial),'Fontsize',14,'hor','left','ver','bottom');
            
            if sacReq
                condStr = 'Saccade';
            else
                condStr = 'Fixation';
            end
            if sum(sbrs)==0 && sum(mbrs)==0 && sum(resp)==nRS
                text(-10,9,sprintf('%s: good',condStr),'Fontsize',14,'hor','left','ver','top');
            else
                text(-10,9,sprintf('%s: bad',condStr),'Fontsize',14,'hor','left','ver','top');
            end
            
            set(gca,'visible','off');
            
            % allow for user interaction: next trial by mouse click
            if waitforbuttonpress
                switch get(gcf,'CurrentCharacter')
                    case 'q'    % quit plotting data alltogether
                        plotData = 0;
                    case 'p'    % print current figure
                        exportfig(gcf,sprintf('figures/%s_Block%i_Trial%i.eps',subCode,block,trial),'FontMode','fixed','Width',8);
                    otherwise   % quit plotting data for this file
                        plotData = 2;
                end
            end
            cla;
        end
        %%
        
        % evaluate rejection criteria (no trials excluded at this stage)
        if 1; % sum(sbrs)==0 && sum(mbrs)==0 && sum(resp)==nRS
            rea = [tab(t,:) reaSac];
            
            % this is what you need in addition to the tab format:
            % %i\t%i\t%i\t%i\t%i\t%i\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n
            fprintf(frea,'%i\t%i\t%.2f\t%.2f\t%i\t%i\t%i\t%i\t%i\t%.4f\t%.4f\t%.4f\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n',rea');
            
            ntGood = ntGood + 1;
        end
        fprintf(fbtr,'%i\t%i\t%i\t%i\t%i\t%i\n',block,trial,sbrs,mbrs,~resp,samp);
    end
    fclose(frea);
    fclose(fbtr);
    
    fprintf(1,'\t Number of trials processed:\t%3.0f\n',nt);
    fprintf(1,'\t Number of trials accepted :\t%3.0f\n',ntGood);
    fprintf(1,'\t Trials wrong sampling rate:\t%3.0f\n',exclude.samp);
    if nRS>0
        for rs = 1:nRS
            fprintf(1,'\n\t Response saccade %i:\n\t  Sacc bef resp sacc  :\t\t%3.0f\n\t  Miss bef resp sacc  :\t\t%3.0f\n\t  No saccade detected :\t\t%3.0f\n',rs,exclude.sbrs(rs),exclude.mbrs(rs),exclude.nors(rs));
        end
    else
        fprintf(1,'\n\t No response saccade:\n\t  Sacc during fixation:\t\t%i\n\t  Miss during fixation:\t\t%i\n',exclude.sbrs(1),exclude.mbrs(1));
    end
else
    if ~exist(tabfile,'file')
        fprintf(1,'\n\tFile %s does not exist!',tabfile);
    end
    if ~exist(datfile,'file')
        fprintf(1,'\n\tFile %s does not exist!',datfile);
    end
end

% move file into folder processed/
unix(sprintf('mv %s %s',datfile,prcfile));

% set plotData to 0 or 1 for output
plotData = plotData>0;
