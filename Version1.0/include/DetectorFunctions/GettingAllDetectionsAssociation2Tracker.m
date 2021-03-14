function [ bbALL]=GettingAllDetectionsAssociation2Tracker(Trackers,bbALL,IndexBBinput,AdjustWidthandHeight,ValidTracker,currentLabels,IndexBBTRacker)
% Adjust the width and the height of new associated detections at time t using
% previous detection result at time t-1.
% Input:
% Trackers: input trackers object
% bbALL: [cLow, rlow, width, height, score]
% IndexBBinput: cell contains the trackers BB
% AdjustWidthandHeight : Flag if (1) adjust the width and height, (0) do not adjust it.
% ValidTracker:  binary vector for active trackers
% currentLabels: current trackers labels
% IndexBBTRacker: detector id corresponds to the tracker id
% output the modified  bbALL: [cLow, rlow, width, height, score]
%%
IDsTrack=currentLabels(ValidTracker);
for loopID=IDsTrack'%TrackerID
    temp=IndexBBTRacker{loopID};%DetectorID
    if AdjustWidthandHeight==1 & not(isempty(temp))
        bbsTr=Trackers(loopID).p;
        W=bbsTr(1,3);
        H=bbsTr(1,4);
        bbALL(IndexBBinput{temp},3)=W;
        bbALL(IndexBBinput{temp},4)=H;
    end
end