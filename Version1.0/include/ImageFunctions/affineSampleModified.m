function [wimgs Y param] = affineSampleModified(frm, sz, opt, param,RightorLeftFlag,previousCenter)
% function [wimgs Y param] = affineSample(frm, sz, opt, param)
% draw N candidates with particle filter

% input --- 
% frm: the image of the current frame
% sz: the size of the tracking window
% opt: initial parameters
% param: the affine parameters

% output ---
% wimgs: the N candidate images (matrix)
% Y: the N candidate images (vector)
% param: the affine parameters

%*************************************************************
%% Copyright (C) Wei Zhong.
%% All rights reserved.
%% Date: 05/2012
if (nargin <5),   RightorLeftFlag=[]; end;
n = opt.numsample;                  % Sampling Number
param.param0 = zeros(6,n);          % Affine Parameter Sampling
param.param = zeros(6,n);
param.param0 = repmat(affparam2geom(param.est(:)), [1,n]);
randMatrix = randn(6,n);
param.param = param.param0 + randMatrix.*repmat(opt.affsig(:),[1,n]);

o = affparam2mat(param.param);      % Extract or Warp Samples which are related to above affine parameters
if isempty(RightorLeftFlag)==0 & RightorLeftFlag~=-1 
 [o,n,param]=selectPoints(frm,o,n,previousCenter,sz,RightorLeftFlag,param);
end
[wimgs wimgsColor o BadExample]= warpimgFunction(frm, o, sz,opt);
param.param(:,BadExample)=[];
param.param0(:,BadExample) =[];
n=size(o,2);
Y= ConcatenateWarpImage(wimgsColor,opt,n);

