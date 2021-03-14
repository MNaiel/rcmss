function recon=Test1DPCA(img,bbALL,Trobject,TrackerOpt,yTest)
% compute the 1D-PCA for test samples in yTest of size (mxnxk)
if (nargin <5)
    CBB=convertDollarToLowFormat(bbALL(:,1:5));
    [yTest]=SampleBBFromImage(img,CBB,TrackerOpt,0);
end
U=Trobject.PCAparam.U;
mu=Trobject.PCAparam.mu;
k=Trobject.PCAparam.k;
%%
Train_Data=Trobject.PCAparam.Train_Data;
Group=Trobject.PCAparam.Group;
iStart=1;iend=size(yTest,3);
% siz(1) = size(yTest,1);siz(2) = size(yTest,2);
for j=[iStart:iend]
    [ccT, yTest_hat]= pcaApply( yTest(:,:,j), U, mu, k );
    ccT=ccT';
    [~, ~,~,~,~,MatchedTo]=DistanceClassifier(ccT,Train_Data,Group);
    Yk=Train_Data(MatchedTo,:)';
    [D,r] = size(U);
    siz = size(yTest);  nd = ndims(yTest);  [D,r] = size(U);
    if(D==prod(siz) && ~(nd==2 && siz(2)==1)); siz=[siz, 1]; nd=nd+1; end
    n = 1;
    % Find Yk, the first k coefficients of X in the new basis
    if( r<=k ); Uk=U; else Uk=U(:,1:k); end;
    muRep = repmat(mu, [ones(1,nd-1), n ] );
    XTrain_hat = Uk * Yk;
    XTrain_hat = reshape( XTrain_hat, siz );
    XTrain_hat = XTrain_hat + muRep;    
    recon(j) = sum(sum((XTrain_hat - yTest_hat).^2));                            % the reconstruction error of each patch
end
if (0)
    figure(1);
    subplot(2,1,1);imshow(uint8(XTrain_hat));title('Reconstructed Training');
    subplot(2,1,2);imshow(uint8(yTest_hat));title('Reconstructed Testing');    
end