function bbsOut=convertLowFormattoLeftTopWHT(bbs)
% input bbs (4xn) [clow; rlow; chigh; rhigh; score] 
% output bbs (nx4) [x y w h] 
%%
clow=bbs(1,:); rlow=bbs(2,:); chigh=bbs(3,:); rhigh=bbs(4,:);
W=chigh-clow;
H=rhigh-rlow;
bbsOut=cat(2,clow', rlow', W', H');
