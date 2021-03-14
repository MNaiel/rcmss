function pr = VOCpr(PASopts,imgset,dets,draw)

pr.label=imgset.label;
pr.subset=imgset.subset;

ni=length(imgset.recs);
np=0;
for i=imgset.posinds
    [imgset.recs(i).objects(:).det]=deal(false);
    np=np+length(imgset.recs(i).objects);
end

nd=length(dets);

rp=randperm(nd); % sort equal confidences randomly
dets=dets(rp);

[sc,si]=sort(-[dets(:).confidence]);
dets=dets(:,si);

tp=zeros(nd,1);
for d=1:nd
    i=dets(d).imgnum;
    bb=dets(d).bbox;
    ovmax=-inf;
    for j=1:length(imgset.recs(i).objects)
        bbgt=imgset.recs(i).objects(j).bbox;
        bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
        bu=[min(bb(1),bbgt(1)) ; min(bb(2),bbgt(2)) ; max(bb(3),bbgt(3)) ; max(bb(4),bbgt(4))];
        iw=bi(3)-bi(1)+1;
        ih=bi(4)-bi(2)+1;
        if iw>0 & ih>0                
            ua=(bu(3)-bu(1)+1)*(bu(4)-bu(2)+1);
            ov=iw*ih/ua;
            if ov>ovmax
                ovmax=ov;
                jmax=j;
            end
        end
        if ovmax>=PASopts.VOCminoverlap
            if ~imgset.recs(i).objects(jmax).det
                tp(d)=1;
                imgset.recs(i).objects(jmax).det=true;
            end
        end
    end
end

tp=cumsum(tp);
pr.recall=tp/np;
pr.precision=tp./(1:length(pr.recall))';

if draw
    plot(pr.recall,pr.precision,'-');
    grid;
    xlabel 'recall'
    ylabel 'precision'
    title(['class: ' imgset.label ', subset: ' imgset.subset]);
end
