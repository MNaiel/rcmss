function NewIndex=MapRangeTrackers(OldIndex, OldRangeReduced)
%%
NewIndex=zeros(length(OldIndex),1);
Index=0;
for JiD=OldIndex(:)'
    Index=Index+1;
    NewIndex(Index)=find(OldRangeReduced==JiD);    
end
    
