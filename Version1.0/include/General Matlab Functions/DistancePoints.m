function distOut=DistancePoints(BBWH,Y)
% compute the distance between BB, and Y
%%
Npoints=size(Y(1:2,:),2);
dist=repmat(BBWH(1:2,1),[1 Npoints])-Y(1:2,:);
distOut=min(sqrt(sum((dist.^2),1)));