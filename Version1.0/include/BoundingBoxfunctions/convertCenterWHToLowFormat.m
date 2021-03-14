function bbs=convertCenterWHToLowFormat(bbs)
% input bbs (nx5) [x, y, w, h, score] 
% out bbs (5xn) [clow; rlow; chigh; Rhigh; score] 
%%
bbs=bbs';
W=bbs(3,:);
H=bbs(4,:);
bbs(1,:)=bbs(1,:)-W/2;
bbs(2,:)=bbs(2,:)-H/2;
bbs(3,:)=bbs(1,:)+bbs(3,:);
bbs(4,:)=bbs(2,:)+bbs(4,:);