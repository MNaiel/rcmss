function [drawopt] = drawAllTrackResult(drawopt, fno, frame, AllTrk,NumofTargets,validRange,PlotTrajectory,PlotParticles,UseWeightedColor,Window,fnotrue,ShowSaveParam)
if (nargin <6),  validRange=ones(1,NumofTargets); end;
if (nargin <7),  PlotTrajectory=0;end
if (nargin <8),  PlotParticles=0; end
if (nargin <9),  UseWeightedColor=0; end
if (nargin <10), Window=150; end
if (nargin <11), fnotrue=fno;end
if (isempty(drawopt))
    figure('position',[30 50 size(frame,2) size(frame,1)]); clf;
    set(gcf,'DoubleBuffer','on','MenuBar','none');
    colormap('gray');
    drawopt.curaxis = [];
    drawopt.curaxis.frm  = axes('position', [0.00 0 1.00 1.0]);
end
TrackRange=1:NumofTargets;
curaxis = drawopt.curaxis;
axes(curaxis.frm);
imagesc(frame, [0,1]);
hold on;
for ID=TrackRange(validRange)
    ScoreOutPos=0;
    if ShowSaveParam.UseGT==0 || (isempty(AllTrk.Trobject(ID).resultEvaluation)==0 && AllTrk.Trobject(ID).resultEvaluation(fno))
        ColorOut=AllTrk.Trobject(ID).color;
    else
        ColorOut=[0; 0 ; 0];
    end
    SHOWBBonImage(frame,AllTrk.Trobject(ID).BBresult(:,fno),ScoreOutPos,ID,1,ColorOut,1,15);
    hold on;
    if PlotTrajectory==1
        ValidV=logical(sum(AllTrk.Trobject(ID).BBresult(:,:),1)>0);
        if  isempty(find(diff(ValidV(1:fno))==1))==0, V=max(max(find(diff(ValidV(1:fno))==1)),1)+1;  else       V=1;        end;
        if ValidV(fno)
            LastValue=fno;
            StartFrame=max(V,fno-Window);
            X1=AllTrk.Trobject(ID).currentCenter(1,StartFrame:LastValue);
            X2=AllTrk.Trobject(ID).currentCenter(2,StartFrame:LastValue);
            COLOR=AllTrk.Trobject(ID).color;
            if UseWeightedColor==1
                x=StartFrame:LastValue;
                Weight=GetColorWeight(x,LastValue,StartFrame);
                COLORPool=zeros(size(X1,2),3);
                for kk=1:size(X1,2)
                    COLORPool(kk,:)=Convertrgb2hsvWeighted(COLOR,Weight(kk));
                end
                scatter(X1,X2,20,COLORPool,'filled');
            else
                h=plot(X1,X2);
                set(h,'Color',[COLOR ],'LineWidth',3);
            end
        end
    end
    if PlotParticles==1
        hold on;
        SizePoint=10;
        PlotParticleWeight=1;
        ShowDetectorOnly=0;
        if PlotParticleWeight==0 && ShowDetectorOnly==1
            scatter(AllTrk.Trobject(ID).CentersParticles(1,:),AllTrk.Trobject(ID).CentersParticles(2,:),SizePoint,AllTrk.Trobject(ID).color,'filled');
        else
            Weight=AllTrk.Trobject(ID).ParticlesWeights;
            COLOR=AllTrk.Trobject(ID).color;
            xStart=min(Weight);
            xfinal=max(Weight);
            Weight=GetColorWeight(Weight,xfinal,xStart);
            COLORPool=Convertrgb2hsvWeighted(COLOR,Weight);
            if AllTrk.Trobject(ID).n_sample>AllTrk.Trobject(ID).opt.numsample
                DiffN=AllTrk.Trobject(ID).n_sample-AllTrk.Trobject(ID).opt.numsample ;%N NewDetectorParticles
                IndexDetector=false(AllTrk.Trobject(ID).n_sample,1);
                IndexDetector(1:DiffN)=1;
            else
                IndexDetector=false(AllTrk.Trobject(ID).n_sample,1);
            end
            if ShowDetectorOnly==0
                scatter(AllTrk.Trobject(ID).CentersParticles(1,not(IndexDetector)),AllTrk.Trobject(ID).CentersParticles(2,not(IndexDetector),:),SizePoint,COLORPool(not(IndexDetector),:),'filled');
            end
            if AllTrk.Trobject(ID).n_sample>AllTrk.Trobject(ID).opt.numsample
                scatter(AllTrk.Trobject(ID).CentersParticles(1,IndexDetector),AllTrk.Trobject(ID).CentersParticles(2,IndexDetector),SizePoint,COLORPool(IndexDetector,:),'Marker','*','MarkerEdgeColor',[0.5 0.5 0.5]);
            end
        end
    end
end
text(10, 15, '#', 'Color','y', 'FontWeight','bold', 'FontSize',24);
text(30, 15, num2str(fnotrue), 'Color','y', 'FontWeight','bold', 'FontSize',24);
axis equal tight off;
hold off;
drawnow;