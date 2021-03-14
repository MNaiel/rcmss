function [Trobject,WeightsParticles,wimgs, Y, param,t1,t2,t3,t4]=MotionModelPF(imgInt,Trobject,f,ID,DatasetInfo,TrackerOpt,TrackerRange,ValidTracker,IndexBBTRacker,InCoflictFlag,StopUpdate,OverlapMatrixAllDt2Tr,InCoflictFlagDetections,IndexBB,bbOutAffine)
% Compute the motion model particles:
% (1) propagate particles based on the object dynamics,
% (2) create new particles from the associated detections
% Input
% imgInt: input frame
% Trobject                : object for the tracker
% f                       : frame number
% ID                      : object id
% DatasetInfo             : dataset information
% TrackerOpt              : trackers options
% TrackerRange            : range of trackers
% ValidTracker            : flag corresponding to valid trackers numbers
% IndexBBTRacker          : associated detections index
% InCoflictFlag           : if (1) tracker in occlusion
% StopUpdate              : if (1) tracker in occlusion or just initialized
% OverlapMatrixAllDt2Tr   : Matrix of overlap between detectins and trackers
% InCoflictFlagDetections : (1)  tracker in conflict (0) othwerwise
% IndexBB                 : detections corresponding to trackers
% bbOutAffine             : bb in affine format
%
%Output
% Trobject                : updated object for the tracker
% WeightsParticles        : particles weights after the robust collaborative model
% wimgs                   : particles patches of size (m x n x k)
% Y                       : particles patches of size (mn x k)
% param                   : particles in affine format
% t1,t2,t3,t4]
%%
t1=0;t2=0;t3=0;t4=0;
if f>DatasetInfo.NewStartFrame
    %% keyframes store
    t1cpu=clock;
    if ID<=length(IndexBBTRacker) &&  InCoflictFlag(ID)==0 && StopUpdate(ID)==0 % SafeZone(ID)==1 &&
        IdDetector=IndexBBTRacker{ID};
        IDtr=find(TrackerRange(ValidTracker)==ID);
        if isempty(IdDetector)==0  && size(OverlapMatrixAllDt2Tr,2)>=IDtr && InCoflictFlagDetections(IdDetector)==0 && OverlapMatrixAllDt2Tr(IdDetector,IDtr)>=TrackerOpt.DA.ThresholdOverlapDt2TrKeyframe
            Trobject.KeyFrames=[Trobject.KeyFrames, f];
            Trobject.KeyFramesCounter=Trobject.KeyFramesCounter+1;
        end
    end
    DAFlag=TrackerOpt.CM.EnableDetectorGuide==1 && ID<=length(IndexBBTRacker) &&  not(isempty(IndexBBTRacker{ID})) && InCoflictFlag(ID)==0 ;
    if DAFlag
        IdDetector=IndexBBTRacker{ID};
        if not(isempty(IndexBB{IdDetector}))
            param = [];
            param.est =bbOutAffine(:,IndexBB{IdDetector});
            [wimgs1 Y1 param1] =RandomWalkSampling(imgInt, TrackerOpt.AM.sz, TrackerOpt.MM.optNewBorn, param);
            if size(Y1,2)==0
                DAFlag=0;
                Trobject.X1=[];
                param1=[];
            end
        else
            DAFlag=0;
            Trobject.X1=[];
        end
    else
        Trobject.X1=[];
    end
    t1=etime(clock,t1cpu);% time newly created samples
    t2cpu=clock;
    
    Trobject.n_sample=TrackerOpt.MM.opt.numsample;%reference number of samples
    if TrackerOpt.MM.UseAdaptiveDA && DAFlag
        wimgs2=[];
        Y2=[];
        param2.param0=[];
        param2.param=[];
        Trobject.n_sample=0;        
    else
        switch Trobject.UseMotionModelAffineORVecolity1
            case 0
                wimgs2=[];
                Y2=[];
                param2.param0=[];
                param2.param=[];
                Trobject.n_sample=0;
            case 1
                [wimgs2 Y2 param2] = affineSampleModified(imgInt, Trobject.sz, Trobject.opt, Trobject.param);    % draw N candidates with particle filter                
            case 2
                [wimgs2 Y2 param2 Trobject]=ConstantVelocityMotionModel(imgInt, Trobject.sz, Trobject.opt, Trobject.param,Trobject,f,TrackerOpt.MM.VelocityMotionModel);
            case 3
                [wimgs2 Y2 param2] = affineSampleModified(imgInt, Trobject.sz, Trobject.opt, Trobject.param);    % draw N candidates with particle filter
                [wimgs3 Y3 param3 Trobject]=ConstantVelocityMotionModel(imgInt, Trobject.sz, Trobject.opt, Trobject.param,Trobject,f,TrackerOpt.MM.VelocityMotionModel);
                wimgs2=cat(3,wimgs2,wimgs3);
                Y2=[Y2,Y3];
                param2.param0=[param2.param0,param3.param0];
                param2.param=[param2.param,param3.param];
                Trobject.n_sample=size(Y2,2);
            case 4
                if DAFlag
                    [wimgs2 Y2 param2 Trobject]=ParticleFilterMotionModel(imgInt, Trobject.sz, Trobject.opt, Trobject.param,Trobject,f,TrackerOpt.MM.VelocityMotionModel,param1);
                else
                    [wimgs2 Y2 param2 Trobject]=ParticleFilterMotionModel(imgInt, Trobject.sz, Trobject.opt, Trobject.param,Trobject,f,TrackerOpt.MM.VelocityMotionModel);
                end
        end
    end
    t2=etime(clock,t2cpu); % time propagated samples
    
    t3cpu=clock;
    if DAFlag
        wimgs=cat(3,wimgs1,wimgs2);
        Y=[Y1,Y2];
        param.est=Trobject.param.est;
        param.param0=[param1.param0,param2.param0];
        param.param=[param1.param,param2.param];
        Trobject.n_sample=size(Y,2);
        if TrackerOpt.CM.UseWeightedDetections==1,   WeightsParticles=[(TrackerOpt.CM.DetectorWeight/size(Y1,2)).*ones(size(Y1,2),1) ;((1-TrackerOpt.CM.DetectorWeight)/size(Y2,2)).*ones(size(Y2,2),1)];   end;
    else
        wimgs=wimgs2;
        Y=Y2;
        param.est=Trobject.param.est;
        param.param0=param2.param0;
        param.param=param2.param;
        Trobject.n_sample=size(Y,2);
        if TrackerOpt.CM.UseWeightedDetections==1,   WeightsParticles=(1/size(Y,2)).*ones(size(Y,2),1);    end;
    end
    t3=etime(clock,t3cpu); % time of computing the weights    
else
    t4cpu=clock;
    Trobject.n_sample=Trobject.opt.numsample;
    [wimgs Y param] = affineSampleModified(imgInt, Trobject.sz, Trobject.opt, Trobject.param);    % draw N candidates with particle filter
    if TrackerOpt.CM.UseWeightedDetections==1,      WeightsParticles=(1/size(Y,2)).*ones(size(Y,2),1);    end;
    t4=etime(clock,t4cpu); % time of computing the weights
end
NoParticles=size(param.param,2);
currentBB=zeros(4,NoParticles);
CenterBB=zeros(2,NoParticles);
for KKK=1:NoParticles
    Param.est = affparam2mat(param.param(:,KKK));
    currentBB(:,KKK)=convertAfftolowFormat(Param.est,TrackerOpt.AM.sz);
    CenterBB(:,KKK)=convertlowFormattoCenter(currentBB(:,KKK));
end
Trobject.currentBB_NP=currentBB;
Trobject.CenterBB_NP=CenterBB;
Trobject.CentersParticles=CenterBB;
if NoParticles==0,  Trobject.ValidTracker=0;end;
