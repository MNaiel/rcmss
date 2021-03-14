function [OverlapMatrix,NewTrackerNum,OverlapMatrixAll]=FindOverlapRatio(BB,gtBB,avoidMultiDetection)
% Compute the overlap matrix for a set of detections BB, and ground truth getBB,
% avoidMultiDetection: option (1) to avoid multiple BB intersecting with
% the same GT
%%
if (nargin <3),   avoidMultiDetection=0;end
OverlapMatrix=zeros(size(BB,2),size(gtBB,2));
OverlapMatrixAll=zeros(size(BB,2),size(gtBB,2));
DetectionWindows=size(gtBB,2);
ovmaxRefmin=0.1;
gtDetected= false(DetectionWindows,1);
NewTrackerNum=[];
for d=1:size(BB,2)% represent General object detector
    ovmax=-inf;
    bb=BB(:,d);
    RangeOfDetections=1:DetectionWindows;
    for j=RangeOfDetections %loop on GT ;>> Trackers
        bbgt=gtBB(:,j);
        bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
        iw=bi(3)-bi(1)+1;
        ih=bi(4)-bi(2)+1;
        if iw>0 && ih>0     %compute overlap as area of intersection / area of union
            ua=(bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
                (bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1)-...
                iw*ih;
            ov=iw*ih/ua;
            if ov>ovmax
                ovmax=ov;
                jmax=j;
            end
            OverlapMatrixAll(d,j)=ov;         
        end
    end
    if ovmax>=ovmaxRefmin
        if ~gtDetected(jmax)
            OverlapMatrix(d,jmax)=ovmax;
            if avoidMultiDetection==1
                gtDetected(jmax)=1;
            end
        else%two trackers merge==> stop their update
            OverlapMatrix(d,jmax)=ovmax;
        end
    elseif ovmax<ovmaxRefmin %create new tracker on this detection
        OverlapMatrix(d,:)=0;
        NewTrackerNum=[NewTrackerNum,d];
    end
end