function Q=convertFromLowFormatToCenter(p)
%input: ClowIm=bb(1);RlowIm=bb(2); CHighIm=bb(3); RHighIm=bb(4);
% outPut: cenetrx, centery, w, h
%%
Q=zeros(4,size(p,2));
for i=1:size(p,2)
    w=p(3,i)-p(1,i);
    h=p(4,i)-p(2,i);
    cx=(p(3,i)+p(1,i))/2;
    cy=(p(4,i)+p(2,i))/2;
    Q(:,i)=[cx, cy, w, h];
end