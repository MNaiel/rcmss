function [Finalresult,AllTrk,stateInfo]=LoadTRResults(DatasetInfo,ResultsOpts,fcol)
A=load(ResultsOpts.ResultsFile);
if isempty(A)==0
    BB=A(:,5:end);
    FrameNumber=A(:,1);objectID=A(:,2);
    frames=unique(FrameNumber);
    Minframes=min(frames);
    OIDs=unique(objectID);
    INdex=0;
    Indexframes=1;
    num=DatasetInfo.finalTest;
    Ntrackers=max(OIDs);
    Ncolor=size(fcol,1);
    for ID=1:Ntrackers
        if ID>Ncolor,     CI=ID-rem(Ncolor,ID)*floor(ID/Ncolor)+1;  else      CI=ID;        end
        AllTrk.Trobject(ID).BBresult=zeros(4,num);
        AllTrk.Trobject(ID).color=fcol(CI,:)';
        AllTrk.Trobject(ID).StartFrame=1;
    end
    stateInfo.frameNums=DatasetInfo.FrameValidIndex;
    stateInfo.Xi=zeros(length(stateInfo.frameNums),Ntrackers);
    stateInfo.Yi=zeros(length(stateInfo.frameNums),Ntrackers);
    stateInfo.W=zeros(length(stateInfo.frameNums),Ntrackers);
    stateInfo.H=zeros(length(stateInfo.frameNums),Ntrackers);
    for f=DatasetInfo.FrameValidIndex;%StartFrame:LastValue
        INdex=INdex+1;
        if Indexframes<=length(frames) && frames(Indexframes)==f
            IndexObjects=find(FrameNumber==frames(Indexframes));
            IDs=objectID(IndexObjects,:);
            cBB=BB(IndexObjects,:);  % in LOWFORMAT
            if ResultsOpts.ChangeWidthHight
                bbsOut=convertLowFormattoLeftTopWHT(cBB');
                bbsOut(:,3)=bbsOut(:,3)*ResultsOpts.ChangeW;
                bbsOut(:,4)=bbsOut(:,4)*ResultsOpts.ChangeH;
                cBB=convertDollarToLowFormat(bbsOut)';
            end
            if isempty(IDs)==0
                for ID=IDs(:)'
                    [iNdex]=find(IDs==ID);
                    AllTrk.Trobject(ID).BBresult(:,f)=cBB(iNdex,:)';
                    AllTrk.Trobject(ID).currentCenter(:,f)=convertlowFormattoCenter(AllTrk.Trobject(ID).BBresult(:,f));
                    Finalresult(f).trackerData.target(ID).bbox=convertLowFormattoLeftTopWHT(AllTrk.Trobject(ID).BBresult(:,f));
                    bbsOut=convertLowFormattoCenterLowWHT(AllTrk.Trobject(ID).BBresult(:,f))';
                    stateInfo.Xi(f,ID)=bbsOut(1);%INdex
                    stateInfo.Yi(f,ID)=bbsOut(2);
                    stateInfo.W(f,ID)=bbsOut(3);
                    stateInfo.H(f,ID)=bbsOut(4);
                end
                Finalresult(f).trackerData.idxTracks=IDs;
            else
                Finalresult(f).trackerData.idxTracks=[];
                Finalresult(f).trackerData.target=[];
            end
            Indexframes=Indexframes+1;
        else
            Finalresult(f).trackerData.idxTracks=[];
            Finalresult(f).trackerData.target=[];
        end
    end
    %%
    if ResultsOpts.FilterAfterTracking==1
        NumberOfTrackers=length(AllTrk.Trobject);
        OldRangeOfTrackers=1:NumberOfTrackers;
        BadTrackerInd=[];
        ValidTrackerIND=true(NumberOfTrackers,1);
        for ID=1:NumberOfTrackers % prepare results in new coordinates %(this in previous time step) t-1
            if isempty(AllTrk.Trobject(ID).currentCenter)==0
                X1=sum(AllTrk.Trobject(ID).BBresult,1);
                ValidX1=X1>0;
                if sum(ValidX1)<=ResultsOpts.MinTrajectoryLength
                    BadTrackerInd=[ BadTrackerInd, ID];
                    ValidTrackerIND(ID)=false;
                end
            end
        end
        if ~isempty(BadTrackerInd)
            Finalresult=ReduceFinalResults(Finalresult,DatasetInfo,BadTrackerInd,OldRangeOfTrackers,ValidTrackerIND);
            stateInfo.Xi(:,BadTrackerInd)=[];
            stateInfo.Yi(:,BadTrackerInd)=[];
            stateInfo.W(:,BadTrackerInd)=[];
            stateInfo.H(:,BadTrackerInd)=[];
            AllTrk.Trobject=AllTrk.Trobject(ValidTrackerIND);
        end
    end
    %%
    stateInfo.Xi=stateInfo.Xi(stateInfo.frameNums',:); stateInfo.Yi=stateInfo.Yi(stateInfo.frameNums',:);  stateInfo.H=stateInfo.H(stateInfo.frameNums',:);  stateInfo.W=stateInfo.W(stateInfo.frameNums',:);
    %%
    if ResultsOpts.UseROI==1
        for j=1:ResultsOpts.ROIOpt.NROI
            [ms1,ms2,ms3]=size(ResultsOpts.ROIOpt.MaskFile(j).MaskImage);
            NumberOfTrackers=length(AllTrk.Trobject);
            OldRangeOfTrackers=1:NumberOfTrackers;
            BadTrackerInd=[];
            ValidTrackerIND=true(NumberOfTrackers,1);
            for ID=1:NumberOfTrackers % prepare results in new coordinates %(this in previous time step) t-1
                cBB=AllTrk.Trobject(ID).BBresult;
                X1=sum(cBB,1);
                if sum(X1>0)>0
                    BadIndex=[];
                    for k=1:size(cBB,2)
                        if X1(k)>0
                            patchsum=mean(mean(ResultsOpts.ROIOpt.MaskFile(j).MaskImage(max(1,cBB(2,k)):min(ms1,cBB(4,k)),max(1,cBB(1,k)):min(ms2,cBB(3,k)),:)));
                            % percent of ones high :> forground
                            if  patchsum<= ResultsOpts.ROIOpt.OverlapThreshold
                                BadIndex=[BadIndex,k];
                            end
                        end
                    end
                    cBB(:,BadIndex)=zeros(4,length(BadIndex));
                    X2=sum(cBB,1);
                    if sum(X2>0)>0  % In ROI
                        AllTrk.Trobject(ID).BBresult= cBB;
                    else
                        ValidTrackerIND(ID)=false;
                    end
                end
            end
            AllTrk.Trobject=AllTrk.Trobject(ValidTrackerIND);
            stateInfo.Xi(:,not(ValidTrackerIND))=[];%INdex
            stateInfo.Yi(:,not(ValidTrackerIND))=[];
            stateInfo.W(:,not(ValidTrackerIND))=[];
            stateInfo.H(:,not(ValidTrackerIND))=[];
            BadTrackerInd=find(ValidTrackerIND~=1);
            Finalresult=ReduceFinalResults(Finalresult,DatasetInfo,BadTrackerInd,OldRangeOfTrackers,ValidTrackerIND);
        end
    end
else
    Finalresult=[];
    AllTrk=[];
    stateInfo =[];
end

function Finalresult=ReduceFinalResults(Finalresult,DatasetInfo,BadTrackerInd,OldRangeOfTrackers,ValidTrackerIND)
OldRangeReduced=OldRangeOfTrackers(ValidTrackerIND);
if ~isempty(BadTrackerInd)
    for f=DatasetInfo.FrameValidIndex;
        if ~isempty(Finalresult(f).trackerData.idxTracks)
            bbox=Finalresult(f).trackerData.target;
            Ids=Finalresult(f).trackerData.idxTracks;
            BadIndex2=[];
            for jID=BadTrackerInd(:)'
                Ind=find(Ids ==jID);
                if ~isempty(Ind)
                    BadIndex2=[BadIndex2 Ind];
                end
            end
            if ~isempty(BadIndex2)
                Ids(BadIndex2)=[];
                IdsN=MapRangeTrackers(Ids, OldRangeReduced);
                Finalresult(f).trackerData.target=[];
                Finalresult(f).trackerData.idxTracks= IdsN;
                Ind3=0;
                for jIDN=IdsN(:)'
                    Ind3=Ind3+1;
                    Finalresult(f).trackerData.target(jIDN).bbox=bbox(Ids(Ind3)).bbox;
                end
            end
        end
    end
end