function [BBconverted]=ConvertBBform1to2(BB,Flag)
if nargin < 2
    Flag=1;
end
if Flag==1
    ClowIm=BB(1,:);
    RlowIm=BB(2,:);
    CHighIm=BB(3,:);
    RHighIm=BB(4,:);
    W=CHighIm-ClowIm+1;
    H=RHighIm-RlowIm+1;
    BBconverted=[ClowIm',RlowIm', W',H'];
else
    ClowIm=BB(:,1);
    RlowIm=BB(:,2);
    CHighIm=BB(:,3)+ClowIm-1;
    RHighIm=BB(:,4)+RlowIm-1;
    BBconverted=[ClowIm';RlowIm'; CHighIm';RHighIm'];
end