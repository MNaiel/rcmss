function distOut=DistanceNPointsandY(BBWH,Y)
% compute the distance between BB, and Y
%%
if size(BBWH,1)>1
    Npoints=size(Y(1:2,:),2);
    Mpoints=size(BBWH,2);
    distOut=zeros(1,Mpoints);
    for i=1:Mpoints
        dist=repmat(BBWH(1:2,i),[1 Npoints])-Y(1:2,:);
        distOut(i)=min(sqrt(sum((dist.^2),1)));
    end
else    
    Npoints=size(Y(1,:),2);
    Mpoints=size(BBWH,2);
    distOut=zeros(1,Mpoints);
    for i=1:Mpoints
        dist=repmat(BBWH(1,i),[1 Npoints])-Y(1,:);
        distOut(i)=min(sqrt(sum((dist.^2),1)));
    end
end