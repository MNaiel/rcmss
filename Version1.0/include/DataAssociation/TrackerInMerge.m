function [AllTrk,IDTerminate,InCoflictFlag,StopUpdate,IndexBBTRacker]=TrackerInMerge(AllTrk,BBTracker,imgdouble,f,bbs,TrackerOpt,DatasetInfo,ShowSaveParam,ResultsOpts,SafeZone,NumberOfTrackers,ValidTracker,IDsNonConflict,InCoflictFlag,Idconflict,IDsConflict,StopUpdate,IDTerminate,IndexBBTRacker)
% program to run in case of TrackerOpt.DA.useMerge==1
% Input/Output AllTrk the tracker object AllTrk
% imgdouble      : input frame at time t
% f              : frame number
% bbs            : Input bbs to intialize the tracker in Dollar Format 
% TrackerOpt     : Options and parameters of the tracker. 
% DatasetInfo    : Dataset options and parameters
% ShowSaveParam  : show / save parameters values 
% ResultsOpts    : Results options 
% SafeZone       : (1) tracker away from the borders (0) tracker close to
% the image borders
% NumberOfTrackers: Number of trackers
% ValidTracker   : binary vector for active trackers
% IDsNonConflict : IDs of not occluded trackers
% Idconflict     : IDs of trackers in occlusion
% IDTerminate    : IDs of trackers that should be terminated
%%
if TrackerOpt.DA.useMerge==1
    currentLabels=1:NumberOfTrackers;
    Temp=currentLabels(ValidTracker);
    if TrackerOpt.DA.UseMasterSlaveMerge==1
        for ID=IDsNonConflict(:)'
            if AllTrk.Trobject(ID).InMerge==1
                Id2=AllTrk.Trobject(ID).MergeWith;
                IDsConflict=[IDsConflict, ID];
                if Id2 ~=0
                    if AllTrk.Trobject(ID).Master==0
                        AllTrk.Trobject(ID).Master=1;
                        AllTrk.Trobject(Id2).Master=0;
                    end
                end
            end
        end
    end
    for ID=IDsNonConflict(:)'
        if AllTrk.Trobject(ID).InMerge==1
            AllTrk.Trobject(ID).InMergeCountSplit=AllTrk.Trobject(ID).InMergeCountSplit+1;
            Id2=AllTrk.Trobject(ID).MergeWith;
            Indexmerg=find(IDsNonConflict(:)==Id2);
            if AllTrk.Trobject(ID).InMergeCountSplit>TrackerOpt.DA.SplitThreshold && isempty(Indexmerg)==0 && isempty(IndexBBTRacker)==0 && isempty(IndexBBTRacker{ID})==0 && isempty(IndexBBTRacker{Id2})==0
                AllTrk.Trobject(ID).InMerge=0;
                AllTrk.Trobject(ID).InMergeCount=0;
                if Id2 ~=0
                    AllTrk.Trobject(Id2).MergeWith=0;
                    AllTrk.Trobject(Id2).InMerge=0;
                    AllTrk.Trobject(Id2).InMergeCount=0;
                    if TrackerOpt.DA.UseMasterSlaveMerge==1
                        if AllTrk.Trobject(ID).Master==0
                            AllTrk.Trobject(ID).Master=1;
                            AllTrk.Trobject(Id2).Master=0;
                        end
                    end
                end
                AllTrk.Trobject(ID).MergeWith=0;
                if TrackerOpt.DA.ReInitializeSDCforAfterMerge==1
                    for IDLoop=[ID Id2]
                        if  AllTrk.Trobject(IDLoop).ValidTracker==1
                            AllTrk.Trobject(IDLoop).UpdateDone=1;
                            DetectionID=IndexBBTRacker{IDLoop};
                            tempLoop=f;
                            [AllTrk]=reInitializeCountParametes(AllTrk,IDLoop,ValidTracker,SafeZone, InCoflictFlag,bbs(DetectionID,:),TrackerOpt.TrackerType,tempLoop,DatasetInfo.MainFolder,DatasetInfo.CurrentDir,ShowSaveParam.SaveWaripImages,ResultsOpts.SaveDirectory,DatasetInfo.DatasetName,DatasetInfo.finalTest,TrackerOpt.DA.ReInitializeAll);
                            
                            AllTrk.Trobject(IDLoop).KeyFrames=[];
                        end
                    end
                end
            end
        end
    end
    for ID=Temp(:)'
        if AllTrk.Trobject(ID).InOcclusion==1 && AllTrk.Trobject(ID).InMerge==0 %IDsConflict contain conflict pairs
            if isempty(AllTrk.Trobject(ID).RightOrLeft)==1 && f-AllTrk.Trobject(ID).StartFrame>TrackerOpt.DA.MergeParam.InconflictWindow
                PrevCenter=convertlowFormattoCenter( AllTrk.Trobject(ID).BBresult(:,f-2));%previous-1 Center
                CurrentCenter=convertlowFormattoCenter( AllTrk.Trobject(ID).BBresult(:,f-1));%previous Center
                StartValue= AllTrk.Trobject(ID).StartFrame;
                FrameInWindow=convertlowFormattoCenter( AllTrk.Trobject(ID).BBresult(:,StartValue:StartValue+TrackerOpt.DA.MergeParam.InconflictWindow));%previous-1 Center
                VInitial=mean(diff(FrameInWindow(1,:)));
                Vcurrent=mean(diff([PrevCenter(1) CurrentCenter(1)]));
                if VInitial~=0 && Vcurrent~=0 && VInitial*Vcurrent>0 %moving in the same dirrection check
                    if VInitial>0 %check right
                        AllTrk.Trobject(ID).RightOrLeft=1;
                    else%check left
                        AllTrk.Trobject(ID).RightOrLeft=0;
                    end
                end
                
            end
        end
    end
    if isempty(IDsConflict)==0
        index=0;
        Nrows=size(IDsConflict,1);
        ConflictMatrix=zeros(length(Idconflict),length(Idconflict));
        for RowID=1:Nrows
            for ID1=IDsConflict(RowID,1)
                ID1Label=find(Idconflict==ID1);
                index=index+1;
                ID2=IDsConflict(RowID,2);
                ID2Label=find(Idconflict==ID2);
                if isempty(AllTrk.Trobject(ID1).RightOrLeft)==0 && isempty(AllTrk.Trobject(ID2).RightOrLeft)==0
                    if (AllTrk.Trobject(ID1).RightOrLeft+ AllTrk.Trobject(ID2).RightOrLeft==2) || (AllTrk.Trobject(ID1).RightOrLeft+ AllTrk.Trobject(ID2).RightOrLeft==0)% RR or LL % merge
                        AllTrk.Trobject(ID1).InMergeCount=AllTrk.Trobject(ID1).InMergeCount+1;
                        if AllTrk.Trobject(ID1).InMergeCount<TrackerOpt.DA.SplitThreshold
                            continue;
                        end
                        if AllTrk.Trobject(ID1).InMerge==0 && AllTrk.Trobject(ID2).InMerge==0
                            if AllTrk.Trobject(ID1).KeyFramesCounter <AllTrk.Trobject(ID2).KeyFramesCounter
                                if TrackerOpt.DA.UseMasterSlaveMerge==1
                                    AllTrk.Trobject(ID2).Master=1;
                                    AllTrk.Trobject(ID1).Master=0;
                                end
                            else
                                if TrackerOpt.DA.UseMasterSlaveMerge==1
                                    AllTrk.Trobject(ID2).Master=0;
                                    AllTrk.Trobject(ID1).Master=1;
                                end
                            end
                            if AllTrk.Trobject(ID1).InMerge==0;
                                AllTrk.Trobject(ID1).StartMergFrame=f;
                                if TrackerOpt.DA.ReInitializeSDCforMerged==1
                                    AllTrk.Trobject(ID1).UpdateDone=1;
                                    ID=ID1;
                                    tempLoop=f-1;
                                    CReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(tempLoop).name);
                                    [A_poso A_nego] = affineTrainG_Modified(CReadStr, AllTrk.Trobject(ID).sz, AllTrk.Trobject(ID).opt, AllTrk.Trobject(ID).paramAll(:,tempLoop) , TrackerOpt.AM.SDC.update.num_p_Init, TrackerOpt.AM.SDC.update.num_n_Init, [], AllTrk.Trobject(ID).p0,ShowSaveParam.SaveWaripImages,ResultsOpts.SaveDirectory, ID);
                                    AllTrk.Trobject(ID).A_pos = A_poso;
                                    AllTrk.Trobject(ID).A_neg = A_nego;                                    
                                    AllTrk.Trobject(ID).KeyFrames=[];
                                end
                            end
                            if AllTrk.Trobject(ID2).InMerge==0;
                                AllTrk.Trobject(ID2).StartMergFrame=f;
                                
                                if TrackerOpt.DA.ReInitializeSDCforMerged==1
                                    AllTrk.Trobject(ID2).UpdateDone=1;
                                    ID=ID2;
                                    tempLoop=f-1;
                                    CReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(tempLoop).name);
                                    [A_poso A_nego] = affineTrainG_Modified(CReadStr, AllTrk.Trobject(ID).sz, AllTrk.Trobject(ID).opt, AllTrk.Trobject(ID).paramAll(:,tempLoop) , TrackerOpt.AM.SDC.update.num_p_Init, TrackerOpt.AM.SDC.update.num_n_Init, [], AllTrk.Trobject(ID).p0,ShowSaveParam.SaveWaripImages,ResultsOpts.SaveDirectory, ID);
                                    AllTrk.Trobject(ID).A_pos = A_poso;
                                    AllTrk.Trobject(ID).A_neg = A_nego;
                                    AllTrk.Trobject(ID).KeyFrames=[];
                                end
                            end
                            AllTrk.Trobject(ID1).InMerge=1;
                            AllTrk.Trobject(ID2).InMerge=1;
                            AllTrk.Trobject(ID1).MergeWith=ID2;
                            AllTrk.Trobject(ID2).MergeWith=ID1;
                        end
                        if TrackerOpt.CM.EnableDetectorGuide==1 && TrackerOpt.DA.ChooseHighSimilarDetectioninMerge==1
                            
                            if isempty(IndexBBTRacker)==0 && isempty(IndexBBTRacker{ID1})==1 && isempty(IndexBBTRacker{ID2})==0
                                Iddetection=IndexBBTRacker{ID2};
                                ID=ID1;
                                con1=SparsityDiscriminativeClassifier(imgdouble,bbs(Iddetection,:),AllTrk.Trobject(ID),TrackerOpt.AM.sz,TrackerOpt.AM.SDC.gamma);
                                ID=ID2;
                                con2=SparsityDiscriminativeClassifier(imgdouble,bbs(Iddetection,:),AllTrk.Trobject(ID),TrackerOpt.AM.sz,TrackerOpt.AM.SDC.gamma);
                                [~,IndexMax]=max([con1,con2]);
                                DetectionBB=convertDollarToLowFormat(bbs(Iddetection,:));
                                DetectionBBCenterFormat=convertFromLowFormatToCenter(DetectionBB);
                                D1=sqrt(sum((DetectionBBCenterFormat(1:2)-AllTrk.Trobject(ID1).currentCenter(:,f-1)).^2));
                                D2=sqrt(sum((DetectionBBCenterFormat(1:2)-AllTrk.Trobject(ID2).currentCenter(:,f-1)).^2));
                                if IndexMax==1 && D1<D2
                                    IndexBBTRacker{ID1}=Iddetection;
                                    IndexBBTRacker{ID2}=[];
                                end
                            elseif isempty(IndexBBTRacker)==0 && isempty(IndexBBTRacker{ID2})==1 && isempty(IndexBBTRacker{ID1})==0
                                Iddetection=IndexBBTRacker{ID1};
                                ID=ID1;
                                con1=SparsityDiscriminativeClassifier(imgdouble,bbs(Iddetection,:),AllTrk.Trobject(ID),TrackerOpt.AM.sz,TrackerOpt.AM.SDC.gamma);
                                ID=ID2;
                                con2=SparsityDiscriminativeClassifier(imgdouble,bbs(Iddetection,:),AllTrk.Trobject(ID),TrackerOpt.AM.sz,TrackerOpt.AM.SDC.gamma);
                                [~,IndexMax]=max([con1,con2]);
                                DetectionBB=convertDollarToLowFormat(bbs(Iddetection,:));
                                DetectionBBCenterFormat=convertFromLowFormatToCenter(DetectionBB);
                                D1=sqrt(sum((DetectionBBCenterFormat(1:2)-AllTrk.Trobject(ID1).currentCenter(:,f-1)).^2));
                                D2=sqrt(sum((DetectionBBCenterFormat(1:2)-AllTrk.Trobject(ID2).currentCenter(:,f-1)).^2));
                                if IndexMax==2 && D2<D1
                                    IndexBBTRacker{ID2}=Iddetection;
                                    IndexBBTRacker{ID1}=[];
                                end
                                
                                
                            end
                        end
                        if TrackerOpt.CM.EnableDetectorGuide==1 && TrackerOpt.DA.ExchangeDetections==1
                            [Overlap]=FindOverlapRatio2Trackers(BBTracker(:,ID1),BBTracker(:,ID2));
                            if isempty(IndexBBTRacker)==0 && isempty(IndexBBTRacker{ID1})==1 && isempty(IndexBBTRacker{ID2})==0 && Overlap>TrackerOpt.DA.OverlapTh2Exchange
                                Iddetection=IndexBBTRacker{ID2};
                                IndexBBTRacker{ID1}=Iddetection;
                            elseif isempty(IndexBBTRacker)==0 && isempty(IndexBBTRacker{ID2})==1 && isempty(IndexBBTRacker{ID1})==0 && Overlap>TrackerOpt.DA.OverlapTh2Exchange
                                Iddetection=IndexBBTRacker{ID1};
                                IndexBBTRacker{ID2}=Iddetection;
                                
                            end
                        end
                        ConflictMatrix(ID1Label,ID2Label)=0;
                    else
                        ConflictMatrix(ID1Label,ID2Label)=1;
                    end
                end
            end
        end
        for ID=Idconflict(:)'
            if sum(ConflictMatrix(Idconflict==ID,:))==0 && sum(ConflictMatrix(:,Idconflict==ID))==0
                if AllTrk.Trobject(ID).MergeWith~=0 % check if you have merge or not
                    IDmerge=AllTrk.Trobject(ID).MergeWith;
                    if sum(Idconflict==IDmerge)>0 && sum(ConflictMatrix(Idconflict==IDmerge,:))==0 && sum(ConflictMatrix(:,Idconflict==IDmerge))==0 % merged occlusion
                        InCoflictFlag(ID)=0;      % in merge
                        StopUpdate(ID)=0;
                        AllTrk.Trobject(ID).InMergewithOcclusion=1;
                    else
                        InCoflictFlag(ID)=1;                % in merge + occlusion
                        StopUpdate(ID)=1;
                    end
                else
                    InCoflictFlag(ID)=1;
                end
                
            end
        end
    end
    %remove merged detections from termination
    if TrackerOpt.DA.removeMergedOBjectsFromTermination==1
        Vector=false(length(IDTerminate),1);
        for ID=IDTerminate(:)'
            if AllTrk.Trobject(ID).InMerge==1
                IndexVal=(IDTerminate==ID);
                Vector(IndexVal)=1;
            end
        end
        IDTerminate(Vector)=[];
    end
end