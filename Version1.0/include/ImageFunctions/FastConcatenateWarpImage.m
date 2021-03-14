function Y= FastConcatenateWarpImage(wimgs,k,TrackerOpt)
% Used to convert the warp images in wimgs of size (mxnxk) into column
% vector and stake them in Matrix Y of size (mnxk).
% Input
% wimgs: images in a volume (mxnxk)
% opt  : options of the feature type.
% k    : number of images
%%
mn = prod(TrackerOpt.AM.sz);             % vectorization
if isempty(wimgs)
    Y=[];
else
    if TrackerOpt.AM.Feature.UseGS==1
        Y = zeros(mn, k);
        for i = 1:k, Y(:,i) = reshape(wimgs(:,:,i), mn, 1); end
    else
        if TrackerOpt.AM.Feature.Use2DHOG
            Nfeat=TrackerOpt.AM.Feature.HOGParam.NLayers;
            mProd=mn/(TrackerOpt.AM.Feature.HOGParam.cellpw^2);
        elseif TrackerOpt.AM.Feature.UseLBP
            Nfeat=1;
            mProd=mn/8;
        elseif TrackerOpt.AM.Feature.Use2DDCT
            Nfeat=1;
            mProd=mn/(TrackerOpt.AM.Feature.DCTParam.BlockSize/TrackerOpt.AM.Feature.DCTParam.CLIP).^2;
        else
            Nfeat=3;
            mProd=mn;
        end
        Y = zeros(mProd*Nfeat, k);
        for i = 1:k
            Y(:,i) = reshape(wimgs(:,:,:,i), mProd*Nfeat, 1);
        end
    end
end