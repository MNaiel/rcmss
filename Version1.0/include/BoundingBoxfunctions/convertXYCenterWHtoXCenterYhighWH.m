function bbsOut=convertXYCenterWHtoXCenterYhighWH(bbs)
% input bbs (4xn) [ Xcenter, Ycenter, W,H] 
% output bbs (nx4)  [ Xcenter, Yhigh, W, H]
%%
W=bbs(3,:);
H=bbs(4,:);
bbsOut=cat(2,bbs(1,:)',bbs(2,:)'+H'./2, W', H');