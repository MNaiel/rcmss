function EstTrack = getEst_TracksCurrentFrame(traj,frameNum)

ids = find(traj(:,frameNum,1)~=0);
if length(ids) < 2
    EstTrack = [ids,round(squeeze(traj(ids,frameNum,:)))'];
else
    EstTrack = [ids,round(squeeze(traj(ids,frameNum,:)))];
end
