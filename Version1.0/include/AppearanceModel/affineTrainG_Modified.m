function [X_pos X_neg wimgsPos wimgsNeg] = affineTrainG_Modified(dataPath, sz, opt, param, num_p, num_n, forMat, p0,SaveWaripImages,SaveDirectory, ID)
global warpType  SigmaAffineNegSamples
% function [X_pos X_neg] = affineTrainG(dataPath, sz, opt, param, num_p, num_n, forMat, p0)
% obtain positive and negative templates for the SDC
% input ---
% dataPath: the path for the input images
% sz: the size of the tracking window
% opt: initial parameters
% param: the affine parameters
% num_p: the number for the positive templates
% num_n: the number for the negative templates
% forMat: the format of the input images in one video, for example '.jpg' '.bmp'.
% p0: aspect ratio in the first frame

% output ---
% X_pos: positive templates
% X_neg: negative templates
%*************************************************************
%% Copyright (C) Wei Zhong.
%% All rights reserved.
%% Date: 05/2012
Show=0;
if (nargin <9)
    SaveWaripImages=0;
    
end
img_color = imread(dataPath);
img=PerFrameFunction(img_color);
%%----------------- positive templates----------------%%
n = num_p;                     % Sampling Number
param.param0 = zeros(6,n);     % Affine Parameter Sampling
param.param = zeros(6,n);
param.param0 = repmat(affparam2geom(param.est(:)), [1,n]);
randMatrix = randn(6,n);
sigma = [2, 2, .000, .000, .000, .000];
param.param = param.param0 + randMatrix.*repmat(sigma(:),[1,n]);

o = affparam2mat(param.param);     % Extract or Warp Samples which are related to above affine parameters
[wimgs wimgsColor]=warpimgFunction(img, o, sz,opt);
wimgsPos=wimgsColor;
CBB=convertAfftolowFormat(param.est(:),sz);
ObjectW=CBB(3)-CBB(1);
ObjectH=CBB(4)-CBB(2);
if Show==1
    CBB=convertAfftolowFormat(o,sz);
    SHOWBBonImage(img,CBB);
end
if SaveWaripImages==1
    SaveDir=strcat(SaveDirectory,'\Tr',num2str(ID));
    Start=0;
    if ~isdir(SaveDir)
        mkdir(SaveDir);
        SaveDir=strcat(SaveDirectory,'\Tr',num2str(ID),'\Pos\');
        mkdir(SaveDir);
    else
        SaveDir=strcat(SaveDirectory,'\Tr',num2str(ID),'\Pos\');
        if ~isdir(SaveDir)
            mkdir(SaveDir);
            Start=0;
        else
            ImageFiles=dir(strcat(SaveDir,'*.png'));
            Start=numel(ImageFiles);
        end
    end
    for i=1:size(wimgs,3)
        Start=Start+1;
        ImageString=strcat(SaveDirectory,'\Tr',num2str(ID),'\Pos\',ZeroPadInNumber(Start),'.png');
        imwrite(uint8(wimgs(:,:,i)),ImageString);
    end
end
X_pos= ConcatenateWarpImage(wimgsPos,opt,n);
%%----------------- negative templates----------------%%
n = num_n;       % Sampling Number
Quarter=floor(n/4);
Half=floor(n/2);
param.param0 = zeros(6,n);      % Affine Parameter Sampling
param.param = zeros(6,n);
param.param0 = repmat(affparam2geom(param.est(:)), [1,n]);
randMatrix = randn(6,n);
Centerx=param.param0(1,1);
Centery=param.param0(2,1);
LeftCenterx=Centerx-1*ObjectW;LeftCentery=Centery;
RightCenterx=Centerx+1*ObjectW;RightCentery=Centery;
TopCenterx=Centerx;TopCentery=Centery-ObjectH;
BottomCenterx=Centerx;BottomCentery=Centery+ObjectH;
param.param0(1:2,1:Quarter)=repmat([LeftCenterx;LeftCentery], [1,Quarter]);
param.param0(1:2,Quarter+1:Half)=repmat([RightCenterx;RightCentery], [1,Quarter]);
param.param0(1:2,Half+1:Half+Quarter)=repmat([TopCenterx;TopCentery], [1,Quarter]);
param.param0(1:2,Half+Quarter+1:end)=repmat([BottomCenterx;BottomCentery], [1,Quarter]);

param.param = param.param0 + randMatrix.*repmat(SigmaAffineNegSamples(:),[1,n]);
back = round(0.7*sigma(1));
center =Centerx;
left = center - back;
right = center + back;
TempVector=param.param(1,1:Half);
nono = TempVector<=right&TempVector>=center;
TempVector(nono)=TempVector(nono)+ObjectW;% +right;
param.param(1,1:Half)=TempVector;

nono = TempVector>=left&TempVector<center;
TempVector(nono)=TempVector(nono)-ObjectW;% +right;
param.param(1,1:Half)=TempVector;
center = Centery;
top = center - back;
bottom = center + back;
nono = param.param(2,:)<=bottom&param.param(2,:)>=center;
param.param(2,nono) = bottom;
nono = param.param(2,:)>=top&param.param(2,:)<center;
param.param(2,nono) = top;

o = affparam2mat(param.param);    %Extract or Warp Samples which are related to above affine parameters
[wimgs wimgsColor]= warpimgFunction(img, o, sz,opt);
wimgsNeg=wimgsColor;
if Show==1
    tempScore=zeros(size(wimgs,3),1);
    CBB=convertAfftolowFormat(o,sz);
    SHOWBBonImage(img,CBB,tempScore,tempScore,tempScore,[0 0 1],0);
end
if SaveWaripImages==1
    SaveDir=strcat(SaveDirectory,'\Tr',num2str(ID));
    if ~isdir(SaveDir)
        mkdir(SaveDir);
        Start=0;
        SaveDir=strcat(SaveDirectory,'\Tr',num2str(ID),'\Neg\');
        mkdir(SaveDir);
    else
        SaveDir=strcat(SaveDirectory,'\Tr',num2str(ID),'\Neg\');
        if ~isdir(SaveDir)
            mkdir(SaveDir);
            Start=0;
        else
            ImageFiles=dir(strcat(SaveDir,'*.png'));
            Start=numel(ImageFiles);
        end
    end
    for i=1:size(wimgs,3)
        Start=Start+1;
        ImageString=strcat(SaveDirectory,'\Tr',num2str(ID),'\Neg\',ZeroPadInNumber(Start),'.png');
        imwrite(uint8(wimgs(:,:,i)),ImageString);
    end
end
X_neg= ConcatenateWarpImage(wimgsNeg,opt,n);