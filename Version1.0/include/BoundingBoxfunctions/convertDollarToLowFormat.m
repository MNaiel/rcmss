function bbs=convertDollarToLowFormat(bbs)
% input bbs (nx5) [x y w h score]
% out bbs (5xn) [clow; rlow; chigh; Rhigh; score]
%%
if isempty(bbs)==0
    bbs=bbs';
    bbs(3,:)=bbs(1,:)+bbs(3,:);
    bbs(4,:)=bbs(2,:)+bbs(4,:);
end
