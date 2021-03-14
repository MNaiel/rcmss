function Im=PerImageFunction(Im,sz)
if  nargin<2
    Aav=[];
end
if size(Im,3)>1
    Im=rgb2gray(Im);
end
Im=double(Im);
Im=imresize(Im,[sz(1) sz(2)]);