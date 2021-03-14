function roc = VOCroc(PASopts,imgset,confidence,draw)

n=length(imgset.recs);
if n~=length(confidence)
    error('confidence vector length must match number of records');
end

roc.label=imgset.label;
roc.subset=imgset.subset;
roc.confidence=confidence;

pres=[imgset.recs(:).present];
    
rp=randperm(n); % sort equal confidences randomly
pres=pres(rp);
confidence=confidence(rp);

np=sum(pres);
nn=n-np;

[sc,si]=sort(-confidence);
sp=pres(si);
roc.tp=cumsum(sp)/np;
roc.fp=cumsum(~sp)/nn;

if draw
    plot(roc.fp,roc.tp,'-');
    grid;
    axis([0 1 0 1]);
    xlabel 'false positive rate'
    ylabel 'true positive rate'
    title(['class: ' imgset.label ', subset: ' imgset.subset]);
end
