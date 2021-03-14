% Example implementation of an object detector
%
% For each VOC class, the training data (train+val) is loaded and a
% trivial detector trained. The test data (test1) is then
% loaded and the detector applied. Precision/recall and
% Detection Error Tradeoff (DET) curves are computed and saved.
%
% Functions in this file:
%
% example_detector: call train and test functions
% example_train:    train the detector
% example_detect:   run the detector
% extractfeatures:  extract feature vector for the detector

function example_detector

% change this path if you install the PASCAL code elsewhere
addpath([cd '/PASCAL']);

% initialize the PASCAL options

VOCinit;

% define a name for this experiment e.g. myinstitution_final
expt='pascal_develtest';

% run experiments for each class
for c=1:length(PASopts.VOCclass)
    
    label=PASopts.VOCclass(c).label;
    fprintf('label: "%s"\n',label);
    
    % load training set 'train+val'
    fprintf('loading training set\n');
    trainset=VOCreadimgset(PASopts,label,'train+val');
    
    % train a detector
    fprintf('training\n');
    cls=example_train(PASopts,trainset);
    
    % load test set 'test1'
    fprintf('loading test set 1\n');
    testset=VOCreadimgset(PASopts,label,'test1');
    
    % run detector on test set
    fprintf('running detector\n');
    dets=example_detect(PASopts,testset,cls);
    
    % plot precision/recall curve
    fprintf('plotting precision/recall\n');
    pr=VOCpr(PASopts,testset,dets,true);
    
    % save precision/recall curve
    fprintf('saving precision/recall\n');
    figure(1);
    VOCsavepr(PASopts,pr,expt);

    % plot DET curve
    fprintf('plotting DET\n');
    figure(2);
    DET=VOCdet(PASopts,testset,dets,true);
    
    % save DET curve
    fprintf('saving DET\n');
    VOCsavedet(PASopts,DET,expt);

    % wait for user
    fprintf('paused... press any key to continue with next class\n');
    pause;
    
end

% Example of training a (trivial) object detector
%
% The present/absent classifier (see example_classifier.m) is used
% to assign confidence to detections. Detection bounding boxes
% are sampled from a Gaussian model of the bounding boxes in the
% training images.

function cls = example_train(PASopts,imgset)

% extract image features (mean RGB)

FD=extractfeatures(PASopts,imgset);

% Gaussian for positive class (present)

cls.pos_mean=mean(FD(:,imgset.posinds),2);
CV=cov(FD(:,imgset.posinds)')';
cls.pos_ICV=inv(chol(CV))';

% Gaussian for negative class (absent)

cls.neg_mean=mean(FD(:,imgset.neginds),2);
CV=cov(FD(:,imgset.neginds)')';
cls.neg_ICV=inv(chol(CV))';

% extract normalized bounding boxes

BB=zeros(4,0);
n=0;
for i=imgset.posinds
    for j=1:length(imgset.recs(i).objects)
        imsz=imgset.recs(i).imgsize(1:2);
        bb=imgset.recs(i).objects(j).bbox;
        n=n+1;
        BB(1,n)=((bb(1)+bb(3))/2)/imsz(1);          % bb x-center/image width
        BB(2,n)=((bb(2)+bb(4))/2)/imsz(2);          % bb y-center/image height
        BB(3,n)=(bb(3)-bb(1)+1)/imsz(1);            % bb width/image width
        BB(4,n)=(bb(4)-bb(2)+1)/(bb(3)-bb(1)+1);    % bb aspect ratio
    end
end

% mean and std dev of bounding boxes

cls.bb_mean=mean(BB,2);
cls.bb_std=std(BB,0,2);

% Example of applying a (trivial) detector
%
% Sample bounding boxes from a Gaussian and assign confidence
% using the present/absent classifier (see example_classifier.m)
%
% The output is a struct array with three fields:
%   imgnum: index of image (1..n)
%   confidence: confidence in detection (increasing => more confident)
%   bbox: bounding box of detection (xmin,ymin)-(xmax,ymax)

function dets = example_detect(PASopts,imgset,cls)

FD=extractfeatures(PASopts,imgset);

PD=cls.pos_ICV*(FD-repmat(cls.pos_mean,1,size(FD,2)));
llp=-sum(PD.*PD);

ND=cls.neg_ICV*(FD-repmat(cls.neg_mean,1,size(FD,2)));
lln=-sum(ND.*ND);

confidence=llp-lln;

n=length(imgset.recs);
d=0;
for i=1:n
    c=confidence(i);
    imsz=imgset.recs(i).imgsize(1:2);
    x=(cls.bb_mean(1)+randn*cls.bb_std(1))*imsz(1);
    y=(cls.bb_mean(2)+randn*cls.bb_std(2))*imsz(2);
    w=(cls.bb_mean(3)+randn*cls.bb_std(3))*imsz(1);
    h=w*(cls.bb_mean(4)+randn*cls.bb_std(4));
    bb=[x-w/2 y-h/2 x+w/2 y+h/2];
    d=d+1;
    dets(d)=struct('imgnum',i,'confidence',c,'bbox',bb);
end

% Example of (trivial) feature extraction
%
% Each image in the image set is loaded and the mean RGB value
% computed and stored in columns of a matrix.

function FD = extractfeatures(PASopts,imgset)

n=length(imgset.recs);
FD=zeros(3,n);
for i=1:n
    if ~mod(i,10)
        fprintf('extract features: %s_%s: image %d/%d\n',imgset.label,imgset.subset,i,n);
        drawnow;    
    end
    I=double(imread([PASopts.imgdir imgset.recs(i).imgname]));
    FD(:,i)=squeeze(mean(mean(I)));
end
