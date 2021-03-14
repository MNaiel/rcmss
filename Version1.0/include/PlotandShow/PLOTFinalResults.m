function PLOTFinalResults(AllTrk,DatasetInfo,ResultsOpts,ShowSaveParam)
if ShowSaveParam.ShowandSaveAllResultsAsVideo2 ==0;
    return;
end
close all
if isempty(AllTrk)==0
    AllTrkPlot=storePLOTVariables(AllTrk,ShowSaveParam.UseGT);
    NumberOfTrackers=length(AllTrk.Trobject);
    ValidTracker=true(1,NumberOfTrackers);
    %% plot trajectories in 3D space
    for ID=1:NumberOfTrackers % prepare results in new coordinates %(this in previous time step) t-1
        StartFrame=AllTrkPlot.Trobject(ID).StartFrame;
        if isempty(AllTrkPlot.Trobject(ID).currentCenter)==0
            X1=AllTrkPlot.Trobject(ID).currentCenter(1,StartFrame:end-1);
            X2=AllTrkPlot.Trobject(ID).currentCenter(2,StartFrame:end-1);
            ValidX1=X1>0;
            t=StartFrame:StartFrame+length(X1)-1;
            COLOR=AllTrkPlot.Trobject(ID).color;
            h=plot3(X1(ValidX1),X2(ValidX1),t(ValidX1));
            set(h,'Color',COLOR,'LineWidth',3);
            hold on;
        end
    end
    hold off
    xlabel('X screen width');
    ylabel('Y screen height');
    zlabel('time');
    grid on
    axis square
    %%
    RangeOfTrackers=1:NumberOfTrackers;
    %% Show and store the video results
    drawopt=[];
    DX=0;
    fTrueNumber=DatasetInfo.FrameIndex;%(DatasetInfo.ValidFrame);
    Findex=0;
    for f= DatasetInfo.FrameValidIndex
        Findex=Findex+1;
        ReadStr=strcat(DatasetInfo.MainFolder,'\',DatasetInfo.CurrentDir(f).name);
        img_color=imread(ReadStr);
        if isfield(ShowSaveParam,'Mask') && ShowSaveParam.Mask
            img_color(:,:,1)=img_color(:,:,1) .* uint8(im2bw(DatasetInfo.mask));
            img_color(:,:,2)=img_color(:,:,2) .*  uint8(im2bw(DatasetInfo.mask));
        end
        [n1,n2,n3]=size(img_color);
        for ID=RangeOfTrackers(:)'
            if ~isempty(AllTrkPlot.Trobject(ID).BBresult) && f<=size(AllTrkPlot.Trobject(ID).BBresult,2) && sum(AllTrkPlot.Trobject(ID).BBresult(:,f))~=0 %&& Findex<=length(AllTrk.Trobject(ID).resultEvaluation)
                ValidTracker(ID)=1;
            else
                ValidTracker(ID)=0;
            end
        end
        [drawopt]=drawAllTrackResult(drawopt, f, img_color, AllTrkPlot,NumberOfTrackers,ValidTracker,1,0,0, 150,fTrueNumber(Findex),ShowSaveParam);
        if ShowSaveParam.StoreVideo2==1
            if f==DatasetInfo.FrameValidIndex(1)
                if ResultsOpts.SaveAVIMethod==0
                    writerObj = avifile(strcat(DatasetInfo.SaveResultsImage,ResultsOpts.SaveVideoName),'fps',ResultsOpts.Frate,'compression','None');
                else
                    writerObj = VideoWriter(strcat(DatasetInfo.SaveResultsImage,ResultsOpts.SaveVideoName));
                    writerObj.FrameRate =ResultsOpts.Frate;
                    open(writerObj);
                end
                img_color=getframe;
                [Ir,Ic,Id]=size(img_color.cdata);
            end
            img_color=getframe;
            if size(img_color,1)~=Ir || size(img_color,2)~=Ic
                img_color.cdata=imresize(img_color.cdata,[Ir,Ic]);
            end
            if ResultsOpts.SaveAVIMethod==0
                writerObj = addframe(writerObj,img_color);
            else
                writeVideo(writerObj,img_color);
            end
        end
    end
    hold off
    if ShowSaveParam.StoreVideo2==1
        if ResultsOpts.SaveAVIMethod==0
            writerObj = close(writerObj);
        else
            close(writerObj);
            clear writerObj
        end
    end
    if ShowSaveParam.ShowandSaveAllResultsAsVideo2==1
        if ShowSaveParam.saveasFiles2==1
            imagefiles=dir(strcat(DatasetInfo.SaveResultsImage,'*.png'));
            writerObj = VideoWriter(strcat(DatasetInfo.SaveResultsImage,ResultsOpts.SaveVideoName));
            writerObj.FrameRate = 3;
            open(writerObj);
            nFrames=numel(imagefiles);
            for f = 1:nFrames
                ReadStr=strcat(DatasetInfo.SaveResultsImage,'\',imagefiles(f).name);
                img_color=imread(ReadStr);
                writeVideo(writerObj,img_color);
            end
            close(writerObj);
            clear writerObj
        end
        if ShowSaveParam.ShowMovieFile==1 && (ShowSaveParam.StoreVideo2==1 || ShowSaveParam.saveasFiles2==1 )
            ReadedVideo = VideoReader(strcat(DatasetInfo.SaveResultsImage,ResultsOpts.SaveVideoName));
            nFrames = ReadedVideo.NumberOfFrames;
            vidHeight = ReadedVideo.Height;
            vidWidth = ReadedVideo.Width;
            % Preallocate movie structure.
            clear mov
            mov(1:nFrames) =  struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),'colormap', []);
            % Read one frame at a time.
            for k = 1 : nFrames
                mov(k).cdata = read(ReadedVideo, k);
            end
            % Size a figure based on the video's width and height.
            hf=figure('position',[30 50 vidWidth vidHeight]); clf;
            set(hf,'DoubleBuffer','on','MenuBar','none');
            colormap('gray');
            movie(hf, mov, 1, ReadedVideo.FrameRate);
        end
    end
    if ResultsOpts.saveworkspace==1,  save(strcat(DatasetInfo.SaveResultsImage,ResultsOpts.SaveVideoName(1:end-4),'.mat'));end
end