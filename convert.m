datfld='raw';
fileList = dir(sprintf('%s/*.dat',datfld));
xres=1280;
yres=960;

fid=fopen(sprintf('%s/%s',datfld,fileList(2).name));
% dur=nan;    
   dump=textscan(fid, '%f %f %f %f');
   fclose(fid);
   xy=[dump{2:3}];
   xy(:,1)=xy(:,1)-round(xres/2);
   xy(:,2)=xy(:,2)-round(yres/2);
%    dur=(dump{1}(end)-dump{1}(1)

%%
dur=1:length(xy);
ind=xy(:,1)==-round(xres/2)-1;
plot (xy(~ind,1),xy(~ind,2))

 xlim([-640,640])
ylim([-480,480])
axis equal

