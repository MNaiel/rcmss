function wimgs=convertFromVector2Image(X_pos,sz)
[n1 n2]=size(X_pos);
wimgs=zeros(sz(1),sz(2),n2);
for i = 1: n2,    wimgs(:,:,i) = reshape(X_pos(:,i), sz);end