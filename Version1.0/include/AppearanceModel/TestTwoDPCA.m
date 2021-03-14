function [Class,MinDistance, ConfusionMatrix,ConfusionMatrixPercentage,MatchedTo,recon]=TestTwoDPCA(TwoDPCAparam, testVolume,IDs,SigmaPCAGM,ReadfromFolder,MainRooT,SecondFolder,f,ID)
% Test 2D-PCA model on the input feature testVolume "Volume".
% TwoDPCAparam  : Training parameters of 2DPCA
% testVolume      : cell input images of size(n1xn2xj), {trackerID} IDs= class label of every image
% IDs           : input valid trackers ID
% ReadfromFolder: (1) read images from the directory of MainRooT
% MainRooT      : Directory of the training data for several IDS
% SecondFolder  : Used to support image folders
%f              : Frame number 
%ID             : tracker ID need to show
%SigmaPCAGM     : sigma for 2DPCA
%%
if nargin<4
SigmaPCAGM=5*10^7;
end
if nargin<5
    ReadfromFolder=0;
end
if nargin<8
    f=[];
    ID=[];
end
if isempty(testVolume)
Class=[];MinDistance=[]; ConfusionMatrix=[];ConfusionMatrixPercentage=[];MatchedTo=[];recon=[];        
else
NumberofPersons=length(IDs);
ConfusionMatrix=zeros(NumberofPersons,NumberofPersons);
ConfusionMatrixPercentage=zeros(NumberofPersons,NumberofPersons);
RatioTrue=[];
RatioFalse=[];
Show=0;
ShowPGM=0;
SaveFigure=0;
F=TwoDPCAparam.F;
Group=TwoDPCAparam.Group;
Train_Data=TwoDPCAparam.Train_Data;
TotalNumImages=TwoDPCAparam.TotalNumImages;
Aav=TwoDPCAparam.Aav;
IndexId=0;
for Person=[IDs]
    IndexId=IndexId+1;
    if ReadfromFolder==1
        str1 = strcat(MainRooT, FolderDirectory(Person).name,'\',SecondFolder,'\');
        ImageDir=dir(strcat(str1,'*',ImageExtension));
        Nimages=numel(ImageDir);
    else
        Nimages=size(testVolume(:,:,:,Person),3);
    end
    TotalNumImages(Person,1)=Nimages;
    iStart=1;iend=Nimages;
    for j=[iStart:iend]
        if ReadfromFolder==1
            strFN = strcat(str1,ImageDir(j).name);
            Im=imread(strFN);
        else
            Im=testVolume(:,:,j,Person);
        end
        Imready=ImageFunction(Im,Aav);
        FinalData= Imready*F; %mxn * nxr == mxr
        [m1,m2]=size(Imready);
        [p1,p2]=size(F);%nxr
        ccT=double(FinalData(:)');
        [Class, MinDistance,MaxCounter,MinDistance2,MeanRatio,MatchedTo]=DistanceClassifier(ccT,Train_Data,Group);
        resultID=find(IDs==Class);
        ConfusionMatrix(IndexId,resultID)=ConfusionMatrix(IndexId,resultID)+1;
        
        NFeature=Train_Data(MatchedTo,:);
        MatchedFet = reshape(NFeature, m1,p2);
        Recon=MatchedFet*F'; %
        ReconOriginal=FinalData*F';
        recon = sum(sum((ReconOriginal - Recon).^2));                            % the reconstruction error of each patch
        if ShowPGM==1  && isempty(f)==0
            sim=exp(-recon/SigmaPCAGM);
            ErrorPGM=uint8(abs(ReconOriginal - Recon));            
            
            if sim<0.99        
                ScaleFactor=40;
                ErrorPGM=imresize(ErrorPGM,ScaleFactor);
                Recon=imresize(Recon,ScaleFactor);
                ReconOriginal=imresize(ReconOriginal,ScaleFactor);
                
            if SaveFigure==1 %&& RedFlag==1
                %%
                imshow(uint8(ReconOriginal));
                SaveReport='D:\PhD\RA\MultiObjectTracking\results\soccer_ICIP08';
                FigureName=strcat('\PGMThreshold2\TestOrig',num2str(f),num2str(ID));
                set(gcf, 'PaperPosition', [0 0 12 8]);
                SaveFigure=strcat(SaveReport,FigureName);
                saveas(gcf,strcat(SaveFigure,'.png'));
                saveas(gcf,strcat(SaveFigure,'.eps'),'epsc');
                %%
                imshow(uint8(Recon));
                SaveReport='D:\PhD\RA\MultiObjectTracking\results\soccer_ICIP08';
                FigureName=strcat('\PGMThreshold2\TestMatchedTo',num2str(f),num2str(ID));
                set(gcf, 'PaperPosition', [0 0 12 8]);
                SaveFigure=strcat(SaveReport,FigureName);
                saveas(gcf,strcat(SaveFigure,'.png'));
                saveas(gcf,strcat(SaveFigure,'.eps'),'epsc');
                %%
                imshow(uint8(ErrorPGM));colormap(jet);
                SaveReport='D:\PhD\RA\MultiObjectTracking\results\soccer_ICIP08';
                FigureName=strcat('\PGMThreshold2\TestError',num2str(f),num2str(ID));
                set(gcf, 'PaperPosition', [0 0 12 8]);
                SaveFigure=strcat(SaveReport,FigureName);
                saveas(gcf,strcat(SaveFigure,'.png'));
                saveas(gcf,strcat(SaveFigure,'.eps'),'epsc');
            end
            end
        end       
    end
    ConfusionMatrixPercentage(IndexId,:)=ConfusionMatrix(IndexId,:)./sum(sum(ConfusionMatrix(IndexId,:)))*100;
end
if Show==1
    SeparationMethod=' ';
    for Person=[IDs]
        disp(sprintf('%s  %s', FolderDirectory(Person).name,ConvertVector2String(ConfusionMatrixPercentage(Person,:),'%3.2f',SeparationMethod)));
    end
    mean(diag(ConfusionMatrixPercentage))
    hist(RatioTrue,100);
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor',[1 0 0]);
    hold on;
    hist(RatioFalse,100);h2 = findobj(gca,'Type','patch');
    set(h2,'FaceColor',[0 1 1]);
    legend('True','False')
    hold off
    toc
end
end
end