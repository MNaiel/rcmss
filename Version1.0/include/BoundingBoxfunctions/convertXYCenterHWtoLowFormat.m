function bbsOut=convertXYCenterHWtoLowFormat(bbs)
% input bbs (4xn) [ Xcenter, Ycenter, Height, Width]
% output bbs (nx4)  [ Xcenter, Yhigh, W, H]
% output bbsOut=[clow; rlow; chigh; rhigh;]; [Xlow;Ylow;Xhigh;Yhigh; ]
%%
Xcenter=bbs(1,:);
Ycenter=bbs(2,:);
W=bbs(3,:);
H=bbs(4,:);
bbsOut=cat(1,Xcenter-W./2,Ycenter-H./2,Xcenter+W./2,Ycenter+H./2);
