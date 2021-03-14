function [wimgs wimgsColor p BadExample]=warpimgFunction(img, p, sz,opt)
% Collect samples from img
% Input 
% img  : Input frame
% p    : Bounding box dimensions 
% sz   : Size of the template 
% if TrackerOpt.AM.Feature.warpType ==1, then use warpimg
% if TrackerOpt.AM.Feature.warpType ==0, then use LoadGSPatchesfromImage
%%
if opt.warpType==1
    wimgs=warpimg(double(img), p, sz);
      wimgsColor=wimgs;
      V=zeros(1, size(p,2));
      for j=1: size(p,2);
          V(j)=sum(sum(wimgs(:,:,j)));
      end
      BadExample=find(V==0);
      if isempty(BadExample)==0          
          if size(wimgsColor,3) == size(wimgs,3)
              wimgs(:,:,BadExample)=[];
              wimgsColor(:,:,BadExample)=[];
          else
              wimgs(:,:,BadExample)=[];
              wimgsColor(:,:,:,BadExample)=[];
          end
          p(:,BadExample)=[];
      end
else
    CBB=convertAfftolowFormat(p,sz);
    n = size(p,2);
    if opt.UseGS
        [wimgs BadExample]=LoadGSPatchesfromImage(img,CBB,sz,n);
        wimgsColor=wimgs;
    else
        [wimgs wimgsColor]=LoadPatchesfromImage(img,CBB,sz,n,opt);
    end
    p(:,BadExample)=[];
end

