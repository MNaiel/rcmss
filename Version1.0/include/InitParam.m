global PNorm DistType
SigmaConfusePOWERIn=[]; SigmaPCAConfusePOWERIn=[];ThresholdSimilarityIN=[];NkeyFramesPosIN=[]; GMTypeIN=[];DetectorWeightIN=[];ThresholdSimilarityForNewTrackerIN=[]; SIGMAxIN=[];SIGMAvxIN=[];SDCUpdateRateIN=[];ThresholdOcclusionIN=[];thrErrorSGMIN=[];SGMlearnRateIN=[]; NewBornIN=[];numsampleIN=[];ThresholdSDCIN=[];
CheckOnHoldDetectionsBeforeCreateNewIN=[]; AffinexIN=[];  AffineyIN=[]; ShiftTimeIN=[];ThresholdSimilarityForNewTrackerIN=[];
OverlapForNewTrackerIN=[];ThresholdSimilarityCheckOnHoldIN=[];ThMaxWaitOnHoldFramesIN=[];SetNumberIN=[];
DAScaleFactorWIN=[]; DAScaleFactorHIN=[];
SelectedSet=[];StratFileName=[];
VOCscore = 0.5;
dispON  = false;
GTFrom='Original GT';
OutMetricsBoYang.Rcll=0;   OutMetricsBoYang.Prcn=0;   OutMetricsBoYang.FAR=0;   OutMetricsBoYang.GT=0;
OutMetricsBoYang.MT=0;     OutMetricsBoYang.PT=0;     OutMetricsBoYang.ML=0;    OutMetricsBoYang.FP=0;
OutMetricsBoYang.FN=0;     OutMetricsBoYang.IDs=0;    OutMetricsBoYang.FM=0;    OutMetricsBoYang.MOTA=0;
OutMetricsBoYang.MOTP=0;   OutMetricsBoYang.MOTAL=0;  OutMetricsBoYang.TrajectoryPrec=0;  OutMetricsBoYang.TrajectoryRecall=0;
OutMetricsBoYang.OverlapTh=VOCscore;
PNorm   =2; DistType=[];
