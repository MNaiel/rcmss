function [o,n,param]=selectPoints(frm,o,n,previousCenter,sz,RightorLeftFlag,param)
show=0;
pnew   =convertAfftolowFormat(o,sz);
Centers=convertlowFormattoCenter(pnew);
Margine=5;
if RightorLeftFlag==1, Indexvalid=find(Centers(1,:)>previousCenter(1)-Margine);
else                   Indexvalid=find(Centers(1,:)<previousCenter(1)+Margine);
end
if isempty(Indexvalid),  return; end;
o=o(:,Indexvalid);
n=length(Indexvalid);
param.param  =param.param(:,Indexvalid);
param.param0 =param.param0(:,Indexvalid);
if show==1
    SHOWBBonImage(uint8(frm),pnew(:,Indexvalid));
    hold on;
    SizePoint=30;
    scatter(previousCenter(1),previousCenter(2),SizePoint,[0 0 1],'filled');
    hold off;
end