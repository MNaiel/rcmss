function pnew=convertlowFormattoCenter(cBB)
%input:   ClowIm=bb(1);RlowIm=bb(2); CHighIm=bb(3); RHighIm=bb(4);
%output  2xn centers of BB
%%
pnew=zeros(2,size(cBB,2));
for i=1:size(cBB,2)
    cx=(cBB(1,i)+cBB(3,i))/2;%column 
    cy=(cBB(2,i)+cBB(4,i))/2;%row
    pnew(:,i)=[cx; cy];    
end
