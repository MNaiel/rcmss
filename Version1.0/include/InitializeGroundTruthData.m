function [gt,DatasetInfo,gt2Info]=InitializeGroundTruthData(DatasetInfo,GTOpt,ShowSaveParam,DetectorObj,ResultsOpts)
%%
global fcol
if GTOpt.UseGT==1
    if GTOpt.ArrangeAnnotation~=3 && GTOpt.ArrangeAnnotation~=4
        A=xlsread(strcat(DatasetInfo.MainFolder,'\',GTOpt.AnnotationFilename));% FrameNumber	id	h	w	xc	yc
    end
    switch GTOpt.ArrangeAnnotation
        case 1
            BB=[A(:,5),A(:,6), A(:,4),A(:,3)];%xc	yc w  h
        case -1
            BB=convertFromLowFormatToCenter(A(:,3:end)')';
        case 2
            BB=convertDollarToLowFormat(A(:,3:6))';%xc	yc w  h
        case 3
            fdoc=importdata(strcat(DatasetInfo.MainFolder,'\',GTOpt.AnnotationFilename));
            Video=fdoc.getFirstChild;
            start_frame=str2num(Video.getAttribute('start_frame'));
            end_frame=str2num(Video.getAttribute('end_frame'));
            Trajectory=Video.getElementsByTagName('Trajectory');
            TLength=Trajectory.getLength;
            A=[];
            for i=0:TLength-1
                Tstart=str2num(Trajectory.item(i).getAttribute('start_frame'));
                Tend=str2num(Trajectory.item(i).getAttribute('end_frame'));
                Frame=Trajectory.item(i).getElementsByTagName('Frame');
                for j=0:Frame.getLength-1
                    xx=str2num(Frame.item(j).getAttribute('x'));
                    yy=str2num(Frame.item(j).getAttribute('y'));
                    ww=str2num(Frame.item(j).getAttribute('width'));
                    hh=str2num(Frame.item(j).getAttribute('height'));
                    frame_no=str2num(Frame.item(j).getAttribute('frame_no'));
                    bbsCentreWHT=[xx+ww/2; yy+hh;ww;hh];
                    A=[A; frame_no+1, i+1, convertCenterLowWHTtoLowFormat(bbsCentreWHT)'];
                end
            end
            [SA,Order]=sort(A(:,1));
            A=A(Order,:);
            BB=A(:,3:end);
        case 4
            A=load(strcat(DatasetInfo.MainFolder,'\',GTOpt.AnnotationFilename));
            BB=convertDollarToLowFormat(A(:,3:6))';%xc	yc w  h
        otherwise
            BB=[A(:,3)+A(:,5)/2,A(:,4)+A(:,6)/2, A(:,5),A(:,6)];%xc	yc w  h
    end
    FrameNumber=A(:,1);objectID=A(:,2);
    frames=unique(FrameNumber);
    fIndex=find(FrameNumber<=DatasetInfo.LastValue+GTOpt.ShiftV & FrameNumber>=DatasetInfo.StartFrameGT+GTOpt.ShiftV);
    A=A(fIndex,:);BB=BB(fIndex,:);
    FrameNumber=A(:,1);objectID=A(:,2);
    frames=unique(FrameNumber);
    Minframes=min(frames);
    INdex=DatasetInfo.StartFrame-1;
    Indexframes=DatasetInfo.StartFrame;
    gt=cell(length([DatasetInfo.StartFrameGT:DatasetInfo.LastValue]),1);
    %%
    start_frame=DatasetInfo.StartFrameGT;
    end_frame=DatasetInfo.LastValue;
    gt2Info.frameNums=start_frame:end_frame;
    [GTid IA]=unique(objectID,'stable'); GTidDummy=[1:length(GTid)]';
    ind=0;
    for id=GTid',
        ind=ind+1;
        CellID{ind}=find(objectID==id);
    end;
    for id=GTidDummy',
        objectID(CellID{id})=id;
    end
    GTid=unique(objectID);
    TLength=1;%length(GTid);
    gt2Info.X=zeros(end_frame-start_frame+1,TLength);
    gt2Info.Y=zeros(end_frame-start_frame+1,TLength);
    gt2Info.H=zeros(end_frame-start_frame+1,TLength);
    gt2Info.W=zeros(end_frame-start_frame+1,TLength);
    %%
    ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(1).name);
    Im=imread(ReadStr);
    [n1,n2,n3]=size(Im);
    if ShowSaveParam.ShowGTNew
        ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(1).name);
        Im=imread(ReadStr);
        Ic=floor(0.85*size(Im,2)) ;
        Ir=floor(0.85*size(Im,1));
        figure('position',[30 50 Ic Ir]); clf;
        hold on;
        if ShowSaveParam.SaveGTVideoNew
            VideoFile=strcat(DatasetInfo.MainFolder,GTOpt.FolderName,GTOpt.GtName,'4.avi');
            if GTOpt.SaveAVIMethod==0
                writerObj = avifile(VideoFile,'fps',GTOpt.Frate,'compression','None');
            else
                writerObj = VideoWriter(VideoFile);
                writerObj.FrameRate =GTOpt.Frate;
                open(writerObj);
            end
        end
    end
    for f=DatasetInfo.FrameIndex(:)'
        INdex=INdex+1;
        if Indexframes<=length(frames) && frames(Indexframes)==f+GTOpt.ShiftV
            IndexObjects=find(FrameNumber==frames(Indexframes));
            ID=objectID(IndexObjects,:);  cBB=BB(IndexObjects,:);
            if GTOpt.ArrangeAnnotation~=2 & GTOpt.ArrangeAnnotation~=3 & GTOpt.ArrangeAnnotation~=4
                cBB=convertCenterWHToLowFormat(cBB);%[clow; rlow; chigh; Rhigh; score]
            else
                cBB=cBB';
            end
            switch DatasetInfo.DatasetName
                otherwise
                    idDiff=0;
            end
            if DetectorObj.FilterDetectionMask==1
                BadIndex=[];
                if ResultsOpts.UseROI==1
                    MaskImage=DetectorObj.MaskImage.*ResultsOpts.ROIOpt.MaskFile(1).MaskImage;
                else
                    MaskImage=DetectorObj.MaskImage;
                end
                for j=1:size(cBB,2)
                    patchsum=mean(mean(MaskImage(max(1,cBB(2,j)):min(n1,cBB(4,j)),max(1,cBB(1,j)):min(n2,cBB(3,j)),:)));
                    % percent of ones high :> forground
                    if  patchsum<= DetectorObj.OverlapThreshold
                        BadIndex=[BadIndex,j];
                    end
                end
                cBB(:,BadIndex)=[];
                ID(BadIndex)=[];
            elseif DetectorObj.FilterDetectionsGeo ~=0
                switch (DatasetInfo.DatasetName)
                    case 'soccer_ICIP08';
                    otherwise
                        bbs=convertLowFormattoLeftTopWHT(cBB);
                        [~,BadIndex]=FilterDetectionsGeometric(bbs,DatasetInfo,DetectorObj,[],Im);
                        cBB(:,BadIndex)=[];
                        ID(BadIndex)=[];
                end
            end
            %%
            if ShowSaveParam.ShowGTNew==1
                ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(f).name);
                Im=imread(ReadStr);
                ScoreOutPos=[];%0 show ID , empty do not show ID
                imshow(Im);
                Ncolor=size(fcol,1);Ind2=0;
                for obID=ID(:)', Ind2=Ind2+1;if obID>Ncolor, CI(Ind2,1)=obID-rem(Ncolor,obID).*floor(obID./Ncolor)+ones(length(obID),1); else CI(Ind2,1)=obID; end;  end;
                SHOWBBonImage(Im,cBB,ID,ID,1,fcol(CI,:),1,15);
                drawnow;
                if ShowSaveParam.ShowGTNew
                    hold on;
                    text(10, 15, '#', 'Color','y', 'FontWeight','bold', 'FontSize',24);
                    text(30, 15, num2str(f), 'Color','y', 'FontWeight','bold', 'FontSize',24);
                    hold off; img_color=getframe;
                    if size(img_color,1)~=Ir || size(img_color,2)~=Ic, img_color.cdata=imresize(img_color.cdata,[Ir,Ic]);end
                    if ShowSaveParam.SaveGTVideoNew
                        if GTOpt.SaveAVIMethod==0, writerObj = addframe(writerObj,img_color); else  writeVideo(writerObj,img_color); end
                    end
                end
            end
            %%
            if isempty(ID)==0
                gt{INdex}=[ID cBB']; %bbox = [id tl.x tl.y br.x br.y] where id is the ID of the target; tl   is the top-left corner of the bbox and br is the bottom-right one.
                if rem(Indexframes, DatasetInfo.ShiftTime)==0 || DatasetInfo.Limit2GT==0
                    DatasetInfo.ValidFrame(INdex)=true;
                else
                    DatasetInfo.ValidFrame(INdex)=false;
                end
                bbsOut=convertLowFormattoCenterLowWHT(cBB)';
                ind=0;
                for ids=ID',
                    ind=ind+1;
                    gt2Info.X(INdex,ids+idDiff)=bbsOut(1,ind); gt2Info.Y(INdex,ids+idDiff)=bbsOut(2,ind);gt2Info.W(INdex,ids+idDiff)=bbsOut(3,ind);gt2Info.H(INdex,ids+idDiff)=bbsOut(4,ind);
                end
                Indexframes=Indexframes+1;
                DatasetInfo.GTExist(INdex)=true;
            else
                Indexframes=Indexframes+1;
                if DatasetInfo.Limit2GT==0
                    DatasetInfo.ValidFrame(INdex)=true;
                else
                    DatasetInfo.ValidFrame(INdex)=false;
                end
                DatasetInfo.GTExist(INdex)=false;
                gt{INdex}=[]; %bbox = [id tl.x tl.y br.x br.y] where id is the ID of the target; tl   is the top-left corner of the bbox and br is the bottom-right one.
            end
        else
            if DatasetInfo.Limit2GT==0, DatasetInfo.ValidFrame(INdex)=true;  else  DatasetInfo.ValidFrame(INdex)=false;   end;
            DatasetInfo.GTExist(INdex)=false;
            gt{INdex}=[]; %bbox = [id tl.x tl.y br.x br.y] where id is the ID of the target; tl   is the top-left corner of the bbox and br is the bottom-right one.
        end
    end
    DatasetInfo.ValidFrame=logical(DatasetInfo.ValidFrame);
    if DatasetInfo.Limit2GT==1
        VIndex=DatasetInfo.FrameIndex(DatasetInfo.ValidFrame);
        DatasetInfo.FrameValidIndex=1:length(VIndex);
        DatasetInfo.StartValidFrame=1;
        DatasetInfo.EndValidFrame=length(DatasetInfo.FrameValidIndex);
    elseif DatasetInfo.Limit2GT==0
        DatasetInfo.StartValidFrame=DatasetInfo.StartFrame;
        DatasetInfo.EndValidFrame=DatasetInfo.LastValue;
        DatasetInfo.FrameValidIndex=DatasetInfo.StartFrame:DatasetInfo.LastValue;
    else
        DatasetInfo.StartValidFrame=DatasetInfo.StartFrame;
        DatasetInfo.EndValidFrame=DatasetInfo.LastValue;
        DatasetInfo.FrameValidIndex=ones(length(DatasetInfo.StartFrame:DatasetInfo.LastValue),1);
        DatasetInfo.ValidFrame=DatasetInfo.FrameValidIndex;
    end
    gt2Info.frameNums= DatasetInfo.FrameValidIndex;
    gt2Info.X=gt2Info.X(DatasetInfo.FrameValidIndex',:); gt2Info.Y=gt2Info.Y(DatasetInfo.FrameValidIndex',:);  gt2Info.H=gt2Info.H(DatasetInfo.FrameValidIndex',:);  gt2Info.W=gt2Info.W(DatasetInfo.FrameValidIndex',:);
    %% remove IDs without GT
    IndZeroID=find(sum(gt2Info.X,1)==0);
    gt2Info.X(:,IndZeroID)=[];
    gt2Info.Y(:,IndZeroID)=[];
    gt2Info.H(:,IndZeroID)=[];
    gt2Info.W(:,IndZeroID)=[];
    switch (DatasetInfo.DatasetName)
        case 'UCFParkinglot';
            switch DetectorObj.DetectorName
                case 'BBdolor';
                    AdjustToGTExist=0;
                otherwise
                    AdjustToGTExist=1;
            end
        case 'TownCentre'
            AdjustToGTExist=0;
        otherwise
            AdjustToGTExist=1;
    end
    if AdjustToGTExist==1
        gt2Info.frameNums=gt2Info.frameNums(DatasetInfo.GTExist);
        gt2Info.X=gt2Info.X(DatasetInfo.GTExist',:); gt2Info.Y=gt2Info.Y(DatasetInfo.GTExist',:);  gt2Info.H=gt2Info.H(DatasetInfo.GTExist',:);  gt2Info.W=gt2Info.W(DatasetInfo.GTExist',:);
    else
        DatasetInfo.GTExist=DatasetInfo.FrameValidIndex;
    end    
    if (ShowSaveParam.ShowGTNew || ShowSaveParam.SaveGTVideoNew),  hold off; end;
    if ShowSaveParam.SaveGTVideoNew       
        if GTOpt.SaveAVIMethod==0
            writerObj = close(writerObj);
        else
            close(writerObj);
            clear writerObj
        end
    end
else
    gt2Info=[];
    gt=cell(length([DatasetInfo.StartFrameGT:DatasetInfo.LastValue]),1);
    INdex=0;
    for f=DatasetInfo.FrameIndex(:)'
        INdex=INdex+1;
        DatasetInfo.ValidFrame(INdex)=true;
    end
    DatasetInfo.ValidFrame=logical(DatasetInfo.ValidFrame);
    VIndex=DatasetInfo.FrameIndex(DatasetInfo.ValidFrame);
    DatasetInfo.FrameValidIndex=1:length(VIndex);
    DatasetInfo.StartValidFrame=1;
    DatasetInfo.EndValidFrame=length(DatasetInfo.FrameValidIndex);
    DatasetInfo.GTExist=DatasetInfo.FrameValidIndex;
end