function gtTrack = getGT_TracksCurrentFrame(trajTot,frameNum)

ids_gt = find(trajTot(:,frameNum,1)~=0);
if length(ids_gt) < 2
    gtTrack = [ids_gt,round(squeeze(trajTot(ids_gt,frameNum,:)))'];
else
    gtTrack = [ids_gt,round(squeeze(trajTot(ids_gt,frameNum,:)))];
end
