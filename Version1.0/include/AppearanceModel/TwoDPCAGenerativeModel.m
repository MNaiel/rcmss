function sim=TwoDPCAGenerativeModel(img,bbALL,Trobject,TrackerOpt,f,ID,wimgsTest)
% Compute the similarity to the PGM model
%%
if (nargin <7)
CBB=convertDollarToLowFormat(bbALL(:,1:5));
[wimgsTest]=SampleBBFromImage(img,CBB,TrackerOpt,0);
end
[~,~, ~,~,~,recon]=TestTwoDPCA(Trobject.TwoDPCAparam,wimgsTest,1,TrackerOpt.DA.SigmaPCAGM,0,[],[],f,ID);
sim=exp(-recon/TrackerOpt.DA.SigmaPCAGM);
end