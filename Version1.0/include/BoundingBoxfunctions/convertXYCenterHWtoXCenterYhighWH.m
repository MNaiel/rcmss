function bbsOut=convertXYCenterHWtoXCenterYhighWH(bbs)
% input bbs (4xn) [ Xcenter, Ycenter, H, W] 
% output bbs (nx4)  [ Xcenter, Yhigh, W, H]
%%
W=bbs(4,:);
H=bbs(3,:);
bbsOut=cat(2,bbs(1,:)',bbs(2,:)'+H'./2, W', H');
