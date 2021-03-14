function [HoGLayers]=Generate2DHOG(Im,cellpw, nthet,clip, softBin, useHog)
binSize=cellpw;
nOrients=nthet;
[M,O] = gradientMag(single(Im) );
HoGLayers = gradientHist(M,O,binSize,nOrients,softBin,useHog,clip);
