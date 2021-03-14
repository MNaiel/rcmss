function  [IDTerminate,IDCreateNew,IndexBBTRacker,ValidTracker,TrackerOpt]=DataAssociation(img, bbs,AllTrk,NumberOfTrackers,ValidTracker,OverlapMatrixAll,f,TrackerOpt,img_color,ShowSaveParam)
%
% img                  : input frame
% bbs                  : Detections after non-max suppression, [cLow, rlow, width, height, score]
% AllTrk               : input trackers object
% NumberOfTrackers     : Max number of trackers
% ValidTracker         : flag corresponding to valid trackers numbers
% OverlapMatrixAll     : matrix contains the VOC overlap ratio between two trackers without filtering
% f                     : frame number
% TrackerOpt           : trackers options
% img_color            : input color frame
% ShowSaveParam        : show / save parameters values
%%
TrackerRange =1:NumberOfTrackers;
S            =zeros(length(TrackerRange),size(bbs,1));
OverlapMatrixAll=OverlapMatrixAll';
BB           =convertDollarToLowFormat(bbs(:,1:4));
BBWH         =convertFromLowFormatToCenter(BB);
SizeDetector =BBWH(3,:).*BBWH(4,:);
ActiveID     =TrackerRange(ValidTracker);
indexTrack   =0;
Show         =0;
[wimgs]=SampleBBFromImage(img,BB,TrackerOpt,0);
%%
for ID= TrackerRange(ValidTracker)
    indexTrack=indexTrack+1;
    FirstTime=0;
    for d=1:size(bbs,1)
        if OverlapMatrixAll(indexTrack,d)~=0 || TrackerOpt.DA.SimilarityType ==1
            switch TrackerOpt.DA.GMType
                case 1
                    S(ID,d)=SparsityGenerativeModel((img),bbs(d,:),AllTrk.Trobject(ID),TrackerOpt,wimgs(:,:,d));
                case 2
                    S(ID,d)=TwoDPCAGenerativeModel((img),bbs(d,:),AllTrk.Trobject(ID),TrackerOpt,f,ID,wimgs(:,:,d));
                case 3
                    S(ID,d)=SparsityGenerativeModel((img),bbs(d,:),AllTrk.Trobject(ID),TrackerOpt,wimgs(:,:,d))+TwoDPCAGenerativeModel((img),bbs(d,:),AllTrk.Trobject(ID),TrackerOpt,f,ID,wimgs(:,:,d));
                case 4
                    S(ID,d)=OneDPCAGenerativeModel((img),bbs(d,:),AllTrk.Trobject(ID),TrackerOpt,wimgs(:,:,d));
                case 5
                    S(ID,d)=SparsityGenerativeModel((img),bbs(d,:),AllTrk.Trobject(ID),TrackerOpt,wimgs(:,:,d))+OneDPCAGenerativeModel((img),bbs(d,:),AllTrk.Trobject(ID),TrackerOpt,wimgs(:,:,d));
                case 6
                    S(ID,d)=1;
            end
            switch TrackerOpt.DA.SimilarityType
                case 0
                    S(ID,d)=TrackerOpt.DA.Factor*S(ID,d).*OverlapMatrixAll(indexTrack,d);
                case 3
                    S(ID,d)=S(ID,d);
                case 1
                    if TrackerOpt.DA.UseGateSize
                        TrackerSize=AllTrk.Trobject(ID).p(3).*AllTrk.Trobject(ID).p(4);
                        GateValueTerm=(TrackerSize-SizeDetector(d))/TrackerSize;
                        GateSizeValue=TrackerOpt.DA.FactorGate*exp(-1*GateValueTerm/TrackerOpt.DA.SigDetctionSquare);
                    else
                        GateSizeValue=1;
                    end
                    [VInitialx VInitialy]=ComputeInstantVelocity(AllTrk.Trobject(ID),3);
                    if sqrt(VInitialx.^2+VInitialy.^2)>TrackerOpt.DA.ThresholdVSimilarity
                        if f-AllTrk.Trobject(ID).StartFrame>3
                            CurrentCenter=convertlowFormattoCenter(AllTrk.Trobject(ID).BBresult(:,f-2));%previous-2 Center                            
                        elseif f-AllTrk.Trobject(ID).StartFrame>2
                            CurrentCenter=convertlowFormattoCenter(AllTrk.Trobject(ID).BBresult(:,f-2));%previous-2 Center
                        else
                            CurrentCenter=convertlowFormattoCenter(AllTrk.Trobject(ID).currentBB);%previous-1 Center
                        end
                        CurrentState=[CurrentCenter(1:2); VInitialx; VInitialy];
                        Y=ExpectedMotionLine( CurrentState,10);
                        rOC=[Y(1:2,end)];
                        rOB=[CurrentCenter(1:2)];
                        rBC=(rOC-rOB);
                        if TrackerOpt.DA.UseHorizontalVelocityOnlySim==1,      rBC(2)=0;  end;
                        UnitrBC=rBC./norm(rBC);
                        tVelocity=sqrt(VInitialx.^2+VInitialy.^2);
                        if TrackerOpt.DA.ShowAllArea==1 && FirstTime==0;
                            FirstTime=1;
                            [Gridx,Gridy] = meshgrid(1:1:size(img,2),1:1:size(img,1));
                            distOutAll=DistanceNPointsandY([Gridx(:),Gridy(:)]',Y);
                            rOAall=[Gridx(:),Gridy(:)]'-repmat(rOB,[1 length(Gridx(:))]);
                            UnitVectors=repmat(UnitrBC,[1 size(rOAall,2)]);
                            Projall=dot(rOAall,UnitVectors);
                            if TrackerOpt.DA.UseVectorDirection==1
                                Projall2=  repmat((Projall./dot(UnitrBC,UnitrBC)), [2 1]);
                                IndexR=find(Projall2<0);
                                Projall2(IndexR)=0.1;
                                SigPosSqaureall=sum(( Projall2),1)*1/tVelocity;
                            else
                                Projall=  Projall./dot(UnitrBC,UnitrBC);
                                SigPosSqaureall=(abs( Projall));
                            end
                            GatePositionValueall=exp(-1*(distOutAll)./(SigPosSqaureall));
                            ImgDistScore=reshape(GatePositionValueall,[size(Gridx,1) size(Gridx,2)]);
                            figure(3);
                            imshow(uint8(img.*ImgDistScore));
                            hold on; quiver(CurrentCenter(1),CurrentCenter(2),UnitrBC(1),UnitrBC(2),100);
                            drawnow;
                            pause on
                            pause(0.5);
                            pause off
                        end
                        distOut=DistancePoints(BBWH(:,d),Y);
                        rOA=[BBWH(1:2,d)]-rOB;
                        Proj=dot(rOA,UnitrBC)/dot(UnitrBC,UnitrBC);
                        Proj(Proj<0)=0.001;
                        TrackerOpt.DA.SigPosSqaure=sum((Proj),1)*TrackerOpt.DA.FactorSigPosVelocity/tVelocity;
                        GatePositionValue=exp(-1*(distOut)./(TrackerOpt.DA.SigPosSqaure))*exp(-(1-OverlapMatrixAll(indexTrack,d)));
                        if Show==1
                            TrestimatedBB=[Y(1:2,:); repmat([AllTrk.Trobject(ID).p(3); AllTrk.Trobject(ID).p(4)],[1 size(Y,2)])];
                            CBB=convertFromCenterToLowFormat(TrestimatedBB,0);
                            SHOWBBonImage(img,CBB);
                            hold on;
                            surf(Gridy,Gridx,ImgDistScore);
                        end
                    else
                        GatePositionValue=exp(-(1-OverlapMatrixAll(indexTrack,d))./TrackerOpt.DA.SigPosSqaure);
                    end
                    if TrackerOpt.DA.UseOverlap==1
                        S(ID,d)=GateSizeValue*TrackerOpt.DA.Factor*S(ID,d).*GatePositionValue.*OverlapMatrixAll(indexTrack,d);
                    else
                        S(ID,d)=GateSizeValue*TrackerOpt.DA.Factor*S(ID,d).*GatePositionValue;
                    end
            end
        end
    end
end
%%
ValidCol=ones(size(S,2),1);
ValidRow=ones(size(S,1),1);
ValidRow(not(ValidTracker))=0;
costMatrix=S;
IndexBBTRacker=cell(length(TrackerRange),1);
while sum(sum(S))>0 
    [C]=max(S(:));
    [row col]=find(S==C);
    switch TrackerOpt.DatasetInfo.DatasetName
        case 'PETS2009';
            L=length(row);
        otherwise
            L=1;
    end
    sim=S(row(L), col(L));
    S(row(L), :)=0;
    S(:,col(L))=0;
    IndexTrack=find(ActiveID==row(L));
    if sim>TrackerOpt.DA.ThresholdSimilarity 
        ValidRow(row(L))=0;%Tracks
        ValidCol(col(L))=0;%Detections
        IndexBBTRacker{row(L)}=col(L);
    elseif OverlapMatrixAll(IndexTrack,col(L))<=TrackerOpt.DA.OverlapForNewTracker %create new tracker if overlap less than this
        1;
    else
        ValidRow(row(L))=0;
        ValidCol(col(L))=0;
    end
end
DetectionID=1:size(OverlapMatrixAll,2);
for i=DetectionID
    if  ValidCol(i)~=0
        if sum(OverlapMatrixAll(:,i))>TrackerOpt.DA.OverlapForNewTracker | max(costMatrix(:,i))>TrackerOpt.DA.ThresholdSimilarityForNewTracker %remove this detections if they are similar or overlab with exsiting tracker
            ValidCol(i)=0;
        end
    end    
end

IDTerminate=[]; %check termination
if sum(ValidRow)>0, IDTerminate=find(ValidRow==1);end
IDCreateNew=[]; %newdetection create tracker
if sum(ValidCol)>0, IDCreateNew=find(ValidCol==1);end;
if TrackerOpt.AM.SGM.ShowReconstructionErrorOnImages && (TrackerOpt.DA.GMType==1 || TrackerOpt.DA.GMType==3 || TrackerOpt.DA.GMType==5)
    if (f==TrackerOpt.DatasetInfo.StartFrame+1), figure('position',[30 50 size(img,2) size(img,1)]); clf;
        set(0,'Units','normalized'); 
    else   clf;
    end
    CBB=[];
    for ID= TrackerRange(ValidTracker)
        IdDetector=IndexBBTRacker{ID};
        if isempty(IdDetector)==0
            [Sim AllTrk.Trobject(ID) bbpatch]=SparsityGenerativeModel((img),bbs(IdDetector,:),AllTrk.Trobject(ID),TrackerOpt,wimgs(:,:,IdDetector));
            NonOccludedMask=AllTrk.Trobject(ID).SGM.NonOccludedMask;
            CBBnew=convertDollarToLowFormat(bbs(IdDetector,:));
            CBB=cat(2,CBB,CBBnew);
            sH=1/(TrackerOpt.AM.sz(1)/(CBBnew(4)-CBBnew(2)));
            sW=1/(TrackerOpt.AM.sz(2)/(CBBnew(3)-CBBnew(1)));
            Oindex=find((NonOccludedMask)==0);
            for i=Oindex(:)'
                img_color(CBBnew(2)+bbpatch(1,i)*sH:CBBnew(2)+bbpatch(2,i)*sH,CBBnew(1)+bbpatch(3,i)*sW:CBBnew(1)+bbpatch(4,i)*sW,1)=AllTrk.Trobject(ID).color(1)*255;
                img_color(CBBnew(2)+bbpatch(1,i)*sH:CBBnew(2)+bbpatch(2,i)*sH,CBBnew(1)+bbpatch(3,i)*sW:CBBnew(1)+bbpatch(4,i)*sW,2)=AllTrk.Trobject(ID).color(2)*255;
                img_color(CBBnew(2)+bbpatch(1,i)*sH:CBBnew(2)+bbpatch(2,i)*sH,CBBnew(1)+bbpatch(3,i)*sW:CBBnew(1)+bbpatch(4,i)*sW,3)=AllTrk.Trobject(ID).color(3)*255;
            end
        end
    end
    hold on;
    imshow(uint8(img_color));
    Index=0;
    for ID= TrackerRange(ValidTracker)
        IdDetector=IndexBBTRacker{ID};
        if isempty(IdDetector)==0
            Index=Index+1;
            ScoreOutPos=[];%0 show ID , empty do not show ID
            SHOWBBonImage(img_color,CBB(:,Index),ScoreOutPos,ID,1,AllTrk.Trobject(ID).color,1,15);
        end
    end
    text(10, 15, '#', 'Color','y', 'FontWeight','bold', 'FontSize',24);
    text(30, 15, num2str(f), 'Color','y', 'FontWeight','bold', 'FontSize',24);
    hold off;
    if ShowSaveParam.SGMError==1
        if f==TrackerOpt.DatasetInfo.StartFrame+1
            writerObj = VideoWriter(strcat(TrackerOpt.DatasetInfo.SaveResultsImage,TrackerOpt.DatasetInfo.SaveSGMvideo));
            writerObj.FrameRate = 3;
            open(writerObj);
            TrackerOpt.DatasetInfo.writerObj=writerObj;
        end
        img_color=getframe;
        [Ir,Ic,Id]=size(img_color.cdata);
        if size(img_color,1)~=Ir || size(img_color,2)~=Ic
            img_color.cdata=imresize(img_color.cdata,[Ir,Ic]);
        end
        writeVideo(TrackerOpt.DatasetInfo.writerObj,img_color);
    end
end