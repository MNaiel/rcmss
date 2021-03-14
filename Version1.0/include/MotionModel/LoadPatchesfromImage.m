function [WarpImages WarpColorImages]=LoadPatchesfromImage(ImIn,BB,sz,nsamples,opt)
% Sample Grayscale patches from an image and extract appropriate features
% ImIn : Input GS image, uint8
%  BB  : Bounding box
%  sz  : the height and the width of the template
% nsamples : number of samples that should be collected
%%
if nargin < 5, ID=zeros(size(BB,2),1); end;
if size(ImIn,3)==3, InGS=0; else    InGS=1;end;
if size(ImIn,3)>1,Im=rgb2gray(uint8(ImIn));else Im=ImIn;end;
WarpColorImages=[];
[n1,n2,n3]=size(Im);
WarpImages=zeros(sz(1), sz(2),nsamples);
if InGS==0
    if opt.Use2DHOG==1
        WarpColorImages=zeros(sz(1)/opt.HOGParam.cellpw, sz(2)/opt.HOGParam.cellpw,opt.HOGParam.NLayers,nsamples);
    elseif opt.UseLBP==1
        WarpColorImages=zeros(sz(1)* sz(2)/8,1,1,nsamples);
    elseif opt.Use2DDCT
        WarpColorImages=zeros(sz(1)/(opt.DCTParam.BlockSize/opt.DCTParam.CLIP),sz(2)/(opt.DCTParam.BlockSize/opt.DCTParam.CLIP),1,nsamples);
    else
        WarpColorImages=zeros(sz(1), sz(2),3,nsamples);
    end
end
for d=1:size(BB,2)
    bb=floor(BB(:,d));
    bb(1)=max(bb(1),1);bb(2)=max(bb(2),1);
    bb(3)=min(bb(3),n2);bb(4)=min(bb(4),n1);
    ClowIm=bb(1);RlowIm=bb(2); CHighIm=bb(3); RHighIm=bb(4);
    if InGS==0
        PatchColor=ImIn(RlowIm:RHighIm,ClowIm:CHighIm,:);
        if isempty(PatchColor)==0
            if opt.Use2DHOG==1
                Temp=rgb2gray(uint8(imresize(PatchColor,[sz(1) sz(2)])));
                [HoGLayers]=Generate2DHOG(Temp,opt.HOGParam.cellpw, opt.HOGParam.nthet,opt.HOGParam.clip, opt.HOGParam.softBin, opt.HOGParam.useHog);
                if opt.UseIntegralChannel
                    WarpColorImages(:,:,:,d)=cat(3,HoGLayers,imresize(Temp,1/opt.HOGParam.cellpw));
                else
                    WarpColorImages(:,:,:,d)=HoGLayers;
                end
            elseif opt.UseLBP
                Temp=rgb2gray(uint8(imresize(PatchColor,[sz(1) sz(2)])));
                H2=LBP(Temp);
                WarpColorImages(:,:,:,d)=H2;                
            elseif opt.Use2DDCT
                Temp=rgb2gray(uint8(imresize(PatchColor,[sz(1) sz(2)])));
                OutIm=ImageTransform(Temp,opt.DCTParam.FlagTransform,opt.DCTParam.mPad,opt.DCTParam.nPad,opt.DCTParam.CLIP,opt.DCTParam.BlockSize);
                WarpColorImages(:,:,1,d)=OutIm;
            else
                WarpColorImages(:,:,:,d)=imresize(PatchColor,[sz(1) sz(2)]);
            end            
        end
        Patch=Im(RlowIm:RHighIm,ClowIm:CHighIm,:);
        if isempty(Patch)==0,   WarpImages(:,:,d)=imresize(Patch,[sz(1) sz(2)]);   end;
    else
        Patch=Im(RlowIm:RHighIm,ClowIm:CHighIm,:);
        if isempty(Patch)==0, WarpImages(:,:,d)=imresize(Patch,[sz(1) sz(2)]);     end;
    end
end
if opt.UseColorImage==0 || InGS==1, WarpColorImages=WarpImages; end
