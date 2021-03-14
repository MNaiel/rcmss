function bbsOut=convertLowFormattoCenterLowWHT(bbs)
% input bbs (4xn) [clow; rlow; chigh; rhigh; score]
% output bbs (nx4) [x+w/2 y+h w h]
% % num=size(bbs,1);
% bbs=bbs';
%%
clow=bbs(1,:); rlow=bbs(2,:); chigh=bbs(3,:); rhigh=bbs(4,:);
W=chigh-clow;
H=rhigh-rlow;
bbsOut=cat(2,clow'+W'./2, rhigh', W', H');
