function Trobject=AdjustOcclusionParameters( Trobject,InConflict)
% Adjust the tracker object parameters based on the conflict state
% InConflict=1: in case of conflict load high variance
% InConflict=0: in case of normal case load initial affine parameters
%%
if InConflict==1
    Trobject.opt.affsig=Trobject.opt.Occlusionaffsig;
else    
    Trobject.opt.affsig=Trobject.opt.Initialaffsig;    
end