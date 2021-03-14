function   BBD=ScaleBBSize(BBD,ScaleOpt,Im)
%% BBD input BB in Low Format
BBin=BBD;
%%
BBc=convertFromLowFormatToCenter(BBin);
BBc(3,:)= BBc(3,:)*ScaleOpt.ScaleFactorW;
BBc(4,:)= BBc(4,:)*ScaleOpt.ScaleFactorH;
BBD=convertCenterWHToLowFormat(BBc');
if(0)
    SHOWBBonImage(Im,(BBD),[],[],1,[1 0 0],0,15);
    SHOWBBonImage(Im,(BBin),[],[],1,[0 1 0],1,15);
end