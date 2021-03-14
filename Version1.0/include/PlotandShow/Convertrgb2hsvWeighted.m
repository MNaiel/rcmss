function OutColor=Convertrgb2hsvWeighted(COLOR,Weight)
N=length(Weight);
OutColor=zeros(N,3);
COLOR1=COLOR;
Convert2HSV=1;
for i=1:length(Weight)
    if Convert2HSV==0
        beta=Weight(i);
        beta=beta-0.5;
        COLOR2 = brighten(COLOR1,beta);
        OutColor(i,:)=COLOR2;
    else
        COLORHsV=rgb2hsv(COLOR1);
        COLORHsV(3)=Weight(i);
        COLOR2=hsv2rgb(COLORHsV);
        OutColor(i,:)=COLOR2;
    end
end
showColors=0;
if showColors==1
    hold off;
    figure(4);SizePoint=50;
    scatter(1,1,SizePoint,COLOR1,'filled');
    hold on;
    scatter(1,2,SizePoint,COLOR2,'filled');
    axis([0 2 0 3])
    drawnow;
    pause(0.25);
    hold off;
end