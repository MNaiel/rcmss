%% Sparsity-based Generative Model (SGM)
if AllTrk.Trobject(ID).UpdateSGM                                               % the template histogram in the first frame and before occlusion handling
    Fii = normVector(AllTrk.Trobject(ID).Fi);                                  % normalization
    AllTrk.Trobject(ID).StartFrame=f;
    AllTrk.Trobject(ID).UpdateSGM =0;
    StepPatches=size(AllTrk.Trobject(ID).patcho,2)/ AllTrk.Trobject(ID).AM.SGM.Nimages;
    pStartIndex=0;
    for nPosImage=1: AllTrk.Trobject(ID).AM.SGM.Nimages
        xo = normVector(AllTrk.Trobject(ID).patcho(:,pStartIndex+1:pStartIndex+StepPatches));
        pStartIndex=pStartIndex+StepPatches;
        paramSR.L = length(xo(:,1));
        paramSR.lambda = TrackerOpt.AM.SGM.Update.lambdaSGM;
        alpha_q = mexLasso(xo, Fii, paramSR);
        AllTrk.Trobject(ID).alpha_q(:,:,nPosImage) = full(alpha_q);
        AllTrk.Trobject(ID).alpha_qq(:,:,nPosImage) = AllTrk.Trobject(ID).alpha_q(:,:,nPosImage);
    end
    if TrackerOpt.AM.SGM.Initial.ExchangePositiveExamples2BeNeg==1
        ValidRange=TrackerRange(ValidTracker);
        IDsValid=find(ValidRange~=ID);
        l1=0;
        for LoopV=1:length(IDsValid)
            l1=l1+1;
            AllTrk.Trobject(ID).A_neg=[AllTrk.Trobject(ID).A_neg,AllTrk.Trobject(ValidRange(IDsValid(l1))).A_pos];
        end
    end
end
if TrackerOpt.AM.AMmode==2 || TrackerOpt.AM.AMmode==3 % SGM - tracker
    patch = affinePatch(wimgs, AllTrk.Trobject(ID).patchsize, AllTrk.Trobject(ID).patchnum);                % obtain M patches for each candidate
    Fii = normVector(AllTrk.Trobject(ID).Fi);                                           % normalization
    temp_q = ones(AllTrk.Trobject(ID).Fisize, prod(AllTrk.Trobject(ID).patchnum));
    sim = zeros(1,AllTrk.Trobject(ID).n_sample);
    b = zeros(1,AllTrk.Trobject(ID).n_sample);
    for i = 1:AllTrk.Trobject(ID).n_sample
        x = normVector(patch(:,:,i));                               % the sparse coefficient vectors for M patches
        paramSR.L = length(x(:,1));
        paramSR.lambda = TrackerOpt.AM.SGM.Tracker.lambda;
        alpha = mexLasso(x, Fii, paramSR);
        alpha = full(alpha);
        AllTrk.Trobject(ID).alpha_p(:,:,i) = alpha;
        recon = sum((x - Fii*alpha).^2);                            % the reconstruction error of each patch
        
        %                                                           % the occlusion indicator
        thr_lable = recon>=TrackerOpt.AM.SGM.Tracker.thr;
        temp = ones(AllTrk.Trobject(ID).Fisize, prod(AllTrk.Trobject(ID).patchnum));
        temp(:, thr_lable) = 0;
        
        p = temp.*abs(alpha);                                       % the weighted histogram for the candidate
        p = reshape(p, 1, numel(p));
        p = p./sum(p);
        
        temp_qq = temp_q;                                           % the weighted histogram for the template
        temp_qq(:, thr_lable) = 0;
        q = temp_qq.*abs(AllTrk.Trobject(ID).alpha_qq);
        q = reshape(q, 1, numel(q));
        q = q./sum(q);                                              % the similarity between the candidate and the template
        a = sum(min([p; q]));
        b(i) = TrackerOpt.AM.SGM.Tracker.lambda_thr*sum(thr_lable);
        sim(i) = a + b(i);
    end
end