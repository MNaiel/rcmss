function [DatasetInfo,AllTrk,BBDetector,BBDetectorAll]=InitializeDetectorandTrackers(TrackerOpt,DatasetInfo,DetectorObj,gt)
i=DatasetInfo.StartValidFrame;
ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(i).name);
Im=imread(ReadStr);
if DetectorObj.ScaleFactor~=1
    imgIn=imresize(Im,DetectorObj.ScaleFactor);
else
    imgIn=Im;
end
if DetectorObj.LoadPrecomputedDetections==1    
    switch DetectorObj.DetectorName
        case 'TD2DHOG'
            ABB=load(DetectorObj.ReadBBFolder);
            FrameID=unique(ABB(:,1));
            Nframes=length(FrameID);
            BBDetector=cell(max(FrameID),1);
            BBDetectorAll=BBDetector;
            for j=DatasetInfo.FrameIndex(DatasetInfo.ValidFrame)
                Sid=find(ABB(:,1)==j );
                BBDetector{j,1}=[convertLowFormattoLeftTopWHT(ABB(Sid,2:5)') ABB(Sid,end)];
                BBDetectorAll{j,1}=BBDetector{j,1};
                ShowDt=0;
                if ShowDt==1
                    cBB=ABB(Sid,2:5)';
                    Score=ABB(Sid,end);
                    ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(j).name);
                    Im=imread(ReadStr);
                    SHOWBBonImage(Im,cBB,Score,Score);
                end
            end
            bbs=BBDetector{DatasetInfo.StartValidFrame,1};
            bbALL=bbs;
        case {'BBGTdetections' , 'BB_BoYang'}
            %%
            A=xlsread(DetectorObj.ReadBBFolder); % in should be in Low Format
            if DetectorObj.ArrangeAnnotation==1
                ABB=A;
                ABB(:,3:6)=convertCenterWHToLowFormat([A(:,5),A(:,6), A(:,4),A(:,3)])';%xc	yc w  h
            elseif DetectorObj.ArrangeAnnotation==-1
                ABB=A;
            elseif DetectorObj.ArrangeAnnotation==-2%In Dollar Format  DetectorObj.ArrangeAnnotation==-2
                ABB=A;
                ABB(:,3:6)=convertDollarToLowFormat(A(:,3:6))';%xc	yc w  h
            else
                ABB=[A(:,3)+A(:,5)/2,A(:,4)+A(:,6)/2, A(:,5),A(:,6)];%xc	yc w  h
            end            
            FrameID=unique(ABB(:,1));
            Nframes=length(FrameID);
            BBDetector=cell(max(FrameID),1);
            BBDetectorAll=BBDetector;
            Index=0;
            for j=DatasetInfo.FrameIndex(DatasetInfo.ValidFrame)
                Index=Index+1;
                Sid=find(ABB(:,1)==j + DetectorObj.ShiftV); %Map the First detection to the corresponding location
                BBDetector{j,1}=[convertLowFormattoLeftTopWHT(ABB(Sid,3:6)') 5*ones(length(Sid),1)];
                BBDetectorAll{j,1}=BBDetector{j,1};
                ShowDt=0;
                if ShowDt==1
                    cBB=ABB(Sid,3:6)';
                    Score=ABB(Sid,end);
                    ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(j).name);
                    ImTemp=imread(ReadStr);
                    SHOWBBonImage(ImTemp,cBB);
                end
            end
            bbs=BBDetector{DatasetInfo.StartValidFrame,1};
            bbALL=bbs;
        case 'DollarDetector'            
            if strcmp('.mat',DetectorObj.ReadBBFolder(end-3:end))
                load(DetectorObj.ReadBBFolder);
                if DatasetInfo.CurrentDirReduced
                    BBDetector=BBDetector(DatasetInfo.ValidFrame);
                    BBDetectorAll=BBDetectorAll(DatasetInfo.ValidFrame);
                    for kk=1:length(BBDetector)
                        bbs=BBDetector{kk};
                        bbALL=BBDetectorAll{kk};
                        [bbs, bbALL]=ApplyFilterDetections(Im,kk,DetectorObj,DatasetInfo,bbs,bbALL,gt{kk}(:,2:end));
                        BBDetector{kk}=bbs;
                        BBDetectorAll{kk}=bbALL;
                    end
                    bbs=BBDetector{i};
                    bbALL=BBDetectorAll{i};
                else
                    bbs=BBDetector{i};
                    bbALL=BBDetectorAll{i};
                end
            else
            ABB=load(DetectorObj.ReadBBFolder);
            FrameID=unique(ABB(:,1));
            Nframes=length(FrameID);
            %initialization
            BBDetector=cell(max(FrameID),1);
            BBDetectorAll=BBDetector;
            Index=0;bbIndex=0;
            for j=DatasetInfo.FrameIndex(DatasetInfo.ValidFrame);%StartFrame+GTOpt.ShiftV+1:1:LastValue+GTOpt.ShiftV+1
                Index=Index+1;
                Sid=find(ABB(:,1)==j + DetectorObj.ShiftV+1& ABB(:,6)>=DetectorObj.ScoreThre);
                if isempty(Sid)==0     
                    if DatasetInfo.CurrentDirReduced
                        bbIndex=bbIndex+1;
                        BBDetector{bbIndex,1}=[ABB(Sid,2:5) ABB(Sid,6)];
                        BBDetectorAll{bbIndex,1}=BBDetector{bbIndex,1}; 
                    else
                        BBDetector{j,1}=[ABB(Sid,2:5) ABB(Sid,6)];
                        BBDetectorAll{j,1}=BBDetector{j,1};
                    end
                    ShowDt=0;
                    if ShowDt==1
                        cBB=convertDollarToLowFormat(ABB(Sid,2:5));
                        Score=ABB(Sid,6);
                        if DatasetInfo.CurrentDirReduced
                            ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(Index).name);
                        else
                            ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(j).name);
                        end                        
                        ImTemp=imread(ReadStr);
                        bbs=BBDetector{j,1};bbALL=BBDetector{j,1};
                        [bbs, bbALL]=ApplyFilterDetections(ImTemp,j,DetectorObj,DatasetInfo,bbs,bbALL,gt{j}(:,2:end));
                        cBB=convertDollarToLowFormat(bbs);
                        SHOWBBonImage(ImTemp,cBB);
                    end
                end
            end
            bbs=BBDetector{DatasetInfo.StartValidFrame,1};
            bbALL=bbs;
            end
        case 'BBdolor'
            load(DetectorObj.ReadBBFolder);
            if DatasetInfo.CurrentDirReduced
                BBDetector=BBDetector(DatasetInfo.ValidFrame);
                BBDetectorAll=BBDetectorAll(DatasetInfo.ValidFrame);            
                for kk=1:length(BBDetector)
                    bbs=BBDetector{kk};
                    bbALL=BBDetectorAll{kk};
                    [bbs, bbALL]=ApplyFilterDetections(Im,kk,DetectorObj,DatasetInfo,bbs,bbALL,gt{kk}(:,2:end));
                    BBDetector{kk}=bbs;
                    BBDetectorAll{kk}=bbALL;
                end
                bbs=BBDetector{i};
                bbALL=BBDetectorAll{i};
            else
                bbs=BBDetector{i};
                bbALL=BBDetectorAll{i};
            end
        case 'ShahCVPR2012_ver2'
            %%
            ABB=load(DetectorObj.ReadBBFolder);
            Vtemp=ABB;
            ABB=[Vtemp(:,2), Vtemp(:,3:6),Vtemp(:,1)];
            FrameID=unique(ABB(:,1));
            Nframes=length(FrameID);
            BBDetector=cell(max(FrameID),1);
            BBDetectorAll=BBDetector;
            Index=0;bbIndex=0;
            for j=DatasetInfo.FrameIndex(DatasetInfo.ValidFrame);%StartFrame+GTOpt.ShiftV+1:1:LastValue+GTOpt.ShiftV+1
                Index=Index+1;
                Sid=find(ABB(:,1)==j + DetectorObj.ShiftV+1& ABB(:,6)>=DetectorObj.ScoreThre);
                if isempty(Sid)==0     
                    if DatasetInfo.CurrentDirReduced
                        bbIndex=bbIndex+1;
                        BBDetector{bbIndex,1}=[convertLowFormattoLeftTopWHT(ABB(Sid,2:5)') ABB(Sid,6)];
                        BBDetectorAll{bbIndex,1}=BBDetector{bbIndex,1}; 
                    else
                        BBDetector{j,1}=[convertLowFormattoLeftTopWHT(ABB(Sid,2:5)') ABB(Sid,6)];
                        BBDetectorAll{j,1}=BBDetector{j,1};
                    end
                    ShowDt=0;
                    if ShowDt==1
                        cBB=(ABB(Sid,2:5))';
                        Score=ABB(Sid,6);
                        if DatasetInfo.CurrentDirReduced
                            ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(Index).name);
                        else
                            ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(j).name);
                        end
                        ImTemp=imread(ReadStr);
                        if DatasetInfo.CurrentDirReduced
                            bbs=BBDetector{bbIndex,1};bbALL=BBDetector{bbIndex,1};                            
                        else
                            bbs=BBDetector{j,1};bbALL=BBDetector{j,1};
                        end
                        [bbs, bbALL]=ApplyFilterDetections(ImTemp,j,DetectorObj,DatasetInfo,bbs,bbALL,gt{j}(:,2:end));
                        cBB=convertDollarToLowFormat(bbs);
                        SHOWBBonImage(ImTemp,cBB);drawnow;
                    end
                end
            end
            bbs=BBDetector{DatasetInfo.StartValidFrame,1};
            bbALL=bbs;
            %%
        case 'ShahCVPR2012'
            load(DetectorObj.ReadBBFolder);
            if DatasetInfo.CurrentDirReduced
                BBDetector=BBDetector(DatasetInfo.ValidFrame);
                BBDetectorAll=BBDetectorAll(DatasetInfo.ValidFrame);
                bbs=BBDetector{i};
                bbALL=BBDetectorAll{i};                
            else
                bbs=BBDetector{i};
                bbALL=BBDetectorAll{i};
            end
        case 'BB_ACFwacv2015'
            %%
            A=xlsread(DetectorObj.ReadBBFolder); % in should be in Low Format
            % GTOpt replace with DetectorObj
            if DetectorObj.ArrangeAnnotation==-2%In Dollar Format  DetectorObj.ArrangeAnnotation==-2
                ABB=A;
                ABB(:,3:6)=convertDollarToLowFormat(A(:,3:6))';%xc	yc w  h
            end
            FrameID=unique(ABB(:,1));
            Nframes=length(FrameID);
            BBDetector=cell(max(FrameID),1);
            BBDetectorAll=BBDetector;
            Index=0;
            for j=DatasetInfo.FrameIndex(DatasetInfo.ValidFrame)
                Index=Index+1;
                Sid=find(ABB(:,1)==j + DetectorObj.ShiftV+1& ABB(:,7)>=DetectorObj.ScoreThre);
                BBDetector{j,1}=[convertLowFormattoLeftTopWHT(ABB(Sid,3:6)') ABB(Sid,7)];
                BBDetectorAll{j,1}=BBDetector{j,1};
                ShowDt=0;
                if ShowDt==1
                    cBB=ABB(Sid,3:6)';
                    Score=ABB(Sid,end);
                    ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(j).name);
                    ImTemp=imread(ReadStr);
                    SHOWBBonImage(ImTemp,cBB);
                end
            end
            bbs=BBDetector{DatasetInfo.StartValidFrame,1};
            bbALL=bbs;
        case 'BB_ACF'
            A=load(DetectorObj.ReadBBFolder); % in should be in Low Format
            if DetectorObj.ArrangeAnnotation==-2%In Dollar Format  DetectorObj.ArrangeAnnotation==-2
                ABB=A;
                ABB(:,2:5)=convertDollarToLowFormat(A(:,2:5))';%xc	yc w  h
            end
            FrameID=unique(ABB(:,1));
            Nframes=length(FrameID);
            BBDetector=cell(max(FrameID),1);
            BBDetectorAll=BBDetector;
            Index=0;
            for j=DatasetInfo.FrameIndex%(DatasetInfo.ValidFrame)
                Index=Index+1;
                Sid=find(ABB(:,1)== (j + DetectorObj.ShiftV+1) & ABB(:,6)>=DetectorObj.ScoreThre);
                BBDetector{j,1}=[convertLowFormattoLeftTopWHT(ABB(Sid,2:5)') ABB(Sid,6)];
                BBDetectorAll{j,1}=BBDetector{j,1};
                ShowDt=0;
                if ShowDt==1
                    cBB=ABB(Sid,2:5)';
                    Score=ABB(Sid,end);
                    ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(j).name);
                    ImTemp=imread(ReadStr);
                    if DetectorObj.ScaleDetections==1
                        cBB=(ScaleBBSize(cBB,DetectorObj.ScaleBBOpt,ImTemp));
                    end
                    SHOWBBonImage(ImTemp,cBB);
                end
            end
            bbs=BBDetector{DatasetInfo.StartValidFrame,1};
            bbALL=bbs;
    end
else
    BBDetector=cell(length(DatasetInfo.StartFrame:DatasetInfo.EndValidFrame),1);
    BBDetectorAll=BBDetector;
    switch DetectorObj.DetectorName
        case {'ACF','BB_ACF'}
            [bbs]= acfDetect(imgIn,DetectorObj.PretrainedACF.detector, [] ,DetectorObj.PretrainedACF.ExtraOpts);
            bbALL=bbs;
        case 'DollarDetector'
            for kk=1:length(BBDetector)
                bbs=BBDetector{kk};
                bbALL=BBDetectorAll{kk};                
                ReadStr2=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(kk).name);
                imgIn2=imread(ReadStr2);
                DetectorObj.PretrainedDollar.prm.imgNm    =imgIn2;
                [bbs, bbALL]=ApplyFilterDetections(imgIn2,kk,DetectorObj,DatasetInfo,bbs,bbALL,gt{kk}(:,2:end));
                BBDetector{kk}=bbs;
                BBDetectorAll{kk}=bbALL;
                if (0)
                    cBB=convertDollarToLowFormat(bbs);
                    SHOWBBonImage(imgIn2,cBB);
                end
            end
            if DetectorObj.SaveDetectionResults==1               
               save(DetectorObj.ReadBBFolder,'BBDetector','BBDetectorAll');
               DetectorObj.LoadPrecomputedDetections=1;
            end
            bbs=BBDetector{i};
            bbALL=BBDetectorAll{i};
        otherwise
            DetectorObj.PretrainedDollar.prm.imgNm    =imgIn;
            [bbs bbALL]=detect(DetectorObj.PretrainedDollar.prm);%- [nx5] array of detected bbs and confidences % bbALL [x y w h wt bbType]
    end
    if DetectorObj.ScaleFactor~=1
        bbs=ScaleDollarBB(bbs,DetectorObj.ScaleFactor);
        bbALL=ScaleDollarBB(bbALL,DetectorObj.ScaleFactor);
    end
end
GTbb=gt{i};  if ~isempty(GTbb), GTbb=GTbb(:,2:end); end;
[bbs, bbALL]=ApplyFilterDetections(Im,i,DetectorObj,DatasetInfo,bbs,bbALL,GTbb);
if (0),
figure(1); im(Im,[],0);
bbApply('draw',bbs,'g');
end
if DetectorObj.LoopUntilDetect
Jv=0;
while Jv==0  % Continue if no detections available
    NumberOfTrackers=size(bbs,1);
    if not(NumberOfTrackers)
        i=i+1;
        if DetectorObj.LoadPrecomputedDetections==1
            bbs=BBDetector{i};
            bbALL=BBDetectorAll{i};
        else
            switch DetectorObj.DetectorName
                case {'ACF','BB_ACF'}
                    Im=imread(strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(i).name));
                    [bbs, bbALL]=ApplyFilterDetections(Im,i,DetectorObj,DatasetInfo,bbs,bbALL,gt{i}(:,2:end));
                otherwise
                    [bbs bbALL]=detect(DetectorObj.PretrainedDollar.prm);%- [nx5] array of detected bbs and confidences % bbALL [x y w h wt bbType]
                    if DetectorObj.ScaleFactor~=1
                        bbs=ScaleDollarBB(bbs,DetectorObj.ScaleFactor);
                        bbALL=ScaleDollarBB(bbALL,DetectorObj.ScaleFactor);
                    end
            end
        end
        [bbs, bbALL]=ApplyFilterDetections([],i,DetectorObj,DatasetInfo,bbs,bbALL,gt{i}(:,2:end));
    else
        Jv=1;
    end    
end
end
ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(i).name);
Im=imread(ReadStr);
%%
DatasetInfo.NewStartFrame=i;
DatasetInfo.MaxTrackerLength=length([DatasetInfo.StartFrame:DatasetInfo.EndValidFrame]);
if min(DatasetInfo.FrameIndex)==1 && sum(DatasetInfo.ValidFrame)~=length(BBDetector)
    BBDetector=BBDetector(DatasetInfo.ValidFrame);
    BBDetectorAll=BBDetectorAll(DatasetInfo.ValidFrame);
end
%%
AllTrk.Trobject=[];
for ID=1:size(bbs,1)
    AllTrk.Trobject(ID).p=[];
    AllTrk=InitializeTracker(AllTrk,ID,i,TrackerOpt, DatasetInfo,Im,bbs(ID,:));
end
DatasetInfo.sizeFrame=size(Im);
end