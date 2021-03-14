function Y= ConcatenateWarpImage(wimgs,opt,k,InColor)
% Used to convert the warp images in wimgs of size (mxnxk) into column
% vector and stake them in Matrix Y of size (mnxk).
% Input
% wimgs: images in a volume (mxnxk)
% opt  : options of the feature type.
% k    : number of images
%%
if nargin<4,    InColor=1;else    InColor=0;end
mn = prod(opt.tmplsize);             % vectorization
if opt.UseColorImage==0 || InColor==0;
    Y = zeros(mn, k);
    for i = 1:k
        Y(:,i) = reshape(wimgs(:,:,i), mn, 1);
    end
else
    if opt.Use2DHOG==1
        Nfeat=opt.HOGParam.NLayers;
        mProd=mn/(opt.HOGParam.cellpw^2);
    elseif opt.UseLBP
        Nfeat=1;
        mProd=mn/8;
    elseif opt.Use2DDCT
        Nfeat=1;
        mProd=mn/(opt.DCTParam.BlockSize/opt.DCTParam.CLIP).^2;
    else
        Nfeat=3;
        mProd=mn;
    end
    Y = zeros(mProd*Nfeat, k);
    for i = 1:k,
        Y(:,i) = reshape(wimgs(:,:,:,i), mProd*Nfeat, 1);
    end
end
end
