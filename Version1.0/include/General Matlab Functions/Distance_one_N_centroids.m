function error=Distance_one_N_centroids(ccT,CCW,PNorm,DistType)
global CCWMahla 
% DistType :'Manhattan'  'Minkowsky' 'Chebychev''Camberra' 'Mahalanobis'
n1=size(CCW,1);
error=zeros(n1,1);
if  nargin<4 | isempty(DistType)
    for j=1:n1
        A=(ccT-CCW(j,:));
        error(j)=norm(A,PNorm);
    end
elseif strcmp(DistType,'Manhattan')
    for j=1:n1
        A=ccT-CCW(j,:);
        error(j)=sum(abs(A));
    end
elseif strcmp(DistType,'Minkowsky')
    for j=1:n1
        A=ccT-CCW(j,:);
        error(j)=sum(abs(A).^PNorm)^(1/PNorm);
    end
elseif strcmp(DistType,'Chebychev')
    for j=1:n1
        A=ccT-CCW(j,:);
        error(j)=max(A);
    end
elseif strcmp(DistType,'Camberra')
    for j=1:n1
        A=ccT-CCW(j,:);
        B=ccT+CCW(j,:);
        error(j)=sum(abs(A)./abs(B));
    end
elseif strcmp(DistType,'Mahalanobis')
    error = mahal(ccT,CCWMahla); % Mahalanobis
elseif strcmp(DistType,'CosSimilarity')
    for j=1:n1
        error(j) = dot(ccT,CCW(j,:))/(norm(CCW(j,:))*norm(ccT));
    end
end