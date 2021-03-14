function bbOut=fromLeftTopWH2CenterWH(bbs, TrackerType)
% input:
% [nx5] array of detected bbs and confidences
%     [x y w h]==[cLow, rlow, width, height]
%%
if size(bbs,2)>size(bbs,1),   bbs=bbs';end;
bbOut=zeros(size(bbs,1),5);
for j=1:size(bbs,1)
    centers=[bbs(j,1)+bbs(j,3)/2 bbs(j,2)+bbs(j,4)/2];
    bbOut(j,:)= [centers(1) centers(2) bbs(j,3) bbs(j,4) 0.0]; %centerx, centery, w,h, orientaion    
end