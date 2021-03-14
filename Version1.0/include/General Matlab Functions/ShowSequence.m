function ShowSequence(V,show,string)
% Show video sequence V
%%
if (nargin <3),  string=strcat('#Enter a title'); end;
if show==1
    for i=1:size(V,3)
        imagesc(V(:,:,i));
        title( strcat(string,'#Sequence',int2str(i))) ;
        colormap(gray);
        axis image off
        axis image
        drawnow;
    end
elseif show==3
    for i=1:size(V,4)
        imshow(V(:,:,:,i));
        drawnow;
    end
end
