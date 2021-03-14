function [AllTrk]=InitializeTracker(AllTrk,ID,referenceFrame,TrackerOpt, DatasetInfo,img,bbs)
global   fcol
% Used to initialize the trackers.
% Input/Output AllTrk the tracker object AllTrk.Trobject(ID)
% ID             : new tracker ID
% referenceFrame : The frame number for initializing the tracker used to capture the initialization
%                  training samples.
% TrackerOpt     : Options and parameters of the tracker.
% DatasetInfo    : Dataset options and parameters
% img            : Input frame
% bbs            : Input bbs to intialize the tracker in LowFormat
%%
if TrackerOpt.TrackerType==3
    AllTrk.Trobject(ID).StartFrame=referenceFrame;
    centers=[bbs(1,1)+bbs(1,3)/2 bbs(1,2)+bbs(1,4)/2];
    p = [centers(1) centers(2) bbs(1,3) bbs(1,4) 0.0]; %centerx, centery, w,h, orientaion
    AllTrk.Trobject(ID).p=p;
    forMat=[];%DatasetInfo.CurrentDir(referenceFrame).name(end-3:end);
    [n1,n2,n3]=size(img);
    Ncolor=size(fcol,1);
    if ID>Ncolor,  CI=ID-rem(Ncolor,ID)*floor(ID/Ncolor)+1; else  CI=ID;    end;
    AllTrk.Trobject(ID).color=fcol(CI,:);
    opt=TrackerOpt.MM.opt;
    num = DatasetInfo.MaxTrackerLength;%length(img_dir);% number of frames
    opt.tmplsize = TrackerOpt.AM.sz;%[tempHeight tempWidth];                                           % [height width]
    AllTrk.Trobject(ID).sz = opt.tmplsize;
    AllTrk.Trobject(ID).n_sample = opt.numsample;
    AllTrk.Trobject(ID).psize=TrackerOpt.AM.sz;
    AllTrk.Trobject(ID).opt=opt;
    AllTrk.Trobject(ID).opt.Initialaffsig=AllTrk.Trobject(ID).opt.affsig;
    AllTrk.Trobject(ID).opt.Occlusionaffsig= TrackerOpt.MM.Occlusionaffsig;
    AllTrk.Trobject(ID).opt.Mergeaffsig=TrackerOpt.MM.Mergeaffsig;
    AllTrk.Trobject(ID).upRate =TrackerOpt.AM.SDC.update.SDCUpdateRate;
    
    param0 = [p(1), p(2), p(3)/AllTrk.Trobject(ID).sz(2), p(5), p(4)/p(3), 0];
    AllTrk.Trobject(ID).p0 = p(4)/p(3);
    AllTrk.Trobject(ID).param0 = param0;
    AllTrk.Trobject(ID).param = [];
    AllTrk.Trobject(ID).param.est = affparam2mat(AllTrk.Trobject(ID).param0)';
    
    AllTrk.Trobject(ID).num_p = TrackerOpt.AM.SDC.update.num_p_Init; %100                                                        % obtain positive and negative templates for the SDC
    AllTrk.Trobject(ID).num_n = TrackerOpt.AM.SDC.update.num_n_Init;%200
    [A_poso A_nego wimgsPos wimgsNeg] = affineTrainG_ModifiedN(img, AllTrk.Trobject(ID).sz, AllTrk.Trobject(ID).opt, AllTrk.Trobject(ID).param, AllTrk.Trobject(ID).num_p, AllTrk.Trobject(ID).num_n, forMat, AllTrk.Trobject(ID).p0,TrackerOpt.MM.SigmaAffineNegSamples);
    AllTrk.Trobject(ID).A_pos = A_poso;
    AllTrk.Trobject(ID).A_neg = A_nego;
    AllTrk.Trobject(ID).A_poswarp =wimgsPos;
    AllTrk.Trobject(ID).A_negwarp =wimgsNeg;
    
    AllTrk.Trobject(ID).patchsize = TrackerOpt.AM.SGM.patchsize;                                                  % obtain the dictionary for the SGM
    AllTrk.Trobject(ID).patchnum(1) = length(AllTrk.Trobject(ID).patchsize(1)/2 : 2: (AllTrk.Trobject(ID).sz(1)-AllTrk.Trobject(ID).patchsize(1)/2));
    AllTrk.Trobject(ID).patchnum(2) = length(AllTrk.Trobject(ID).patchsize(2)/2 : 2: (AllTrk.Trobject(ID).sz(2)-AllTrk.Trobject(ID).patchsize(2)/2));
    AllTrk.Trobject(ID).Fisize = TrackerOpt.AM.SGM.Fisize;%the number of cluster centers
    if isempty(wimgsPos),      AllTrk.Trobject(ID).ValidTracker=0;        return;    end;
    [Fio AllTrk.Trobject(ID).patcho] = affineTrainL_ModifiedN(wimgsPos(:,:,TrackerOpt.AM.SGM.Nimages), AllTrk.Trobject(ID).param.est, AllTrk.Trobject(ID).opt, AllTrk.Trobject(ID).patchsize, AllTrk.Trobject(ID).patchnum, AllTrk.Trobject(ID).Fisize, forMat);
    AllTrk.Trobject(ID).Fi = Fio;    
    AllTrk.Trobject(ID).AM.SGM.Nimages=TrackerOpt.AM.SGM.Nimages;
    AllTrk.Trobject(ID).SGM.ValidRecon = zeros(AllTrk.Trobject(ID).Fisize, prod(AllTrk.Trobject(ID).patchnum));
    AllTrk.Trobject(ID).SGM.NonOccludedMask=zeros(AllTrk.Trobject(ID).Fisize, prod(AllTrk.Trobject(ID).patchnum));
    %% Initialize 2DPCA GM
    InputImages=AllTrk.Trobject(ID).A_pos;
    wimgs=convertFromVector2Image(InputImages,TrackerOpt.AM.sz);
    Volume{ID}=wimgs;
    if isempty(wimgs), AllTrk.Trobject(ID).ValidTracker=0; return; end;
    [AllTrk.Trobject(ID).TwoDPCAparam]=TrainTwoDPCA(Volume,ID,TrackerOpt.AM.PGM);    
    [AllTrk.Trobject(ID).PCAparam]=Train1DPCA(Volume,ID,TrackerOpt.AM.PCAGM);
    %%
    AllTrk.Trobject(ID).paramSR.lambda2 =  TrackerOpt.AM.SDC.paramSR.lambda2;
    AllTrk.Trobject(ID).paramSR.mode =  TrackerOpt.AM.SDC.paramSR.mode;
    AllTrk.Trobject(ID).alpha_p = zeros(AllTrk.Trobject(ID).Fisize, prod(AllTrk.Trobject(ID).patchnum), num);
    AllTrk.Trobject(ID).result = zeros(1, 6);%zeros(num, 6);
    AllTrk.Trobject(ID).missedDetections=zeros(num,1);
    AllTrk.Trobject(ID).GetBackCount=0;
    AllTrk.Trobject(ID).missedCount=0;
    AllTrk.Trobject(ID).currentCenter=zeros(2,1);
    AllTrk.Trobject(ID).RightOrLeft=[];
    AllTrk.Trobject(ID).BBresult=zeros(4,num);
    AllTrk.Trobject(ID).KeyFrames=[];
    AllTrk.Trobject(ID).A_posLimitStart=floor(.5*AllTrk.Trobject(ID).num_p);%AllTrk.Trobject(ID).num_p;
    AllTrk.Trobject(ID).A_posLimitEnd=2*AllTrk.Trobject(ID).num_p;%AllTrk.Trobject(ID).num_p;
    AllTrk.Trobject(ID).A_negLimitStart=floor(.5*AllTrk.Trobject(ID).num_n);
    AllTrk.Trobject(ID).A_negLimitEnd=AllTrk.Trobject(ID).num_n;
    AllTrk.Trobject(ID).InOcclusion=0;
    AllTrk.Trobject(ID).CountOcclusion=0;
    AllTrk.Trobject(ID).InMerge=0;
    AllTrk.Trobject(ID).MergeWith=0;
    AllTrk.Trobject(ID).StartMergFrame=[];
    AllTrk.Trobject(ID).EndMergFrame=[];
    AllTrk.Trobject(ID).OcclusionFrames=[];
    AllTrk.Trobject(ID).UpdateDone=1;
    AllTrk.Trobject(ID).OnHold=0;
    AllTrk.Trobject(ID).KeyFramesCounter=0;
    AllTrk.Trobject(ID).Master=0;
    AllTrk.Trobject(ID).OnHoldFrame=0;
    AllTrk.Trobject(ID).UpdateSGM =1;
    AllTrk.Trobject(ID).InMergeCountSplit=0;
    AllTrk.Trobject(ID).StopUpdate=1;
    AllTrk.Trobject(ID).ValidTracker=1;
    AllTrk.Trobject(ID).SafeZone=1;
    AllTrk.Trobject(ID).VInitialx=[];
    AllTrk.Trobject(ID).VInitialy=[];
    AllTrk.Trobject(ID).InMergewithOcclusion=0;
    AllTrk.Trobject(ID).objCenter=[p(1); p(2)];
    AllTrk.Trobject(ID).InMergeCount=0;
    if param0(1)<n2/2, AllTrk.Trobject(ID).EnterFromLR=1;%from left
    else               AllTrk.Trobject(ID).EnterFromLR=0;%from right
    end
    if param0(2)>n1/2, AllTrk.Trobject(ID).EnterFromTB=0;%from bottom
    else               AllTrk.Trobject(ID).EnterFromTB=1;%from top
    end
    AllTrk.Trobject(ID).X=[];
    AllTrk.Trobject(ID).Neff=zeros(num,1);
    AllTrk.Trobject(ID).Wkm1=[];
    AllTrk.Trobject(ID).X1=[];
    AllTrk.Trobject(ID).KeyFramesUSed=[];
    AllTrk.Trobject(ID).OcclusionDegree=[];
    AllTrk.Trobject(ID).PartsContribution=[];
    AllTrk.Trobject(ID).Sigmax=TrackerOpt.MM.VelocityMotionModel.Sigmax;
    AllTrk.Trobject(ID).SigmaVx=TrackerOpt.MM.VelocityMotionModel.SigmaVx;
    AllTrk.Trobject(ID).Sigmay=TrackerOpt.MM.VelocityMotionModel.Sigmay;
    AllTrk.Trobject(ID).SigmaVy=TrackerOpt.MM.VelocityMotionModel.SigmaVy;
    AllTrk.Trobject(ID).Last_f=referenceFrame;
    AllTrk.Trobject(ID).MaxLikeLihood=0;
    AllTrk.Trobject(ID).currentBB=convertFromCenterToLowFormat(p,1)';
    AllTrk.Trobject(ID).resultEvaluation=ones(num,1);
    NoParticles=size( AllTrk.Trobject(ID).param.est,2);
    currentBB=zeros(4,NoParticles);
    CenterBB=zeros(2,NoParticles);
    for KKK=1:NoParticles
        currentBB(:,KKK)=convertAfftolowFormat( AllTrk.Trobject(ID).param.est(:,KKK),TrackerOpt.AM.sz);
        CenterBB(:,KKK)=convertlowFormattoCenter(currentBB(:,KKK));
    end
    AllTrk.Trobject(ID).currentBB_NP=currentBB;
    AllTrk.Trobject(ID).CenterBB_NP=CenterBB;
    AllTrk.Trobject(ID).CentersParticles=CenterBB;
else
    
end