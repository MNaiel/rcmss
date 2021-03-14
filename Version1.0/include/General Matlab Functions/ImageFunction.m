function Im=ImageFunction(Im,Aav)
% Apply a function on each image before processing
if  nargin<2
    Aav=[];
end
if size(Im,3)>1
    Im=rgb2gray(Im);
end
Im=double(Im);