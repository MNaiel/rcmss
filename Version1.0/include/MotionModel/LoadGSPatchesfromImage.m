function [WarpImages BadExample]=LoadGSPatchesfromImage(ImIn,BB,sz,nsamples,minLength)
% Sample Grayscale patches from an image
% ImIn : Input GS image, uint8
%  BB  : Bounding box
%  sz  : the height and the width of the template
% nsamples : number of samples that should be collected
%%
if nargin < 5, minLength=0;end
[n1,n2,n3]=size(ImIn);
WarpImages=zeros(sz(1),sz(2),nsamples);
BB=floor(BB);
if minLength==1
    BB(1,:)=max(BB(1,:),1);BB(2,:)=max(BB(2,:),1);
    BB(3,:)=min(BB(3,:),n2);BB(4,:)=min(BB(4,:),n1);
end
BadExample=[];
for d=1:size(BB,2)
    if  minLength==0 && ((BB(1,d)>BB(3,d)|| BB(1,d)<1 ||  BB(3,d) >= n2) || (BB(2,d)>BB(4,d) || BB(2,d)<1 ||  BB(4,d) >=n1)) %remove bad samples
        BadExample=[BadExample,d];
    else
        Patch=ImIn(BB(2,d):BB(4,d),BB(1,d):BB(3,d),:);
        if isempty(Patch)==0
            WarpImages(:,:,d)=imResample((Patch),sz,'bilinear');%%Dollar Toolbox 10x faster
        end
    end
end
WarpImages(:,:,BadExample)=[];
WarpImages=double(WarpImages);