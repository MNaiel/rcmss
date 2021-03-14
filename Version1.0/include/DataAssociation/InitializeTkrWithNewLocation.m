function Trobject=InitializeTkrWithNewLocation(Trobject)
p                  = Trobject.p;
param0             = [p(1), p(2), p(3)/Trobject.sz(2), p(5), p(4)/p(3), 0];
Trobject.p0        = p(4)/p(3);
Trobject.param0    = param0;
Trobject.param     = [];
Trobject.param.est = affparam2mat(Trobject.param0)';

