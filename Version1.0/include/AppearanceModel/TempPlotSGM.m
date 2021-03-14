%%
% Plot RangeThresholdSGM
plotFunction=@(x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12) line(x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12);
IndexCurve=0;
AxisLimitParam.xmin=0.2;
AxisLimitParam.xmax=1;
AxisLimitParam.ymin=-0.4;
AxisLimitParam.ymax=0.2;
AxisLimitParam=[];
X1=[];Y1=[];
for lambda=Rangelambda
    for lambda_thr=Rangelambda_thr
        IndexCurve=IndexCurve+1;
        IndexLamdaThr=find(Record(:,4)==lambda_thr & Record(:,5)==lambda);
        X1{IndexCurve}=Record(IndexLamdaThr,3);Y1{IndexCurve}=Record(IndexLamdaThr,1);
        [MaxSim IndexMax]=max(Record(IndexLamdaThr,1));
        LegendCell{IndexCurve}={strcat('MaxDiffSim=', sprintf('%5.4f',MaxSim),'; Thr. =', num2str(Record(IndexLamdaThr(IndexMax),3)),'; Bias =',num2str(lambda_thr),'; \lambda =',num2str(lambda))};
    end
end
Xlabel='Threshold for SGM recon. error';Ylabel='Av. diff. sim.';
StringType='%3.2f';SeparationMethod='_';
FileName=strcat('SGMRecoThrVsDiffSim_V2',DatasetName,ConvertVector2StringWithoutSpace(RangeThresholdSGM,StringType,SeparationMethod),...
    ConvertVector2StringWithoutSpace(Rangelambda_thr,StringType,SeparationMethod),ConvertVector2StringWithoutSpace(Rangelambda,StringType,SeparationMethod));
SavePlotandFigures(X1,Y1,Xlabel,Ylabel,LegendCell,DirSave,FileName,plotFunction,Plotparam,AxisLimitParam);
