function p=convertFromCenterToLowFormat(p,InputInrows)
%input: centerx, centery, w, h
%output: ClowIm=bb(1);RlowIm=bb(2); CHighIm=bb(3); RHighIm=bb(4);
%if input in rows convert it to columns
%%
if InputInrows==1,   p=p';end;
for i=1:size(p,2)
    w=p(3,i);
    h=p(4,i);
    p(1,i)=p(1,i)-p(3,i)/2;
    p(2,i)=p(2,i)-p(4,i)/2;
    p(3,i)=p(1,i)+w;
    p(4,i)=p(2,i)+h;
end
if InputInrows==1,    p=p';end