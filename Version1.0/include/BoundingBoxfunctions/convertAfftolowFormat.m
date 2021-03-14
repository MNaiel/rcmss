function pnew=convertAfftolowFormat(cBB,sz)
% input size(6xn) : cBB = affparam2mat(param.param);
% output size (4xn) in LowFormat  : pnew =[ClowIm; RlowIm; CHighIm; RHighIm];
%%
if size(cBB,1)~=6,  cBB=cBB';end;
pnew=zeros(4,size(cBB,2));
InputInrows=1;
for i=1:size(cBB,2)
    cBBnew = affparam2geom(cBB(:,i));
    p=[cBBnew(1),cBBnew(2)];
    p(3)=cBBnew(3)*sz(2);
    p(4)=cBBnew(5)*p(3);
    pnew(:,i)=convertFromCenterToLowFormat(p,InputInrows)';
end
