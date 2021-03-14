%% Sample Selection and Tracker Update
if TrackerOpt.AM.UpdateOpt.RuleUpdateType~=0
    InitialUpdate  =f-AllTrk.Trobject(ID).StartFrame==TrackerOpt.AM.UpdateOpt.NumExamples+1;
    UpdateRate     =(not(StopUpdate(ID)) && rem(f, AllTrk.Trobject(ID).upRate)==0);
    UpdateRateOnly =rem(f, AllTrk.Trobject(ID).upRate)==0 ;
    LimitSizeRule  =size(AllTrk.Trobject(ID).A_pos,2)< AllTrk.Trobject(ID).A_posLimitEnd ;
    MergeFlag      =AllTrk.Trobject(ID).InMerge==0; %Avoid update in case of merge
    OcclusionFlag  =AllTrk.Trobject(ID).InOcclusion==0;%Avoid update in case of merge
    if InitialUpdate==1, collectPreviousExp=TrackerOpt.AM.UpdateOpt.collectPreviousExpInitial;
    else collectPreviousExp=TrackerOpt.AM.UpdateOpt.collectPreviousExpEveryUpdate;
    end
    switch TrackerOpt.AM.UpdateOpt.RuleUpdateType
        case 1
            UpdateFlag=InitialUpdate;
        case 2
            UpdateFlag= UpdateRate || InitialUpdate;
        case 3
            UpdateFlag=(LimitSizeRule && UpdateRate) || InitialUpdate;
        case 4
            UpdateFlag=(LimitSizeRule && UpdateRate && MergeFlag) || InitialUpdate;
        case 5
            UpdateFlag=(OcclusionFlag && UpdateRate) || InitialUpdate;
        case 6
            UpdateFlag=(UpdateRateOnly && MergeFlag) || InitialUpdate;
        case 7
            UpdateFlag=(UpdateRateOnly) || InitialUpdate;
        case 8
            UpdateFlag=(OcclusionFlag && UpdateRateOnly) || InitialUpdate;
        case 9
            UpdateFlag=(UpdateRateOnly && OcclusionFlag  && MergeFlag) || InitialUpdate;
        case 10
            [VInitialx VInitialy]=ComputeVelocity(AllTrk.Trobject(ID),TrackerOpt.MM.VelocityMotionModel);
            VI=sum(sqrt(VInitialx.^2+ VInitialy.^2));
            if VI <TrackerOpt.AM.UpdateOpt.ThresholdSpeed,  SpeedRate=rem(f, TrackerOpt.AM.UpdateOpt.LowSpeedRate)==0;
            else SpeedRate=1;
            end
            UpdateFlag=(UpdateRateOnly && OcclusionFlag  && MergeFlag && SpeedRate) || InitialUpdate;
    end
end
if UpdateFlag && DatasetInfo.EndValidFrame-f>5
    TimeTotalUpdatecpu=clock;
    AllTrk.Trobject(ID).UpdateDone=1;
    if collectPreviousExp==1
        % use only initial knowledge
        for tempLoop= AllTrk.Trobject(ID).StartFrame+1:AllTrk.Trobject(ID).StartFrame+TrackerOpt.AM.UpdateOpt.NumExamples
            if TrackerOpt.AM.UpdateOpt.UseVolume==1
                fVolumeTemp=rem(tempLoop,VolumeSize);  if fVolumeTemp==0, fVolumeTemp=VolumeSize; end;  if MapF(tempLoop)~=fVolumeTemp, disp('Check the volume mapping'); end;
                img_color=VolumeGSIm(:,:,fVolumeTemp);
            else
                ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(tempLoop).name);
                img_color=imread(ReadStr);
            end
            [A_poso A_nego] = affineTrainG_ModifiedN(img_color, AllTrk.Trobject(ID).sz, AllTrk.Trobject(ID).opt, AllTrk.Trobject(ID).paramAll(:,tempLoop) , TrackerOpt.AM.SDC.update.num_pUpdate, TrackerOpt.AM.SDC.update.num_nUpdate, forMat, AllTrk.Trobject(ID).p0,TrackerOpt.MM.SigmaAffineNegSamples,ResultsOpts.SaveWaripImages,ResultsOpts.SaveDirectory, ID);
            AllTrk.Trobject(ID).A_pos =[AllTrk.Trobject(ID).A_pos, A_poso];
            AllTrk.Trobject(ID).A_neg =[AllTrk.Trobject(ID).A_neg, A_nego];
        end
    elseif collectPreviousExp==2
        for tempLoop= AllTrk.Trobject(ID).KeyFrames % detection and tracker agree on them
            if TrackerOpt.AM.UpdateOpt.UseVolume==1
                fVolumeTemp=rem(tempLoop,VolumeSize);  if fVolumeTemp==0, fVolumeTemp=VolumeSize; end;  if MapF(tempLoop)~=fVolumeTemp, disp('Check the volume mapping'); end;
                img_color=VolumeGSIm(:,:,fVolumeTemp);
            else
                ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(tempLoop).name);
                img_color=imread(ReadStr);
            end
            [A_poso A_nego] = affineTrainG_ModifiedN(img_color, AllTrk.Trobject(ID).sz, AllTrk.Trobject(ID).opt, AllTrk.Trobject(ID).paramAll(:,tempLoop) , TrackerOpt.AM.SDC.update.num_pUpdate, TrackerOpt.AM.SDC.update.num_nUpdate, forMat, AllTrk.Trobject(ID).p0,TrackerOpt.MM.SigmaAffineNegSamples,ResultsOpts.SaveWaripImages,ResultsOpts.SaveDirectory, ID);
            AllTrk.Trobject(ID).A_pos =[AllTrk.Trobject(ID).A_pos, A_poso];
            AllTrk.Trobject(ID).A_neg =[AllTrk.Trobject(ID).A_neg, A_nego];
        end
        AllTrk.Trobject(ID).KeyFrames=[];
    elseif collectPreviousExp==3
        for tempLoop= min(AllTrk.Trobject(ID).KeyFrames)
            if TrackerOpt.AM.UpdateOpt.UseVolume==1
                fVolumeTemp=rem(tempLoop,VolumeSize);  if fVolumeTemp==0, fVolumeTemp=VolumeSize; end;  if MapF(tempLoop)~=fVolumeTemp, disp('Check the volume mapping'); end;
                img_color=VolumeGSIm(:,:,fVolumeTemp);
            else
                ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(tempLoop).name);
                img_color=imread(ReadStr);
            end
            
            [A_poso A_nego] = affineTrainG_ModifiedN(img_color, AllTrk.Trobject(ID).sz, AllTrk.Trobject(ID).opt, AllTrk.Trobject(ID).paramAll(:,tempLoop) , TrackerOpt.AM.SDC.update.num_pUpdate, TrackerOpt.AM.SDC.update.num_nUpdate, forMat, AllTrk.Trobject(ID).p0,TrackerOpt.MM.SigmaAffineNegSamples,ResultsOpts.SaveWaripImages,ResultsOpts.SaveDirectory, ID);
            AllTrk.Trobject(ID).A_pos =A_poso;
            AllTrk.Trobject(ID).A_neg =A_nego;
        end
        AllTrk.Trobject(ID).KeyFrames=[];
    elseif collectPreviousExp==4
        % use only keyframes
        if TrackerOpt.AM.UpdateOpt.UsePastBetweenKeyframes && isempty(AllTrk.Trobject(ID).KeyFrames)==0 && min(AllTrk.Trobject(ID).KeyFrames)-AllTrk.Trobject(ID).StartFrame>9
            r1=min(AllTrk.Trobject(ID).KeyFramesUSed);
            r2=max(AllTrk.Trobject(ID).KeyFramesUSed);
            tempV=1:1:r2;
            IDused=false(length(tempV),1);
            IDused(AllTrk.Trobject(ID).KeyFramesUSed)=1;
            IDused(1:AllTrk.Trobject(ID).StartFrame)=1;
            KeyNotUsed=tempV(not(IDused));
            OccFrames=AllTrk.Trobject(ID).OcclusionFrames;
            if isempty(OccFrames)
                AddKeyframes=KeyNotUsed;
            else
                ExcludeFlag=false(length(KeyNotUsed),1);
                for jj=1:length(KeyNotUsed)
                    Index=find(OccFrames==KeyNotUsed(jj));
                    if isempty(Index)==0 && (max(AllTrk.Trobject(ID).OcclusionDegree(Index))>TrackerOpt.AM.UpdateOpt.SafeOcclusionThreshold)
                        ExcludeFlag(jj)=1;
                    end
                end
                KeyNotUsed(ExcludeFlag)=[];
                AddKeyframes=KeyNotUsed;
            end
            AllTrk.Trobject(ID).KeyFramesUSed=[AllTrk.Trobject(ID).KeyFramesUSed, AddKeyframes];
            %% UsePastBetweenKeyframes
            if  isempty(AddKeyframes)==0
                ThresholdSDC_Variable=TrackerOpt.AM.SDC.update.ThresholdSDC_Safe;
                KeyFramesID2=AddKeyframes;
                ConnectedSegments=logical(diff(KeyFramesID2)==1);
                ConnectedComponents=bwconncomp(ConnectedSegments);
                NumberofComponents=numel(ConnectedComponents.PixelIdxList);
                for loopKey=1:NumberofComponents
                    CurrentKeyIndex=ConnectedComponents.PixelIdxList{loopKey};
                    if length(CurrentKeyIndex)>TrackerOpt.AM.UpdateOpt.MinNumerOfConnectedFrames
                        LastKeyFrame=max(KeyFramesID2(CurrentKeyIndex));
                        FirstKeyFrame=min(KeyFramesID2(CurrentKeyIndex));
                        for tempLoop= FirstKeyFrame:LastKeyFrame
                            if TrackerOpt.AM.UpdateOpt.UseVolume==1
                                fVolumeTemp=rem(tempLoop,VolumeSize);  if fVolumeTemp==0, fVolumeTemp=VolumeSize; end;  if MapF(tempLoop)~=fVolumeTemp, disp('Check the volume mapping'); end;
                                img_color=VolumeGSIm(:,:,fVolumeTemp);
                            else
                                ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(tempLoop).name);
                                img_color=imread(ReadStr);
                            end
                            AllTrk.Trobject(ID)=TakeSamplesFromSDC(img_color,tempLoop,ID,AllTrk.Trobject(ID),ThresholdSDC_Variable,TrackerOpt,ShowSaveParam,ResultsOpts);
                        end
                    end
                end
            end
        else
            AddKeyframes=[];
        end
        KeyFramesID=AllTrk.Trobject(ID).KeyFrames;
        AllTrk.Trobject(ID).KeyFramesUSed=[AllTrk.Trobject(ID).KeyFramesUSed, KeyFramesID];
        %% Keyframes Selected last Update rate
        wimgsPosAll=[];
        if isempty(KeyFramesID)==0
            ThresholdSDC_Variable=TrackerOpt.AM.SDC.update.ThresholdSDC;
            AllTrk.Trobject(ID).KeyFrames=[];
            ConnectedSegments=logical(diff(KeyFramesID)==1);
            ConnectedComponents=bwconncomp(ConnectedSegments);
            NumberofComponents=numel(ConnectedComponents.PixelIdxList);
            wimgsPosAll=[];
            for loopKey=1:NumberofComponents
                CurrentKeyIndex=ConnectedComponents.PixelIdxList{loopKey};
                if length(CurrentKeyIndex)>TrackerOpt.AM.UpdateOpt.MinNumerOfConnectedFrames
                    LastKeyFrame=max(KeyFramesID(CurrentKeyIndex));
                    FirstKeyFrame=min(KeyFramesID(CurrentKeyIndex));
                    if TrackerOpt.AM.UpdateOpt.UseBetweenKeyframes
                        RangeKeyFrame=FirstKeyFrame:LastKeyFrame ;
                    else
                        RangeKeyFrame=KeyFramesID ;
                    end
                    if length(RangeKeyFrame)>TrackerOpt.AM.SDC.update.NkeyFramesNeg
                        RangeKeyFrame=RangeKeyFrame(end-TrackerOpt.AM.SDC.update.NkeyFramesNeg+1:end);
                    end
                    for tempLoop=RangeKeyFrame
                        if TrackerOpt.AM.UpdateOpt.UseVolume==1
                            fVolumeTemp=rem(tempLoop,VolumeSize);  if fVolumeTemp==0, fVolumeTemp=VolumeSize; end;  if MapF(tempLoop)~=fVolumeTemp, disp('Check the volume mapping'); end;
                            img_color=VolumeGSIm(:,:,fVolumeTemp);
                        else
                            ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(tempLoop).name);
                            img_color=imread(ReadStr);
                        end
                        [AllTrk.Trobject(ID), wimgsPos]=SampleSelection(img_color,tempLoop,ID,AllTrk.Trobject(ID),ThresholdSDC_Variable,TrackerOpt,ShowSaveParam,ResultsOpts);
                        if TrackerOpt.AM.SGM.UPdateGenerativeModel || TrackerOpt.AM.PGM.UPdateGenerativeModel || TrackerOpt.AM.PCAGM.UPdateGenerativeModel
                            wimgsPosAll=cat(3,wimgsPosAll,wimgsPos);
                        end
                    end
                end
            end
        end
        if TrackerOpt.AM.SGM.UPdateGenerativeModel  && isempty(wimgsPosAll)==0
            Tempcpu=clock;
            [simSGM AllTrk.Trobject(ID)]=SparsityGenerativeModel([],[],AllTrk.Trobject(ID),TrackerOpt,wimgsPosAll);
            [MaxSGM, MaxIndexSGM]=max(simSGM);
            for nPosImage=1: AllTrk.Trobject(ID).AM.SGM.Nimages
                AllTrk.Trobject(ID).alpha_qq(:,:,nPosImage) = UpdateSGMmodel2(AllTrk.Trobject(ID).alpha_q(:,:,nPosImage), AllTrk.Trobject(ID).alpha_p(:,:,MaxIndexSGM), TrackerOpt.AM.SGM.occMap,TrackerOpt.AM.SGM.Update.SGMlearnRate);
                AllTrk.Trobject(ID).alpha_q(:,:,nPosImage)=AllTrk.Trobject(ID).alpha_qq(:,:,nPosImage);
            end
            TimeTrainSGM(fIndex)=TimeTrainSGM(fIndex)+etime(clock,Tempcpu);
        end
        if  TrackerOpt.AM.PGM.UPdateGenerativeModel  && isempty(wimgsPosAll)==0
            VolumeTemp{ID}=AllTrk.Trobject(ID).A_poswarp; %#ok<*SAGROW>
            Tempcpu=clock;
            [AllTrk.Trobject(ID).TwoDPCAparam]=TrainTwoDPCA(VolumeTemp,ID,TrackerOpt.AM.PGM);
            TimeTrain2DCPA(fIndex)=TimeTrain2DCPA(fIndex)+etime(clock,Tempcpu);
            VolumeTemp=[];
        end
        if  TrackerOpt.AM.PCAGM.UPdateGenerativeModel  && isempty(wimgsPosAll)==0
            VolumeTemp{ID}=AllTrk.Trobject(ID).A_poswarp; %#ok<*SAGROW>
            Tempcpu=clock;
            [AllTrk.Trobject(ID).PCAparam]=Train1DPCA(VolumeTemp,ID,TrackerOpt.AM.PCAGM);
            TimeTrain1DCPA(fIndex)=TimeTrain1DCPA(fIndex)+etime(clock,Tempcpu);
            VolumeTemp=[];
        end
    end
    TimeTotalUpdate(fIndex)=TimeTotalUpdate(fIndex)+etime(clock,TimeTotalUpdatecpu);
    NumberOfTrackersUPdate_t(fIndex)=NumberOfTrackersUPdate_t(fIndex)+1;
end