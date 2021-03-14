function [ScoreTh,EER,ap]=EvaluateDetector(GTC,BBDetector,RangeOfInput,DatasetInfo,DetectorObj,ShowSaveParam,GTOpt)
% function  [ap, EER, nTp, nFp,nMissed,nTn,TPR,FDR,AFPPFrame,AFPPObject,ATPPFrame,ClearMOT,BBFinal,ScoreAll]=PrecRecallFinal(ImC,GTC,RangeOfInput,ResultsA,Detector,DataInfo,EvParameter,ShowParameter,EERScoreTh)
% FinalSavePrecRecallOpt;
% imgset              =DataInfo.imgset;
% SaveResultsImage    =DataInfo.SaveResultsImage;
% SaveScoreResuts      =DataInfo.SaveScoreResuts;
% GTObj                =DataInfo.GTObj;
% StringScore         =Detector.Test.StringScore;
% nMsupParam          =Detector.nMSup;
% nmax_param           =nMsupParam.nmax_paramLoop;
% cls                  =ShowParameter.cls;
%%
ScoreTh=[];ap=[];EER=[];
if DetectorObj.EvaluateDetector==1
    Xcell=cell(2,1);Ycell=cell(2,1);LegendV=cell(2,1);
    SaveScoreResuts = strcat(DetectorObj.ReadBBFolder,'\PRcurve\'); 
    %%
    if ShowSaveParam.ShowDNew && ShowSaveParam.SaveDVideoNew
        ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(1).name);
        Im=imread(ReadStr);
        Ic=floor(0.85*size(Im,2)) ;
        Ir=floor(0.85*size(Im,1));
        figure('position',[30 50 Ic Ir]); clf;
        hold on;
        VideoFile=strcat(DetectorObj.SaveResultsbbFolder,DetectorObj.DetectorName,'.avi');
        if DetectorObj.SaveAVIMethod==0
            writerObj = avifile(VideoFile,'fps',GTOpt.Frate,'compression','None');
        else
            writerObj = VideoWriter(VideoFile);
            writerObj.FrameRate =GTOpt.Frate;
            open(writerObj);
        end        
    end
    %%
    GTObj=[];
    tp=[];fp=[];score=[];npos=0;
    for i=RangeOfInput
        ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(i).name);
        Im=imread(ReadStr);
        gtBB=GTC{i,1}(:,2:end)';
        BB=convertDollarToLowFormat(BBDetector{i}(:,1:5));
        if size(BB,1)>1
        ScoreOutPos=BB(5,:)';
        [tpL,fpL]=EvaluateDetection(i,BB(1:4,:),gtBB,DetectorObj.EvaluateDetectorOpt,GTObj,DetectorObj.EvaluateDetectorOpt.ShowParameter);
        tp=[tp;tpL];
        fp=[fp;fpL];
        score=[score;ScoreOutPos];
        npos=npos+size(gtBB,2);
        if ShowSaveParam.ShowDNew==1
            imshow(Im);
            cBB=BB(1:4,:);
            SHOWBBonImage(Im,cBB,ScoreOutPos,ScoreOutPos,1,[0 0 1],1,15);
            if ShowSaveParam.SaveDVideoNew
                hold on;
                text(10, 15, '#', 'Color','y', 'FontWeight','bold', 'FontSize',24);
                text(30, 15, num2str(i), 'Color','y', 'FontWeight','bold', 'FontSize',24);
                hold off;                
                img_color=getframe;
                if size(img_color,1)~=Ir || size(img_color,2)~=Ic
                    img_color.cdata=imresize(img_color.cdata,[Ir,Ic]);
                end
                if DetectorObj.SaveAVIMethod==0
                    writerObj = addframe(writerObj,img_color);
                else
                    writeVideo(writerObj,img_color);
                end                
            end
        end
        end
    end 
    if length(fp)>length(tp)
        tp=[tp;0];
    elseif length(fp)<length(tp)
        fp=[fp;0];
    else
    end
    if isempty(tp)==0
        if DetectorObj.EvaluateDetectorOpt.ComputePlotInvPRRecall
            Xlabel='1-Precision';Ylabel='Recall';LegendLoc='SouthEast';
            [ap, rec,precinv,EER,nTp,nFp,ScoreTh]=plotRvsInvPrecisioncurve(fp,tp,npos,0,score);
            XaxisV=precinv;
            YaxisV=rec;
            strcat(DetectorObj.DetectorName,', EER =',sprintf('%5.2f',EER*100),'%','Average precision=',sprintf('%5.2f',ap*100));
            if DetectorObj.EvaluateDetectorOpt.ShowParameter.UseLatex==1
                LegendV{DetectorObj.EvaluateDetectorOpt.MethodNumber}=strcat('\textrm{',DetectorObj.DetectorName,'}');
            else
                LegendV{DetectorObj.EvaluateDetectorOpt.MethodNumber}=strcat(DetectorObj.DetectorName);
            end
        else % plotPRRecall
            Xlabel='Recall';Ylabel='Precision';LegendLoc='SouthEast';
            [ap,rec,prec]=plotPRcurve(fp,tp,npos,0,score);
            XaxisV=rec;
            YaxisV=prec;
            if DetectorObj.EvaluateDetectorOpt.ShowParameter.UseLatex==1
                LegendV{DetectorObj.EvaluateDetectorOpt.MethodNumber}=strcat('\textrm{',DetectorObj.DetectorName,', ap} =',sprintf('%5.2f',ap*100),'\%');
            else
                LegendV{DetectorObj.EvaluateDetectorOpt.MethodNumber}=strcat(DetectorObj.DetectorName,', ap =',sprintf('%5.2f',ap*100),'%');
            end
        end
        Xcell{DetectorObj.EvaluateDetectorOpt.MethodNumber}=XaxisV;
        Ycell{DetectorObj.EvaluateDetectorOpt.MethodNumber}=YaxisV;
        if DetectorObj.EvaluateDetectorOpt.ShowParameter.PlotPRFlag
            figure;
            PlotCurve(Xcell,Ycell,LegendV,Xlabel,Ylabel,0,1,0,1,10,LegendLoc,1,DetectorObj.EvaluateDetectorOpt.ShowParameter.UseLatex,DetectorObj.EvaluateDetectorOpt.MethodNumber);
            LegendString=[];
            for l=1:length(LegendV)
                LegendString=cat(2,LegendString,LegendV{l});
            end
            FileName=strcat(SaveScoreResuts,DatasetInfo.DatasetName,'_',DetectorObj.DetectorName,num2str(DetectorObj.EvaluateDetectorOpt.ComputePlotInvPRRecall),LegendString);
            if DetectorObj.EvaluateDetectorOpt.ShowParameter.SAVE_VOC_PR_Curve==1
                disp(strcat('Stored PR curve:', FileName));
                saveas(gcf,strcat(FileName,'.pdf'));
            end
        end
    end    
    hold off
    if ShowSaveParam.SaveDVideoNew
        if DetectorObj.SaveAVIMethod==0
            writerObj = close(writerObj);
        else
            close(writerObj);
            clear writerObj
        end
    end
end