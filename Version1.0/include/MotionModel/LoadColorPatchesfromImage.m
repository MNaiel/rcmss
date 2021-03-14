function WarpImages=LoadColorPatchesfromImage(Im,BB,sz,nsamples)
[n1,n2,n3]=size(Im);
WarpImages=zeros(sz(1), sz(2),n3,nsamples);
for d=1:size(BB,2)
    bb=floor(BB(:,d));
    bb(1)=max(bb(1),1);bb(2)=max(bb(2),1);
    bb(3)=min(bb(3),n2);bb(4)=min(bb(4),n1);
    ClowIm=bb(1);RlowIm=bb(2); CHighIm=bb(3); RHighIm=bb(4);
    Patch=Im(RlowIm:RHighIm,ClowIm:CHighIm,:);
    if isempty(Patch)==0,    WarpImages(:,:,:,d)=imresize(Patch,[sz(1) sz(2)]); end;
end