img=imgdouble;
[n1,n2,~]=size(img_color);
if f>DatasetInfo.NewStartFrame && rem(f, TrackerOpt.CM.DetectorupRate)==0
    %% Run Detector
    TimeObjectDetectorCPU=clock;
    [bbs, bbALL,newbbs]=ApplyFilterDetections(img_color,f,DetectorObj,DatasetInfo,BBDetector{f},BBDetectorAll{f},gt{f}(:,2:end));
    TimeObjectDetector(fIndex)=etime(clock,TimeObjectDetectorCPU);
    if ShowSaveParam.ShowStepsDetector==1 && isempty(bbs)==0
        if exist('H1','var')==0, H1=figure('position',[800 250 size(img,2) size(img,1)]);
        else  figure(H1);
        end
        SHOWBBonImage(img_color,newbbs(1:4,:),newbbs(5,:));
    end
    %%  Terminate trackers located out of the tracking zone
    BBTracker=zeros(4,length(AllTrk.Trobject));
    TimeBeforeDACPU=clock;
    for ID=1:NumberOfTrackers
        if AllTrk.Trobject(ID).ValidTracker
            BBTracker(:,ID)=AllTrk.Trobject(ID).currentBB;
            if ShowSaveParam.ShowSteps==1,    SHOWBBonImage(img,AllTrk.Trobject(ID).currentBB,0,1,1);  end;
            if AllTrk.Trobject(ID).currentBB(1,1) <2 || AllTrk.Trobject(ID).currentBB(3,1) >n2-2 || AllTrk.Trobject(ID).currentBB(2,1) <2  ||AllTrk.Trobject(ID).currentBB(4,1) >n1-2
                ValidTracker(ID)=0; AllTrk.Trobject(ID).ValidTracker=0;
                AllTrk          =TerminateVariables(AllTrk,ID);
                if ShowSaveParam.ShowUpdates, disp(strcat('Tracker ID',num2str(ID),' stopped out of image')); end;
            end
            if TrackerOpt.MM.FilterDetectionMask==1
                if AllTrk.Trobject(ID).ValidTracker
                    cBB=AllTrk.Trobject(ID).currentBB;
                    patchsum=mean(mean(TrackerOpt.MM.MaskImage(max(1,cBB(2)):min(n1,cBB(4)),max(1,cBB(1)):min(n2,cBB(3)),:)));
                    % Percent of ones high :> forground
                    if  patchsum<=TrackerOpt.MM.OverlapThreshold
                        SafeZone(ID)    =0; AllTrk.Trobject(ID).SafeZone=0;
                        ValidTracker(ID)=0; AllTrk.Trobject(ID).ValidTracker=0;
                        AllTrk=TerminateVariables(AllTrk,ID);
                        if ShowSaveParam.ShowUpdates,  disp(strcat('Tracker ID',num2str(ID),' stopped out of ROI')); end;
                    else
                        SafeZone(ID)=1; %in safe zone (default)
                        AllTrk.Trobject(ID).SafeZone=1;
                    end
                else
                    SafeZone(ID)=0;
                    AllTrk.Trobject(ID).SafeZone=0;
                end
            else
                if AllTrk.Trobject(ID).ValidTracker && AllTrk.Trobject(ID).currentBB(1,1) >n2/5 && AllTrk.Trobject(ID).currentBB(3,1) <n2-n2/5
                    SafeZone(ID)=1; %in safe zone (default)
                    AllTrk.Trobject(ID).SafeZone=1;
                else
                    SafeZone(ID)=0;
                    AllTrk.Trobject(ID).SafeZone=0;
                end
            end
        else
            ValidTracker(ID)=0;
        end
    end
    %% Find conflicts in detection windows
    if isempty(bbs)==0
        NumnewDetections       =size(newbbs,2);
        ValidDetections        =true(NumnewDetections,1);
        currentDetectionLabels =1:NumnewDetections;
        TempDetect             =currentDetectionLabels(ValidDetections);
        InCoflictFlagDetections=findConflictDetections(newbbs(1:4,:),TrackerOpt.DA.ConflictOverlapThreshold,TempDetect,ValidDetections);
    end
    %% Find occlusions among active trackers
    currentLabels   =1:NumberOfTrackers;
    Temp            =currentLabels(ValidTracker);
    [OverlapMatrixConflict,NewTrackerNumTemp,StopUpdateNotUsed,OverlapMatrixConflictAll]=FindOverlapRatioAmongTrackers(BBTracker(:,ValidTracker),BBTracker(:,ValidTracker));
    [TrID1,TrID2]   =find(OverlapMatrixConflictAll>TrackerOpt.DA.ConflictThreshold);
    IDsConflict     =[Temp(TrID1)',Temp(TrID2)'];%IDs of Tracker Conflict
    IDsConflictValidTracker=[TrID1,TrID2];
    %% Check trackers occlusion and avoid updates if they are intersecting
    Idconflict               =unique(IDsConflict);
    InCoflictFlag            =zeros(length(currentLabels),1);
    InCoflictFlag(Idconflict)=1;
    StopUpdate(Idconflict)   =1;
    IDsNonConflict           =[];
    %% Adjust parameters for trackers in occlusion
    for ID=Temp
        Index=find(Idconflict(:)'==ID);
        if isempty(Index)==0
            AllTrk.Trobject(ID)                =AdjustOcclusionParameters(AllTrk.Trobject(ID),1);
            AllTrk.Trobject(ID).InOcclusion    =1;
            AllTrk.Trobject(ID).CountOcclusion =AllTrk.Trobject(ID).CountOcclusion+1;
            AllTrk.Trobject(ID).OcclusionFrames=[AllTrk.Trobject(ID).OcclusionFrames, f];
            ValidTrackerTemp    =ValidTracker;
            ValidTrackerTemp(ID)=0;
            AllTrk.Trobject(ID).OcclusionDegree=[AllTrk.Trobject(ID).OcclusionDegree,max(FindOverlapRatio2Trackers(BBTracker(:,ID),BBTracker(:,ValidTrackerTemp)))];
        else
            AllTrk.Trobject(ID)                 =AdjustOcclusionParameters(AllTrk.Trobject(ID),0);
            StopUpdate(ID)=0;
            IDsNonConflict=cat(1,IDsNonConflict,ID);
            if AllTrk.Trobject(ID).InOcclusion==1
                AllTrk.Trobject(ID).missedCount=0;
                AllTrk.Trobject(ID).InOcclusion=0;
            else
                AllTrk.Trobject(ID).InOcclusion=0;
            end
        end
    end
    %% USEGateFunction use current motion model Affine/Constant Velocity MOdel
    % get direction of every tracker and filter motion model output
    % outside this range
    if TrackerOpt.MM.USEGateFunction==1
        for ID=currentLabels(ValidTracker) % prepare results in new coordinates %(this in previous time step) t-1
            if f-AllTrk.Trobject(ID).StartFrame<=TrackerOpt.MM.WindowSizeToMeasureVelocity
                StartFrame1=AllTrk.Trobject(ID).StartFrame;
                ChangeinX  =diff(AllTrk.Trobject(ID).currentCenter(1,StartFrame1:f-1))>0;
                %Positive going to right
                if isempty(ChangeinX)==0
                    ChangeRight=find(ChangeinX>=0);
                    ChangeLeft =find(ChangeinX<0);
                    if length(ChangeRight)> length(ChangeLeft) %going to right
                        AllTrk.Trobject(ID).RightOrLeft=1;
                    else            %going to left
                        AllTrk.Trobject(ID).RightOrLeft=0;
                    end
                else
                    AllTrk.Trobject(ID).RightOrLeft    =-1;
                end
            end
        end
    end
    TimeBeforeDA(fIndex)=etime(clock,TimeBeforeDACPU);
    %%  Data Association
    TimeDataAssociationCPU=clock;
    if isempty(bbs)==0
        currentLabels=1:NumberOfTrackers;
        avoidMultiDetection=0;
        if TrackerOpt.DA.DoubleHightInOverlap==1
            BBD      =ScaleBBSize(newbbs(1:4,:),TrackerOpt.DA.ScaleBBOpt,imgInt);
            BBtracker=ScaleBBSize(BBTracker(:,ValidTracker),TrackerOpt.DA.ScaleBBOpt,imgInt);
        else
            BBD      =newbbs(1:4,:);
            BBtracker=BBTracker(:,ValidTracker);
        end
        [~,~,OverlapMatrixAllDt2Tr]=FindOverlapRatio(BBD,BBtracker,avoidMultiDetection);%size of detectedxValidTrackers
        [IDTerminate,IDCreateNew,IndexBBTRacker,~,TrackerOpt]=DataAssociation(imgdouble, bbs,AllTrk,NumberOfTrackers,ValidTracker,OverlapMatrixAllDt2Tr,f,TrackerOpt,img_color,ShowSaveParam);
        NewTrackerNum =IDCreateNew;
    else
        IDTerminate   =[];            IndexBBTRacker=[];            NewTrackerNum =[];
    end
    TimeDataAssociation(fIndex)=etime(clock,TimeDataAssociationCPU);
    %% Merge trackers if they are in conflict and moving in the same direction
    TimeMergeCPU=clock;
    if TrackerOpt.DA.useMerge==1,  [AllTrk,IDTerminate,InCoflictFlag,StopUpdate,IndexBBTRacker]=TrackerInMerge(AllTrk,BBTracker,imgdouble,f,bbs,TrackerOpt,DatasetInfo,ShowSaveParam,ResultsOpts,SafeZone,NumberOfTrackers,ValidTracker,IDsNonConflict,InCoflictFlag,Idconflict,IDsConflict,StopUpdate,IDTerminate,IndexBBTRacker);  end;
    TimeMerge(fIndex)=etime(clock,TimeMergeCPU);
    %% Adjust the bounding boxes of the detectors to support the motion model
    if isempty(bbs)==0 && TrackerOpt.CM.EnableDetectorGuide==1
        if TrackerOpt.CM.UseBeforeorAfterNonMaxSup==1
            newbbsAll   =convertDollarToLowFormat(bbALL(:,1:5));
            avoidMultiDetection=0;
            OverlapMatrix=FindOverlapRatio(newbbsAll(1:4,:),newbbs(1:4,:),avoidMultiDetection);
            IndexBB      =GettingDetectionsAssociation(OverlapMatrix,newbbsAll,DetectorObj.ThresholdDetector,bbs,bbALL);
            Trackers     =AllTrk.Trobject;
            currentLabels=1:NumberOfTrackers;
            bbALL        =GettingAllDetectionsAssociation2Tracker(Trackers,bbALL,IndexBB,TrackerOpt.CM.AdjustWidthandHeight,ValidTracker,currentLabels,IndexBBTRacker);
            bbOut        =convertDollarToLowFormat(bbALL(:,1:4));
            bbOutAffine  =convertLowFormattoAffine(bbOut,TrackerOpt.AM.sz);
        else
            bbALL        =bbs;
            newbbsAll    =convertDollarToLowFormat(bbALL(:,1:5));
            avoidMultiDetection=0;
            OverlapMatrix=FindOverlapRatio(newbbsAll(1:4,:),newbbs(1:4,:),avoidMultiDetection);
            IndexBB      =GettingDetectionsAssociation(OverlapMatrix,newbbsAll,DetectorObj.ThresholdDetector,bbs,bbALL);
            if TrackerOpt.CM.AdjustWidthandHeight==1
                IDsTrack=currentLabels(ValidTracker);
                for loopID=IDsTrack(:)'         %TrackerID
                    temp=IndexBBTRacker{loopID};%DetectorID
                    if not(isempty(temp))
                        W0=AllTrk.Trobject(loopID).LeftTopWHT(1,3);
                        H0=AllTrk.Trobject(loopID).LeftTopWHT(1,4);
                        DW=(bbs(temp,3)-W0)*TrackerOpt.CM.RateOfChangeW; %Pos: Increase,  Neg: Decrease
                        DH=(bbs(temp,4)-H0)*TrackerOpt.CM.RateOfChangeH; %Pos: Increase,  Neg: Decrease
                        bbs(temp,3)=W0+DW;
                        bbs(temp,4)=H0+DH;
                    end
                end
            end
            bbOut       =convertDollarToLowFormat(bbs(:,1:4));
            bbOutAffine =convertLowFormattoAffine(bbOut,TrackerOpt.AM.sz);
        end
    end
    %% Default assume tracker has associated detection
    for ID= 1:NumberOfTrackers;  AllTrk.Trobject(ID).missedDetections(f)=0;  end
    %% Check if tracker change direction then terminate it
    TimeChangeDirectionCPU=clock;
    if TrackerOpt.MM.ChangeDirectionCheck==1
        TrackerRange=1:NumberOfTrackers;
        for ID= TrackerRange(ValidTracker)
            StartFrame1=AllTrk.Trobject(ID).StartFrame;
            Right=diff(AllTrk.Trobject(ID).currentCenter(1,StartFrame1:f-1))>0;
            if TrackerOpt.MM.WindowLastIteration<length(Right)
                Left=not(Right);
                if sum(Right)>sum(Left),   Indector=Right;      else   Indector=Left; end;
                if sum(Indector(end-TrackerOpt.MM.WindowLastIteration:end))>TrackerOpt.MM.WindowLastIteration-3
                    % low number of missed detections
                    continue;
                else
                    ValidTracker(ID)=0;AllTrk.Trobject(ID).ValidTracker=0;
                    if AllTrk.Trobject(ID).InOcclusion ==0 &&   AllTrk.Trobject(ID).KeyFramesCounter <2
                        AllTrk=TerminateVariables(AllTrk,ID);
                        if ShowSaveParam.ShowUpdates,   disp(strcat('Tracker ID',num2str(ID),' Terminated- Change Direction'));     end;
                    elseif TrackerOpt.DA.useOnHoldMissedDetections==1
                        AllTrk.Trobject(ID).OnHold     =1;
                        AllTrk.Trobject(ID).OnHoldFrame=f-1;
                        AllTrk.Trobject(ID)=DoOnHoldSubroutine(AllTrk.Trobject(ID),ID,TrackerOpt);
                        if ShowSaveParam.ShowUpdates,   disp(strcat('Tracker ID',num2str(ID),' onhold'));                            end;
                    end
                end
            end
        end
    end
    TimeChangeDirection(fIndex)=etime(clock,TimeChangeDirectionCPU);
    %% Count missed detections of every tracker and terminate/on-hold it if the detection missing exceeded a certain threshold
    TimeStatisticscpu=clock;
    if isempty(bbs)==0 && isempty(IDTerminate)==0
        for ID=IDTerminate(:)'
            [VInitialx VInitialy]=ComputeVelocity(AllTrk.Trobject(ID),TrackerOpt.MM.VelocityMotionModel);
            VI=sum(sqrt(VInitialx.^2+ VInitialy.^2));
            if VI< TrackerOpt.DA.ThresholdSpeed
                missedDetectionsThreshold=TrackerOpt.DA.ThresholdLowSpeed;
            else
                if AllTrk.Trobject(ID).InMerge==1 && TrackerOpt.DA.removeMergedOBjectsFromTermination==0
                    missedDetectionsThreshold=TrackerOpt.DA.ThresholdInMerge;
                elseif AllTrk.Trobject(ID).InOcclusion==1
                    missedDetectionsThreshold=TrackerOpt.DA.ThresholdOcclusion;
                else
                    missedDetectionsThreshold=TrackerOpt.DA.ThresholdwithOutOcclusion;
                end
            end
            if f-TrackerOpt.MM.WindowMissTest>0 && sum(AllTrk.Trobject(ID).missedDetections(f-TrackerOpt.MM.WindowMissTest:f))>=1%previous missing
                AllTrk.Trobject(ID).missedDetections(f)=1;
                AllTrk.Trobject(ID).missedCount=AllTrk.Trobject(ID).missedCount+1;
                if ShowSaveParam.ShowUpdates
                    disp(strcat('Tracker ID',num2str(ID),' stop missed count=',num2str(AllTrk.Trobject(ID).missedCount)));
                end
                if AllTrk.Trobject(ID).missedCount>missedDetectionsThreshold
                    ValidTracker(ID)=0;AllTrk.Trobject(ID).ValidTracker=0;
                    if (1) && AllTrk.Trobject(ID).InOcclusion ==0 &&   AllTrk.Trobject(ID).KeyFramesCounter <2
                        if ShowSaveParam.ShowUpdates
                            disp(strcat('Tracker ID',num2str(ID),' Terminated - Missed detections =', num2str(AllTrk.Trobject(ID).missedCount)));
                        end
                        AllTrk=TerminateVariables(AllTrk,ID);
                    elseif TrackerOpt.DA.useOnHoldMissedDetections==1
                        AllTrk.Trobject(ID).OnHold=1;
                        AllTrk.Trobject(ID).OnHoldFrame=f-1;
                        AllTrk.Trobject(ID)=DoOnHoldSubroutine(AllTrk.Trobject(ID),ID,TrackerOpt);
                        if ShowSaveParam.ShowUpdates
                            disp(strcat('Tracker ID',num2str(ID),' onhold'));
                        end
                    end
                end
            else %comeback to detect  or first miss
                AllTrk.Trobject(ID).missedDetections(f)=1;
                AllTrk.Trobject(ID).GetBackCount=AllTrk.Trobject(ID).GetBackCount+1;
                if ShowSaveParam.ShowUpdates,           disp(strcat('Tracker ID',num2str(ID),' GetBack count=',num2str(AllTrk.Trobject(ID).GetBackCount)));   end;
                if AllTrk.Trobject(ID).GetBackCount<TrackerOpt.DA.GetBackThreshold
                    AllTrk.Trobject(ID).missedCount=0;
                else
                    ValidTracker(ID)=0;AllTrk.Trobject(ID).ValidTracker=0;
                    if AllTrk.Trobject(ID).InOcclusion ==0 &&   AllTrk.Trobject(ID).KeyFramesCounter <TrackerOpt.DA.TrustKeyFramesThreshold %to reduce FP detections
                        AllTrk=TerminateVariables(AllTrk,ID);
                        if ShowSaveParam.ShowUpdates,   disp(strcat('Tracker ID',num2str(ID),' Terminated', '-insufficient keysamples'));     end;
                    elseif TrackerOpt.DA.useOnHoldMissedDetections==1
                        AllTrk.Trobject(ID).OnHold=1;
                        AllTrk.Trobject(ID).OnHoldFrame=f-1;
                        AllTrk.Trobject(ID)=DoOnHoldSubroutine(AllTrk.Trobject(ID),ID,TrackerOpt);
                        if ShowSaveParam.ShowUpdates,  disp(strcat('Tracker ID',num2str(ID),' onhold', '-Exceed missedDetectionsThreshold')); end;
                    end
                end
            end
        end
    end
    TimeStatistics(fIndex)=etime(clock,TimeStatisticscpu);
    %% Check if a new detection match a tracker on-Hold for reactivation
    TimeCheckOnHoldcpu=clock;
    [AllTrk,NewTrackerNum,IndexBBTRacker,ValidTracker, InCoflictFlag, SafeZone]=TrackerRedetection(AllTrk,imgdouble,f,bbs,NumberOfTrackers,TrackerOpt, DatasetInfo,ShowSaveParam,ResultsOpts,IndexBBTRacker,ValidTracker,NewTrackerNum,InCoflictFlag,SafeZone);
    TimeCheckOnHold(fIndex)=etime(clock,TimeCheckOnHoldcpu);
    TimeCreateTrackerscpu=clock;
    %% Create new tracker(s) for unassociated detection(s)
    if isempty(NewTrackerNum)==0 && isempty(bbs)==0
        CurrentN=NumberOfTrackers;
        NumberOfTrackers=NumberOfTrackers+length(NewTrackerNum);
        indexID=0;
        trackersUpdate=zeros(1,NumberOfTrackers);
        for ID=CurrentN+1:NumberOfTrackers
            if ShowSaveParam.ShowUpdates, disp(strcat('Tracker ID',num2str(ID),' created'));       end;
            indexID=indexID+1;
            AllTrk.Trobject(ID).p=[];
            AllTrk=InitializeTracker(AllTrk,ID,f,TrackerOpt, DatasetInfo,imgdouble,bbs(NewTrackerNum(indexID),:));
            if AllTrk.Trobject(ID).ValidTracker==1
                StopUpdate(ID)=1;  AllTrk.Trobject(ID).StopUpdate=1;
                ValidTracker(ID)=1;AllTrk.Trobject(ID).ValidTracker=1;
                InCoflictFlag(ID)=0;
                SafeZone(ID)=1;    AllTrk.Trobject(ID).SafeZone=1;
                IndexBBTRacker{ID}=[]; %#ok<*SAGROW>
                trackersUpdate(ID)=1; AllTrk.Trobject(ID).UpdateSGM =1;
            else
                StopUpdate(ID)=1;  AllTrk.Trobject(ID).StopUpdate=1;
                ValidTracker(ID)=0;AllTrk.Trobject(ID).ValidTracker=0;
                InCoflictFlag(ID)=0;
                SafeZone(ID)=0;    AllTrk.Trobject(ID).SafeZone=0;
                IndexBBTRacker{ID}=[]; %#ok<*SAGROW>
                trackersUpdate(ID)=0; AllTrk.Trobject(ID).UpdateSGM =0;
            end
        end
    end
    TimeCreateTrackers(fIndex)=etime(clock,TimeCreateTrackerscpu);
end
TimeSmallParametercpu=clock;
TrackerRange=1:NumberOfTrackers;
IndexLeft=0;IndexRight=0;
if TrackerOpt.MM.ComputeLeftRightVelocity==1
    if isempty(AVLeftx)==1 || isempty(AVRightx)==1
        AVLeftxTemp=0;AVLeftyTemp=0;AVRightxTemp=0;
        AVRightyTemp=0;
        for ID=TrackerRange(ValidTracker)
            if isempty(AllTrk.Trobject(ID).VInitialx)==0
                if AllTrk.Trobject(ID).VInitialx>0 %left going to right
                    IndexLeft=IndexLeft+1;
                    AVLeftxTemp= AVLeftxTemp+AllTrk.Trobject(ID).VInitialx;
                    AVLeftyTemp= AVLeftyTemp+AllTrk.Trobject(ID).VInitialy;
                else%from right going to left
                    IndexRight=IndexRight+1;
                    AVRightxTemp=AVRightxTemp+AllTrk.Trobject(ID).VInitialx;
                    AVRightyTemp=AVRightyTemp+AllTrk.Trobject(ID).VInitialy;
                end
            end
        end
        if IndexLeft>0,  AVLeftxTemp=AVLeftxTemp./IndexLeft;    AVLeftx=AVLeftxTemp;  end;
        if IndexRight>0, AVRightxTemp=AVRightxTemp./IndexRight; AVRightx=AVRightxTemp;end;
    end
end
%% Load special flags for every detector
for ID= TrackerRange(ValidTracker)
    if AllTrk.Trobject(ID).ValidTracker
        if (AllTrk.Trobject(ID).SafeZone==0 || AllTrk.Trobject(ID).InOcclusion==1 ) &&  f-AllTrk.Trobject(ID).StartFrame>TrackerOpt.MM.VelocityMotionModel.Window
            if  AllTrk.Trobject(ID).InMerge==1 &&  AllTrk.Trobject(ID).InMergewithOcclusion==0 % Tracker in merge only and no occlusion
                AllTrk.Trobject(ID).UseMotionModelAffineORVecolity1=TrackerOpt.MM.Vecolity1inMerge;%in case of associated detection exist
                AllTrk.Trobject(ID).UseMotionModelAffineORVecolity2=TrackerOpt.MM.Vecolity2inMerge;%in case of no associated detection
            elseif AllTrk.Trobject(ID).SafeZone==0 % if a tracker is in occlusion
                AllTrk.Trobject(ID).UseMotionModelAffineORVecolity1=TrackerOpt.MM.UseVelocityModel;
                AllTrk.Trobject(ID).UseMotionModelAffineORVecolity2=TrackerOpt.MM.UseVelocityModel2;
            else
                AllTrk.Trobject(ID).UseMotionModelAffineORVecolity1=TrackerOpt.MM.UseVelocityModel1;
                AllTrk.Trobject(ID).UseMotionModelAffineORVecolity2=TrackerOpt.MM.UseVelocityModel2;
            end
        else
            AllTrk.Trobject(ID).UseMotionModelAffineORVecolity1=TrackerOpt.MM.UseMotionModelAffineORVecolity1;%in case of associated detection exist
            AllTrk.Trobject(ID).UseMotionModelAffineORVecolity2=TrackerOpt.MM.UseMotionModelAffineORVecolity2;%in case of no associated detection
        end
    end
end
TimeSmallParameter(fIndex)=etime(clock,TimeSmallParametercpu);