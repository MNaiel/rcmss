function [TrackerOpt,ResultsOpts]=RCMSSTracker(AllTrk,TrackerOpt,DatasetInfo,DetectorObj,ResultsOpts,ShowSaveParam,BBDetector,BBDetectorAll,gt)
% Online multi-object tracking via robust collaborative model and sample selection (RCMSS) Version 1.0
% -------------------------------------------------------------------------------------------------------
% This is a Matlab implementation of the RCMSS algorithm [1].  
% Copyright 2016 (c) Mohamed A. Naiel (m_naiel@encs.concordia.ca, mohamednaiel@gmail.com, https://sites.google.com/site/mohamednaiel/), all rights reserved. 
% This code can be used for academic purpose only. For other usage, please contact Prof. M. Omair Ahmad (omair@ece.concordia.ca), Department of Electrical 
% and Computer Engineering, Concordia University, Montreal, QC, Canada H3G 1M8. If you used this code in developing your technique or testing this code, please cite the following paper:
% Mohamed A. Naiel, M. Omair Ahmad, M.N.S. Swamy, Jongwoo Lim, and Ming-Hsuan Yang, "Online multi-object tracking via robust collaborative model and sample selection", 
% Computer Vision and Image Understanding, August 2016, In Press, DOI: http://dx.doi.org/10.1016/j.cviu.2016.07.003.
% [1] Mohamed A. Naiel, M. Omair Ahmad, M.N.S. Swamy, Jongwoo Lim, and Ming-Hsuan Yang, "Online multi-object tracking via robust collaborative model and sample selection", Computer Vision and Image Understanding, August 2016, In Press.
% [2] Mohamed A. Naiel, M. Omair Ahmad, M.N.S. Swamy, Yi Wu, and Ming-Hsuan Yang, "Online multi-person tracking via robust collaborative model",  21st IEEE International Conference on Image Processing (ICIP), Paris, France, pp. 431 – 435, Oct. 2014.
%% Last update: October 13, 2016
% This code is developed and tested by using MATLAB R2012a on Windows 8
%% Initialization
IndexBBTRacker=[]; OverlapMatrixAllDt2Tr=[]; InCoflictFlagDetections=[];IndexBB=[];bbOutAffine=[]; drawopt=[]; forMat=[];AVLeftx=[]; AVRightx=[];
NumberOfTrackers   =length(AllTrk.Trobject);
SafeZone           =true(NumberOfTrackers,1);
StopUpdate         =zeros(NumberOfTrackers,1);
InCoflictFlag      =StopUpdate;
ValidTracker       =true(NumberOfTrackers,1);
fIndex             =0;
countString        =0;
if TrackerOpt.AM.UpdateOpt.UsePastBetweenKeyframes ==1,    VolumeSize=2*TrackerOpt.AM.SDC.update.SDCUpdateRate;else    VolumeSize=TrackerOpt.AM.SDC.update.SDCUpdateRate;end
if TrackerOpt.AM.UpdateOpt.UseVolume==1,                   VolumeGSIm=zeros(DatasetInfo.sizeFrame(1),DatasetInfo.sizeFrame(2),VolumeSize);end
ZV                      =zeros(length(DatasetInfo.FrameValidIndex),1);
TimeBeforeDA            =ZV;  TimeTotalUpdate         =ZV; NumberOfTrackersUPdate_t=ZV;  TimeDataAssociation     =ZV;
TimeMerge               =ZV;  TimeChangeDirection     =ZV; TimeTrain2DCPA          =ZV;  TimeTrain1DCPA          =ZV;
TimeTrainSGM            =ZV;  TimeCheckOnHold         =ZV; TimeCreateTrackers      =ZV;  TimeObjectDetector      =ZV;
TimeMotionModel         =ZV;  TimeAddDetectorforMAP   =ZV; TimeTrackerLikelihood   =ZV;  TimeResamplingPF        =ZV;
TimeShowVideo           =ZV;  TimeSaveFigure          =ZV; TimeSaveVideo           =ZV;  TimeSmallParameter      =ZV;
TimeStatistics          =ZV;  TimePerFrame            =ZV; NumberOfTrackers_t      =ZV;  t1=ZV;  t2=ZV; t3=ZV; t4=ZV; t7=ZV;  t8=ZV; t9=ZV; t10=ZV; t11=ZV; t12=ZV;
MapF                    =ZV;
ResultsOpts.ResultsFile=[DatasetInfo.SaveResultsImage 'Test1' num2str(ResultsOpts.VideoNumberi) DatasetInfo.DatasetName '.txt'];
delete(ResultsOpts.ResultsFile);
fid=fopen(ResultsOpts.ResultsFile,'w');
%%
for f = DatasetInfo.FrameValidIndex
    fIndex=fIndex+1;
    if ShowSaveParam.ShowUpdates==0 && rem(fIndex,50)==0, fprintf(1, repmat('\b',1,countString));  countString = fprintf('Percent tracked by RCMSS: %3.2f %% \n',(f/max(DatasetInfo.FrameValidIndex))*100); end;
    if ShowSaveParam.ShowUpdates==1, disp(strcat('Frame # ',num2str(f))); end;
    ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(f).name); img_color=imread(ReadStr);
    [imgdouble,imgInt]=PerFrameFunction(img_color,TrackerOpt.MM.opt);
    if TrackerOpt.AM.UpdateOpt.UseVolume==1
        fVolume=rem(f,VolumeSize);
        if fVolume~=0
            VolumeGSIm(:,:,fVolume)=imgdouble;
            MapF(f)=fVolume;
        else
            VolumeGSIm(:,:,VolumeSize)=imgdouble;
            MapF(f)=VolumeSize;
        end
    end
    %% Control and Data Association
    ControlandDA;
    %% Particle filtering using SDC, SGM(optional)
    for ID= TrackerRange(ValidTracker)
        if  TrackerOpt.DA.UseMasterSlaveMerge==1 && AllTrk.Trobject(ID).InMerge==1 && AllTrk.Trobject(ID).Master==0,  continue;  end;
        %% Motion model
        [AllTrk.Trobject(ID),WeightsParticles,wimgs, Y, param,t1o,t2o,t3o,t4o]=MotionModelPF(imgInt,AllTrk.Trobject(ID),f,ID,DatasetInfo,TrackerOpt,TrackerRange,ValidTracker,IndexBBTRacker,InCoflictFlag,StopUpdate,OverlapMatrixAllDt2Tr,InCoflictFlagDetections,IndexBB,bbOutAffine);
        t1(fIndex)= t1(fIndex)+t1o;  t2(fIndex)= t2(fIndex)+t2o;     t3(fIndex)= t3(fIndex)+t3o;    t4(fIndex)= t4(fIndex)+t4o;
        TimeMotionModel(fIndex)= TimeMotionModel(fIndex)+t1(fIndex)+t2(fIndex)+t3(fIndex)+t4(fIndex);
        if AllTrk.Trobject(ID).ValidTracker==0; AllTrk=TerminateVariables(AllTrk,ID); if ShowSaveParam.ShowUpdates, disp(strcat('Tracker ID',num2str(ID),' stopped out of image')); end; continue;  end
        %% SDC
        tAMcpu     =clock;
        SDCtracker;
        %% SGM
        t11cpu     =clock;
        SGMtracker;
        t11(fIndex)= t11(fIndex)+etime(clock,t11cpu);
        t12cpu=clock;
        %% Likelihood
        switch TrackerOpt.AM.AMmode,  case 1, likelihood = con; case 2,  likelihood = con.*sim;  case 3, likelihood = sim; end;
        L1    =isnan(likelihood); likelihood(L1)=0;
        L2    =isinf(likelihood); likelihood(L2)=0;
        AllTrk     =EstimatePFState(AllTrk,ID,f,likelihood,TrackerOpt);
        t12(fIndex)=t12(fIndex)+etime(clock,t12cpu);
        TimeTrackerLikelihood(fIndex)=TimeTrackerLikelihood(fIndex)+etime(clock,tAMcpu);
        if AllTrk.Trobject(ID).MaxLikeLihood(f)<TrackerOpt.LH.LikeliHoodThreshold
            AllTrk.Trobject(ID).OnHold     =1;
            AllTrk.Trobject(ID).OnHoldFrame=f-1;
            AllTrk.Trobject(ID)            =DoOnHoldSubroutine(AllTrk.Trobject(ID),ID,TrackerOpt);
            if ShowSaveParam.ShowUpdates, disp(strcat('Tracker ID',num2str(ID),' onhold')); end;
        end
        %% Sample selection and Tracker update
        TrackerUpdate;
        %% Particle filter resampling
        TimeResamplingPFcpu=clock;
        if AllTrk.Trobject(ID).UseMotionModelAffineORVecolity1==4||AllTrk.Trobject(ID).UseMotionModelAffineORVecolity2 ==4
            [AllTrk.Trobject(ID).X  AllTrk.Trobject(ID).Neff(f) AllTrk.Trobject(ID).Wkm1]= resample_particles(AllTrk.Trobject(ID).X1,AllTrk.Trobject(ID).X,likelihood,AllTrk.Trobject(ID).Wkm1) ;
        end
        TimeResamplingPF(fIndex)=TimeResamplingPF(fIndex)+etime(clock,TimeResamplingPFcpu);
    end
    %% Store (optional) and show (optional) the tracking results of the current frame, update some paramaters
    DArelated_ShowStoreResults;
    %%
    TimePerFrame(fIndex)=(TimeBeforeDA(fIndex) + TimeTotalUpdate(fIndex)+ TimeDataAssociation(fIndex)+ TimeMerge(fIndex)+...
        TimeChangeDirection(fIndex)+ TimeCheckOnHold(fIndex)+...
        TimeCreateTrackers(fIndex) + TimeMotionModel(fIndex) + TimeAddDetectorforMAP(fIndex)+...
        TimeTrackerLikelihood(fIndex) + TimeResamplingPF(fIndex));
end
fclose(fid);
if ShowSaveParam.StoreVideo==1, close(writerObj);    clear writerObj;end;
if ShowSaveParam.SGMError  ==1, close(TrackerOpt.DatasetInfo.writerObj);end;
if ShowSaveParam.ShowUpdates, disp('[t7,        t8,        t9,        t10,       t11,       t12]'); end;
TotalTimeSDCandSGM=sum([t7,t8,t9,t10,t11,t12],2);
TimePerFrameMatrix=[TimeBeforeDA,TimeTotalUpdate,TimeDataAssociation, TimeMerge, TimeChangeDirection,...
    TimeCheckOnHold, TimeCreateTrackers,TimeMotionModel,TimeAddDetectorforMAP , TimeTrackerLikelihood,TimeResamplingPF ];
TotalTimePerFrame  =sum(TimePerFrameMatrix,2); TotalTimePerSubject=sum(TimePerFrameMatrix,1);
PercentEachSubject =TotalTimePerSubject./sum(sum(TotalTimePerFrame))*100;
StringCell={'TimeBeforeDA','TimeTotalUpdate','TimeDataAssociation', 'TimeMerge', 'TimeChangeDirection',...
    'TimeCheckOnHold', 'TimeCreateTrackers','TimeMotionModel','TimeAddDetectorforMAP' , 'TimeTrackerLikelihood','TimeResamplingPF'};
TableHead={'Time','Percentage'};
PlotTable(PercentEachSubject,StringCell,TableHead);
%% Compute feature vector size for saving results
if NumberOfTrackers>0 && (TrackerOpt.DA.GMType ==2 ||TrackerOpt.DA.GMType ==3)
    FeatureSize2DPCA  =AllTrk.Trobject(ID).TwoDPCAparam.FSize;
    r_2DPCA           =AllTrk.Trobject(ID).TwoDPCAparam.r;
    Alpha2DPCA        =TrackerOpt.AM.PGM.Alpha;
else
    FeatureSize2DPCA  =0;
    r_2DPCA           =0;
    Alpha2DPCA        =0;
end
if NumberOfTrackers>0 &&( TrackerOpt.DA.GMType ==4 ||TrackerOpt.DA.GMType ==5)
    FeatureSizePCA=AllTrk.Trobject(ID).PCAparam.FSize;
    k_PCA         =AllTrk.Trobject(ID).PCAparam.k;
    AlphaPCA      =TrackerOpt.AM.PCAGM.Alpha;
else
    FeatureSizePCA=0;
    k_PCA         =0;
    AlphaPCA      =0;
end
UpdateIndex=TimeTotalUpdate~=0;
DAIndex=TimeDataAssociation~=0;
ResultsOpts.TwoDPCA_var.FeatureSize2DPCA  =FeatureSize2DPCA;
ResultsOpts.TwoDPCA_var.r_2DPCA           =r_2DPCA;
ResultsOpts.TwoDPCA_var.Alpha2DPCA        =Alpha2DPCA;
ResultsOpts.OneDPCA_var.FeatureSizePCA    =FeatureSizePCA;
ResultsOpts.OneDPCA_var.k_PCA             =k_PCA;
ResultsOpts.OneDPCA_var.AlphaPCA          =AlphaPCA;
ResultsOpts.TimeResults.TotalTimeSDCandSGM=TotalTimeSDCandSGM;
ResultsOpts.TimeResults.TimePerFrameMatrix=TimePerFrameMatrix;
ResultsOpts.TimeResults.TotalTimePerFrame =TotalTimePerFrame;
ResultsOpts.TimeResults.TotalTimePerSubject=TotalTimePerSubject;
ResultsOpts.TimeResults.TimePerFrame       =TimePerFrame;
ResultsOpts.TimeResults.TimeTotalUpdate    =TimeTotalUpdate;
ResultsOpts.TimeResults.PercentEachSubject =PercentEachSubject;
ResultsOpts.TimeResults.NumberOfTrackers_t =NumberOfTrackers_t;
ResultsOpts.TimeResults.NumberOfTrackersUPdate_t=NumberOfTrackersUPdate_t;
ResultsOpts.TimeResults.MeanUpdateTimePerTargetPerFrame=sum((TimeTotalUpdate(UpdateIndex))./(NumberOfTrackersUPdate_t(UpdateIndex)))./(sum(UpdateIndex));
ResultsOpts.TimeResults.MeanTimeDataAssociation=mean(TimeDataAssociation(DAIndex));
ResultsOpts.TimeResults.MeanTimeUpdate         =mean(TimeTotalUpdate(UpdateIndex));
ResultsOpts.TimeResults.MeanTimeTrain1DCPA     =mean(TimeTrain1DCPA(UpdateIndex));
ResultsOpts.TimeResults.MeanTimeTrain2DCPA     =mean(TimeTrain2DCPA(UpdateIndex));
ResultsOpts.TimeResults.MeanTimeTrainSGM       =mean(TimeTrainSGM(UpdateIndex));
end