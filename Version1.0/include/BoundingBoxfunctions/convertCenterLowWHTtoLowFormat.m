function bbsOut=convertCenterLowWHTtoLowFormat(bbs)
% input bbs (4xn) [clow; rlow; chigh; rhigh; score] 
% output bbs (nx4) [x+w/2 y+h w h] 
% % num=size(bbs,1);
% bbs=bbs';
%%
cCentre=bbs(1,:); 
rhigh=bbs(2,:);
W=bbs(3,:); 
H=bbs(4,:); 
clow=cCentre-W./2;
rlow=rhigh-H;
chigh=clow+W;
bbsOut=[clow; rlow; chigh; rhigh;];
