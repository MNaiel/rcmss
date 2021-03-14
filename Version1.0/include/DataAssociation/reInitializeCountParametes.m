function [AllTrk ValidTracker InCoflictFlag SafeZone]=reInitializeCountParametes(AllTrk,ID,ValidTracker,SafeZone, InCoflictFlag,bbs,f,img,ReInitializeAll,TrackerOpt, DatasetInfo,ResultsOpts)
centers=[bbs(1,1)+bbs(1,3)/2 bbs(1,2)+bbs( 1,4)/2];
if TrackerOpt.TrackerType==1 | TrackerOpt.TrackerType==3 |TrackerOpt.TrackerType==4
    p = [centers(1) centers(2) bbs( 1,3) bbs( 1,4) 0.0]; %centerx, centery, w,h, orientaion
elseif TrackerOpt.TrackerType==2
    p =floor (bbs( 1,1:4));% [cLow, rlow, width, height]
end
AllTrk.Trobject(ID).p=p;
if ReInitializeAll==0
    AllTrk.Trobject(ID).OcclusionFrames=[];
    AllTrk.Trobject(ID).CountOcclusion=0;
    AllTrk.Trobject(ID).OnHold=0;
    AllTrk.Trobject(ID).InOcclusion=0;
    AllTrk.Trobject(ID).GetBackCount=0;
    AllTrk.Trobject(ID).missedCount=0;
    AllTrk.Trobject(ID).KeyFrames=[];
    AllTrk.Trobject(ID).KeyFramesCounter=0;
    AllTrk.Trobject(ID).StartMergFrame=[];
    AllTrk.Trobject(ID).EndMergFrame=[];
    AllTrk.Trobject(ID).OcclusionFrames=[];
    AllTrk.Trobject(ID).StartFrame=f;
    AllTrk.Trobject(ID).UpdateDone=1;
    AllTrk.Trobject(ID).UpdateSGM=1;
    AllTrk.Trobject(ID).OnHoldFrame=0;
    AllTrk.Trobject(ID).ValidTracker=1;
    % AllTrk.Trobject(ID).Master=0;
    ValidTracker(ID)=1;
    InCoflictFlag(ID)=0;
    SafeZone(ID)=0;
    %% remove merge
    AllTrk.Trobject(ID)=InitializeTkrWithNewLocation(AllTrk.Trobject(ID));
    [A_poso A_nego wimgsPos wimgsNeg] = affineTrainG_ModifiedN(img, AllTrk.Trobject(ID).sz, AllTrk.Trobject(ID).opt, AllTrk.Trobject(ID).param, AllTrk.Trobject(ID).num_p, AllTrk.Trobject(ID).num_n, [], AllTrk.Trobject(ID).p0,TrackerOpt.MM.SigmaAffineNegSamples);
    AllTrk.Trobject(ID).A_pos = A_poso;
    AllTrk.Trobject(ID).A_neg = A_nego;
    AllTrk.Trobject(ID).A_poswarp =wimgsPos;
    AllTrk.Trobject(ID).A_negwarp =wimgsNeg;
else
    [AllTrk]=InitializeTracker(AllTrk,ID,f,TrackerOpt, DatasetInfo,img,bbs);
end