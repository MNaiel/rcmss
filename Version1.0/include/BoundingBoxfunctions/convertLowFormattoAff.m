function pnew=convertLowFormattoAff(cBB,sz)
% ClowIm=bb(1);RlowIm=bb(2); CHighIm=bb(3); RHighIm=bb(4);
% input size(4xn) ClowIm=bb(1);RlowIm=bb(2); CHighIm=bb(3); RHighIm=bb(4);
%output  6xn output of affparam2mat
% steps: convert to center format, then apply affparam2mat
%%
pnew=zeros(6,size(cBB,2));
Orientation=0.0;
for i=1:size(cBB,2)
    p=cBB(:,i);
    param0 = [p(1), p(2), p(3)/sz(2), Orientation, p(4)/p(3), 0];
    pnew(:,i) = affparam2mat(param0)';
end
