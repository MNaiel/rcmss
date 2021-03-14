function bbs=ScaleDollarBB(bbs,Scale)
% scale bbs of Dollar format when the detections are coming from pre-scaled
% image by a factor (Scale), if Scale >1 upsampling, while if S<1
% downsamping
% input bbs (nx5) [x y w h score]
% out bbs (nx5) [x/Scale y/Scale w/Scale h/Scale score]
%%
if isempty(bbs)==0
    bbs(:,1:4)=bbs(:,1:4)./Scale;    
end
