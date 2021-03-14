function [Fi patch] = affineTrainL_ModifiedN(img_color, param0, opt, patchsize, patchnum, Fisize, forMat)
% obtain the dictionary for the SGM

% input --- 
% dataPath: the path for the input images
% param0: the initial affine parameters
% opt: initial parameters
% patchsize: the size of each patch
% patchnum: the number of patches in one candidate
% Fisize: the number of cluster centers
% forMat: the format of the input images in one video, for example '.jpg' '.bmp'.

% output ---
% Fi: the dictionary for the SGM
% patch: the patches obtained from the first frame (vector)

%*************************************************************
%% Copyright (C) Wei Zhong.
%% All rights reserved.
%% Date: 05/2012
if size(img_color,3)==3
    img	= double(rgb2gray(img_color));
else
    img	= double(img_color);
end
if size(img,1)~=opt.tmplsize(1) && size(img,2)~=opt.tmplsize(2)
image = warpimgFunction(img, param0, opt.tmplsize,opt);
else
    image=img;
end
Nimages=size(img,3);
patch = zeros(prod(patchsize), prod(patchnum)*Nimages);

blocksize = size(image);
y = patchsize(1)/2;
x = patchsize(2)/2;

patch_centy = y : 2: (blocksize(1)-y);
patch_centx = x : 2: (blocksize(2)-x);
l =1;
for i=1:Nimages
for j = 1: patchnum(1)                   % sliding window
    for k = 1:patchnum(2)
        data = image(patch_centy(j)-y+1 : patch_centy(j)+y, patch_centx(k)-x+1 : patch_centx(k)+x,i);
        patch(:, l) = reshape(data,numel(data),1);
        l = l+1;
    end
end
end
if Fisize~=size(patch,2)
Fi = formCodebookL(patch, Fisize);      % form the dictionary
else
  Fi=patch;  
end