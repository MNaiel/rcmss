function alpha_qq = UpdateSGMmodel2(alpha_q, alpha_p, occMap,gamma)
% update the template histogram in the SGM

% input --- 
% alpha_q: the template histogram in the current frame
% alpha_p: the histogram of the tracking result
% occMap: the occlusion condition
% output ---
% alpha_qq: the template histogram in the SGM for the next frame

%*************************************************************
%% Copyright (C) Wei Zhong.
%% All rights reserved.
%% Date: 05/2012
if nargin <4
gamma = 0.95; 
end
%%----------------- update template histogram in the SGM ----------------%%
if occMap<=0.8, alpha_qq = alpha_q*gamma + alpha_p*(1 - gamma);else    alpha_qq = alpha_q;end