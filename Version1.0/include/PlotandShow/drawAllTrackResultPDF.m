function [drawopt] = drawAllTrackResultPDF(drawopt, fno, frame, AllTrk,NumofTargets,validRange)
% plot the particles weights
if (nargin <6), validRange=ones(1,NumofTargets);end
PlotImage=1;
PlotBB=0;
PlotFrameN=0;
TrackRange=1:NumofTargets;
if (isempty(drawopt))
    figure('position',[800 250 size(frame,2)*0.7 size(frame,1)*0.7]); clf;
    set(gcf,'DoubleBuffer','on','MenuBar','none');
    drawopt.curaxis = [];
    drawopt.curaxis.frm  = axes;
end
curaxis = drawopt.curaxis;
axes(curaxis.frm);
if PlotImage==1
    imagesc(frame, [0,1]);
    hold on;
end
maxWeight=-10;
for ID=TrackRange(validRange)
    ScoreOutPos=0;
    if PlotBB==1
        SHOWBBIDonImageOnly(frame,AllTrk.Trobject(ID).BBresult(:,fno),ScoreOutPos,ID,1,AllTrk.Trobject(ID).color,1);
        hold on;
    end
    hold on;
    SizePoint=10;
    PlotParticleWeight=0;
    ShowDetectorOnly=1;
    showPropagatedOnly=0;
    PCenters=AllTrk.Trobject(ID).CentersParticles;
    PCenters(3,:)=AllTrk.Trobject(ID).ParticlesWeights;
    maxWeight=max(maxWeight,max(PCenters(3,:)));
    Weight=AllTrk.Trobject(ID).ParticlesWeights;
    COLOR=AllTrk.Trobject(ID).color;
    xStart=min(Weight);
    xfinal=max(Weight);
    Weight=GetColorWeight(Weight,xfinal,xStart);
    COLORPool=Convertrgb2hsvWeighted(COLOR,Weight,PlotParticleWeight);
    stem3(PCenters(1,:), PCenters(2,:),PCenters(3,:),'Color',AllTrk.Trobject(ID).color);
    if AllTrk.Trobject(ID).n_sample>AllTrk.Trobject(ID).opt.numsample
        DiffN=AllTrk.Trobject(ID).n_sample-AllTrk.Trobject(ID).opt.numsample ;%N NewDetectorParticles
        IndexDetector=false(AllTrk.Trobject(ID).n_sample,1);
        IndexDetector(1:DiffN)=1;
    else
        IndexDetector=false(AllTrk.Trobject(ID).n_sample,1);
    end
    if showPropagatedOnly==1, stem3 (PCenters(1,not(IndexDetector)), PCenters(2,not(IndexDetector)),PCenters(3,not(IndexDetector)),'Color',AllTrk.Trobject(ID).color); figure(gcf);  end;
    if ShowDetectorOnly==1,   stem3 (PCenters(1,IndexDetector), PCenters(2,IndexDetector),PCenters(3,IndexDetector),'fill','Color',AllTrk.Trobject(ID).color,'MarkerEdgeColor',[0.5 0.5 0.5]); figure(gcf);  end;
    if AllTrk.Trobject(ID).n_sample>AllTrk.Trobject(ID).opt.numsample,  stem3 (PCenters(1,IndexDetector), PCenters(2,IndexDetector),PCenters(3,IndexDetector),'fill','Color',AllTrk.Trobject(ID).color,'MarkerEdgeColor',[0.5 0.5 0.5]); figure(gcf); end;
end
view(-8,30);
[m1,m2,m3]=size(frame);
xlabel('$x$','FontSize',14,'Interpreter','LaTex');
ylabel('$y$','FontSize',14,'Interpreter','LaTex');
zlabel('$w$','FontSize',14,'Interpreter','LaTex');
xmin=0; xmax=m2; ymin=0; ymax=m1; zmin=0; zmax=maxWeight+maxWeight*0.1;
axis([xmin xmax ymin ymax zmin zmax ]);
xlabh = get(gca,'XLabel');
set(xlabh,'Position',get(xlabh,'Position') - [-m2/6 10 0]);
ylabh = get(gca,'YLabel');
set(ylabh,'Position',get(ylabh,'Position') - [-40 m1/2 0]);
grid on;
set(gca,'Xtick',[0:100:m2],'XTickLabel',[0:100:m2]);
if PlotFrameN==1
    text(10, 15, '#', 'Color','y', 'FontWeight','bold', 'FontSize',24);
    text(30, 15, num2str(fno), 'Color','y', 'FontWeight','bold', 'FontSize',24);
    hold off;
    drawnow;
end