function AllTrkOut=storePLOTVariables(AllTrk,UseGT)
N=length(AllTrk.Trobject);
for ID=1:N
    AllTrkOut.Trobject(ID).BBresult=AllTrk.Trobject(ID).BBresult;
    AllTrkOut.Trobject(ID).color=AllTrk.Trobject(ID).color;
    AllTrkOut.Trobject(ID).StartFrame=AllTrk.Trobject(ID).StartFrame;
    AllTrkOut.Trobject(ID).currentCenter=AllTrk.Trobject(ID).currentCenter;
    if UseGT==1, AllTrkOut.Trobject(ID).resultEvaluation=AllTrk.Trobject(ID).resultEvaluation; end;
end