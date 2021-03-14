%%    Sparsity-based Discriminative Classifier (SDC)
if TrackerOpt.AM.AMmode==1 ||TrackerOpt.AM.AMmode==2
    t7cpu=clock;
    if TrackerOpt.AM.SDC.NormVector==1
        YY = normVector(Y);                                             % normalization
        if AllTrk.Trobject(ID).UpdateDone==1
            AllTrk.Trobject(ID).UpdateDone=0;
            AllTrk.Trobject(ID).AA_pos = normVector(AllTrk.Trobject(ID).A_pos);
            AllTrk.Trobject(ID).AA_neg = normVector(AllTrk.Trobject(ID).A_neg);
        end
    else
        YY = Y;                                                         % normalization
        if AllTrk.Trobject(ID).UpdateDone==1
            AllTrk.Trobject(ID).UpdateDone=0;
            AllTrk.Trobject(ID).AA_pos = AllTrk.Trobject(ID).A_pos;
            AllTrk.Trobject(ID).AA_neg = AllTrk.Trobject(ID).A_neg;
        end
    end
    t7(fIndex)= t7(fIndex)+etime(clock,t7cpu);
    t8cpu=clock;
    if TrackerOpt.AM.SDC.UseFeatureSelection==1
        P = selectFeature(AllTrk.Trobject(ID).AA_pos, AllTrk.Trobject(ID).AA_neg, AllTrk.Trobject(ID).paramSR);                     % feature selection
        YYY = P'*YY;                                                    % project the original feature space to the selected feature space
        AAA_pos = P'*AllTrk.Trobject(ID).AA_pos;
        AAA_neg = P'*AllTrk.Trobject(ID).AA_neg;
    else
        m=size(AllTrk.Trobject(ID).AA_pos,1);
        P=eye(m,m);
        YYY = P'*YY;                                                    % project the original feature space to the selected feature space
        AAA_pos = P'*AllTrk.Trobject(ID).AA_pos;
        AAA_neg = P'*AllTrk.Trobject(ID).AA_neg;
    end
    t8(fIndex)= t8(fIndex)+etime(clock,t8cpu);
    t9cpu=clock;
    paramSR.L = length(YYY( :,1));                                  % represent each candidate with training template set
    paramSR.lambda = TrackerOpt.AM.SDC.paramSR.lambda;
    beta = mexLasso(YYY, [AAA_pos AAA_neg], paramSR);
    beta = full(beta);
    Epos=YYY - AAA_pos*beta(1:size(AAA_pos,2),:);
    Eneg=YYY - AAA_neg*beta(size(AAA_pos,2)+1:end,:);
    rec_f = sum((Epos).^2);      % the confidence value of each candidate
    if TrackerOpt.AM.SDC.SDCModelConfidenceMethod==1
        rec_b = sum((Eneg).^2);
        con = exp(-(rec_f-rec_b)/TrackerOpt.AM.SDC.gamma);
    else
        con = exp(-rec_f/TrackerOpt.AM.SDC.gamma);
    end
    t9(fIndex)= t9(fIndex)+etime(clock,t9cpu);
    t10cpu=clock;
    if TrackerOpt.AM.SDC.useSparseRep==1
        %%
        L1Pos=sum(abs(beta(1:size(AAA_pos,2),:)));
        L1Neg=sum(abs(beta(size(AAA_pos,2)+1:end,:)));
        L1Beta=sum(abs(beta));
        Sparse_Conc_Index= (2*max(L1Pos./L1Beta,L1Neg./L1Beta)-1)';
        if TrackerOpt.CM.UseWeightedDetections==1
            con=con.*Sparse_Conc_Index'.*WeightsParticles';
        else
            con=con.*Sparse_Conc_Index';
        end
    end
    t10(fIndex)= t10(fIndex)+etime(clock,t10cpu);
end