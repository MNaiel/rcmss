function [bbs, bbALL,newbbs]=ApplyFilterDetections(img_color,f,DetectorObj,DatasetInfo,bbs,bbALL,Gti)
% Gti =gt{f}(:,2:end),
% ApplyFilterDetections used to filter detections based on several arguments
% img_color  : input frame
% f          : frame number
% DetectorObj: detector options
% .LoadPrecomputedDetections    : if (0) recompute the detections
% .ScaleFactor                  : if (~=1) then resize the image by a factor
%                                 of ScaleFactor before detections
% .PretrainedDollar.prm         : Dollar detector parameters
% .FilterDetectionsLessThanTh   : if (1) then filter detections based on
%                                 score detection
% .ThresholdDetector             : filter detections with score less than ThresholdDetector
% .FilterDetectionsGeo           : if (1) then filter detections based on area
%                                  specified in FilterDetectionsGeometric
% .FilterDetectionsLessThanAvSize: if (1) then fiter detections based on
%                                  the size
% DatasetInfo   : information about the dataset
% bbs           : input/output detections
% bbALL         : input/output detections before Non-max supression
% Gti           : input ground truth
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if DetectorObj.LoadPrecomputedDetections==0 && isempty(bbs)
    if DetectorObj.ScaleFactor~=1
        imgIn=imResample(img_color,DetectorObj.ScaleFactor,'bilinear');%%Dollar Toolbox 10x faster
    else
        imgIn=img_color;
    end
    switch DetectorObj.DetectorName
        case {'ACF','BB_ACF'}
            [bbs]= acfDetect(imgIn,DetectorObj.PretrainedACF.detector, [] ,DetectorObj.PretrainedACF.ExtraOpts);
            bbALL=bbs;
        otherwise
            DetectorObj.PretrainedDollar.prm.imgNm    =imgIn;
            [bbs bbALL]=detect(DetectorObj.PretrainedDollar.prm);%- [nx5] array of detected bbs and confidences % bbALL [x y w h wt bbType]
    end
    if DetectorObj.ScaleFactor~=1
        bbs=ScaleDollarBB(bbs,DetectorObj.ScaleFactor);
        bbALL=ScaleDollarBB(bbALL,DetectorObj.ScaleFactor);
    end
end
%%
if DetectorObj.FilterDetectionsLessThanTh==1
    if size(bbs,1)>1
        BadDetections=(bbs(:,5)<DetectorObj.ThresholdDetector);
        bbs(BadDetections,:)=[];
    end
end
%%
if DetectorObj.ScaleDetections==1
    newbbs=convertDollarToLowFormat(bbs);
    if size(bbs,1)>1
        bbs(:,1:4)=convertLowFormattoLeftTopWHT(ScaleBBSize(newbbs(1:4,:),DetectorObj.ScaleBBOpt,img_color));
    end
end
%%
if DetectorObj.FilterDetectionsGeo ~=0
    bbs=FilterDetectionsGeometric(bbs,DatasetInfo,DetectorObj,Gti,img_color);
    bbALL=FilterDetectionsGeometric(bbALL,DatasetInfo,DetectorObj,Gti,img_color);
end
if size(bbs,1)<1,   bbs=[];end
%%
if DetectorObj.UseOpticalFlow==1 & f>1
    DetectorObj.OF.Angle=zeros(size(bbs,1),1);
    for J=1:size(bbs,1)
        [U, V] = DoFlow1(DetectorObj.OF.dx(bbs(J,2):bbs(J,2)+bbs(J,4),bbs(J,1):bbs(J,1)+bbs(J,3)),DetectorObj.OF.dy(bbs(J,2):bbs(J,2)+bbs(J,4),bbs(J,1):bbs(J,1)+bbs(J,3)),DetectorObj.OF.dt(bbs(J,2):bbs(J,2)+bbs(J,4),bbs(J,1):bbs(J,1)+bbs(J,3)),DetectorObj.OF.tIntegration,1,DetectorObj.OF.flowRes);
        Mag=sqrt(V.^2+U.^2);
        IndMax=Mag>0;
        Angle=atan(V(IndMax)./U(IndMax));
        DetectorObj.OF.Angle(J)= mode(mode(Angle));
    end
    SHOWBBIDonImageOnly(img_color,convertDollarToLowFormat(bbs),[DetectorObj.OF.Angle],[DetectorObj.OF.Angle],[],[0 0 1],0);
end
%% filtering detection points
newbbs=convertDollarToLowFormat(bbs);
if DetectorObj.FilterDetectionsLessThanAvSize==1 && isempty(bbs)==0 && f-DatasetInfo.NewStartFrame<5
    CandidateDetectionPoints=convertFromLowFormatToCenter(newbbs);
    Width=[ CandidateDetectionPoints(3,:)];
    Hight=[ CandidateDetectionPoints(4,:)];
    AvWidth=mean(Width); %STDWidth=std(Width);
    AvHight=mean(Hight);%STDHight=std(Hight);
    BadDetection=find(CandidateDetectionPoints(3,:)<AvWidth-0.5*AvWidth | CandidateDetectionPoints(3,:)>AvWidth+0.5*AvWidth);
    BadDetection=[BadDetection,find(CandidateDetectionPoints(4,:)<AvHight-0.7*AvHight | CandidateDetectionPoints(4,:)>AvHight+0.8*AvHight)];
    bbs(BadDetection,:)=[];
    newbbs(:,BadDetection)=[];
end
if DetectorObj.FilterDetectionsGreaterThanSize && isempty(bbs)==0
    CandidateDetectionPoints=convertFromLowFormatToCenter(newbbs);
    BadDetection=find(CandidateDetectionPoints(3,:)>DetectorObj.MaxWidth);
    BadDetection=[BadDetection,find(CandidateDetectionPoints(4,:)>DetectorObj.MaxHight)];
    bbs(BadDetection,:)=[];
    newbbs(:,BadDetection)=[];
end
if DetectorObj.FilterDetectionsGreaterImage
    if isempty(newbbs)==0
        BadDetection=((newbbs(1,:)>newbbs(3,:)| newbbs(1,:)<1 |  newbbs(3,:) >= DatasetInfo.ImageSize(2)) | (newbbs(2,:)>newbbs(4,:) | newbbs(2,:)<1 |  newbbs(4,:) >=DatasetInfo.ImageSize(1)));
        bbs(BadDetection,:)=[];
        newbbs(:,BadDetection)=[];
    end
end