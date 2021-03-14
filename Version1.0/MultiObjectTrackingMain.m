clear all
close all
%% Online multi-object tracking via robust collaborative model and sample selection (RCMSS) Version 1.0
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
%%
addpath(genpath(strcat(cd,'\include')));
InitParam;
%%
FixedParam.ObjectType='Pedestrian';
%% Load trackers parameters
initialVars = who;
for SelectedSet=1
    fprintf(strcat('******* Test Set Number : %s,  Object type: %s *******\n'),num2str(SelectedSet),FixedParam.ObjectType);
    switch (SelectedSet)
        case (1)    % PETS2009 S2L1
            StratFileName='StartFilePETS_2009_S2_L1';
        otherwise
            error('please add StratFileName for this dataset');
    end
    for loop=1:1;disp(strcat('Loop no.',num2str(loop)));
        %%
        clearvars('-except',initialVars{:}); initialVars = who;
        DatasetInfo.ObjectType=FixedParam.ObjectType;
        %% Update the parameters changed in the loop
        run(StratFileName);
        %% Load ground truth Data
        [gt,DatasetInfo,gt2Info]=InitializeGroundTruthData(DatasetInfo,GTOpt,ShowSaveParam,DetectorObj,ResultsOpts);
        if DatasetInfo.ShiftTime>1, DatasetInfo.CurrentDir=DatasetInfo.CurrentDir(DatasetInfo.ValidFrame); DatasetInfo.CurrentDirReduced=1; end;
        %% Load detections and initialize trackers
        [DatasetInfo,AllTrk,BBDetector,BBDetectorAll]=InitializeDetectorandTrackers(TrackerOpt,DatasetInfo,DetectorObj,gt);
        if DetectorObj.EvaluateDetector
            for gtID=1:length(GTOptAll.GTOpt)
                if gtID==1, ShowSaveParam.ShowDNew=1;  ShowSaveParam.SaveDVideoNew=1;    DetectorObj.SaveAVIMethod=1;
                else        ShowSaveParam.ShowDNew=0;  ShowSaveParam.SaveDVideoNew=0;    DetectorObj.SaveAVIMethod=0;
                end
                GTOpt                   =GTOptAll.GTOpt(gtID);
                [gt,DatasetInfo,gt2Info]=InitializeGroundTruthData(DatasetInfo,GTOpt,ShowSaveParam,DetectorObj);% load ground truth Data
                [ScoreTh,EER,ap]        =EvaluateDetector(gt(DatasetInfo.ValidFrame),BBDetector,DatasetInfo.FrameValidIndex,DatasetInfo,DetectorObj,ShowSaveParam,GTOpt);
            end
        end
        %% Run the proposed multi-object tracking algorithm on each frame
        if TrackerOpt.TrackerType==3
            [TrackerOpt,ResultsOpts]      =RCMSSTracker(AllTrk,TrackerOpt,DatasetInfo,DetectorObj,ResultsOpts,ShowSaveParam,BBDetector,BBDetectorAll,gt);
        else
            error('Please add the appropriate tracker file that obtains compatible result files as TrackerType3 for evaluation');
        end
        %% Evaluation
        % Load the multi-object tracking results
        [Finalresult,AllTrk,stateInfo]=LoadTRResults(DatasetInfo,ResultsOpts,fcol);
        fprintf(strcat('Av. time per frame (including the tracker update time)= %3.2f Sec; STD=%3.2f Sec; \n'),mean(ResultsOpts.TimeResults.TimePerFrame),std(ResultsOpts.TimeResults.TimePerFrame));
        fprintf(strcat('Av. time per frame (without the tracker update time)  = %3.2f Sec; STD=%3.2f Sec; \n'),mean(ResultsOpts.TimeResults.TimePerFrame-ResultsOpts.TimeResults.TimeTotalUpdate),(std(ResultsOpts.TimeResults.TimePerFrame-ResultsOpts.TimeResults.TimeTotalUpdate)));
        if GTOpt.UseGT==1
            for gtID=1:length(GTOptAll.GTOpt)
                GTOpt=GTOptAll.GTOpt(gtID);
                [gt,DatasetInfo,gt2Info] =InitializeGroundTruthData(DatasetInfo,GTOpt,ShowSaveParam,DetectorObj,ResultsOpts); % Load ground truth Data
                if length(Finalresult)  ~=length(gt(DatasetInfo.ValidFrame))
                    [ClearMOT, AllTrk]   =evaluateMOT_Modified(gt(DatasetInfo.FrameIndex),Finalresult(DatasetInfo.NewStartFrame:DatasetInfo.EndValidFrame),VOCscore,dispON,AllTrk);
                else
                    [ClearMOT, AllTrk]   =evaluateMOT_Modified(gt,Finalresult,VOCscore,dispON,AllTrk);
                end
                FinalMetrics             =ComputeEvaluationMetrics(ClearMOT.TP, ClearMOT.FN, ClearMOT.FP, ClearMOT.IDSW);
                [metrics,metricsInfo,OutMetrics]=CLEAR_MOT_Evaluate(gt2Info,stateInfo,VOCscore,DatasetInfo);
                disp(OutMetrics);
                TxtFileName                     =sprintf(strcat(DatasetInfo.Sequence,'_',TrackerOpt.GM.Name,'_MOTA_%3.2f_V%d\n'),FinalMetrics.MOTA,ResultsOpts.VideoNumberi);
                %% SaveParamInExcelFile;
                SaveParamInExcelFile;
            end
        else
            FinalMetrics.MOTA='NA';
        end
    end
    %%
    %% Store and show the tracking results
    StrFile=strcat(DatasetInfo.CameraName,'\',DatasetInfo.ObjectType,'\',TxtFileName);
    if ~isdir(strcat(DatasetInfo.SaveResultsImage,DatasetInfo.CameraName,'\',DatasetInfo.ObjectType,'\')); mkdir(strcat(DatasetInfo.SaveResultsImage,DatasetInfo.CameraName,'\',DatasetInfo.ObjectType,'\')); end;
    ResultsOpts.SaveVideoName=strcat(StrFile,'.avi');
    SaveFileName=[DatasetInfo.SaveResultsImage strcat(StrFile,'.txt')];
    copyfile(ResultsOpts.ResultsFile,SaveFileName);
    disp(strcat('Results Saved, ', SaveFileName));
    PLOTFinalResults(AllTrk,DatasetInfo,ResultsOpts,ShowSaveParam);  
end