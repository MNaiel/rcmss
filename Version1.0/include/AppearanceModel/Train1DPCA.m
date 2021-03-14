function [PCAparam ]=Train1DPCA(Volume,IDs,opt1DPCA)
% Train 1D-PCA model on the input feature volume "Volume".
% Input
% Volume=cell input images of size(n1xn2xj), {trackerID} IDs= class label of every image
% [n1,n2,n3]=size(Volume);
% IDs : input valid trackers ID
%%
if isfield(opt1DPCA,'Alpha'), Alpha= opt1DPCA.Alpha;else    Alpha=0.98;end;
RbyAlpha=1;
cVolume=Volume{IDs};
[ U, mu, D1 ] = pca(cVolume);
if RbyAlpha==1
    SumComm=cumsum(D1);
    if Alpha~=1
        IndexDominant=find(SumComm<Alpha*SumComm(end));
        if isempty(IndexDominant), k=length(SumComm)-1;  else  k=IndexDominant(end);   end;
    else
        k=length(SumComm);
    end
end
Train_Data= pcaApply( cVolume, U, mu, k )';
PCAparam.U=U;
PCAparam.mu=mu;
PCAparam.Train_Data=Train_Data;
PCAparam.k=k;
PCAparam.Group=IDs*ones(size(cVolume,3),1);
PCAparam.TotalNumImages=size(cVolume,3);
PCAparam.FSize=size(Train_Data,2);
end

