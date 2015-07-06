fDir='prepare/';
fileList = dir(sprintf('%s*.mat',fDir));
nFiles = length(fileList);

OBS=cell(nFiles,1); % ADD LABELS
col1=cell(9,1);

OBS(:)={ [col1 {...
    ['ID'] % 1
    ['Ecc.'] % 2
    ['Gap'] % 3
    ['Acc.'] % 4
    ['RTs'] % 5
    ['SD of RTs by cue type']
    ['Acc. by Target & Gap position']
    ['Acc. by duration and cue type']
    ['Overall SD of RTs']}] };

%%
allIDs=[];
for f=1:nFiles
    load(sprintf('%s%s',fDir,fileList(f).name))
    
    % observer initials
    OBS{f}(1)= {fileList(f).name(1:2)};
    allIDs=[allIDs {fileList(f).name(1:2)}];
    % session eccentricity & gap size
    OBS{f}(2)={constant.ECCENTRICITY};
    OBS{f}(3)={constant.GAPSIZE};
    
    % correct responses
    cr=[trialData.block(1).trial.cor trialData.block(2).trial.cor];
    %RTs
    rts=[trialData.block(1).trial.keyRT trialData.block(2).trial.keyRT]';
    
    % indices:
    % valid cue
    V=[[trialData.block(1).trial.trialType]==1 [trialData.block(2).trial.trialType]==1];
    % target on left
    L=[[trialData.block(1).trial.targetLoc]==1 [trialData.block(2).trial.targetLoc]==1];
    %gap on top
    T=[[trialData.block(1).trial.gapLocT]==1 [trialData.block(2).trial.gapLocT]==1];
    
    % 300 ms base cue duration
    sh=[[trialData.block(1).trial.delay]==.3 [trialData.block(2).trial.delay]==.3];
    % 600 ms base cue duration
    md=[[trialData.block(1).trial.delay]==.6 [trialData.block(2).trial.delay]==.6];
    % 900 ms base cue duration
    lg=[[trialData.block(1).trial.delay]==.9 [trialData.block(2).trial.delay]==.9];
    
    % accuracy with valid or neutral cues
    OBS{f}(4)={[sum(cr(V))/sum(V),... % valid trials
        sum(cr(~V))/sum(~V)]}; % neutral trials
    
    
    low=150; % low end cut off for RTs
    mdv=median(rts(V)); % valid trials median RT
    sdv=std(rts(V));                      % valid trials SD of RTs
    
    mdn=median(rts(~V)); % neutral trials median RT
    sdn=std( rts(~V));                      % neutral trials SD of RTs
    
    % values below 'low' or above 2x the SD are excluded
    incv=low<rts & rts<mdv+2*sdv & V';
    incn=low<rts & rts<mdn+2*sdn & ~V';
    OBS{f}(9)={std(rts(incv|incn))};
    
    % mean RT in valid & neutral trials (outliers trimmed)
    OBS{f}(5)={[...
        mean(rts(incv )),... % valid trials
        mean(rts(incn))  ]}; %neutral trials
    
    
    % RT SD in valid & neutral trials (outliers trimmed)
    OBS{f}(6)={[...
        std(rts(incv)),...% valid trials
        std(rts(incn))  ]};% neutral trials
    
    
    % nuisance stuff (postion of target and gap)
    % accuracy for each target & gap postion combination
    OBS{f}(7)={[ ...
        sum(cr( L & T ))/ sum(L&T),... % left-top
        sum(cr(~L & T ))/ sum(~L&T),... % right-top
        sum(cr(~L &~T ))/ sum(~L&~T),... % right-bottom
        sum(cr( L &~T ))/ sum(L&~T) ]}; % left-bottom
    
    % accuracy as a function of base cue duration and validity
    OBS{f}(8)={[...
        sum(cr(V & sh)) / sum(V & sh),... % valid short cue trials
        sum(cr(~V & sh)) / sum(~V & sh);... % neutral short cue trials
        sum(cr(V & md)) / sum(V & md),... % valid medium cue trials
        sum(cr(~V & md)) / sum(~V & md);... % neutral medium cue trials
        sum(cr(V & lg)) / sum(V & lg),... % valid long cue trials
        sum(cr(~V & lg)) / sum(~V & lg)]}; % neutral long cue trials
    
    
end
IDlist=unique(allIDs);
% col=[linspace(0,1,length(IDlist))' linspace(0,.5,length(IDlist))' logspace(1,0,length(IDlist))'];
col=[linspace(0,1,length(IDlist))' (mod(1:length(IDlist),2).*.8)' logspace(0,-1,length(IDlist))'];

%% examine stuff

% for i = 1:nFiles
% figure(1)
% bar(stuff{i}{4})
% ylim([0,1])
% title(sprintf('Accuracy: %s - %1.0fº Ecc. %.3fº Gap', stuff{i}{1}, stuff{i}{2}, stuff{i}{3}))
% set(gca, 'XTickLabel',{'Valid','Neutral'})
% pause

% figure(2)
% bar(stuff{i}{7})
% ylim([0,1])
% title(sprintf('Accuracy: %s - %1.0fº Ecc. %.3fº Gap', stuff{i}{1}, stuff{i}{2}, stuff{i}{3}))
% set(gca, 'XTickLabel',{'T-L','T-R', 'B-R', 'B-L'})
% pause



% end

% %% accuracy scatter plot (V vs N)
% figure(3)
% clf
% for i = 1:nFiles
%     hold on
%     % if strcmp(stuff{i}{1},IDlist)
%     %     col='b';
%     % else
%     %     col='c';
%     % end
%     if OBS{i}{2}==4
%         marker='x';
%     elseif OBS{i}{2}==8
%         marker='o';
%     end
%     scatter(OBS{i}{4}(1),OBS{i}{4}(2),75,[col(strcmp(OBS{i}{1},IDlist),:)],marker, 'LineWidth',1.5)
% end
% plot([0 1],[0 1], 'k:')
% axis equal
% ylim([0.5,1])
% xlim([0.5,1])
% title('Accuracy (%-correct)')
% xlabel('Valid')
% ylabel('Neutral')
% legend(allIDs,'Location','NorthWest')
%
% %% RT scatter plot
% figure(4)
% clf
% for i = 1:nFiles
%     hold on
%
%     if OBS{i}{2}==4
%         marker='x';
%     elseif OBS{i}{2}==8
%         marker='o';
%     end
%     scatter(OBS{i}{5}(1),OBS{i}{5}(2),75, [col(strcmp(OBS{i}{1},IDlist),:)] ,marker, 'LineWidth',1.5)
%
%
%     xlabel('Valid')
%     ylabel('Neutral')
% end
% axis equal
%
% soLims=max([xlim ylim]);
% plot([0 soLims],[0 soLims], 'Color', [.8 .8 .8])
% title('RTs (ms)')
% legend(allIDs,'Location','NorthWest')

% %% accuracy as a function of cue length and  type scatter plot
% figure(5)
% clf
% col2= [1 0 0; 0 1 0; 0 0 1];
% for i = 1:nFiles
%     hold on
%
%     if OBS{i}{2}==4
%         marker='x';
%     elseif OBS{i}{2}==8
%         marker='o';
%     end
%     scatter(OBS{i}{8}(:,1),OBS{i}{8}(:,2),75, col2 ,marker, 'LineWidth',1.5)
%
%
%
% end
% plot([0 1],[0 1], 'Color', [.8 .8 .8])
% xlabel('Valid')
% ylabel('Neutral')
% axis equal
% axis equal
% ylim([0.5,1])
% xlim([0.5,1])

% legend('sh 4º','md 4º','ln 4º','sh 8º','md 8º','ln 8º','Location','NorthWest')

%% accuracy scatter plot (V vs N)
totO=length(IDlist);
% h=cell(2,totO);
figure(1)
clf
hold on
for id = 1:totO
    temp={ OBS{ strcmp(allIDs,IDlist(id)) } };
    fDeg=[];
    eDeg=[];
    for ses=1:length(temp)
        if temp{ses}{2}==4
            fDeg=[fDeg; temp{ses}{4}];
        elseif temp{ses}{2}==8
            eDeg=[eDeg; temp{ses}{4}];
        end
    end
    if ~isempty(fDeg)
        h(1,id)=scatter(mean(fDeg(:,1)), mean(fDeg(:,2)),100,[col(id,:)],'x', 'LineWidth',2.5);
    end
    if ~isempty(eDeg)
        h(2,id)=scatter(mean(eDeg(:,1)), mean(eDeg(:,2)),100,[col(id,:)],'o', 'LineWidth',2.5);
    end
end
plot([0.5 1],[0.5 1], 'k:')
axis equal
ylim([0.5,1])
xlim([0.5,1])
title('Accuracy (%-correct)')
legend(h(2,:),IDlist,'Location','NorthWest')
grid on
xlabel('Valid')
ylabel('Neutral')
text(.8,.55,'x = 4º , o = 8º', 'FontSize', 20)
%% RTS scatter plot (V vs N)
figure(2)
clf
hold on
for id = 1:totO
    temp={ OBS{ strcmp(allIDs,IDlist(id)) } };
    fDeg=[];
    eDeg=[];
    for ses=1:length(temp)
        if temp{ses}{2}==4
            fDeg=[fDeg; temp{ses}{5}];
        elseif temp{ses}{2}==8
            eDeg=[eDeg; temp{ses}{5}];
        end
    end
    gMean=[mean(mean(fDeg)), mean(mean(eDeg))];
    if ~isempty(fDeg)
        h(1,id)=scatter(mean(fDeg(:,1)), mean(fDeg(:,2)),100,[col(id,:)],'x', 'LineWidth',2.5);
    end
    %     tp=get(h(1,id));
    %     plot([tp.XData+temp{1}{6}(1); tp.XData-temp{1}{6}(1)], [tp.YData; tp.YData], 'Color', [.8 .8 .8])
    %     plot([tp.XData; tp.XData], [tp.YData+temp{1}{6}(2); tp.YData-temp{1}{6}(2)], 'Color', [.8 .8 .8])
    if ~isempty(eDeg)
        h(2,id)=scatter(mean(eDeg(:,1)), mean(eDeg(:,2)),100,[col(id,:)],'o', 'LineWidth',2.5);
    end
end
title('RT (ms)')
legend(h(2,:),IDlist,'Location','NorthWest')
grid on
lims=[xlim; ylim];
soLims=sort(lims(:));
axis equal
plot([0 soLims(3)*1.3],[0 soLims(3)*1.3], 'Color', [.8 .8 .8])
xlabel('Valid')
ylabel('Neutral')
xlim([0,lims(1,2)*1.3])
ylim([0,lims(2,2)*1.3])
text(lims(1,2)*.6,lims(1,2)*.15,'x = 4º , o = 8º', 'FontSize', 20)