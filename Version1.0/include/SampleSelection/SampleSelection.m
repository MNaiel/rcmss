function [Trobject wimgsPos]=SampleSelection(Im,KeySampleIndex,ID,Trobject,ThresholdSDC_Variable,TrackerOpt,ShowSaveParam,ResultsOpts)
% Select keysamples using SDC tracker, and update the model
% Im                   : Input image
% KeySampleIndex       : Index of the ith keysample
% ID                   : Object ID
% Trobject             : Tracker object 
% ThresholdSDC_Variable: Confidence threshold
% TrackerOpt           : Tracker options
% ShowSaveParam        : Parameters of show and save 
% ResultsOpts          : Results options 
%%
[A_poso A_nego wimgsPos wimgsNeg] = affineTrainG_ModifiedN(Im, Trobject.sz, Trobject.opt, Trobject.paramAll(:,KeySampleIndex) , TrackerOpt.AM.SDC.update.num_pUpdate, TrackerOpt.AM.SDC.update.num_nUpdate,[], Trobject.p0,TrackerOpt.MM.SigmaAffineNegSamples);%SaveWaripImages,SaveDirectory, ID);
InputType=1;
conPos=SparsityDiscriminativeClassifier([],[],Trobject,TrackerOpt.AM.sz,TrackerOpt.AM.SDC.gamma,InputType,A_poso);
conNeg=SparsityDiscriminativeClassifier([],[],Trobject,TrackerOpt.AM.sz,TrackerOpt.AM.SDC.gamma,InputType,A_nego);
IndexGoodPos=find(conPos>ThresholdSDC_Variable);
IndexGoodNeg=find(conNeg<ThresholdSDC_Variable);
if ShowSaveParam.SaveWaripImages
    SaveImagesInDir(wimgsPos(:,:,IndexGoodPos),ShowSaveParam.SaveWaripImages,ResultsOpts.SaveDirectory, ID,'Pos',KeySampleIndex);
    SaveImagesInDir(wimgsNeg(:,:,IndexGoodNeg),ShowSaveParam.SaveWaripImages,ResultsOpts.SaveDirectory, ID,'Neg',KeySampleIndex);
end
A_poso=A_poso(:,IndexGoodPos);
A_nego=A_nego(:,IndexGoodNeg);
if isempty(A_poso)==0 %&& size(Trobject.A_pos,2)>limitPos
    StartValuePos= Trobject.A_posLimitStart+1;
    EndValuePos=StartValuePos+size(A_poso,2)-1;
    StartValueNeg= Trobject.A_negLimitStart+1;
    EndValueNeg=StartValueNeg+size(A_nego,2)-1;
    Trobject.A_posLimitStart=EndValuePos;
    Trobject.A_negLimitStart=EndValueNeg;
    if Trobject.A_posLimitStart>=TrackerOpt.AM.SDC.update.limitPos %Trobject.A_posLimitEnd
        Trobject.A_posLimitStart=TrackerOpt.AM.SDC.update.StartLimitPos;
    end
    if Trobject.A_negLimitStart>=TrackerOpt.AM.SDC.update.limitNeg %Trobject.A_negLimitEnd
        Trobject.A_negLimitStart=TrackerOpt.AM.SDC.update.StartLimitNeg;
    end
    Trobject.A_pos(:,StartValuePos: EndValuePos) =A_poso;
    Trobject.A_neg(:,StartValueNeg: EndValueNeg) =A_nego;
    Trobject.A_poswarp(:,:,StartValuePos: EndValuePos) =wimgsPos(:,:,IndexGoodPos);
    Trobject.A_negwarp(:,:,StartValueNeg: EndValueNeg) =wimgsNeg(:,:,IndexGoodNeg);
end
wimgsPos=wimgsPos(:,:,IndexGoodPos);
