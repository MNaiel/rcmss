function [gtInfo,stateInfo]=ConvertGTandTrBoYangFormat(gt,Finalresult, DatasetInfo)
start_frame=DatasetInfo.NewStartFrame;
end_frame=DatasetInfo.EndValidFrame;
GT=cell2mat(gt);
GTid=unique(GT(:,1));
Trajectory=Video.getElementsByTagName('Trajectory');
TLength=Trajectory.getLength;
gtInfo.frameNums=start_frame:end_frame;
gtInfo.X=zeros(end_frame-start_frame+1,TLength);
gtInfo.Y=zeros(end_frame-start_frame+1,TLength);
gtInfo.H=zeros(end_frame-start_frame+1,TLength);
gtInfo.W=zeros(end_frame-start_frame+1,TLength);
for i=0:TLength-1
    Tstart=str2num(Trajectory.item(i).getAttribute('start_frame'));
    Tend=str2num(Trajectory.item(i).getAttribute('end_frame'));
    Frame=Trajectory.item(i).getElementsByTagName('Frame');
    for j=0:Frame.getLength-1
        xx=str2num(Frame.item(j).getAttribute('x'));
        yy=str2num(Frame.item(j).getAttribute('y'));
        ww=str2num(Frame.item(j).getAttribute('width'));
        hh=str2num(Frame.item(j).getAttribute('height'));
        frame_no=str2num(Frame.item(j).getAttribute('frame_no'));
        gtInfo.X(frame_no-start_frame+1,i+1)=xx+ww/2;
        gtInfo.Y(frame_no-start_frame+1,i+1)=yy+hh;
        gtInfo.W(frame_no-start_frame+1,i+1)=ww;
        gtInfo.H(frame_no-start_frame+1,i+1)=hh;
    end
end
end