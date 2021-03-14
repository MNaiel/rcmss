function [wimgs Y wimgsColor BadExampleIndex]=SampleBBFromImage(img,CBB,TrackerOpt,Vectorize)
% Collect samples from img and vectrorize them
% Input
% img  : Input frame
% p    : Bounding box dimensions
% sz   : Size of the template
% if TrackerOpt.AM.Feature.warpType ==1, then use warpimg
% if TrackerOpt.AM.Feature.warpType ==0, then use LoadGSPatchesfromImage
% if Vectorize ==1, then vectorize the data, otherwise save cost and
% return.
%%
BadExampleIndex=[];
n = size(CBB,2);
if TrackerOpt.AM.Feature.UseGS
    [wimgs BadExampleIndex]=LoadGSPatchesfromImage(img,CBB,TrackerOpt.AM.sz,n);
    wimgsColor=wimgs;
else
    [wimgs wimgsColor]=LoadPatchesfromImage(img,CBB,TrackerOpt.AM.sz,n,TrackerOpt.MM.opt);
end
if Vectorize
    Y= FastConcatenateWarpImage(wimgs,n,TrackerOpt);
else
    Y=[];
end
end