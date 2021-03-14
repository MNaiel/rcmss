function [Class, MinDistance,MaxCounter,MinDistance2,MeanRatio,MatchedTo]=DistanceClassifier(ccT,Train_Data,Group)
global PNorm KnnNumber DistType
Dist1=Distance_one_N_centroids(ccT,Train_Data,PNorm,DistType);
[SortedDist,Label]=sort(Dist1);%min to max
MaxCounter=0;
if KnnNumber~=1
    InitialClass=Group(Label(1:KnnNumber));%Minimum Class
    reducedClass = unique(InitialClass);
    L1=length(reducedClass);% Number of Labels
    for i=1:L1
        Index=find(InitialClass==reducedClass(i));
        Counter(i)=length(Index);%Number of centroids per class
    end
    MaxCounter=(max(Counter));
    Index=find(Counter==MaxCounter);
    if (length(Index)==1)
        Class=reducedClass(Index);
    else
        Class=Group(Label(1));
    end
    MatchedTo=Label(1:KnnNumber);
else
    Class=Group(Label(1));
    MatchedTo=Label(1);
end
MinDistance=SortedDist(1);
Index2=(Group~=Class);
if isempty(Index2)
    SortedDist2=sort(Dist1(Index2));
    IndexNan=isnan(SortedDist2);
    SortedDist2(IndexNan)=[];
    MinDistance2=SortedDist2(1);
    
    Index1=(Group==Class);
    SortedDist1=(Dist1(Index1));
    IndexNan=isnan(SortedDist1);
    SortedDist1(IndexNan)=[];
    
    Av1=std(SortedDist1);
    Av2=std(SortedDist2);
    MeanRatio=(Av2+Av1)/Av1;
else
    SortedDist1=[];
    SortedDist2=[];
    MeanRatio=10000;
    MinDistance2=10000;
end