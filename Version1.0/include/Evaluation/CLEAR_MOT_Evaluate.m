function [metrics metricsInfo OutMetrics]=CLEAR_MOT_Evaluate(gtInfo,stateInfo,td,DatasetInfo)
% compute CLEAR MOT and other metrics
% metrics contains the following
% [1]   recall	- recall = percentage of detected targets
% [2]   precision	- precision = percentage of correctly detected targets
% [3]   FAR		- number of false alarms per frame
% [4]   GT        - number of ground truth trajectories
% [5-7] MT, PT, ML	- number of mostly tracked, partially tracked and mostly lost trajectories
% [8]   falsepositives- number of false positives (FP)
% [9]   missed        - number of missed targets (FN)
% [10]  idswitches	- number of id switches     (IDs)
% [11]  FRA       - number of fragmentations
% [12]  MOTA	- Multi-object tracking accuracy in [0,100]
% [13]  MOTP	- Multi-object tracking precision in [0,100] (3D) / [td,100] (2D)
% [14]  MOTAL	- Multi-object tracking accuracy in [0,100] with log10(idswitches)
% Thanks to Shun Zhang for this code.
%%
docNode = com.mathworks.xml.XMLUtils.createDocument('Evaluation');
Root=docNode.getDocumentElement;
Element1=docNode.createElement('ID_Switch');
Element2=docNode.createElement('Fragments');
Element3=docNode.createElement('False_Positives');
Element4=docNode.createElement('False_Negatives');
if nargin <3,td=0.5; end

length_overflow=length(gtInfo.frameNums)-length(stateInfo.frameNums);
if length_overflow~=0
    warning('Length of Ground Truth and State is unequal')
end
while length_overflow>0
    gtInfo.frameNums(end) = [];
    gtInfo.X(end,:) = [];
    gtInfo.Y(end,:) = [];
    gtInfo.W(end,:) = [];
    gtInfo.H(end,:) = [];
    length_overflow=length_overflow-1;
end
while length_overflow<0
    stateInfo.frameNums(end) = [];
    stateInfo.Xi(end,:) = [];
    stateInfo.Yi(end,:) = [];
    stateInfo.W(end,:) = [];
    stateInfo.H(end,:) = [];
    length_overflow=length_overflow+1;
end
assert(all(gtInfo.frameNums==stateInfo.frameNums), ...
    'Ground Truth and state must contain equal frame numbers');

assert(all(isfield(gtInfo,{'X','Y','W','H'})), ...
    'Ground Truth coordinates X,Y,W,H needed for 2D evaluation');
assert(all(isfield(stateInfo,{'Xi','Yi','W','H'})), ...
    'State coordinates Xi,Yi,W,H needed for 2D evaluation');

gtInd=~~gtInfo.X;
stInd=~~stateInfo.Xi;

[Fgt Ngt]=size(gtInfo.X);
[F N]=size(stateInfo.Xi);

aspectRatio=mean(gtInfo.W(~~gtInfo.W)./gtInfo.H(~~gtInfo.H));
% gtInfo.W=gtInfo.H*aspectRatio;


metricsInfo.names.long = {'Recall','Precision','False Alarm Rate', ...
    'GT Tracks','Mostly Tracked','Partially Tracked','Mostly Lost', ...
    'False Positives', 'False Negatives', 'ID Switches', 'Fragmentations', ...
    'MOTA','MOTP', 'MOTA Log'};

metricsInfo.names.short = {'Rcll','Prcn','FAR', ...
    'GT','MT','PT','ML', ...
    'FP', 'FN', 'IDs', 'FM', ...
    'MOTA','MOTP', 'MOTAL'};

metricsInfo.widths.long = [6 9 16 9 14 17 11 15 15 11 14 5 5 8];
metricsInfo.widths.short = [5 5 5 3 3 3 3 4 4 3 3 5 5 5];

metricsInfo.format.long = {'.1f','.1f','.2f', ...
    'i','i','i','i', ...
    'i','i','i','i', ...
    '.1f','.1f','.1f'};

metricsInfo.format.short=metricsInfo.format.long;


metrics=zeros(1,14);
metrics(9)=numel(find(gtInd));  % False Negatives (missed)
metrics(7)=Ngt;                 % Mostly Lost

% nothing to be done, if state is empty
if ~N, return; end

% mapping
M=zeros(F,Ngt);

mme=zeros(1,F); % ID Switchtes (mismatches)
c=zeros(1,F);   % matches found
fp=zeros(1,F);  % false positives
m=zeros(1,F);   % misses = false negatives
g=zeros(1,F);
d=zeros(F,Ngt);  % all distances;
ious=Inf*ones(F,Ngt);  % all overlaps

matched=@matched2d;

for t=1:F
    g(t)=numel(find(gtInd(t,:)));
    if g(t)>0
        % mapping for current frame
        if t>1
            mappings=find(M(t-1,:));
            for map=mappings
                if gtInd(t,map) && stInd(t,M(t-1,map)) && matched(gtInfo,stateInfo,t,map,M(t-1,map),td)
                    M(t,map)=M(t-1,map);
                end
            end
        end
        
        GTsNotMapped=find(~M(t,:) & gtInd(t,:));
        EsNotMapped=setdiff(find(stInd(t,:)),M(t,:));
        allisects=zeros(Ngt,N);        maxisect=Inf;
        
        while maxisect > td && numel(GTsNotMapped)>0 && numel(EsNotMapped)>0
            for o=GTsNotMapped
                GT=[gtInfo.X(t,o)-gtInfo.W(t,o)/2 ...
                    gtInfo.Y(t,o)-gtInfo.H(t,o) ...
                    gtInfo.W(t,o) gtInfo.H(t,o) ];
                for e=EsNotMapped
                    E=[stateInfo.Xi(t,e)-stateInfo.W(t,e)/2 ...
                        stateInfo.Yi(t,e)-stateInfo.H(t,e) ...
                        stateInfo.W(t,e) stateInfo.H(t,e) ];
                    allisects(o,e)=boxiou(GT(1),GT(2),GT(3),GT(4),E(1),E(2),E(3),E(4));
                end
            end
            [maxisect cind]=max(allisects(:));
            
            if maxisect >= td
                [u v]=ind2sub(size(allisects),cind);
                M(t,u)=v;
                allisects(:,v)=0;
                GTsNotMapped=find(~M(t,:) & gtInd(t,:));
                EsNotMapped=setdiff(find(stInd(t,:)),M(t,:));
            end
            
        end
        curtracked=find(M(t,:));
        alltrackers=find(stInd(t,:));
        mappedtrackers=intersect(M(t,find(M(t,:))),alltrackers);
        falsepositives=setdiff(alltrackers,mappedtrackers);
        alltracked(t,:)=M(t,:);
        allfalsepos(t,1:length(falsepositives))=falsepositives;
        %%  mismatch errors
        if t>1
            for ct=curtracked
                lastnotempty=find(M(1:t-1,ct),1,'last');
                if gtInd(t-1,ct) && ~isempty(lastnotempty) && M(t,ct)~=M(lastnotempty,ct)
                    mme(t)=mme(t)+1;
                    Element11=docNode.createElement('IDS');
                    Element11.setAttribute('frame',num2str(t-1));
                    Element11.setAttribute('ID',num2str(M(t,ct)));
                    Element1.appendChild(Element11);
                end
            end
        end
        c(t)=numel(curtracked);
        for ct=curtracked
            eid=M(t,ct);
            gtLeft=gtInfo.X(t,ct)-gtInfo.W(t,ct)/2;
            gtTop=gtInfo.Y(t,ct)-gtInfo.H(t,ct);
            gtWidth=gtInfo.W(t,ct);    gtHeight=gtInfo.H(t,ct);
            
            stLeft=stateInfo.Xi(t,eid)-stateInfo.W(t,eid)/2;
            stTop=stateInfo.Yi(t,eid)-stateInfo.H(t,eid);
            stWidth=stateInfo.W(t,eid);    stHeight=stateInfo.H(t,eid);
            ious(t,ct)=boxiou(gtLeft,gtTop,gtWidth,gtHeight,stLeft,stTop,stWidth,stHeight);
        end
        fp(t)=numel(find(stInd(t,:)))-c(t);
        if fp(t)~=0
            Element33=docNode.createElement('FP');
            Element33.setAttribute('frame',num2str(t-1));
            Element33.setAttribute('times',num2str(fp(t)));
            Element3.appendChild(Element33);
        end
        m(t)=g(t)-c(t);
        if m(t)~=0
            Element44=docNode.createElement('FN');
            Element44.setAttribute('frame',num2str(t-1));
            Element44.setAttribute('times',num2str(m(t)));
            Element4.appendChild(Element44);
        end
    end
end
missed=sum(m);
falsepositives=sum(fp);
idswitches=sum(mme);
MOTP=sum(ious(ious>=td & ious<Inf))/sum(c) * 100; % avg ol

MOTAL=(1-((sum(m)+sum(fp)+log10(sum(mme)+1))/sum(g)))*100;
MOTA=(1-((sum(m)+sum(fp)+(sum(mme)))/sum(g)))*100;
recall=sum(c)/sum(g)*100;
precision=sum(c)/(sum(fp)+sum(c))*100;
FAR=sum(fp)/Fgt;
%% MT PT ML
MTstatsa=zeros(1,Ngt);
for i=1:Ngt
    gtframes=find(gtInd(:,i));
    gtlength=length(gtframes);
    gttotallength=numel(find(gtInd(:,i)));
    trlengtha=numel(find(alltracked(gtframes,i)>0));
    if gtlength/gttotallength >= 0.8 && trlengtha/gttotallength < 0.2
        MTstatsa(i)=3;
    elseif t>=find(gtInd(:,i),1,'last') && trlengtha/gttotallength <= 0.8
        MTstatsa(i)=2;
    elseif trlengtha/gttotallength >= 0.8
        MTstatsa(i)=1;
    end
end
% MTstatsa
MT=numel(find(MTstatsa==1));PT=numel(find(MTstatsa==2));ML=numel(find(MTstatsa==3));
%% fragments
fr=zeros(1,Ngt);
fm_frames=[];
fm_frames_id=[];
for i=1:Ngt
    b=alltracked(find(alltracked(:,i),1,'first'):find(alltracked(:,i),1,'last'),i);% Tracker ID
    b(~~b)=1;
    diffb=find(diff(b)==-1);
    fr(i)=numel(diffb); % Count number of fragments for the same trajectory ID
    for j=1:size(diffb,1)
        fm_frame=find(alltracked(:,i),1,'first')+diffb(j)-1;
        fm_frames=[fm_frames;fm_frame];
        if fm_frame>1
            fm_frames_id=[fm_frames_id;alltracked(fm_frame-1,i)];
        else
            fm_frames_id=[fm_frames_id;alltracked(fm_frame,i)];
        end
    end
end
fm_frame=sortrows([fm_frames,fm_frames_id]);
for i=1:size(fm_frame,1)
    Element22=docNode.createElement('FM');
    Element22.setAttribute('frame',num2str(fm_frame(i,1)));
    Element22.setAttribute('ID',num2str(fm_frame(i,2)));
    Element2.appendChild(Element22);
end
FRA=sum(fr);

assert(Ngt==MT+PT+ML,'Hmm... Not all tracks classified correctly.');
metrics=[recall, precision, FAR, Ngt, MT, PT, ML, falsepositives, missed, idswitches, FRA, MOTA, MOTP, MOTAL];
printMetrics1(metrics,metricsInfo,1,DatasetInfo);

Root.appendChild(Element1);
Root.appendChild(Element2);
Root.appendChild(Element3);
Root.appendChild(Element4);
% global out_path;
% xmlwrite([out_path,'/metriclog.xml'],Root);
OutMetrics.Rcll=metrics(1);
OutMetrics.Prcn=metrics(2);
OutMetrics.FAR=metrics(3);
OutMetrics.GT=metrics(4);
OutMetrics.MT=metrics(5);
OutMetrics.PT=metrics(6);
OutMetrics.ML=metrics(7);
OutMetrics.FP=metrics(8);
OutMetrics.FN=metrics(9);
OutMetrics.IDs=metrics(10);
OutMetrics.FM=metrics(11);
OutMetrics.MOTA=metrics(12);
OutMetrics.MOTP=metrics(13);
OutMetrics.MOTAL=metrics(14);
% rec=tp/npos;
% prec=tp./(fp+tp);
TpT=(MT+PT);FpT=max(0,size(stateInfo.Xi,2)-TpT); FnT=ML;
OutMetrics.TrajectoryPrec=TpT/(FpT+TpT);
OutMetrics.TrajectoryRecall=TpT/(TpT+FnT);
OutMetrics.OverlapTh=td;
% OutMetrics.TrajectoryAccuracy=(TpT)/(TpT+FnT);
end
function ret=matched2d(gtInfo,stateInfo,t,map,mID,td)
gtLeft=gtInfo.X(t,map)-gtInfo.W(t,map)/2;
gtTop=gtInfo.Y(t,map)-gtInfo.H(t,map);
gtWidth=gtInfo.W(t,map);    gtHeight=gtInfo.H(t,map);

stLeft=stateInfo.Xi(t,mID)-stateInfo.W(t,mID)/2;
stTop=stateInfo.Yi(t,mID)-stateInfo.H(t,mID);
stWidth=stateInfo.W(t,mID);    stHeight=stateInfo.H(t,mID);

ret = boxiou(gtLeft,gtTop,gtWidth,gtHeight,stLeft,stTop,stWidth,stHeight) >= td;
end

function printMetrics1(metrics, metricsInfo, dispHeader,DatasetInfo,dispMetrics,padChar)
%global out_path;global in_filename;global in_path;global gtInfoPath;
fid=fopen(strcat(DatasetInfo.SaveResultsImage,'/Evaluation_result.txt'),'wt');
t=now; tt=datestr(t,0);
fprintf(fid, '%s:\n',tt);
docNode = com.mathworks.xml.XMLUtils.createDocument('Video');
Root=docNode.getDocumentElement;

namesToDisplay=metricsInfo.names.long;
widthsToDisplay=metricsInfo.widths.long;
formatToDisplay=metricsInfo.format.long;

namesToDisplay=metricsInfo.names.short;
widthsToDisplay=metricsInfo.widths.short;
formatToDisplay=metricsInfo.format.short;

if nargin<3, dispHeader=1; end
if nargin<4+1
    dispMetrics=1:length(metrics);
end
if nargin<5+1
    padChar={' ',' ','|',' ',' ',' ','|',' ',' ',' ','| ',' ',' ',' '};
end

if dispHeader
    for m=dispMetrics
        printString=sprintf('fprintf(fid,''%%%is%s'',char(namesToDisplay(m)))',widthsToDisplay(m),char(padChar(m)));
        eval_temp=eval(printString);
    end
    fprintf(fid,'\n');
end
attributes={ 'Rcll'  'Prcn'   'FAR' 'GT' 'MT' 'PT'  'ML'  'FP'   'FN' 'IDs'  'FM'  'MOTA'  'MOTP' 'MOTAL' };
for m=dispMetrics
    printString=sprintf('fprintf(fid,''%%%i%s%s'',metrics(m))',widthsToDisplay(m),char(formatToDisplay(m)),char(padChar(m)));
    eval_temp=eval(printString);
    Element=docNode.createElement(attributes(m));
    Element.setAttribute('value',num2str(metrics(m)));
    Root.appendChild(Element);
end
xmlwrite(strcat(DatasetInfo.SaveResultsImage,'/Evaluation_Result.xml'),Root);

% if standard, new line
if nargin<4+1
    fprintf(fid,'\n');
end
fclose(fid);
end