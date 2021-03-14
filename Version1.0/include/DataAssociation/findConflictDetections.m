function [InCoflictFlag,IDsConflictValidTracker]=findConflictDetections(BB,ConflictOverlapThreshold,BBid,ValidTracker)
%input 
% BB                      : in Low FORMAT
% ConflictOverlapThreshold: Threshold on overlap if the overlap ratio greater than this threshold it considered conflict
% BBid                    : detections BB ID
% ValidTracker            :  binary vector for active trackers
%%
[~,~,~,OverlapMatrixConflictAll]=FindOverlapRatioAmongTrackers(BB,BB);
[ID1,ID2]=find(OverlapMatrixConflictAll>ConflictOverlapThreshold);
IDsConflict=[BBid(ID1)',BBid(ID2)'];%IDs of Tracker Conflict
IDsConflictValidTracker=[ID1,ID2];
%check trackers conflict and avoid updates if they are intersecting
Idconflict=unique(IDsConflict);
InCoflictFlag=zeros(length(ValidTracker),1);
InCoflictFlag(Idconflict)=1;
