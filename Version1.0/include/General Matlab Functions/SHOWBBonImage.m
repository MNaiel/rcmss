function SHOWBBonImage(Im,BB,score,ID,center,COLOR,inLoop,FontSizeUsed)
%  show the bounding boxes in low format (BB) on the image (Im).
%  Input
%  Im : input image
%  BB : associated bounding box.
%  score : associated score
%  ID    : associated ID
%  center: plot particle center
%  COLOR:  associated colot
%  inLoop: if in for loop
%%
if nargin <4, ID=zeros(size(BB,2),1);end
if nargin <3, score=[]; end
PlotCenter=0;
if nargin <5 || isempty(center),   PlotCenter=0;    end
if nargin <6,  COLOR=[1 0 0];end
if nargin <7,  inLoop=0; end
if nargin <8,  FontSizeUsed=20; end
if inLoop==0,  imshow(uint8(Im));end
[m1,m2,m3]=size(Im);
if isempty(BB)==0
    hold_was_on = ishold; hold on;
    for d=1:size(BB,2)
        bb=BB(:,d);
        ClowIm=max(1,bb(1));RlowIm=max(1,bb(2)); CHighIm=min(m2,bb(3)); RHighIm=min(m1,bb(4));
        V1=RlowIm:0.2:RHighIm;
        V2=ClowIm :0.2:CHighIm;
        h1(d)=plot(ClowIm*ones(length(V1),1) ,V1);
        h2(d)=plot(CHighIm*ones(length(V1),1),V1);
        h3(d)=plot(V2 ,RlowIm*ones(length(V2),1));
        h4(d)=plot(V2 ,RHighIm*ones(length(V2),1));
        if isempty(score)==0
            ObjWidth=bb(3)-bb(1);ObjHeight=bb(4)-bb(2);
            if inLoop==0
                PlotString=strcat('ID=',num2str(ID(d)),'Score=',num2str(score(d)),'WxH=',num2str(ObjWidth),'X',num2str(ObjHeight));
                T(d)=text(ClowIm,RlowIm,PlotString,'LineWidth',3);
            else
                PlotString=strcat(num2str(ID(d)));
                T(d)=text(ClowIm+(CHighIm-ClowIm)/2,RlowIm-10,PlotString);
            end
        end
        if PlotCenter
            pnew=convertlowFormattoCenter(bb);
            SizePoint=10;
            h6(d)=scatter(pnew(1),pnew(2),SizePoint,[1 0 0],'filled');
        end
    end
    set(h1,'Color',COLOR,'LineWidth',3);
    set(h2,'Color',COLOR,'LineWidth',3);
    set(h3,'Color',COLOR,'LineWidth',3);
    set(h4,'Color',COLOR,'LineWidth',3);
    if PlotCenter        
    end
    if isempty(score)==0
        set(T,'color',[1 1 0],'FontSize',FontSizeUsed);
    end
    if inLoop==0
        drawnow;
    end
    if (~hold_was_on), hold off; end
end