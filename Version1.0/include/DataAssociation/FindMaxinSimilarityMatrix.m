function [IndexBBTRacker]=FindMaxinSimilarityMatrix(S,ThresholdSimilarity,NumberOfTrackers)
ValidCol=ones(size(S,2),1);
ValidRow=ones(size(S,1),1);
TrackerRange=1:NumberOfTrackers;
IndexBBTRacker=zeros(length(TrackerRange),1);
while sum(sum(S))>0
    C      =max(S(:));
    [row col]=find(S==C);
    S(row, :) =0;
    S(:,col)  =0;
    if C>ThresholdSimilarity
        ValidRow(row)      =0;
        ValidCol(col)      =0;
        IndexBBTRacker(row)=col;
    else
        ValidRow(row)      =0;
        ValidCol(col)      =0;
    end
end