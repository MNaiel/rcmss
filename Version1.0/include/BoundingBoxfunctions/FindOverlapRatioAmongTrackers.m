function [OverlapMatrix,NewTrackerNum,OcclusionFlag,OverlapMatrixAll]=FindOverlapRatioAmongTrackers(BB1,BB2)
% Compute the overlap between two trackers 
% input : BB1, BB2
% output: 
% OverlapMatrix   : matrix contains the VOC overlap ratio between two trackers after filtering overlap< 0.01
% OverlapMatrixAll: matrix contains the VOC overlap ratio between two trackers without filtering
% NewTrackerNum   : new tracker number if needed
% OcclusionFlag   : Flag for the tracker state in case of occlusion
%%
OverlapMatrix=zeros(size(BB1,2),size(BB2,2));
OverlapMatrixAll=OverlapMatrix;
DetectionWindows=size(BB1,2);
ovmaxRefmin=0.01;
ovmaxRef=ovmaxRefmin;
gtDetected= false(DetectionWindows,1);
NewTrackerNum=[];
OcclusionFlag=false(DetectionWindows,1);
StartWindow=0;
for d=1:size(BB1,2)% represent General object detector
    ovmax=-inf;    
    bb=BB1(1:4,d);
    StartWindow=StartWindow+1;
    for j=StartWindow:DetectionWindows %loop on GT ;>> Trackers
        if j~=d
            bbgt=BB2(:,j);
            bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
            iw=bi(3)-bi(1)+1;
            ih=bi(4)-bi(2)+1;
            if iw>0 && ih>0            %compute overlap as area of intersection / area of union
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
    end
    if ovmax>=ovmaxRef
        if ~gtDetected(jmax)
            OverlapMatrix(d,jmax)=ovmax;
            OcclusionFlag(d)=true;
        else          %two trackers merge==> stop their update
            OverlapMatrix(d,jmax)=ovmax;          
            OcclusionFlag(d)=true;
        end
    elseif ovmax<ovmaxRefmin %create new tracker on this detection
        OverlapMatrix(d,:)=0;
        NewTrackerNum=[NewTrackerNum,d];        
    end
end