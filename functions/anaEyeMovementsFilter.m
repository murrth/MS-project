if welche == 1
    sfid = fopen('subjects.all','r');
else
    sfid = fopen('subjects.tmp','r');
end

%%
if plotData
    cout = [0.3 0.3 0.3];
    
    close all;
    figure;
    set(gcf,'pos',[100 100 1000 500],'color','w');
    ax(1) = axes('pos',[0 0 0.5 1]);
    ax(2) = axes('pos',[0.5 0.5 0.5 0.5]);
    ax(3) = axes('pos',[0.5 0.0 0.5 0.5]);
end
%%

ntGoodAll = 0;
ntBadAll = 0;
vp = 0;
cnt = 1;
while cnt ~= 0  % Schleife ueber alle VPs
    [vpcode, cnt] = fscanf(sfid,'%s',1);
    if cnt ~= 0
        vp = vp + 1;
        
        % create file strings
        tabfile = sprintf('../tab/%s.tab',vpcode);
        datfile = sprintf('../raw/%s.dat',vpcode);
        reafile = sprintf('../rea/%s_V%iD%iT%iS%i.rea',vpcode,velSD,minDur,VELTYPE,SAMPRATE);
        btrfile = sprintf('../btr/%s_V%iD%iT%iS%i.btr',vpcode,velSD,minDur,VELTYPE,SAMPRATE);
        
        
        % WATCH OUT: We define an exception!!
        switch vpcode
            case 'BF01'
                scrCen    = [800 540];  % screen center (intial fixation position)
                MO_WIDE   = 1600;
            otherwise
                scrCen    = [640 480];  % screen center (intial fixation position)
                MO_WIDE   = 1280;
        end
        DPP = pix2deg(MO_WIDE,MO_PHYS,ABSTAND,1); % degrees per pixel
        PPD = deg2pix(MO_WIDE,MO_PHYS,ABSTAND,1); % pixels per degree
        
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
        frea = fopen(reafile,'w');
        fbtr = fopen(btrfile,'w');
        
        % counting variables
        nt   = 0;   % number of trials
        ntGood=0;   % number of good trials
        
        % exclusion criteria (for up to 100 response saccades)
        ex.sbrs = zeros(1,100);   % saccades > 1 deg before response saccade
        ex.mbrs = zeros(1,100);   % Missing before saccade (blinks)
        ex.nors = zeros(1,100);   % no response saccade
        ex.samp = zeros(1,  1);   % sampling rate error
        for t = 1:size(tab,1) % Schleife ueber alle Trials der VP
            nt = nt + 1;
            
            block = tab(t,1);
            trial = tab(t,2);
            
            tTarOnEDF = tab(t,24);  % time of saccade target onset
            tStiOfEDF = tab(t,29);  % time of stimulus offset
            
            % the reference time is at t = 0
            tReference = tTarOnEDF;
            timBefRef  = timBefTar;
            
            % get relevant positions and flip y axis
            fixPos = tab(t,3:4).*[1 -1];
            sacReq = tab(t,end);
            if sacReq
                tarPos = [fixPos;[1 -1].*(tab(t,5:6)-scrCen)*DPP];
                timAftRef = maxRT;
            else
                tarPos = fixPos;
                timAftRef = tStiOfEDF;
            end
            stiPos = [1 -1].*(tab(t,8:9))*DPP;
            nRS    = size(tarPos,1)-1;
            
            % reset all rejection criteria
            if nRS > 0
                sbrs = zeros(1,nRS);
                mbrs = zeros(1,nRS);
                resp = zeros(1,nRS);
                samp = zeros(1,1);
            else
                sbrs = zeros(1,1);
                mbrs = zeros(1,1);
                resp = zeros(1,1);
                samp = zeros(1,1);
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Analysis of saccadic response times %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            t1 = tReference-timBefRef;
            t2 = tReference+timAftRef;
            
            % get data in response saccade interval 
            idxrs = find(dat(:,1)>=t1 & dat(:,1)<=t2);
            timers = dat(idxrs,1);	% time stamp
            
            % determine sampling rate (differs across
            % trials if something went wrong)
            if ~mod(length(timers),2)   % delete last sample if even number
                timers(end) = [];
                idxrs(end)  = [];
            end
            samrat = round(1000/mean(diff(timers)));
            minsam = minDur*samrat/1000;
            if 0 %samrat<SAMPRATE
                samp = 1;
                ex.samp = ex.samp+1;
            end
            
            %%% if ~samp
            % get gaze positions, transform them to deg of visual
            % angle, and flip y axis.
            xrs = DPP*([dat(idxrs,2)-scrCen(1) -(dat(idxrs,3)-scrCen(2))]);    % positions
            
            % filter eye movement data
            clear xrsf;
            try
                xrsf(:,1) = filtfilt(fir1(35,0.05*SAMPRATE/samrat),1,xrs(:,1));
                xrsf(:,2) = filtfilt(fir1(35,0.05*SAMPRATE/samrat),1,xrs(:,2));
            catch
                xrsf = xrs;
            end
            % xrsf(:,1) = decimate(xrsf(:,1),dsfact);
            % xrsf(:,2) = decimate(xrsf(:,2),dsfact);
            % timers    = timers(1:dsfact:end);
            
            vrs = vecvel(xrs , samrat, VELTYPE);   % velocities
            vrsf= vecvel(xrsf, samrat, VELTYPE);   % velocities
            
            % detect saccades based on unfiltered data
            mrs = microsaccMerge(xrs,vrs,velSD,minsam,mergeInt);  % saccades
            mrs = saccpar(mrs);
            if size(mrs,1)>0
                amp = mrs(:,7);
                mrs = mrs(amp>maxMSAmp,:);
            end
            nSac = size(mrs,1);
            %%
            if plotData
                axes(ax(1));
                cla;
                hold on;
                
                % draw fixation and saccade targets
                x = [tarPos(:,1); stiPos(1)];
                y = [tarPos(:,2); stiPos(2)];
                for i = 1:length(x)
                    xs = x(i) + tarRad*cos(-pi:pi/360:pi);
                    ys = y(i) + tarRad*sin(-pi:pi/360:pi);
                    
                    line(xs,ys,'color',cout,'linewidth',1,'linestyle','--');
                end
                
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
                plot(timers-tReference,vrsf(:,1),'k-','color',[0.6 0.6 0.6]);
                plot(timers-tReference,vrs(:,1),'g-');
                for i = 1:size(mrs,1)
                    plot(timers(mrs(i,1):mrs(i,2))-tReference,vrs(mrs(i,1):mrs(i,2),1)','r-','linewidth',2);
                end
                xlim(timers([1 end])-tReference);
                ylim([-timBefRef timAftRef]);
                
                axes(ax(3));
                cla;
                hold on;
                plot(timers-tReference,vrsf(:,2),'k-','color',[0.6 0.6 0.6]);
                plot(timers-tReference,vrs(:,2),'g-');
                for i = 1:size(mrs,1)
                    plot(timers(mrs(i,1):mrs(i,2))-tReference,vrs(mrs(i,1):mrs(i,2),2)','r-','linewidth',2);
                end
                xlim(timers([1 end])-tReference);
                ylim([-timBefRef timAftRef]);
            end
            %%
            % loop over all necessary response saccades
            s = 0;
            if sacReq
                for rs = 1:nRS
                    fixRec = repmat(tarPos(rs  ,:),1,2)+[-tarRad -tarRad tarRad tarRad];
                    tarRec = repmat(tarPos(rs+1,:),1,2)+[-tarRad -tarRad tarRad tarRad];
                    
                    % check for response saccade
                    reaSacNumber = 0;
                    if s<nSac
                        while ~resp(rs) && s<nSac
                            s = s+1;
                            onset = timers(mrs(s,1))-tReference;
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
                            if plotData
                                if resp(rs)
                                    axes(ax(1));
                                    plot([xBeg xEnd],[yBeg yEnd],'ko','color',[0 0 0],'markersize',8,'linewidth',2);
                                    axes(ax(2));
                                    plot(timers(mrs(s,1:2))-tReference,vrs(mrs(s,1:2),1),'ko','color',[0 0 0],'markersize',8,'linewidth',2);
                                    axes(ax(3));
                                    plot(timers(mrs(s,1:2))-tReference,vrs(mrs(s,1:2),2),'ko','color',[0 0 0],'markersize',8,'linewidth',2);
                                end
                            end
                            %%
                        end
                    end
                    
                    if ~resp(rs)
                        ex.nors(rs) = ex.nors(rs) + 1;
                        
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
                        sacType    = rs+1; % 0 = no response; 1 = microsaccade; 2 = large saccade; 3 = second large saccade
                        sacOnset   = timers(mrs(reaSacNumber,1))-tReference;
                        sacOffset  = timers(mrs(reaSacNumber,2))-tReference;
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
                        ex.sbrs(rs) = ex.sbrs(rs)+1;
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % missings before current response saccade %
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if resp(rs)
                        rt = sacRT;
                        if rs == 1
                            t1 = tReference-timBefRef;       % stimulus onset (ans some time before)
                            t2 = tReference+sacRT+sacDur;    % end of saccade period
                        else
                            t1 = tReference+reaSac(rs-1,5);  % offset of last saccade
                            t2 = t1+sacRT+sacDur;           % end of saccade period
                        end
                        
                        % get index for current data period
                        idx  = find(dat(:,1)>=t1 & dat(:,1)<t2);
                        
                        % Trials with missings from fixein to response go
                        idxmbrs = find(dat(idx,crit_cols)==-1);
                        if ~isempty(idxmbrs)
                            mbrs(rs) = 1;
                            ex.mbrs(rs) = ex.mbrs(rs) + 1;
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
                    ex.sbrs(1) = ex.sbrs(1)+1;
                end
                
                % Missings in the critical time window
                idxmbrs = find(dat(idxrs,crit_cols)==-1);
                if ~isempty(idxmbrs)
                    mbrs = 1;
                    ex.mbrs(1) = ex.mbrs(1) + 1;
                end
            end
            
            %%
            if plotData
                axes(ax(1));
                hold on;
                xlim([-10 10]);
                ylim([-10 10]);
                text(-9,-9,sprintf('Block %i, Trial %i',block,trial),'Fontsize',14,'hor','left','ver','bottom');
                
                if sacReq
                    condStr = 'Saccade';
                else
                    condStr = 'Fixation';
                end
                if sum(sbrs)==0 && sum(mbrs)==0 && sum(resp)==nRS
                    text(0,-9,sprintf('%s: good',condStr),'Fontsize',14,'hor','center','ver','bottom');
                else
                    text(0,-9,sprintf('%s: bad',condStr),'Fontsize',14,'hor','center','ver','bottom');
                end
                
                set(gca,'visible','off');
                if waitforbuttonpress
                    plotData = 0;
                end
                cla;
            end
            %%
            %%% end % end of if ~samp
            
            % evaluate rejection criteria
            if 1%sum(sbrs)==0 && sum(mbrs)==0 && sum(resp)==nRS
                rea = [tab(t,:) reaSac];
                
                % this is what you need in addition to the tab format:
                % %i\t%i\t%i\t%i\t%i\t%i\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n
                fprintf(frea,'%i\t%i\t%.2f\t%.2f\t%i\t%i\t%i\t%i\t%i\t%.4f\t%.4f\t%.4f\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n',rea');
                
                ntGood = ntGood + 1;
                ntGoodAll = ntGoodAll + 1;
            else
                ntBadAll = ntBadAll + 1;
            end
            fprintf(fbtr,'%i\t%i\t%i\t%i\t%i\t%i\n',tab(t,1),tab(t,2),sbrs,mbrs,~resp,samp);
        end
        fclose(frea);
        fclose(fbtr);
        
        fprintf(1,'\t Trials der VP:\t\t%i\n\t GoodTrials :\t\t%i\n\t Samp. error:\t\t%i\n',nt,ntGood,ex.samp);
        if nRS>0
            for rs = 1:nRS
                fprintf(1,'\t Response saccade %i:\n\t  SacBefSac :\t\t%i\n\t  MisBefSac :\t\t%i\n\t  NoSaccade :\t\t%i\n',rs,ex.sbrs(rs),ex.mbrs(rs),ex.nors(rs));
            end
        else
            fprintf(1,'\t Response saccade %i:\n\t  SacBefSOf :\t\t%i\n\t  MisBefSOf :\t\t%i\n',0,ex.sbrs(1),ex.mbrs(1));
        end
    end
end
fclose(sfid);

fprintf(1,'\n\nInsgesamt kamen %i Trials von %i Trials durch!',ntGoodAll,ntGoodAll+ntBadAll);
