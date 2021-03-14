function sim=OneDPCAGenerativeModel(img,bbALL,Trobject,TrackerOpt,yTest)
% compute the 1D-PCA for test samples in yTest of size (mxnxk)
%%
if (nargin <5)
    CBB=convertDollarToLowFormat(bbALL(:,1:5));
    [yTest]=SampleBBFromImage(img,CBB,TrackerOpt,0);
end
recon=Test1DPCA(img,bbALL,Trobject,TrackerOpt,yTest);
sim=exp(-recon/TrackerOpt.AM.PCAGM.Sigma);
end


