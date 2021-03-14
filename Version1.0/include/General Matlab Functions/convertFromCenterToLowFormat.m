function p=convertFromCenterToLowFormat(p)
%input: centerx, centery, w, h
%output: ClowIm=bb(1);RlowIm=bb(2); CHighIm=bb(3); RHighIm=bb(4);
%%
w=p(3);
h=p(4);
p(1)=p(1)-p(3)/2;
p(2)=p(2)-p(4)/2;
p(3)=p(1)+w;
p(4)=p(2)+h;