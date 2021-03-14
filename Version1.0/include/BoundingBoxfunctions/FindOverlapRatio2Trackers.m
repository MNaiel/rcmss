function [OverlapMatrix]=FindOverlapRatio2Trackers(BB,gtBB)
% Compute the overlap between two trackers BB, gtBB
%%
OverlapMatrix=zeros(size(BB,2),size(gtBB,2));
for d=1:size(BB,2)% represent General object detector
    ovmax=-inf;
    bb=BB(:,d);
    for j=1:size(gtBB,2) %loop on GT ;>> Trackers
        bbgt=gtBB(:,j);
        bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
        iw=bi(3)-bi(1)+1;
        ih=bi(4)-bi(2)+1;
        if iw>=0 && ih>=0
            % compute overlap as area of intersection / area of union
            ua=(bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
                (bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1)-...
                iw*ih;
            ov=iw*ih/ua;
            if ov>ovmax
                ovmax=ov;
                jmax=j;
            end
            OverlapMatrix(d,j)=ov;
        end
    end
end