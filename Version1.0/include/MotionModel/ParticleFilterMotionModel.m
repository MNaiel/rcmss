function [wimgs Y param Trobject]=ParticleFilterMotionModel(ImgIn,sz, opt, param,Trobject,f,VelocityMotionModel,param1)
%% use Constant veclocity sampling scheme
%Input
% ImgIn   : Input image
% sz      : Template size
% opt     : options to sample particles state
% param   : last parameter state at time t-1
% Trobject: Tracker object
%Output
% wimgs    : samples in volume format
% Y        : corresponding in a matrix format
% param    : proposed states to compute the likelihood
% Trobject: Tracker object after updates
%%
if (nargin <8),param1=[];end;
n = size(Trobject.X,2);% opt.numsample;                  % Sampling Number of propagated samples
if n==0, n=opt.numsample; end;
param.param0 = zeros(6,n);          % Affine Parameter Sampling
param.param = zeros(6,n);
param.param0 = repmat(affparam2geom(param.est(:)), [1,n]);

[Trobject, X,param]=HyprideMotionModel(Trobject,f,VelocityMotionModel,param,opt,param1,n);

o = affparam2mat(param.param);      % Extract or Warp Samples which are related to above affine parameters
[wimgs wimgsColor o BadExample]= warpimgFunction(ImgIn, o, sz,opt);
param.param(:,BadExample)=[];
param.param0(:,BadExample) =[];
n=size(o,2);
Y= ConcatenateWarpImage(wimgsColor,opt,n);
if (0),   SHOWBBonImage(uint8(ImgIn),Trobject.BBresult(:,f-1));end;
