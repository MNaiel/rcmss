function [Dist]=DistanceFunction(bbs,Trobject,img)
global PNorm DistType
bbOut=convertDollarToLowFormat(bbs);
Dist=Distance_one_N_centroids(bbOut(1:4,:)',Trobject.currentBB',PNorm,DistType);

