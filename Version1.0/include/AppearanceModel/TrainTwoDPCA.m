function [TwoDPCAparam ]=TrainTwoDPCA(Volume,IDs,opt2DPCA,ReadfromFolder,MainRooT,SecondFolder,TrainRatio)
% Train 2D-PCA model on the input feature volume "Volume".
% Volume        : cell input images of size(n1xn2xj), {trackerID} IDs= class label of every image
% IDs           : input valid trackers ID
% ReadfromFolder: (1) read images from the directory of MainRooT
% MainRooT      : Directory of the training data for several IDS
% SecondFolder  : Used to support image folders
% TrainRatio    : [0-1] percentage used to train the 2DPCA model
%%
if nargin<4
    ReadfromFolder=0;
    TrainRatio=1;
end
show=0;
if isfield(opt2DPCA,'Alpha'),  Alpha= opt2DPCA.Alpha;else    Alpha=0.98;end;
RbyAlpha=1;
if ReadfromFolder==1
    ImageExtension='.png';
    FolderDirectory=dir(MainRooT);
    NoTracks=numel(FolderDirectory);
    for i=1:NoTracks
        switch (FolderDirectory(i).name)
            case '.';
                iDot=i;
            case '..';
                iDotDot=i;
            otherwise
        end
    end
    FolderDirectory(iDot:iDotDot)=[];
    NumberofPersons=numel(FolderDirectory);
else
    NumberofPersons=length(IDs);
end
G=0;
tic;
TotalNumImages=zeros(NumberofPersons,1);
for Person=IDs(:)'
    if ReadfromFolder==1
        str1 = strcat(MainRooT, FolderDirectory(Person).name,'\',SecondFolder,'\');
        ImageDir=dir(strcat(str1,'*',ImageExtension));
        Nimages=numel(ImageDir);
    else
        Nimages=size(Volume{Person},3);
        cVolume=Volume{Person};
    end
    TotalNumImages(Person,1)=Nimages;
    iStart=1; iend=floor(TrainRatio*Nimages);
    for j=iStart:iend
        if ReadfromFolder==1
            strFN = strcat(str1,ImageDir(j).name);
            Im=imread(strFN);
        else
            Im=cVolume(:,:,j);
        end
        Imready=ImageFunction(Im);
        G=G+1;
        if (G==1)
            Aav=(Imready);
        else
            Aav=Aav+(Imready);
        end
    end
end
Aav=Aav./G;
[n1]=size(Aav,1);
NTrainExamples=G;
G=0;
for Person=IDs(:)'
    if ReadfromFolder==1
        str1 = strcat(MainRooT, FolderDirectory(Person).name,'\',SecondFolder,'\');
        ImageDir=dir(strcat(str1,'*',ImageExtension));
        Nimages=numel(ImageDir);
    else
        Nimages=size(Volume{Person},3);
        cVolume=Volume{Person};
    end
    TotalNumImages(Person,1)=Nimages;
    iStart=1; iend=floor(TrainRatio*Nimages);
    for j=iStart:iend
        if ReadfromFolder==1
            strFN = strcat(str1,ImageDir(j).name);
            Im=imread(strFN);
        else
            Im=cVolume(:,:,j);
        end
        Imready=ImageFunction(Im);
        M=double(Imready-Aav);
        G=G+1;
        COV1=M'*M;
        if G==1
            Covm1=(COV1);
        else
            Covm1=Covm1+(COV1);
        end
    end
end
Covm1=Covm1./G;
if show==1
    subplot(2,2,2);ShowSequence(Covm1,1,'Covariance_Average');
end
% Finding the eigenvectors
[V1,D1]=eig(Covm1);%240*240
Vsort1=double(zeros(size(V1)));%Vsort1= All eigen vectors of Oneing
n2=size(Covm1,1);
for i=1:n2
    Vsort1(:,i)= V1(:,n2-i+1);
end
D1=sort(diag(D1),'descend');
if RbyAlpha==1
    SumComm=cumsum(D1);
    if Alpha==1
        r=length(SumComm);
    else
        IndexDominant=find(SumComm<Alpha*SumComm(end));
        if isempty(IndexDominant)
            r=length(SumComm)-1;
        else
            r=IndexDominant(end);
        end
    end
end

if show==1
    subplot(2,2,2);plot(D1);title(num2str(r));
    drawnow;
end
F=double(Vsort1(:,1:r));
G=0;
Train_Data=zeros(NTrainExamples,n1*r);
Group=zeros(NTrainExamples,1);
for Person=IDs(:)'
    if ReadfromFolder==1
        str1 = strcat(MainRooT, FolderDirectory(Person).name,'\',SecondFolder,'\');
        ImageDir=dir(strcat(str1,'*',ImageExtension));
        Nimages=numel(ImageDir);
    else
        Nimages=size(Volume{Person},3);
        cVolume=Volume{Person};
    end
    TotalNumImages(Person,1)=Nimages;
    iStart=1; iend=floor(TrainRatio*Nimages);
    for j=iStart:iend
        if ReadfromFolder==1
            strFN = strcat(str1,ImageDir(j).name);
            Im=imread(strFN);
        else
            Im=cVolume(:,:,j);
        end
        Imready=ImageFunction(Im,Aav);
        FinalData= Imready*F;
        cc1=double(FinalData(:)');
        flagvalid=1;
        if flagvalid==1
            G=G+1;
            Train_Data(G,:)=cc1;
            Group(G)=Person;
        end
    end
end
TwoDPCAparam.F=F;
TwoDPCAparam.Group=Group;
TwoDPCAparam.Train_Data=Train_Data;
TwoDPCAparam.TotalNumImages=TotalNumImages;
TwoDPCAparam.Aav=Aav;
TwoDPCAparam.FSize=size(Train_Data,2);
TwoDPCAparam.r=size(F,2);
end
