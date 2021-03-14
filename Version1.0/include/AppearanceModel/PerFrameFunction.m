function [imgdouble, imgInt]=PerFrameFunction(img_color,opt)
% Apply a function on each image before processing
%%
if opt.UseColorImage==1    
    imgdouble=double(img_color);
elseif opt.Use2DHOG==1
    imgdouble=double(img_color);
else
    if size(img_color,3)==3
        img	= rgb2gray(img_color);
    else
        img	= img_color;
    end
    imgdouble=double(img);
    imgInt=uint8(img);    
end
