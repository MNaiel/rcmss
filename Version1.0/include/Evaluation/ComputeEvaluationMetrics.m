function [OutMetrics]=ComputeEvaluationMetrics(TP, FN, FP, IDSW)
% Input	TP, FN, FP, IDSW 				
ObjectWindows=FN+TP+IDSW;
prec=TP/(TP+FP);
recall=TP/(TP+FN);
% Output	False Positive rate 	1-precission	1-TP/(FP+TP)		
FalsePR=FP/(TP+FP);%1-prec;
FalseNR=(FN)/(TP+FN);%1-recall;
TruePR=TP/(TP+FN+IDSW);
MOTA=1-(FP+FN+IDSW)/ObjectWindows;
					
OutMetrics.FalsePR=FalsePR*100;
OutMetrics.FalseNR=FalseNR*100;
OutMetrics.TruePR=TruePR*100;
OutMetrics.MOTA=MOTA*100;
OutMetrics.ObjectWindows=ObjectWindows;
OutMetrics.IDSW=IDSW;

