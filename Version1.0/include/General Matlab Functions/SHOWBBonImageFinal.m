function SHOWBBonImageFinal(Im,BB,ScoreOutPos,tp,ShowParameter,inLoop,AdjustScreen,StringSaveFig)
COLOR=ShowParameter.Dcol;
PlotScore=ShowParameter.ShowScoreFinal;
if AdjustScreen
    figure(3);
    imshow(uint8(Im));%drawnow;
    h2=gcf;
    scrsz = get(0,'ScreenSize');
    set(h2,'Position',[1 scrsz(4)/2 scrsz(3)*0.3 scrsz(4)*0.4]);
    h1=[];
    h2=h1;h3=h1;h4=h1;
    T=[];
    hold on
end
if nargin <6, inLoop=0;end
if nargin <8, StringSaveFig=[];end
if isempty(BB)==0
    hold_was_on = ishold; hold on;
    COLORLoop=[];
    for d=1:size(BB,2)
        bb=BB(:,d);
        ClowIm=bb(1);RlowIm=bb(2); CHighIm=bb(3); RHighIm=bb(4);
        V1=RlowIm:0.2:RHighIm;
        V2=ClowIm :0.2:CHighIm;
        h1(d)=plot(ClowIm*ones(length(V1),1) ,V1);
        h2(d)=plot(CHighIm*ones(length(V1),1),V1);
        h3(d)=plot(V2 ,RlowIm*ones(length(V2),1));
        h4(d)=plot(V2 ,RHighIm*ones(length(V2),1));
        if isempty(ScoreOutPos)==0 && PlotScore
            ObjWidth=bb(3)-bb(1);ObjHeight=bb(4)-bb(2);
            if inLoop==0
                PlotString=strcat('ID=',num2str(ID(d)),'Score=',num2str(ScoreOutPos(d)),'WxH=',num2str(ObjWidth),'X',num2str(ObjHeight));
                T(d)=text(ClowIm,RlowIm,PlotString,'LineWidth',3);
            else
                PlotString=strcat(num2str(ID(d)));
                T(d)=text(ClowIm+(CHighIm-ClowIm)/2,RlowIm-10,PlotString);
            end
        end
        if tp(d)==1,  COLORid=1;  else    COLORid=2;    end
        set(h1(d),'Color',COLOR(COLORid,:),'LineWidth',3);
        set(h2(d),'Color',COLOR(COLORid,:),'LineWidth',3);
        set(h3(d),'Color',COLOR(COLORid,:),'LineWidth',3);
        set(h4(d),'Color',COLOR(COLORid,:),'LineWidth',3);
    end    
    if inLoop==0, drawnow;    end;
    if ShowParameter.saveasFigFinal==1
        for J =1:length(ShowParameter.FigFinalFormat),  saveas(gcf,strcat(StringSaveFig,ShowParameter.FigFinalFormat{J}));  end
    end    
    if (~hold_was_on) hold off; end    
    hold off;
end