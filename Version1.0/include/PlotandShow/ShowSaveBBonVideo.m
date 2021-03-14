function ShowSaveVideoParam=ShowSaveBBonVideo(img_color,CBB,score,TrackID,fID,ShowSaveVideoParam)
if fID==1
    close all;
    writerObj = VideoWriter(strcat(ShowSaveVideoParam.SaveResultsVideoFolder,ShowSaveVideoParam.VideoName));
    writerObj.FrameRate = ShowSaveVideoParam.FrameRate;
    open(writerObj);
    ShowSaveVideoParam.writerObj=writerObj;
    figure('position',[30 50 size(img_color,2) size(img_color,1)]); clf;
    set(gcf,'DoubleBuffer','on','MenuBar','none');
    colormap('gray');
    ShowSaveVideoParam.curaxis = [];
    ShowSaveVideoParam.curaxis.frm  = axes('position', [0.00 0 1.00 1.0]);
end
Ncolor=size(ShowSaveVideoParam.fcol,1);
curaxis = ShowSaveVideoParam.curaxis;
axes(curaxis.frm);
imagesc(img_color, [0,1]);
hold on;
Index=0;
for ID= TrackID
    Index=Index+1;
    if ID>Ncolor, CI=ID-rem(Ncolor,ID)*floor(ID/Ncolor)+1; else CI=ID;  end;
    SHOWBBonImage(img_color,CBB(:,Index),score(Index),ID,1,ShowSaveVideoParam.fcol(CI,:),1,15);
end
text(10, 15, '#', 'Color','y', 'FontWeight','bold', 'FontSize',24);
text(30, 15, num2str(fID), 'Color','y', 'FontWeight','bold', 'FontSize',24);
hold off;
img_color=getframe;
[Ir,Ic,Id]=size(img_color.cdata);
if size(img_color,1)~=Ir || size(img_color,2)~=Ic,  img_color.cdata=imresize(img_color.cdata,[Ir,Ic]);end
writeVideo(ShowSaveVideoParam.writerObj,img_color);
if fID==ShowSaveVideoParam.FinalFrameNo,    close(ShowSaveVideoParam.writerObj);end