function evlScores = computeMeasures(estTrk,gtTrk)

card_estTrk = size(estTrk,1);
card_gtTrk = size(gtTrk,1);
evlScores.card_estTrk = card_estTrk;
evlScores.card_gtTrk = card_gtTrk;

evlScores.cardErrRate1 = abs(card_estTrk - card_gtTrk)/card_gtTrk;
evlScores.cardErrRate2 = abs(card_estTrk - card_gtTrk)/card_estTrk;

for j=1:card_estTrk
    for i=1:card_gtTrk
        estBbox = estTrk(j,2:end);
        gtBbox = gtTrk(i,2:end);
        if isempty(estBbox) || isempty(gtBbox)
            Overlap = 0;
        else
            Overlap = overlapping(estBbox,gtBbox);
        end
        O(i,j) = 1 - Overlap;
    end
end

if isempty(estTrk) || isempty(gtTrk)
    assgn = 0;
    matchingError = 0;
else
    [assgn,matchingError]= Hungarian(O);
end
    
evlScores.normMatchingError = matchingError/card_gtTrk;
evlScores.assgn = assgn;

if (card_estTrk==0 && card_gtTrk==0)
    METE = 0;
    
elseif (card_estTrk==0 || card_gtTrk==0)
    METE = 1/(max(card_estTrk,card_gtTrk))*abs(card_estTrk-card_gtTrk);
    
else
    METE = 1/((max(card_estTrk,card_gtTrk)))*(matchingError + abs(card_estTrk-card_gtTrk));
end
evlScores.METE = METE;

evlScores.ae = matchingError;
evlScores.ce = abs(card_estTrk-card_gtTrk);
