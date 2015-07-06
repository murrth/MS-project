if welche == 1
    reaAllFile = sprintf('../rea/AllSubjects_V%iD%iT%iS%i.rea',velSD,minDur,VELTYPE,SAMPRATE);
    btrAllFile = sprintf('../btr/AllSubjects_V%iD%iT%iS%i.btr',velSD,minDur,VELTYPE,SAMPRATE);
    
    freaAll = fopen(reaAllFile,'w');
    fbtrAll = fopen(btrAllFile,'w');
    
    fprintf(freaAll,'01_Block\t02_Trial\t03_fixpox\t04_fixpoy\t05_tespox\t06_tespoy\t');
    fprintf(freaAll,'07_staTim\t08_tesTim\t09_staTil\t10_staCon\t11_tesTil\t12_tesCon\t');
    fprintf(freaAll,'13_tedfFix\t14_tedfSOn\t15_tedfSOf\t16_tGo\t17_tedfTOn\t18_tedfTOf\t19_tSac\t20_tRes\t21_tedfClr\t');
    fprintf(freaAll,'22_sacRT\t23_keyRT\t24_resSide\t25_resCont\t26_resTilt\t27_sacReq\t');
    fprintf(freaAll,'28_sacLat\t29_sacNum\t30_sacType\t31_sacOnset\t32_sacOffset\t');
    fprintf(freaAll,'33_sacDur\t34_sacVPeak\t35_sacDist\t36_sacAngleDist\t37_sacAmp\t38_sacAngleAmp\t');
    fprintf(freaAll,'39_sacxOnset\t40_sacyOnset\t41_sacxOffset\t42_sacyOffset\n');
    
    sfid = fopen('subjects.all','r');
else
    sfid = fopen('subjects.tmp','r');
end

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
        
        if ~exist(tabfile,'file')
            fprintf(1,'\n\tDatei %s existiert nicht!',tabfile);
        end
        if ~exist(datfile,'file')
            fprintf(1,'\n\tDatei %s existiert nicht!',datfile);
        end
        
        fprintf(1,'\n\n\tloading %s ...',vpcode);
        
        tab = load(tabfile);
        dat = load(datfile);
        
        DPP = DPP*318/abs(tab(1,5));PPD = 1/DPP;
        scrCen    = round(abs(tab(1,5))/318*[640 480]);
        fprintf(1,' xres = %i ...',round(1280*abs(tab(1,5))/318));
        
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
        ex.loss = zeros(1,  1);   % Data loss before saccade (blinks)
        for t = 1:size(tab,1) % Schleife ueber alle Trials der VP
            nt = nt + 1;
            
            block = tab(t,1);
            trial = tab(t,2);
            
            tFixOnEDF = tab(t,13);
            tCueOnEDF = tFixOnEDF+tab(t,16);
            tProOnEDF = tFixOnEDF+tab(t,17);
            tProOfEDF = tFixOnEDF+tab(t,18);
            
            sacReq = tab(t,27);
            
            % 0 deg is right, 90 deg is up
            fixPos = tab(t,3:4);
            if sacReq==1
                tarPos = [fixPos;tab(t,5:6)]*DPP;
            else
                tarPos =  fixPos;
            end
            
            nRS = size(tarPos,1)-1;     % nRS is 0 if no saccade required
            
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
            % get data in response time interval
            if sacReq == 1
                idxrs = find(dat(:,1)>=tCueOnEDF & dat(:,1)<=tCueOnEDF+maxRT);
            else
                % change this to test offset plus postProOf
                idxrs = find(dat(:,1)>=tCueOnEDF & dat(:,1)<=tProOfEDF+postProOf);
            end
            timers = dat(idxrs,1);	% time stamp
            
            % actual sampling rate in recorded data
            samrat = round(1000/mean(diff(timers)));
            minsam = minDur*samrat/1000;
            
            if length(timers)<length(tCueOnEDF:SAMPRATE/samrat:tProOfEDF+postProOf)
                loss = 1;
                ex.loss = ex.loss + 1;
            else
                % determine sampling rate (differs across
                % trials if something went wrong)
                if ~mod(length(timers),2)   % delete last sample if even number
                    timers(end) = [];
                    idxrs(end)  = [];
                end
                if 0 %samrat<SAMPRATE
                    samp = 1;
                    ex.samp = ex.samp+1;
                end
                
                %% if ~samp
                xrsf = DPP*([dat(idxrs,2)-scrCen(1) -(dat(idxrs,3)-scrCen(2))]);    % positions
                
                % filter eye movement data
                clear xrs;
                xrs(:,1) = filtfilt(fir1(35,0.05*SAMPRATE/samrat),1,xrsf(:,1));
                xrs(:,2) = filtfilt(fir1(35,0.05*SAMPRATE/samrat),1,xrsf(:,2));
                
                vrs = vecvel(xrs, samrat, VELTYPE);   % velocities
                vrsf= vecvel(xrsf, samrat, VELTYPE);   % velocities
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
                    hold off;
                    xs = 0 + [-sl -sl sl sl -sl]/2;
                    ys = 0 + [-sl sl sl -sl -sl]/2;
                    line(xs,ys,'color',cout,'linewidth',2);
                    hold on;
                    
                    % Make dependent on cue, then uncomment
                    % line([0 cl]+fp/2,[0 0],'color',cout,'linewidth',2);
                    % line([0 0],[0 cl]+fp/2,'color',cout,'linewidth',2);
                    
                    [x,y] = pol2cart(0:pi:pi,ec);
                    
                    for i = 1:length(x)
                        xs = x(i) + [-sl -sl sl sl -sl]/2;
                        ys = y(i) + [-sl sl sl -sl -sl]/2;
                        
                        line(xs,ys,'color',cout,'linewidth',2);
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
                    plot(timers-tCueOnEDF,vrsf(:,1),'k-','color',[0.6 0.6 0.6]);
                    hold on;
                    plot(timers-tCueOnEDF,vrs(:,1),'g-');
                    for i = 1:size(mrs,1)
                        plot(timers(mrs(i,1):mrs(i,2))-tCueOnEDF,vrs(mrs(i,1):mrs(i,2),1)','r-','linewidth',2);
                    end
                    hold off;
                    xlim(timers([1 end])-tCueOnEDF);
                    ylim([-1000 1000]);
                    
                    axes(ax(3));
                    plot(timers-tCueOnEDF,vrsf(:,2),'k-','color',[0.6 0.6 0.6]);
                    hold on;
                    plot(timers-tCueOnEDF,vrs(:,2),'g-');
                    for i = 1:size(mrs,1)
                        plot(timers(mrs(i,1):mrs(i,2))-tCueOnEDF,vrs(mrs(i,1):mrs(i,2),2)','r-','linewidth',2);
                    end
                    hold off;
                    xlim(timers([1 end])-tCueOnEDF);
                    ylim([-1000 1000]);
                end
            end
            %%
            % loop over all necessary response saccades
            s = 0;
            if sacReq == 1 && ~loss
                for rs = 1:nRS
                    fixRec = repmat(tarPos(rs  ,:),1,2)+[-tarRad -tarRad tarRad tarRad];
                    tarRec = repmat(tarPos(rs+1,:),1,2)+[-tarRad -tarRad tarRad tarRad];
                    
                    % check for response saccade
                    reaSacNumber = 0;
                    if s<nSac
                        while ~resp(rs) && s<nSac
                            s = s+1;
                            onset = timers(mrs(s,1))-tCueOnEDF;
                            xBeg  = xrs(mrs(s,1),1);   % initial eye position x
                            yBeg  = xrs(mrs(s,1),2);	% initial eye position y
                            xEnd  = xrs(mrs(s,2),1);   % final eye position x
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
                                axes(ax(1));
                                if resp(rs)
                                    plot([xBeg xEnd],[yBeg yEnd],'ko','color',[0 0 0],'markersize',8,'linewidth',2);
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
                        sacOnset   = timers(mrs(reaSacNumber,1))-tCueOnEDF; % start-screen-geloggt
                        sacOffset  = timers(mrs(reaSacNumber,2))-tCueOnEDF; % start-screen-geloggt
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
                            t1 = tCueOnEDF-timBefCue;
                            t2 = tCueOnEDF+sacRT+sacDur;
                        else
                            t1 = tCueOnEDF+reaSac(rs-1,5);
                            t2 = t1+sacRT+sacDur;
                        end
                        
                        % get index for current data period
                        idx  = find(dat(:,1)>=t1 & dat(:,1)<t2);
                        
                        % Trials mit Missings von fixein bis response raus
                        idxmbrs = find(dat(idx,crit_cols)==-1);
                        if ~isempty(idxmbrs)
                            mbrs(rs) = 1;
                            ex.mbrs(rs) = ex.mbrs(rs) + 1;
                        end
                    end
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
                
                reaSac = [sacRT reaSacNumber sacType sacOnset sacOffset sacDur, ...
                    sacVPeak sacDist sacAngle1 sacAmp sacAngle2 sacxOnset, ...
                    sacyOnset sacxOffset sacyOffset];
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % saccades before current response  %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if nSac > 0
                    sbrs = 1;
                    ex.sbrs = ex.sbrs+1;
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % missings before current response %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                rt = sacRT;
                t1 = tCueOnEDF-timBefCue;
                t2 = tCueOnEDF+sacRT+sacDur;
                
                % get index for current data period
                idx  = find(dat(:,1)>=t1 & dat(:,1)<t2);
                
                % Trials mit Missings von fixein bis response raus
                idxmbrs = find(dat(idx,crit_cols)==-1);
                if ~isempty(idxmbrs)
                    mbrs = 1;
                    ex.mbrs = ex.mbrs + 1;
                end
            end
            
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
            
            % evaluate rejection criteria
            if sum(sbrs)==0 && sum(mbrs)==0 && sum(resp)==nRS && ~loss % && samp==0
                if sacReq == 1
                    rea = [repmat(tab(t,:),nRS,1) reaSac];
                else
                    rea = [tab(t,:) reaSac];
                end
                fprintf(frea,'%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%.4f\t%.4f\t%.4f\t%.4f\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n',rea');
                
                if welche == 1
                    rea = [vp*ones(size(rea,1),1), rea];
                    fprintf(freaAll,'%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%.4f\t%.4f\t%.4f\t%.4f\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n',rea');
                end
                ntGood = ntGood + 1;
                ntGoodAll = ntGoodAll + 1;
            else
                ntBadAll = ntBadAll + 1;
            end
            fprintf(fbtr,'%i\t%i\t%i\t%i\t%i\t%i\n',tab(t,1),tab(t,2),sbrs,mbrs,~resp,samp);
        end
        fclose(frea);
        fclose(fbtr);
        
        fprintf(1,'\t Trials der VP:\t\t%i\n\t GoodTrials :\t\t%i\n\t Samp. error:\t\t%i\n\t Data loss  :\t\t%i\n',nt,ntGood,ex.samp,ex.loss);
        if sacReq == 1
            for rs = 1:nRS
                fprintf(1,'\t Response saccade %i:\n\t  SacBefSac :\t\t%i\n\t  MisBefSac :\t\t%i\n\t  NoSaccade :\t\t%i\n',rs,ex.sbrs(rs),ex.mbrs(rs),ex.nors(rs));
            end
        else
            if nRS>0
                fprintf(1,'\t Response saccade %i:\n\t  SacBefSac :\t\t%i\n\t  MisBefSac :\t\t%i\n\t  NoSaccade :\t\t%i\n',rs,ex.sbrs,ex.mbrs,ex.nors);
            else
                fprintf(1,'\t Fixation condition:\n\t  SacBefEnd :\t\t%i\n\t  MisBefEnd :\t\t%i\n',ex.sbrs(1),ex.mbrs(1));
            end
        end
        if welche == 1
            fprintf(fbtrAll,'%s\t%i\t%i\t%i\t%i',vpcode,nt,ntGood,ex.samp,ex.loss);
            if nRS>0
                for rs = 1:nRS
                    fprintf(fbtrAll,'\t%i\t%i\t%i',ex.sbrs(rs),ex.mbrs(rs),ex.nors(rs));
                end
            else
                fprintf(fbtrAll,'\t%i\t%i\t%i',ex.sbrs(1),ex.mbrs(1),ex.nors(1));
            end
            fprintf(fbtrAll,'\n');
        end
    end
end
fclose(sfid);

if welche == 1
    fclose(fbtrAll);
    fclose(freaAll);
end

fprintf(1,'\n\nInsgesamt kamen %i Trials von %i Trials durch!',ntGoodAll,ntGoodAll+ntBadAll);
