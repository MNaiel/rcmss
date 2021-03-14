function imgset = VOCreadimgset(PASopts,label,subset)

subsets={'train','val','train+val','test1','test2'};

cls=strmatch(label,{PASopts.VOCclass(:).label},'exact');
if isempty(cls)
    error('invalid class label');
end

if isempty(strmatch(subset,subsets,'exact'))
    error('invalid subset: should be {train|val|train+val|test1|test2}');
end

imgset.label=label;
imgset.subset=subset;
imgset.recs=[];
while true
    [ss,subset]=strtok(subset,'+');
    if isempty(ss)
        break
    end
    imgset.recs=[imgset.recs readrecords(PASopts,cls,ss,[cls 1:(cls-1) (cls+1):length(PASopts.VOCclass)])];;
end
imgset.posinds=find([imgset.recs(:).present]);
imgset.neginds=find(~[imgset.recs(:).present]);

function recs = readrecords(PASopts,cls,subset,cset)

n=0;
for c=cset
	imgsetpath=[fileparts(which(mfilename)) ...
                '/imgsets/imgset_' PASopts.VOCclass(c).label '_' subset '.txt'];
	
	annonames=textread(imgsetpath,'%s');

	for i=1:length(annonames)
        recpath=[PASopts.imgdir annonames{i}];
        t=PASreadrecord(recpath);
        if exist('recs','var')
            if strmatch(t.imgname,{recs.imgname},'exact')
                continue
            end
        end
        v=true(length(t.objects),1);
        for j=1:length(t.objects)
            if isempty(strmatch(t.objects(j).label,PASopts.VOCclass(cls).PASlabels,'exact'))
                v(j)=false;
            end
        end
        t.objects=t.objects(v);
        t.present=length(t.objects)>0;
        n=n+1;
        recs(n)=t;
	end
end
