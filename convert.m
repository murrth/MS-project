%% eye movement analysis
% NMS 7/6/2015
% assembled with injections of pre-existing code from Martin Rolfs, Bonnie Lawrence, and
% Andra Mihali
% also calls function

% cells to be created for each of the following for each succesful trial:
% observer initials [s], (1)
% session number [n], (1)
% target eccentricity [n], (1)
% trial length [t],(1)
% gaze position [x,y], (1:t,1:t)
% instantaneous velocity [Vx,Vy], (1:t,1:t)
% cue type  [L/R/N], (1)  Valid left, valid right, neutral
% MS flag [T/F], (1:t)    was a given time point deemed part of a microsaccade
% Correct [T/F], (1)  Accuracy of response
items=6; % # of cells provided for each trial's data

datfld='raw';
tabfld='tab';
fileList = dir(sprintf('%s/*.dat',datfld));
%
fArray=cell(length(fileList),1);

%% microsaccade parameters
velSD     = 6;          % Lambda : median velocity threshold factor 
minDur    = 8;          % minimum microSac duration (ms) % was 6
maxMSAmp  = 1.5;        % maximum microsaccade amplitude

VELTYPE   = 2;          % velocity type for saccade detection (n-measure smoothing )
% visual display
DIST   = 114;         % Monitor distance in cm
xPx   = 1280;       % monitor pixels along x-axis (1280X960)
yPx   = 960;       % monitor pixels along y-axis (1280X960)
xCm   = 40;         % x Monitor width in cm (40X30 cm)
yCm   = 30;         % x Monitor width in cm (40X30 cm)

scrCen = [xPx yPx]/2;  % screen center (intial fixation position) 
DPP = pix2deg(xPx,xCm,DIST,1); % degrees per pixel
PPD = deg2pix(xPx,xCm,DIST,1); % pixels per degree
%% loop from here
% for f=1:length(fileList)
f=13;
%data file import
did=fopen(sprintf('%s/%s',datfld,fileList(f).name));
ddump=textscan(did, '%f %f %f %f');
fclose(did);

%msg file import
tid=fopen(sprintf('%s/%s.tab',tabfld,fileList(f).name(1:end-4)));
tdump=textscan(tid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
StartStop= [tdump{8} tdump{8}+tdump{11} tdump{8}+tdump{13}];

tArray=cell (length(StartStop),items); % temporary trial array

tArray(:,3)={fileList(f).name(1:end-6)};
tArray(:,4)={fileList(f).name(end-5:end-4)};


xy=[ddump{2:3}];
xy(xy==-1)=nan;
xy(:,1)=xy(:,1)-round(xres/2);
xy(:,2)=xy(:,2)-round(yres/2);
%    dur=(dump{1}(end)-dump{1}(1)



fArray{f}=cell (length(StartStop),items);

for i=1:length(StartStop)
    sta = find (ddump{1}==StartStop(i,1));
    sto = find (ddump{1}==StartStop(i,3));
    tArray(i)={xy(sta:sto,:)};
    tArray(i,2)={ddump{1}(sta:sto)}; % indexes 
end


%%
vt=cell(size(tArray(:,1))); sr=cell(size(tArray(:,1)));
vt(:)=VELTYPE;
sr(:)=S


ERT=cellfun(@vecvel,{tArray{:,1}}', {1000*ones(size(tArray(:,1)))}, {2*ones()})
%%
VS=vecvel(tArray{:}, 1000, 2)
MS= microsacc(tArray{:},
for i=1:length(StartStop)
    subplot(1,2,1)
    plot(tArray{i}(:,1),tArray{i}(:,2))
    axis equal
    xlim([-640,640])
    ylim([-480,480])
         grid minor

    subplot (1,2,2)
    plot (tArray{i})
     ylim([-640,640])
         xlim([1 length(tArray{i})])
     grid minor
    pause
end




