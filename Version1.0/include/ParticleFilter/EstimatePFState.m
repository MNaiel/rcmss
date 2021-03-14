function AllTrk=EstimatePFState(AllTrk,ID,f,likelihood,TrackerOpt)
% input
% AllTrk: input trackers object
% ID: tracker ID
% f: current frame number
% likelihood: likelihood of the particles 
% TrackerOpt: tracker options
%%
[v_max,id_max] = max(likelihood);
if TrackerOpt.LH.wightedAv==2    
    AllTrk.Trobject(ID).Wkm1=1/length(likelihood);
    if TrackerOpt.LH.UseGatePositionforLikeLihood==1 %&& AllTrk.Trobject(ID).InMerge==0
        GatePositionValue=WeightParticlesUsingConstantV(AllTrk,ID,AllTrk.Trobject(ID).CenterBB,f,TrackerOpt.LH);
        if sum(sum(GatePositionValue))~=0 && sum(isnan(GatePositionValue))==0
            WeightValues=AllTrk.Trobject(ID).Wkm1.*likelihood.*GatePositionValue;
        else
            WeightValues=AllTrk.Trobject(ID).Wkm1.*likelihood;
        end
    else
        WeightValues=AllTrk.Trobject(ID).Wkm1.*likelihood;
    end    
    WeightValues=WeightValues/sum(sum(WeightValues));
    AllTrk.Trobject(ID).ParticlesWeights=WeightValues;
    WindowFlag=f-AllTrk.Trobject(ID).StartFrame>3;
    if AllTrk.Trobject(ID).InOcclusion==0 || TrackerOpt.LH.UseMaxLikelihood==0 || WindowFlag
        BBout=floor(sum((AllTrk.Trobject(ID).currentBB_NP*WeightValues'),2));
    else
        [v_max2,id_max2] = max(WeightValues);
        if length(id_max2)==1
            BBout=floor(AllTrk.Trobject(ID).currentBB_NP(:,id_max2));
        else
            BBout=floor(sum((AllTrk.Trobject(ID).currentBB_NP*WeightValues'),2));
        end
    end
    BBoutAffine=convertLowFormattoAffine(BBout,TrackerOpt.AM.sz);
    currentBBTest=BBout;
    AllTrk.Trobject(ID).Wkm1=WeightValues;
else
    currentBBTest=floor(AllTrk.Trobject(ID).currentBB_NP(:,id_max));
    [BBoutAffine]=convertLowFormattoAffine(currentBBTest,TrackerOpt.AM.sz);
end
AllTrk.Trobject(ID).MaxLikeLihood(f)  =v_max;
AllTrk.Trobject(ID).param.est         =BBoutAffine;
AllTrk.Trobject(ID).paramAll(:,f).est =BBoutAffine;
AllTrk.Trobject(ID).BBresult(:,f)     =currentBBTest;
AllTrk.Trobject(ID).currentCenter(:,f)=convertlowFormattoCenter(currentBBTest);
AllTrk.Trobject(ID).LeftTopWHT        =convertLowFormattoLeftTopWHT(currentBBTest);
AllTrk.Trobject(ID).result(f,:)       =AllTrk.Trobject(ID).param.est';
AllTrk.Trobject(ID).currentBB         =currentBBTest;
AllTrk.Trobject(ID).Last_f            =f;