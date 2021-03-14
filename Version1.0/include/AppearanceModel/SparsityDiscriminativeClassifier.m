function con=SparsityDiscriminativeClassifier(img,bbALL,Trobject,sz,gamma,InputType,Y)
% global tempHeight tempWidth
% img      : is the input image
% bbALL    : input BB in Dollar standard input bbs (nx5) [x y w h score]
% Trobject : input tracker object
% sz       : sample size
% gamma    : used to adjust the confidence value
% InputType: (0) extract image patches
%          : (1) use image patches extracted and stacked in matrix Y directly
% Y        : matrix contains the patches (mnxk)
%con       : Output confidence
%%
con=zeros(size(Y,2),1);
if nargin < 6
    InputType=0;%extract image patches
end
if InputType==0
    bbOut=convertDollarToLowFormat(bbALL);
    [bbOutAffine,bt]=convertLowFormattoAffine(bbOut,sz);
    param0=bt;
    opt.tmplsize = [sz(1) sz(2)];
    opt.numsample=size(bbALL,1);
    n = opt.numsample;                  % Sampling Number
    param = [];
    param.est = bbOutAffine;
    [wimgs Y param] = affineSampleUsingDetector(double(img), sz, opt, param);
end

YY = normVector(Y);                                             % normalization
Trobject.AA_pos = normVector(Trobject.A_pos);
Trobject.AA_neg = normVector(Trobject.A_neg);

P = selectFeature(Trobject.AA_pos, Trobject.AA_neg, Trobject.paramSR);                     % feature selection
if isempty(P)==0
    YYY = P'*YY;                                                    % project the original feature space to the selected feature space
    AAA_pos = P'*Trobject.AA_pos;
    AAA_neg = P'*Trobject.AA_neg;
    
    paramSR.L = length(YYY( :,1));                                  % represent each candidate with training template set
    paramSR.lambda = 0.01;
    beta = mexLasso(YYY, [AAA_pos AAA_neg], paramSR);
    beta = full(beta);
    
    rec_f = sum((YYY - AAA_pos*beta(1:size(AAA_pos,2),:)).^2);      % the confidence value of each candidate
    rec_b = sum((YYY - AAA_neg*beta(size(AAA_pos,2)+1:end,:)).^2);
    con = exp(-rec_f/gamma)./exp(-rec_b/gamma);
end