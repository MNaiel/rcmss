TimeSmallParametercpu=clock;
if TrackerOpt.DA.UseMasterSlaveMerge==1 && AllTrk.Trobject(ID).InMerge==1 && AllTrk.Trobject(ID).Master==0
    for ID= TrackerRange(ValidTracker)
        Id2=AllTrk.Trobject(ID).MergeWith;
        if AllTrk.Trobject(Id2).Master==1
            AllTrk.Trobject(ID).param.est        =AllTrk.Trobject(Id2).param.est ;
            AllTrk.Trobject(ID).paramAll(:,f).est=AllTrk.Trobject(Id2).paramAll(:,f).est;
            AllTrk.Trobject(ID).BBresult(:,f)    =AllTrk.Trobject(Id2).BBresult(:,f);
            AllTrk.Trobject(ID).result(f,:)      =AllTrk.Trobject(Id2).param.est';
        end
    end
end
TimeSmallParameter(fIndex)= TimeSmallParameter(fIndex)+etime(clock,TimeSmallParametercpu);
%%
if ShowSaveParam.ShowandSaveAllResultsAsVideo==1
    TimeShowVideocpu=clock;
    [drawopt]=drawAllTrackResult(drawopt, f, img_color, AllTrk,NumberOfTrackers,ValidTracker,1,ShowSaveParam.ShowParticles,0,1,1,ShowSaveParam);
    if ShowSaveParam.plotPDF && f==ShowSaveParam.PlotFrameN
        SaveFigure=strcat(DatasetInfo.SaveResultsImage,'Particles\FrameNumber',PadIndexWithZeros(f));
        saveas(gcf,strcat(SaveFigure,'.png'));
        saveas(gcf,strcat(SaveFigure,'.pdf'));
        saveas(gcf,strcat(SaveFigure,'.eps'),'psc2');
        if ShowSaveParam.superimposeFigures
            TrackImage=imread(strcat(SaveFigure,'.png'));
        end
        [drawopt2] = drawAllTrackResultPDF(drawopt2, f, img_color, AllTrk,NumberOfTrackers,ValidTracker);
        SaveFigure=strcat(DatasetInfo.SaveResultsImage,'Particles\PFWeights',PadIndexWithZeros(f));
        saveas(gcf,strcat(SaveFigure,'.png'));
        saveas(gcf,strcat(SaveFigure,'.pdf'));
        saveas(gcf,strcat(SaveFigure,'.eps'),'psc2');
        if ShowSaveParam.superimposeFigures
            ParticleImag=imread(strcat(SaveFigure,'.png'));
            [mp1,mp2,~]=size(ParticleImag);
            nr1=floor(mp1*0.5);nc1=floor(mp2*0.5);
            ResizedParticleImag=imresize(ParticleImag,[nr1, nc1]);
            NewIm=TrackImage;
            NewIm(end-nr1+1:end,end-nc1+1:end,:)=ResizedParticleImag;
        end
    end
    TimeShowVideo(fIndex)= etime(clock,TimeShowVideocpu);
end
if ShowSaveParam.saveasFiles==1
    TimeSaveFigurecpu=clock;
    SaveFigure=strcat(DatasetInfo.SaveResultsImage,PadIndexWithZeros(f));
    saveas(gcf,strcat(SaveFigure,'.png'));
    TimeSaveFigure(fIndex)=TimeSaveFigure(fIndex)+etime(clock,TimeSaveFigurecpu);
end
%% Store tracking results on a text file
TimeSmallParametercpu=clock;
NumberOfTrackers     =length(AllTrk.Trobject);
NumberOfTrackersValid=0;
for ID=1:NumberOfTrackers
    if AllTrk.Trobject(ID).ValidTracker
        fprintf(fid,'%d %d %f %f %f %f %f %f\n',f,ID,AllTrk.Trobject(ID).currentCenter(:,f),AllTrk.Trobject(ID).BBresult(:,f));
        NumberOfTrackersValid=NumberOfTrackersValid+1;
    end
end
TimeSmallParameter(fIndex)= TimeSmallParameter(fIndex)+etime(clock,TimeSmallParametercpu);
NumberOfTrackers_t(fIndex)=NumberOfTrackersValid;