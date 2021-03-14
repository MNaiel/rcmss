global TrackerOpt fcol 
% PETS Dataset
% 15-10-2016
warning off
clear TrackerOpt ResultsOpts AllTrk  Finalresult DetectorObj GTOpt % clear previous trackers objects and results
%% Dataset Parameters
DatasetInfo.DatasetName   ='PETS2009';
DatasetInfo.CameraName    ='PETS2009';
DatasetInfo.Sequence      ='S2_L1';
DatasetInfo.TimeFrames    ='Time_12-34';
DatasetInfo.ViewInfo      ='View_001';
DatasetInfo.LimiTNoFrames =1; % Flag (1) use DatasetInfo.StartFrame and DatasetInfo.FinalNoFrames to limit the tracking between these frame numbers
DatasetInfo.Limit2GT      =1;
if DatasetInfo.Limit2GT, DatasetInfo.StartFrame=1; else DatasetInfo.StartFrame=200;end
DatasetInfo.FinalNoFrames =100;%795;
DatasetInfo.StartFrameGT  =1;
DatasetInfo.ShiftTime     =1;
DatasetInfo.CurrentDirReduced  =0;
ResultsOpts.FilterAfterTracking=1;
TrackerOpt.AM.AMmode           =1; % Select the mode of the apperance model of the Particle filter| AMmode= (1) SDC, (2) SDC+SGM, (3) SGM
TrackerOpt.TrackerType         =3;
TrackerOpt.ResultsVersion      =1;
nCol=30; fcol=zeros(nCol,3); for i=1:nCol, fcol(i,:)=max(.01,mod([78 121 42]*(i+1),255)/255);end;
seed = 1; rand('state', seed);   randn('state', seed);
%% Dataset Folders
CDir                         =cd;
IndexFinder                  =strfind(CDir,'\');
MainDir                      =CDir(1:IndexFinder(end)-1);
StartExtention               =MainDir;
StartExtentionHardDisk       =MainDir;
StartExtentionTrackingCode   =StartExtentionHardDisk;
StartExtentionAnnotationCode =StartExtentionHardDisk;
StartExtentionDatasetRead    =CDir(1:IndexFinder(end)-1);
DatasetInfo.MainFolder       =strcat(StartExtentionDatasetRead,'\Datasets\PETS2009\',DatasetInfo.Sequence,'\Crowd_PETS09\S2\L1\',DatasetInfo.TimeFrames,'\',DatasetInfo.ViewInfo,'\');
DatasetInfo.SaveResultsImage =strcat(DatasetInfo.MainFolder,'results\TrackerType',num2str(TrackerOpt.TrackerType),'\');
ResultsOpts.SaveParameters   =strcat(StartExtentionHardDisk,'\Quantitative Results\',DatasetInfo.DatasetName,'\Parameters and results ',DatasetInfo.DatasetName,'.xlsx');
ResultsOpts.SaveDirectory    =strcat(DatasetInfo.MainFolder,'\results\TrackerType',num2str(TrackerOpt.TrackerType),'\Warpimages');
ResultsOpts.SaveAVIMethod    =1;
run    (strcat(StartExtentionHardDisk,'\Dependencies\piotr_toolbox_V3.01\AddPitorPaths.m'));
addpath(strcat(StartExtentionHardDisk,'\Dependencies\IntegralChannelFeatures\detect'));
addpath(strcat(StartExtentionHardDisk,'\Dependencies\VOCcode 2005\VOCdevkit\PASCAL'));
addpath(strcat(StartExtentionHardDisk,'\Dependencies\cvpr12_wei_code\code'));
addpath(strcat(StartExtentionHardDisk,'\Dependencies\cvpr12_wei_code\code\Affine Sample Functions'));
if ~isdir(DatasetInfo.SaveResultsImage),   mkdir(DatasetInfo.SaveResultsImage);end
%% Detector Parameters
GTOptAll.GTOpt(1).GtName       ='BoYang';
GTOpt.GtName                   ='PETSMain';
GTOpt.SaveAVIMethod            =0;
GTOpt.UseGT                    =1;
DetectorObj.DetectorName       ='BBdolor';
DetectorObj.ShortName          =DetectorObj.DetectorName;
DetectorObj.DetectorPath       ='detections';
DetectorObj.MainFolderDecetions=strcat( DatasetInfo.MainFolder,DetectorObj.DetectorPath);
DetectorObj.SaveResultsbbFolder=strcat(DetectorObj.MainFolderDecetions,'\',DetectorObj.DetectorName,'\');
DetectorObj.LoopUntilDetect    =0;
DetectorObj.FilterDetectionsGeo=0;
DetectorObj.EvaluateDetector   =0;
DetectorObj.FilterDetectionsLessThanAvSize=0;
DetectorObj.EvaluateDetectorOpt.MethodNumber          =1;
DetectorObj.EvaluateDetectorOpt.ComputePlotInvPRRecall=1;
DetectorObj.EvaluateDetectorOpt.BBoxEvaluationMethod  =1;
DetectorObj.EvaluateDetectorOpt.MultiScaleData        =1;
DetectorObj.EvaluateDetectorOpt.ovmaxRef              =0.5;
DetectorObj.EvaluateDetectorOpt.AlfaHeight            =128;
DetectorObj.EvaluateDetectorOpt.AlfaWidth             =64;
DetectorObj.EvaluateDetectorOpt.SaveFalsePos          =0;
DetectorObj.EvaluateDetectorOpt.ShowParameter.UseLatex          =1;
DetectorObj.EvaluateDetectorOpt.ShowParameter.PlotPRFlag        =1;
DetectorObj.EvaluateDetectorOpt.ShowParameter.SaveResultsPosFlag=0;
DetectorObj.EvaluateDetectorOpt.ShowParameter.SAVE_VOC_PR_Curve =0;
ResultsOpts.ChangeWidthHight=0;
[DetectorObj,ExtraOpts,ResultsOpts]=AdjustDetectorParam(DetectorObj,ResultsOpts);
DetectorObj.ReadBBFolder=strcat(DetectorObj.SaveResultsbbFolder,DetectorObj.BBFileName);%Folder of BB detections for load
%%
DatasetInfo.Extension         ='*.jpg';
DatasetInfo.ImagesDir         =strcat(DatasetInfo.MainFolder,'\',DatasetInfo.Extension);
DatasetInfo.CurrentDir        =dir(DatasetInfo.ImagesDir);
DatasetInfo.finalTest         =numel(DatasetInfo.CurrentDir);
DatasetInfo.ImageSize         =size(imread(strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(1).name)));
if DatasetInfo.LimiTNoFrames==1, DatasetInfo.LastValue=DatasetInfo.FinalNoFrames;else DatasetInfo.LastValue=DatasetInfo.finalTest;end;
DatasetInfo.FrameIndex        =DatasetInfo.StartFrame:1:DatasetInfo.LastValue;
DatasetInfo.ValidFrame        =true([length(DatasetInfo.StartFrame:1:DatasetInfo.LastValue),1]);
DatasetInfo.mask              =ExtraOpts.MaskImage;
ResultsOpts.SaveResultsFlag   =1;% Save in excel file flag
ResultsOpts.SheetName         ='sheet1';
SystemParametersCellStartNumIndex=UpdateIndexExcelResults(ResultsOpts.SaveResultsFlag,ResultsOpts.SaveParameters,ResultsOpts.SheetName);
%% flags
ShowSaveParam.ShowStepsDetector=0;
ShowSaveParam.ShowUpdates      =0;
ShowSaveParam.ShowParticles    =0;
ShowSaveParam.showGT           =0;
ShowSaveParam.SAVEresults      =0;
ShowSaveParam.saveasFiles      =0;
ShowSaveParam.StoreVideo       =0;
ShowSaveParam.saveasFiles2     =0;
ShowSaveParam.StoreVideo2      =1;
ShowSaveParam.ShowMovieFile    =0;
ShowSaveParam.saveworkspace    =1;
ShowSaveParam.ShowSteps        =0;
ShowSaveParam.SilentMOde       =1;
ShowSaveParam.ShowGTNew        =0;
ShowSaveParam.SaveGTVideoNew   =0;
ShowSaveParam.SaveWaripImages  =0;
ShowSaveParam.superimposeFigures=0;
ShowSaveParam.plotPDF           =0;
ShowSaveParam.PlotFrameN        =5;
ShowSaveParam.Mask              =0;
ShowSaveParam.UseGT             =0;
ShowSaveParam.SGMError          =0;
ResultsOpts.VideoNumberi        =4;
SaveVideoName=strcat('NewVideo',num2str(ResultsOpts.VideoNumberi),'.avi');
ShowSaveParam.ShowandSaveAllResultsAsVideo =0;
ShowSaveParam.ShowandSaveAllResultsAsVideo2=1;
ShowSaveParam.CheckTrackersOverlapandSTOP  =1;
ResultsOpts.SaveWaripImages     =ShowSaveParam.SaveWaripImages;
ResultsOpts.SaveVideoName       =SaveVideoName;
ResultsOpts.saveworkspace       =ShowSaveParam.saveworkspace;
if ShowSaveParam.SaveWaripImages==1
    SDir=dir(ResultsOpts.SaveDirectory); NoTracks=numel(SDir);
    for i=1:NoTracks, switch (SDir(i).name), case '.'; case '..'; otherwise, rmdir(strcat(ResultsOpts.SaveDirectory,'\',SDir(i).name,'\'),'s');  end; end; 
end;
%% Data Association blocks
%GMType: (1) SGM , (2) TwoDPCA GM, (3) SGM+ 2DPCA,  (4) 1DPCA,
if isempty(GMTypeIN)==0, TrackerOpt.DA.GMType=GMTypeIN; else  TrackerOpt.DA.GMType=3; end;
TrackerOpt.DA.SigmaPCAGM=5*10^7;
if isempty(ThresholdOcclusionIN),
    TrackerOpt.DA.ThresholdOcclusion        =4;
    TrackerOpt.DA.ThresholdwithOutOcclusion =4;
    TrackerOpt.DA.ThresholdInMerge          =4;
else
    TrackerOpt.DA.ThresholdOcclusion        =ThresholdOcclusionIN;
    TrackerOpt.DA.ThresholdwithOutOcclusion =ThresholdOcclusionIN;
    TrackerOpt.DA.ThresholdInMerge          =ThresholdOcclusionIN;
end
if ResultsOpts.FilterAfterTracking, ResultsOpts.MinTrajectoryLength=4;else    ResultsOpts.MinTrajectoryLength=0;end;
TrackerOpt.DA.GetBackThreshold                     =7;
TrackerOpt.DA.OverlapForNewTracker                 =0.2;  % Remove creating new tracker if close objects occur if sum(OverlapMatrixAll(:,i))>OverlapForNewTracker      ValidCol(i)=0;   end
if TrackerOpt.DA.GMType==1
    TrackerOpt.GM.Name                             ='SGM';
    TrackerOpt.DA.ThresholdSimilarity              =0.25;% If similarity >ThresholdSimilarity make assingment tracker and detection
    TrackerOpt.DA.ThresholdSimilarityForNewTracker =0.05;% (low~0) reduce detections, (higher than 0) increase detections
    TrackerOpt.AM.OH.ModelType                     =1;
    TrackerOpt.AM.SGM.Update.thrErrorSGM           =0.8;
elseif TrackerOpt.DA.GMType==2
    TrackerOpt.GM.Name                              ='2DPCAGM';
    TrackerOpt.DA.ThresholdSimilarity               =1.25;% If similarity >ThresholdSimilarity make assingment tracker and detection
    TrackerOpt.DA.ThresholdSimilarityForNewTracker  =0.05;%(low~0) reduce detections, (higher than 0) increase detections
    TrackerOpt.AM.OH.ModelType                      =1;
    TrackerOpt.AM.SGM.Update.thrErrorSGM            =0.8;
elseif TrackerOpt.DA.GMType==3
    TrackerOpt.GM.Name               ='SGMand2DPCAGM';
    TrackerOpt.DA.ThresholdSimilarity              =2.5;% If similarity >ThresholdSimilarity make assingment tracker and detection
    TrackerOpt.DA.ThresholdSimilarityForNewTracker =0.05;%(low~0) reduce detections, (higher than 0) increase detections
    TrackerOpt.AM.OH.ModelType                     =1;
    TrackerOpt.AM.SGM.Update.thrErrorSGM           =0.8;    
elseif TrackerOpt.DA.GMType==4  
    TrackerOpt.GM.Name                             ='PCAGM';
    TrackerOpt.DA.ThresholdSimilarity              =1.5;% If similarity >ThresholdSimilarity make assingment tracker and detection
    TrackerOpt.DA.ThresholdSimilarityForNewTracker =0.05;% (low~0) reduce detections, (higher than 0) increase detections
    TrackerOpt.AM.OH.ModelType                     =2;
    TrackerOpt.AM.SGM.Update.thrErrorSGM           =0.9;
elseif TrackerOpt.DA.GMType==5 
    TrackerOpt.GM.Name                             ='SGMandPCAGM';
    TrackerOpt.DA.ThresholdSimilarity              =2.5;% If similarity >ThresholdSimilarity make assingment tracker and detection
    TrackerOpt.DA.ThresholdSimilarityForNewTracker =0.05;%(low~0) reduce detections, (higher than 0) increase detections
    TrackerOpt.AM.OH.ModelType                     =2;
    TrackerOpt.AM.SGM.Update.thrErrorSGM           =0.8;
elseif TrackerOpt.DA.GMType==6
    TrackerOpt.GM.Name                             ='NoGM';
    TrackerOpt.DA.ThresholdSimilarity              =0.25;% If similarity >ThresholdSimilarity make assingment tracker and detection
    TrackerOpt.DA.ThresholdSimilarityForNewTracker =0.05;%(low~0) reduce detections, (higher than 0) increase detections
    TrackerOpt.AM.OH.ModelType                     =1;
    TrackerOpt.AM.SGM.Update.thrErrorSGM           =0.8;
end
if isempty(ThresholdSimilarityIN)==0,                TrackerOpt.DA.ThresholdSimilarity =ThresholdSimilarityIN;end;
if isempty(ThresholdSimilarityForNewTrackerIN)==0,   TrackerOpt.DA.ThresholdSimilarityForNewTracker=ThresholdSimilarityForNewTrackerIN;end
if isempty(thrErrorSGMIN)==0,                        TrackerOpt.AM.SGM.Update.thrErrorSGM=thrErrorSGMIN;end;
TrackerOpt.DA.useMerge                          =0;
TrackerOpt.DA.MergeParam.InconflictWindow       =4;
TrackerOpt.DA.SplitThreshold                    =3;
TrackerOpt.DA.removeMergedOBjectsFromTermination=0;
TrackerOpt.DA.UseMasterSlaveMerge               =0;
TrackerOpt.DA.ReInitializeSDCforMerged          =0;
TrackerOpt.DA.ReInitializeSDCforAfterMerge      =0;
TrackerOpt.DA.ChooseHighSimilarDetectioninMerge =0;
TrackerOpt.DA.ExchangeDetections                =1;
TrackerOpt.DA.OverlapTh2Exchange                =0.7;
TrackerOpt.DA.SimilarityType                    =0;
TrackerOpt.DA.ThresholdLowSpeed                 =20;
TrackerOpt.DA.ThresholdHighSpeed                =2;
TrackerOpt.DA.ThresholdSpeed                    =1;
TrackerOpt.DA.ThresholdVSimilarity               =3;
TrackerOpt.DA.FactorSigPosVelocity               =50;
TrackerOpt.DA.UseHorizontalVelocityOnlySim       =0;
TrackerOpt.DA.Factor                             =10;
TrackerOpt.DA.ConflictThreshold                  =0.1;% consider TRacker in occlusion
TrackerOpt.DA.NonConflictThreshold               =0.1;% consider TRacker in no occlusion
TrackerOpt.DA.ConflictOverlapThreshold           =0.6;% occluded detections help to select keyframes
TrackerOpt.DA.ThresholdOverlapDt2TrKeyframe      =0.6;
TrackerOpt.DA.TrustKeyFramesThreshold            =2;
if isempty(CheckOnHoldDetectionsBeforeCreateNewIN), TrackerOpt.DA.CheckOnHoldDetectionsBeforeCreateNew=1;else TrackerOpt.DA.CheckOnHoldDetectionsBeforeCreateNew=CheckOnHoldDetectionsBeforeCreateNewIN; end
TrackerOpt.DA.useOnHoldMissedDetections          =TrackerOpt.DA.CheckOnHoldDetectionsBeforeCreateNew;
TrackerOpt.DA.CheckInvalidOnly                   =0;
TrackerOpt.DA.CheckOnHoldOnly                    =1;
TrackerOpt.DA.CheckValidOnly                     =0;
TrackerOpt.DA.ReInitializeAll                    =0;%use partial initialization (update SDC with current location)
TrackerOpt.DA.ThMaxWaitOnHoldFrames              =8;
TrackerOpt.DA.ThresholdSimilarityCheckOnHold     =0.7;
TrackerOpt.DA.SiGmaSquare                        =1000;
TrackerOpt.DA.SigDetection                       =1;
TrackerOpt.DA.SigDetctionSquare                  =TrackerOpt.DA.SigDetection.^2;
TrackerOpt.DA.SigPosSqaure                       =25;
TrackerOpt.DA.FactorGate                         =1;
TrackerOpt.DA.ShowAllArea                        =1;
TrackerOpt.DA.UseOverlap                         =1;
TrackerOpt.DA.UseVectorDirection                 =1;
TrackerOpt.DA.DoubleHightInOverlap               =1;
TrackerOpt.DA.ScaleBBOpt.ScaleFactorW            =0.8;
TrackerOpt.DA.ScaleBBOpt.ScaleFactorH            =0.8;
%% Detector flags
TrackerOpt.CM.EnableDetectorGuide                =1; % Enable Detector to guide the tracker - affect motion model
TrackerOpt.CM.UseWeightedDetections              =1;
if isempty(DetectorWeightIN)==0,
    TrackerOpt.CM.DetectorWeight=DetectorWeightIN;else
    if TrackerOpt.DA.GMType==3, TrackerOpt.CM.DetectorWeight=0.85; elseif TrackerOpt.DA.GMType==5, TrackerOpt.CM.DetectorWeight=0.85; else TrackerOpt.CM.DetectorWeight=0.54; end;
end
TrackerOpt.CM.DetectorupRate                     =1;
TrackerOpt.CM.UseBeforeorAfterNonMaxSup          =0;%(1) before (0) After
TrackerOpt.CM.AddDetectorforMAP                  =0;
TrackerOpt.CM.AdjustWidthandHeight               =1;
TrackerOpt.CM.RateOfChangeW                      =0.5;
TrackerOpt.CM.RateOfChangeH                      =0.5;
%% Tracker parameters
% SDC tracker
TrackerOpt.AM.SDC.SDCModelConfidenceMethod       =1;
TrackerOpt.AM.SDC.useSparseRep                   =1;
TrackerOpt.AM.SDC.UseFeatureSelection            =0;
TrackerOpt.AM.SDC.paramSR.lambda2                =0;
TrackerOpt.AM.SDC.paramSR.mode                   =2;
TrackerOpt.AM.SDC.NormVector                     =1;
TrackerOpt.AM.SDC.paramSR.lambda                 =0.02;
tempHeight=32; tempWidth=16;
sz=[tempHeight tempWidth];
TrackerOpt.AM.SDC.update.NewMethodLimit           =1;
TrackerOpt.AM.SDC.update.Num_posSDC               =10;% Np initialization
TrackerOpt.AM.SDC.update.Num_negSDC               =20;% Nn initialization
TrackerOpt.AM.SDC.update.num_pUpdate              =10;% N_p obtain positive and negative templates for the SDC
TrackerOpt.AM.SDC.update.num_nUpdate              =20;% N_n 
TrackerOpt.AM.SDC.update.num_p                    =TrackerOpt.AM.SDC.update.num_pUpdate;
TrackerOpt.AM.SDC.update.num_n                    =TrackerOpt.AM.SDC.update.num_nUpdate;
if isempty(NkeyFramesPosIN)==0, TrackerOpt.AM.SDC.update.NkeyFramesPos=NkeyFramesPosIN;TrackerOpt.AM.SDC.update.NkeyFramesNeg=NkeyFramesPosIN; else TrackerOpt.AM.SDC.update.NkeyFramesPos=20;TrackerOpt.AM.SDC.update.NkeyFramesNeg=20;end;
TrackerOpt.AM.SDC.update.PercentStart=0.5;
if TrackerOpt.AM.SDC.update.NewMethodLimit
    TrackerOpt.AM.SDC.update.limitPos      =TrackerOpt.AM.SDC.update.Num_posSDC+TrackerOpt.AM.SDC.update.num_pUpdate*TrackerOpt.AM.SDC.update.NkeyFramesPos; 
    TrackerOpt.AM.SDC.update.limitNeg      =TrackerOpt.AM.SDC.update.Num_negSDC+TrackerOpt.AM.SDC.update.num_nUpdate*TrackerOpt.AM.SDC.update.NkeyFramesNeg;
    TrackerOpt.AM.SDC.update.StartLimitPos =floor(TrackerOpt.AM.SDC.update.PercentStart*TrackerOpt.AM.SDC.update.Num_posSDC)+1;
    TrackerOpt.AM.SDC.update.StartLimitNeg =floor(TrackerOpt.AM.SDC.update.PercentStart*TrackerOpt.AM.SDC.update.Num_negSDC)+1;
    TrackerOpt.AM.SDC.update.num_p_Init    =TrackerOpt.AM.SDC.update.Num_posSDC;
    TrackerOpt.AM.SDC.update.num_n_Init    =TrackerOpt.AM.SDC.update.Num_negSDC;
else
    TrackerOpt.AM.SDC.update.limitPos      =TrackerOpt.AM.SDC.update.num_pUpdate+TrackerOpt.AM.SDC.update.Num_posSDC*TrackerOpt.AM.SDC.update.NkeyFramesPos; 
    TrackerOpt.AM.SDC.update.limitNeg      =TrackerOpt.AM.SDC.update.num_nUpdate+TrackerOpt.AM.SDC.update.Num_negSDC*TrackerOpt.AM.SDC.update.NkeyFramesNeg;
    TrackerOpt.AM.SDC.update.StartLimitPos =TrackerOpt.AM.SDC.update.num_pUpdate;
    TrackerOpt.AM.SDC.update.StartLimitNeg =TrackerOpt.AM.SDC.update.num_nUpdate;
    TrackerOpt.AM.SDC.update.num_p_Init    =TrackerOpt.AM.SDC.update.num_pUpdate;
    TrackerOpt.AM.SDC.update.num_n_Init    =TrackerOpt.AM.SDC.update.num_nUpdate;
end
if isempty(SDCUpdateRateIN),  TrackerOpt.AM.SDC.update.SDCUpdateRate=10;  else TrackerOpt.AM.SDC.update.SDCUpdateRate=SDCUpdateRateIN; end
if isempty(ThresholdSDCIN),   TrackerOpt.AM.SDC.update.ThresholdSDC =1;   else TrackerOpt.AM.SDC.update.ThresholdSDC =ThresholdSDCIN;  end
TrackerOpt.AM.SDC.update.ThresholdSDC_Safe=0.25;
%% SGM tracker parameters
TrackerOpt.AM.SGM.Nimages                            =1;
TrackerOpt.AM.SGM.ShowOccludedPatches                =0;
TrackerOpt.AM.SGM.ShowReconstructionErrorOnImages    =0;
if TrackerOpt.DA.GMType==2|| TrackerOpt.DA.GMType==4, TrackerOpt.AM.SGM.UPdateGenerativeModel=0; else  TrackerOpt.AM.SGM.UPdateGenerativeModel=1;end;
if isempty(SGMlearnRateIN), TrackerOpt.AM.SGM.Update.SGMlearnRate=0.6; else TrackerOpt.AM.SGM.Update.SGMlearnRate=SGMlearnRateIN; end  %balance between previous histogram and current one
TrackerOpt.AM.SGM.occMap                             =0;
TrackerOpt.AM.SGM.Update.lambda_thrSGM               =0.1;
TrackerOpt.AM.SGM.Update.lambdaSGM                   =0.06;
TrackerOpt.AM.SGM.patchsize                          =[6 6];  % obtain the dictionary for the SGM
TrackerOpt.AM.SGM.Fisize                             =50;
TrackerOpt.AM.SGM.Initial.ExchangePositiveExamples2BeNeg=0;
TrackerOpt.AM.SGM.Tracker.lambda_thr                 =0.00003;
TrackerOpt.AM.SGM.Tracker.thr                        =0.04;
TrackerOpt.AM.SGM.Tracker.lambda                     =0.01;

TrackerOpt.AM.UpdateOpt.RuleUpdateType               =9;
TrackerOpt.AM.UpdateOpt.NumExamples                  =2;
TrackerOpt.AM.UpdateOpt.collectPreviousExpInitial    =1;%Value at the initial update
TrackerOpt.AM.UpdateOpt.collectPreviousExpEveryUpdate=4;%Value every update rate
TrackerOpt.AM.UpdateOpt.MinNumerOfConnectedFrames    =0;
TrackerOpt.AM.UpdateOpt.SafeOcclusionThreshold       =0.3;
TrackerOpt.AM.UpdateOpt.UseBetweenKeyframes          =1;% if collectPrevious=4;
TrackerOpt.AM.UpdateOpt.UsePastBetweenKeyframes      =0;
TrackerOpt.AM.UpdateOpt.UseVolume                    =0;
TrackerOpt.AM.sz=[tempHeight tempWidth];
%% 2DPCA and PCA parameters
TrackerOpt.AM.PGM.SigmaConfuse=5*10^6;
TrackerOpt.AM.PCAGM.Sigma     =5*10^7;
%% Likelihood fun
TrackerOpt.LH.wightedAv                          =2;
TrackerOpt.LH.UseGatePositionforLikeLihood       =0;
TrackerOpt.LH.ThresholdVLikelihood               =5;
TrackerOpt.LH.UseHorizontalVelocityOnlyLikelihood=0;
TrackerOpt.LH.FactorSigPosVelocityLike           =50;
TrackerOpt.LH.LikeliHoodThreshold                =2*10^-4;
TrackerOpt.LH.UseMaxLikelihood                   =1;
%% Tracker re-detection
% initialization
TrackerOpt.AM.OH.Use2DPCA                        =0;
TrackerOpt.AM.OH.UsePCA                          =0;
TrackerOpt.AM.OH.UseSDC                          =0;
TrackerOpt.AM.OH.UseSGM                          =0;
switch TrackerOpt.AM.OH.ModelType, case 1, TrackerOpt.AM.OH.Use2DPCA=1; case 2, TrackerOpt.AM.OH.UsePCA=1; case 3, TrackerOpt.AM.OH.UseSDC=1;  case 4, TrackerOpt.AM.OH.UseSGM=1;end;
if isempty(SigmaPCAConfusePOWERIn)==0,  TrackerOpt.AM.PCAGM.OH.SigmaConfuse=5*10^SigmaPCAConfusePOWERIn; else   TrackerOpt.AM.PCAGM.OH.SigmaConfuse=5*10^7;end;
if isempty(SigmaConfusePOWERIn)   ==0,  TrackerOpt.AM.PGM.OH.SigmaConfuse  =5*10^SigmaConfusePOWERIn;    else   TrackerOpt.AM.PGM.OH.SigmaConfuse=5*10^6; end;
if TrackerOpt.DA.GMType==4 || TrackerOpt.DA.GMType==5
    TrackerOpt.AM.PCAGM.Alpha                    =0.98;
    TrackerOpt.AM.PCAGM.UPdateGenerativeModel    =1;
    if TrackerOpt.AM.OH.ModelType==1, TrackerOpt.AM.PGM.UPdateGenerativeModel=1;    else   TrackerOpt.AM.PGM.UPdateGenerativeModel=0;    end;
else
    TrackerOpt.AM.PGM.Alpha                    =0.98;
    TrackerOpt.AM.PGM.UPdateGenerativeModel    =1;
    if TrackerOpt.AM.OH.ModelType==2,   TrackerOpt.AM.PCAGM.UPdateGenerativeModel=1;else   TrackerOpt.AM.PCAGM.UPdateGenerativeModel=0;  end;
end
%% Motion Model
TrackerOpt.MM.UseAdaptiveDA                  =0;% if DA ==1 then use detections only, otherwise use PF tracking.
TrackerOpt.MM.USEGateFunction                =0;% (1) select right or left candidates from motion model, (0) use current motion model Affine/Constant Velocity MOdel
TrackerOpt.MM.WindowSizeToMeasureVelocity    =7;
TrackerOpt.MM.UseMotionModelAffineORVecolity1=4; %(0) with Object Detector (1)Affine (2)USe Constant Velocity MOdel  (0) Don't use motion model
TrackerOpt.MM.UseMotionModelAffineORVecolity2=4; %(1) without Object Detector (1)Affine (2)USe Constant Velocity MOdel
TrackerOpt.MM.UseVelocityModel               =4;
TrackerOpt.MM.UseVelocityModel1              =4; % with detector guid + fixed to refer to velocity motion model at the borders and occlusions
TrackerOpt.MM.UseVelocityModel2              =4; % without detector guid + fixed to refer to velocity motion model at the borders and occlusions
TrackerOpt.MM.Vecolity1inMerge               =4;
TrackerOpt.MM.Vecolity2inMerge               =4;
TrackerOpt.MM.WindowLastIteration            =1; % check direction of motion
TrackerOpt.MM.ComputeLeftRightVelocity       =0;
TrackerOpt.MM.WindowMissTest                 =6;
TrackerOpt.MM.ChangeDirectionCheck           =0;
TrackerOpt.MM.USeInstantVelocity             =1;
TrackerOpt.MM.OcclusionRefreshRate           =4;
TrackerOpt.MM.SumVelocityTwice               =1;
if isempty(NewBornIN), TrackerOpt.CM.NewBorn=100;else TrackerOpt.CM.NewBorn=NewBornIN;end;%when detector associated to tracker
TrackerOpt.CM.NewBornaffsig= [4,  2,  0, .00,.000,.000]; %
if  ExtraOpts.FilterDetectionMask==1
    TrackerOpt.MM.FilterDetectionMask        =1;
    TrackerOpt.MM.MaskImage                  =ExtraOpts.MaskImage;
    TrackerOpt.MM.OverlapThreshold           =0.8; % less than the threshold is terminated 
else
    TrackerOpt.MM.FilterDetectionMask        =0;
end
%% features flags
TrackerOpt.AM.Feature.UseGS              =1;
TrackerOpt.AM.Feature.UseColorImage      =0;
TrackerOpt.AM.Feature.UseLBP             =0;
TrackerOpt.AM.Feature.Use2DHOG           =0;
TrackerOpt.AM.Feature.Use2DDCT           =0;
TrackerOpt.AM.Feature.UseIntegralChannel =1;
TrackerOpt.AM.Feature.HOGParam.cellpw    =2;
TrackerOpt.AM.Feature.HOGParam.nthet     =5;
TrackerOpt.AM.Feature.HOGParam.clip      =0.2;
TrackerOpt.AM.Feature.HOGParam.softBin   =1;
TrackerOpt.AM.Feature.HOGParam.useHog    =0;
if TrackerOpt.AM.Feature.HOGParam.useHog==1,   TrackerOpt.AM.Feature.HOGParam.NLayers=TrackerOpt.AM.Feature.HOGParam.nthet*4;else    TrackerOpt.AM.Feature.HOGParam.NLayers=TrackerOpt.AM.Feature.HOGParam.nthet;end;
if TrackerOpt.AM.Feature.UseIntegralChannel==1,TrackerOpt.AM.Feature.HOGParam.NLayers= TrackerOpt.AM.Feature.HOGParam.NLayers+1; end;
TrackerOpt.AM.Feature.DCTParam.CLIP      =4;
TrackerOpt.AM.Feature.DCTParam.BlockSize =8;
TrackerOpt.AM.Feature.DCTParam.mPad      =0;
TrackerOpt.AM.Feature.DCTParam.nPad      =0;
TrackerOpt.AM.Feature.DCTParam.FlagTransform=2;
TrackerOpt.AM.Feature.warpType            =2;
if TrackerOpt.AM.Feature.Use2DHOG==0, TrackerOpt.AM.SDC.gamma = 0.4; else  TrackerOpt.AM.SDC.gamma = 0.04;end
%% Annotation parameters
addpath(strcat(StartExtentionAnnotationCode,'PhD\RA\tools\CLEAT-MOT-script1\CLEAT-MOT-script'));
switch (DatasetInfo.DatasetName)
    case 'PETS2009';
        ResultsOpts.Frate=15;
        switch (DatasetInfo.Sequence)
            case 'S2_L1'
                switch (DatasetInfo.TimeFrames)
                    case 'Time_12-34'
                        for gtID=1:length(GTOptAll.GTOpt)+1
                            if gtID<length(GTOptAll.GTOpt)+1
                                GtName =(GTOptAll.GTOpt(gtID).GtName);
                            else
                                GtName = GTOpt.GtName;
                            end
                            GTOpt.Frate=ResultsOpts.Frate;
                            switch (GtName)
                                case 'BB_ACFwacv2015';
                                    GTOpt.ArrangeAnnotation =2;
                                    GTOpt.ShiftV            =0; % Shift No of frames to allign annotation with images
                                    GTOpt.AnnotationFilename='GTfiles\BB_ACFwacv2015\gtFile.xlsx';
                                    GTOpt.FolderName        ='GTfiles\BB_ACFwacv2015\';
                                case 'BoYang'
                                    GTOpt.ArrangeAnnotation =3;
                                    GTOpt.ShiftV            =0; % Shift No of frames to allign annotation with images
                                    GTOpt.AnnotationFilename='GTfiles\BB_BoYang\PETS09_View001_S2_L1_000to794.avi.gt.xml';
                                    GTOpt.FolderName        ='GTfiles\BB_BoYang\';
                                case 'PETSMain'
                                    GTOpt.ArrangeAnnotation =1;
                                    GTOpt.ShiftV            =-1; % Shift No of frames to allign annotation with images
                                    GTOpt.AnnotationFilename='PETS2009-S2L1.xlsx';
                                    GTOpt.FolderName        ='GTfiles\BB_PETSMain\';
                            end
                            if gtID<length(GTOptAll.GTOpt)+1
                                GTOptAll.GTOpt(gtID).ArrangeAnnotation =GTOpt.ArrangeAnnotation;
                                GTOptAll.GTOpt(gtID).ShiftV            =GTOpt.ShiftV;
                                GTOptAll.GTOpt(gtID).AnnotationFilename=GTOpt.AnnotationFilename;
                                GTOptAll.GTOpt(gtID).FolderName        =GTOpt.FolderName;
                                GTOptAll.GTOpt(gtID).Frate             =GTOpt.Frate;
                                GTOptAll.GTOpt(gtID).SaveAVIMethod     =GTOpt.SaveAVIMethod;
                                GTOptAll.GTOpt(gtID).UseGT             =GTOpt.UseGT;
                            end
                        end
                    otherwise;
                        disp('please add information about annotation file time frame');
                end
            otherwise;
                disp('please add information about annotation file sequence');
        end
    otherwise;
        disp('please add information about annotation file dataset');
end
%%
if isempty(numsampleIN),  numsample=150;  else numsample=numsampleIN; end;
opt = struct('numsample', numsample, 'affsig',[5,  5,  0.03, .00,.01,.000]); 
TrackerOpt.MM.Occlusionaffsig=[7, 7,  .05, .00,.01,.000];
TrackerOpt.MM.Mergeaffsig=    [5, 5,  .05, .00,.01,.000];
if isempty(SIGMAxIN),  TrackerOpt.MM.VelocityMotionModel.Sigmax =3; else TrackerOpt.MM.VelocityMotionModel.Sigmax =SIGMAxIN; end;
if isempty(SIGMAvxIN), TrackerOpt.MM.VelocityMotionModel.SigmaVx=2; else TrackerOpt.MM.VelocityMotionModel.SigmaVx=SIGMAvxIN; end;
TrackerOpt.MM.VelocityMotionModel.UseMarkov        =3;
TrackerOpt.MM.VelocityMotionModel.Sigmay           =TrackerOpt.MM.VelocityMotionModel.Sigmax;
TrackerOpt.MM.VelocityMotionModel.SigmaVy          =TrackerOpt.MM.VelocityMotionModel.SigmaVx;
TrackerOpt.MM.VelocityMotionModel.Window           =5;
FactorOcclusionx=3;FactorOcclusiony  =1;
TrackerOpt.MM.VelocityMotionModel.SigmaxOcclusion  =FactorOcclusionx*TrackerOpt.MM.VelocityMotionModel.Sigmax;
TrackerOpt.MM.VelocityMotionModel.SigmaVxOcclusion =FactorOcclusionx*TrackerOpt.MM.VelocityMotionModel.SigmaVx;
TrackerOpt.MM.VelocityMotionModel.SigmayOcclusion  =FactorOcclusiony*TrackerOpt.MM.VelocityMotionModel.Sigmay;
TrackerOpt.MM.VelocityMotionModel.SigmaVyOcclusion =FactorOcclusiony*TrackerOpt.MM.VelocityMotionModel.SigmaVy;
TrackerOpt.MM.VelocityMotionModel.SigmaxMerge      =0.5*TrackerOpt.MM.VelocityMotionModel.Sigmax;
TrackerOpt.MM.VelocityMotionModel.SigmaVxMerge     =0.5*TrackerOpt.MM.VelocityMotionModel.SigmaVx;
TrackerOpt.MM.VelocityMotionModel.SigmayMerge      =TrackerOpt.MM.VelocityMotionModel.Sigmay;
TrackerOpt.MM.VelocityMotionModel.SigmaVyMerge     =TrackerOpt.MM.VelocityMotionModel.SigmaVy;
TrackerOpt.MM.SigmaAffineNegSamples                =[10, 10, .00, .000, .000, .000];
TrackerOpt.MM.SigmaAffinePosSamples                =[2, 1, .01, .000, .000, .000];
% WindowMotionModel                                   =TrackerOpt.MM.VelocityMotionModel.Window;
TrackerOpt.MM.VelocityMotionModel.USeInstantVelocity=TrackerOpt.MM.USeInstantVelocity;
TrackerOpt.MM.VelocityMotionModel.SumVelocityTwice  =TrackerOpt.MM.SumVelocityTwice;
TrackerOpt.MM.opt                     =opt;
TrackerOpt.MM.opt.warpType            =2;
TrackerOpt.MM.opt.UseColorImage       =TrackerOpt.AM.Feature.UseColorImage;
TrackerOpt.MM.opt.UseLBP              =TrackerOpt.AM.Feature.UseLBP;
TrackerOpt.MM.opt.Use2DHOG            =TrackerOpt.AM.Feature.Use2DHOG;
TrackerOpt.MM.opt.Use2DDCT            =TrackerOpt.AM.Feature.Use2DDCT;
TrackerOpt.MM.opt.DCTParam            =TrackerOpt.AM.Feature.DCTParam;
TrackerOpt.MM.opt.UseIntegralChannel  =TrackerOpt.AM.Feature.UseIntegralChannel;
TrackerOpt.MM.opt.HOGParam            =TrackerOpt.AM.Feature.HOGParam;
TrackerOpt.MM.opt.UseGS               =TrackerOpt.AM.Feature.UseGS;
TrackerOpt.MM.optNewBorn              =TrackerOpt.MM.opt;
TrackerOpt.MM.optNewBorn.tmplsize     =TrackerOpt.AM.sz;
TrackerOpt.MM.optNewBorn.numsample    =TrackerOpt.CM.NewBorn;
TrackerOpt.MM.optNewBorn.affsig       =TrackerOpt.CM.NewBornaffsig;
TrackerOpt.DatasetInfo                =DatasetInfo;
TrackerOpt.DatasetInfo.SaveSGMvideo   =strcat('SGMError_',num2str(TrackerOpt.AM.SGM.Update.thrErrorSGM),'.avi');