function Trobject=DoOnHoldSubroutine(Trobject,ID,TrackerOpt)
% Apply this program on tracker before going to an on-hold status
InputImages=Trobject.A_pos;
wimgs=convertFromVector2Image(InputImages,TrackerOpt.AM.sz);
Volume{ID}=wimgs;
[Trobject.TwoDPCAparam]=TrainTwoDPCA(Volume,ID,TrackerOpt.AM.PGM);
[Trobject.PCAparam]=Train1DPCA(Volume,ID,TrackerOpt.AM.PCAGM);
end