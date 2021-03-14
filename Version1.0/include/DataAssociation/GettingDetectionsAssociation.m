function [IndexBB,bbALL]=GettingDetectionsAssociation(OverlapMatrix,newbbsAll,ThresholdDetector,bbs,bbALL,AdjustWidthandHeight)
% OverlapMatrix        : Input matrix of overlaps between detections in rows and trackers in columns
% newbbsAll            : All detections before non-max suppression in Low Format
% bbALL                : All detections before non-max suppression in dollar Format
% bbs                  : Detections after non-max suppression, [cLow, rlow, width, height, score]
% ThresholdDetector    : add threshold on detections to choose high overlapped
% AdjustWidthandHeight : Flag if (1) adjust the width and height, (0) do not adjust it. 
%ones using detection score of the corresponding detection
%output:IndexBB cell(length(unique detections)) for every tracker ID get the corresponding IDs of Detections
%%
if (nargin <2),   UseThreshold=0;            else UseThreshold=1;end
if (nargin <6),   AdjustWidthandHeight=0;    end
BNMatrix=im2bw(OverlapMatrix,0.01);
[RowI,ColI]=find(BNMatrix==1);
[SortedRow,IndexS]=sort(RowI);
IDnewbb=ColI(IndexS);%corresponding ID for every newbbsAll
IDsDetector=unique(IDnewbb);
IndexBB=cell(length(IDsDetector),1);
for loopID=IDsDetector'
    temp=find(IDnewbb==loopID) ;
    IndexBB{loopID}=temp;
    if UseThreshold==1
        IndexBB{loopID}=temp(newbbsAll(5,IndexBB{loopID})>ThresholdDetector);
        if AdjustWidthandHeight==1
            W=bbs(loopID,3);
            H=bbs(loopID,4);
            bbALL(IndexBB{loopID},3)=W;
            bbALL(IndexBB{loopID},4)=H;
        end
    end
end