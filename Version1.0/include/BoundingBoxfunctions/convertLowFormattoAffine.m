function [pnew,param0 ]=convertLowFormattoAffine(cBB,sz)
% ClowIm=bb(1);RlowIm=bb(2); CHighIm=bb(3); RHighIm=bb(4);
% input size(4xn) ClowIm=bb(1);RlowIm=bb(2); CHighIm=bb(3); RHighIm=bb(4);
%output  6xn output of affparam2mat
% steps: convert to center format, then apply affparam2mat
%%
pnew=zeros(6,size(cBB,2));
param0=zeros(6,size(cBB,2));
Orientation=0.0;
for i=1:size(cBB,2)
    p=convertFromLowFormatToCenter(cBB(:,i));
    param0(:,i) = [p(1), p(2), p(3)/sz(2), Orientation, p(4)/p(3), 0]';  %affsig = [center_x center_y width rotation aspect_ratio skew]
    pnew(:,i) = affparam2mat(param0(:,i));
end
