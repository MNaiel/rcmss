function [sim Trobject bbpatch]=SparsityGenerativeModel(img,bbALL,Trobject,TrackerOpt,wimgs)
% Compute the similarity to the SGM model and show occluded patches
%%
if (nargin <5), CBB    =convertDollarToLowFormat(bbALL(:,1:5));
                [wimgs]=SampleBBFromImage(img,CBB,TrackerOpt,0);
end
[patch bbpatch]= affinePatch(wimgs, Trobject.patchsize, Trobject.patchnum);                % obtain M patches for each candidate
N_Samples=size(patch,3);
Fii = normVector(Trobject.Fi);                                           % normalization
temp_q = ones(Trobject.Fisize, prod(Trobject.patchnum));
sim = zeros(1,N_Samples);
b   = zeros(1,N_Samples);
for i = 1:N_Samples
    x = normVector(patch(:,:,i));                               % the sparse coefficient vectors for M patches
    paramSR.L = length(x(:,1));
    paramSR.lambda = TrackerOpt.AM.SGM.Update.lambdaSGM;
    alpha = mexLasso(x, Fii, paramSR);
    alpha = full(alpha);
    Trobject.alpha_p(:,:,i) = alpha;
    
    recon = sum((x - Fii*alpha).^2);                            % the reconstruction error of each patch
                                                                 % the occlusion indicator
    thr_lable = recon>=TrackerOpt.AM.SGM.Update.thrErrorSGM;
    temp = ones(Trobject.Fisize, prod(Trobject.patchnum));
    temp(:, thr_lable) = 0;
    
    Trobject.SGM.ValidRecon = zeros(Trobject.Fisize, prod(Trobject.patchnum));
    Trobject.SGM.ValidRecon(thr_lable)=recon(thr_lable);
    Trobject.SGM.NonOccludedMask=not(thr_lable);
    
    p = temp.*abs(alpha);                                       % the weighted histogram for the candidate
    p = reshape(p, 1, numel(p));
    p = p./sum(p);
    
    temp_qq = temp_q;                                           % the weighted histogram for the template
    temp_qq(:, thr_lable) = 0;
    for j=1:Trobject.AM.SGM.Nimages
        q = temp_qq.*abs(Trobject.alpha_qq(:,:,j));
        q = reshape(q, 1, numel(q));
        Q(j,:) = q./sum(q);
    end    
                                                                % the similarity between the candidate and the template
    a = sum(min([p; Q]));
    b(i) = TrackerOpt.AM.SGM.Update.lambda_thrSGM*sum(thr_lable);
    sim(i) = a + b(i);
    
    if  TrackerOpt.AM.SGM.ShowOccludedPatches %& sum(thr_lable)>4
        Ti_Train=[];Ti_test=[];
        for j=1:size(Fii,2)
            Ti_Train(:,:,j)=(uint8(reshape(Trobject.Fi(:,j),[Trobject.patchsize(1),Trobject.patchsize(2)])));
        end
        for j=1:size(patch,2)
            Ti_test(:,:,j)=(uint8(reshape(patch(:,j),[Trobject.patchsize(1),Trobject.patchsize(2)])));
        end
        prm = struct('extraInfo',0,'perRow',0,'showLines',1,'mm',Trobject.patchnum(1),'nn',Trobject.patchnum(2));
        subplot(2,2,1);montage2( Ti_Train, [prm] );title('Train patches');
        prm = struct('extraInfo',0,'perRow',0,'showLines',1,'mm',Trobject.patchnum(1),'nn',Trobject.patchnum(2));
        subplot(2,2,2);montage2( Ti_test, [prm] );title('Test patches');
        Dreconstructed=Fii*alpha;
        TempWindow=zeros(Trobject.sz(1),Trobject.sz(2));
        RecWindow=zeros(Trobject.sz(1),Trobject.sz(2));
        Lp=1:size(bbpatch,2);
        for j=Lp(thr_lable)
            TempWindow(bbpatch(1,j):bbpatch(2,j),bbpatch(3,j):bbpatch(4,j))=max(TempWindow(bbpatch(1,j):bbpatch(2,j),bbpatch(3,j):bbpatch(4,j)),recon(j).*ones(Trobject.patchsize(1),Trobject.patchsize(2)));          
        end
        subplot(2,2,3);imshow(TempWindow,'Colormap',gray);title('Error');
    end
end