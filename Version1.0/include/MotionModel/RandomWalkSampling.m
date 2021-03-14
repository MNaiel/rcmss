function [wimgs Y param] =RandomWalkSampling(ImgIn, sz, opt, param)    
%% use random walk sampling scheme
%Input
% ImgIn   : Input image
% sz      : Template size
% opt     : options to sample particles state
% param   : last parameter state at time t-1
%Output
% wimgs    : samples in volume format
% Y        : corresponding in a matrix format 
% param    : proposed states to compute the likelihood
%%
n = opt.numsample;                  % Sampling Number
param.param0 = zeros(6,n);          % Affine Parameter Sampling
param.param = zeros(6,n);
param.param0 = repmat(affparam2geom(param.est(:)), [1,n]);
randMatrix = randn(6,n);
param.param = param.param0 + randMatrix.*repmat(opt.affsig(:),[1,n]);
o = affparam2mat(param.param);      % Extract or Warp Samples which are related to above affine parameters
[wimgs wimgsColor o BadExample]= warpimgFunction(ImgIn, o, sz,opt);
param.param(:,BadExample)=[];
param.param0(:,BadExample) =[];
n=size(o,2);
Y= ConcatenateWarpImage(wimgsColor,opt,n);
