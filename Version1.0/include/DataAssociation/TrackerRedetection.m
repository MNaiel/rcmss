function [AllTrk,NewTrackerNum,IndexBBTRacker,ValidTracker, InCoflictFlag, SafeZone]=TrackerRedetection(AllTrk,imgdouble,f,bbs,NumberOfTrackers,TrackerOpt, DatasetInfo,ShowSaveParam,ResultsOpts,IndexBBTRacker,ValidTracker,NewTrackerNum,InCoflictFlag,SafeZone)
% Program to run in case of TrackerOpt.DA.CheckOnHoldDetectionsBeforeCreateNew==1
% Tracker re-detection scheme
% Input/Output AllTrk the tracker object AllTrk
% imgdouble      : input frame at time t
% f              : frame number
% bbs            : Input bbs to intialize the tracker in Dollar Format
% NumberOfTrackers: Number of trackers
% TrackerOpt     : Options and parameters of the tracker.
% DatasetInfo    : Dataset options and parameters
% ShowSaveParam  : show / save parameters values
% ResultsOpts    : Results options
% IndexBBTRacker : Detector id corresponds to the tracker ID
% ValidTracker   : binary vector for active trackers
% NewTrackerNum  : Detector ID used to intialize new tracker
% InCoflictFlag  : (1) tracker in occlusion
% SafeZone       : (1) tracker away from the borders (0) tracker close to
% the image borders
%%
if TrackerOpt.DA.CheckOnHoldDetectionsBeforeCreateNew==1
    [n1,n2,n3]=size(imgdouble);
    TrackerRange=1:NumberOfTrackers;
    for ID= TrackerRange
        if AllTrk.Trobject(ID).OnHold==1
            if f- AllTrk.Trobject(ID).OnHoldFrame>TrackerOpt.DA.ThMaxWaitOnHoldFrames % || AllTrk.Trobject(ID).SafeZone==0
                ValidTracker(ID)=0; AllTrk.Trobject(ID).ValidTracker=0;
                AllTrk=TerminateVariables(AllTrk,ID);
                if ShowSaveParam.ShowUpdates,       disp(strcat('Tracker ID',num2str(ID),' Terminated- Max Onhold reached'));   end
            end
        end
    end
    InvalidTrackers=not(ValidTracker);
    TrackerRange=1:NumberOfTrackers;
    SimiliarityMatrix=zeros(NumberOfTrackers,NumberOfTrackers);
    if isempty(NewTrackerNum)==0
        if TrackerOpt.DA.CheckInvalidOnly==1
            for ID=TrackerRange(InvalidTrackers)
                if AllTrk.Trobject(ID).OnHold==1
                    for Detection=NewTrackerNum(:)'
                        BB=convertDollarToLowFormat(bbs(Detection,1:4));
                        [wimgs Y]=SampleBBFromImage(imgdouble,BB,TrackerOpt,1);
                        con=SparsityDiscriminativeClassifier(imgdouble,bbs(Detection,:),AllTrk.Trobject(ID),TrackerOpt.AM.sz,TrackerOpt.AM.SDC.gamma,1, Y);
                        Sim=SparsityGenerativeModel(imgdouble,bbs(Detection,:),AllTrk.Trobject(ID),TrackerOpt,wimgs);
                        DetectionBB=convertDollarToLowFormat(bbs(Detection,:));
                        DetectionBBCenterFormat=convertFromLowFormatToCenter(DetectionBB);
                        D=sqrt(sum((DetectionBBCenterFormat(1:2)-AllTrk.Trobject(ID).currentCenter(:,AllTrk.Trobject(ID).OnHoldFrame)).^2));
                        if D<min(n1/4,n2/4),  SimiliarityMatrix(ID,Detection)=con.*Sim;   end
                    end
                end
            end
        end
        if TrackerOpt.DA.CheckOnHoldOnly==1
            SimOH=0;
            for Detection=NewTrackerNum(:)'
                for ID=TrackerRange(:)'
                    if AllTrk.Trobject(ID).OnHold==1
                        BB=convertDollarToLowFormat(bbs(Detection,1:4));
                        [wimgsTest Y]=SampleBBFromImage(imgdouble,BB,TrackerOpt,1);
                        if TrackerOpt.AM.OH.Use2DPCA==1
                            [~,~, ~,~,~,recon]=TestTwoDPCA(AllTrk.Trobject(ID).TwoDPCAparam,wimgsTest,1,TrackerOpt.DA.SigmaPCAGM);
                            if isempty(recon)==0,  SimOH=exp(-recon/TrackerOpt.AM.PGM.OH.SigmaConfuse);   end
                        elseif TrackerOpt.AM.OH.UsePCA==1
                            recon=Test1DPCA(imgdouble,bbs(Detection,1:4),AllTrk.Trobject(ID),TrackerOpt,wimgsTest);
                            if isempty(recon)==0,  SimOH=exp(-recon/TrackerOpt.AM.PCAGM.OH.SigmaConfuse);  end
                        elseif TrackerOpt.AM.OH.UseSDC==1
                            SimOH=SparsityDiscriminativeClassifier([],[],AllTrk.Trobject(ID),TrackerOpt.AM.sz,TrackerOpt.AM.SDC.gamma,1,Y);
                        elseif TrackerOpt.AM.OH.UseSGM==1
                            SimOH=SparsityGenerativeModel((imgdouble),bbs(Detection,:),AllTrk.Trobject(ID),TrackerOpt,wimgsTest);
                        end
                        DetectionBB=convertDollarToLowFormat(bbs(Detection,:));
                        DetectionBBCenterFormat=convertFromLowFormatToCenter(DetectionBB);
                        D=sqrt(sum((DetectionBBCenterFormat(1:2)-AllTrk.Trobject(ID).currentCenter(:,AllTrk.Trobject(ID).OnHoldFrame)).^2));
                        if D<min(n1/4,n2/4),       SimiliarityMatrix(ID,Detection)=SimOH;        end
                    end
                end
            end
        end
        if TrackerOpt.DA.CheckValidOnly==1
            for ID=TrackerRange(ValidTracker)
                if  AllTrk.Trobject(ID).InMerge==1 ||AllTrk.Trobject(ID).InOcclusion ==1
                    if AllTrk.Trobject(ID).InOcclusion==1
                        CenterFarame=AllTrk.Trobject(ID).OcclusionFrames(1);
                    elseif AllTrk.Trobject(ID).InMerge==1
                        CenterFarame=AllTrk.Trobject(ID).StartMergFrame;
                    end
                    for Detection=NewTrackerNum(:)'
                        BB=convertDollarToLowFormat(bbs(Detection,1:4));
                        [wimgsTest Y]=SampleBBFromImage(imgdouble,BB,TrackerOpt,1);
                        con=SparsityDiscriminativeClassifier(imgdouble,bbs(Detection,:),AllTrk.Trobject(ID),TrackerOpt.AM.sz,TrackerOpt.AM.SDC.gamma,1, Y);
                        Sim=SparsityGenerativeModel(imgdouble,bbs(Detection,:),AllTrk.Trobject(ID),TrackerOpt,wimgsTest);
                        DetectionBB=convertDollarToLowFormat(bbs(Detection,:));
                        DetectionBBCenterFormat=convertFromLowFormatToCenter(DetectionBB);
                        D=sqrt(sum((DetectionBBCenterFormat(1:2)-AllTrk.Trobject(ID).currentCenter(:,CenterFarame-1)).^2));
                        if D<min(n1/4,n2/4),  SimiliarityMatrix(ID,Detection)=con.*Sim;  end
                    end
                end
            end
        end
        if sum(sum(SimiliarityMatrix~=0))
            [IndexOut]=FindMaxinSimilarityMatrix(SimiliarityMatrix,TrackerOpt.DA.ThresholdSimilarityCheckOnHold,NumberOfTrackers);
            rangeID=find(IndexOut~=0);
            %%     activate matched trackers to new detections
            for ID=rangeID(:)'
                Index=find(NewTrackerNum==IndexOut(ID));
                IndexBBTRacker{ID}=NewTrackerNum(Index);
                ValidTracker(ID)=1;
                [AllTrk ValidTracker InCoflictFlag SafeZone]=reInitializeCountParametes(AllTrk,ID,ValidTracker,SafeZone, InCoflictFlag,bbs(NewTrackerNum(Index),:),f,imgdouble,TrackerOpt.DA.ReInitializeAll,TrackerOpt, DatasetInfo,ResultsOpts);
                NewTrackerNum(Index)=[];
                if ShowSaveParam.ShowUpdates, disp(strcat('Tracker ID',num2str(ID),' re activated'));      end;
            end
        end
    end
end
end