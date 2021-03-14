function GatePositionValue=WeightParticlesUsingConstantV(AllTrk,ID,BBWH,f,LH)
% AllTrk: trackers object
% ID    : tracker ID
% BBWH  :
% f     : frame number
%%
Show=0;
UseVectorDirection=1;
Alpha=1;
if isempty(AllTrk.Trobject(ID).VInitialx)
    [VInitialx VInitialy]=ComputeInstantVelocity(AllTrk.Trobject(ID),3);
else
    [VxInstant VyInstant]=ComputeInstantVelocity(AllTrk.Trobject(ID),3);
    VInitialx=Alpha*AllTrk.Trobject(ID).VInitialx+(1-Alpha)*VxInstant ;
    VInitialy=Alpha*AllTrk.Trobject(ID).VInitialy+(1-Alpha)*VyInstant;
end
if (sqrt(VInitialx.^2+VInitialy.^2)>LH.ThresholdVLikelihood||AllTrk.Trobject(ID).InOcclusion==1) && f-AllTrk.Trobject(ID).StartFrame>3
    if f-AllTrk.Trobject(ID).StartFrame >10, CWindow= f-3;    else        CWindow=f-3;    end
    CurrentCenter=convertlowFormattoCenter(AllTrk.Trobject(ID).BBresult(:,CWindow));%previous-2 Center
    CurrentState=[CurrentCenter(1:2); VInitialx; VInitialy];
    Y=ExpectedMotionLine( CurrentState,10);
    rOC=Y(1:2,end);
    rOB=CurrentCenter(1:2);
    rBC=(rOC-rOB);
    if LH.UseHorizontalVelocityOnlyLikelihood==1,  rBC(2)=0;     end
    if norm(rBC)~=0
        UnitrBC=rBC./norm(rBC);
        tVelocity=sqrt(VInitialx.^2+VInitialy.^2);
        distOutAll=DistanceNPointsandY(BBWH,Y);
        rOAall=BBWH(1:2,:)-repmat(rOB,[1, size(BBWH,2)]);
        UnitVectors=repmat(UnitrBC,[1, size(rOAall,2)]);
        Projall=dot(rOAall,UnitVectors);
        if UseVectorDirection==1
            Projall2=  repmat((Projall./dot(UnitrBC,UnitrBC)), [2 1]);%.*UnitVectors;
            IndexR=find(Projall2<0);
            Projall2(IndexR)=0.1;
            SigPosSqaureall=sum(( Projall2),1)*LH.FactorSigPosVelocityLike/tVelocity;
        else
            Projall=  Projall./dot(UnitrBC,UnitrBC);
            SigPosSqaureall=(abs( Projall));
        end
        GatePositionValueall=exp(-1*(distOutAll)./(SigPosSqaureall));
        GatePositionValue=GatePositionValueall;
        if Show==1
            TrestimatedBB=[Y(1:2,:); repmat([AllTrk.Trobject(ID).p(3); AllTrk.Trobject(ID).p(4)],[1 size(Y,2)])];
            CBB=convertFromCenterToLowFormat(TrestimatedBB,0);
            SHOWBBonImage(img,CBB);
            hold on;
            surf(Gridy,Gridx,ImgDistScore);
        end
    else
        GatePositionValue=ones(1,size(BBWH,2));
    end
else
    GatePositionValue=ones(1,size(BBWH,2));
end
end