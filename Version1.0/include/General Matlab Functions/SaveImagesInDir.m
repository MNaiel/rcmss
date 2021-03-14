function SaveImagesInDir(wimgs,SaveWaripImages,SaveDirectory, ID,SecondFolderName,KeyFrameN,colorFlag)
%this function create new directory
if nargin <7,      colorFlag=0;end
if nargin <6,      KeyFrameN=0;end
if colorFlag==0,   NImages= size(wimgs,3);    else  NImages= size(wimgs,4); end
if SaveWaripImages==1
    SaveDir=strcat(SaveDirectory,'\Tr',num2str(ID));
    Start=0;
    if ~isdir(SaveDir)
        mkdir(SaveDir);
        SaveDir=strcat(SaveDirectory,'\Tr',num2str(ID),'\',SecondFolderName,'\');
        mkdir(SaveDir);
    else
        SaveDir=strcat(SaveDirectory,'\Tr',num2str(ID),'\',SecondFolderName,'\');
        if ~isdir(SaveDir),   mkdir(SaveDir);          Start=0;
        else
            ImageFiles=dir(strcat(SaveDir,'*.png'));
            Start=numel(ImageFiles);
        end
    end
    for i=1:NImages
        Start=Start+1;
        ImageString=strcat(SaveDirectory,'\Tr',num2str(ID),'\',SecondFolderName,'\',ZeroPadInNumber(KeyFrameN),ZeroPadInNumber(Start),'.png');        
        if colorFlag==0,  ImSave=uint8(wimgs(:,:,i));
        else              ImSave=uint8(wimgs(:,:,:,i));
        end
        imwrite(ImSave,ImageString);
    end
end