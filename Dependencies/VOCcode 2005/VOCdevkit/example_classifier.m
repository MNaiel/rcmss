% Example implementation of an object present/absent classifier
%
% For each VOC class, the training data (train+val) is loaded and a
% trivial classifier trained. The test data set (test1) is then
% loaded and the classifier applied. An ROC curve is
% computed and saved.
%
% Functions in this file:
%
% example_classifier: call train and test functions
% example_train:      train the classifier
% example_classify:   run the classifier
% extractfeatures:    extract feature vector for the classifier

function example_classifier

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
    
    % train a present/absent classifier here       
    fprintf('training\n');
    cls=example_train(PASopts,trainset);
    
    % load test set 'test1'
    fprintf('loading test set 1\n');
    testset=VOCreadimgset(PASopts,label,'test1');
    
    % run classifier on test set
    fprintf('running classifier\n');
    confidence=example_classify(PASopts,testset,cls);
    
    % plot ROC curve
    fprintf('plotting ROC\n');
    roc=VOCroc(PASopts,testset,confidence,true);
    
    % save ROC curve
    fprintf('saving ROC\n');
    VOCsaveroc(PASopts,roc,expt);

    % wait for user
    fprintf('paused... press any key to continue with next class\n');
    pause;
    
end

% Example of training a (trivial) object present/absent classifier
%
% The classifier uses the mean RGB value of the image,
% modelling the distributions for positive and negative images
% as Gaussian.

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

% Example of applying a (trivial) present/absent classifier
%
% The mean RGB value of the image is computed and the
% (unnormalized) log-likelihood ratio is computed using Gaussians
% for positive (present) and negative (absent) classes.
%
% The output is a vector of confidence that the object is present
% with one element per image.

function confidence = example_classify(PASopts,imgset,cls)

FD=extractfeatures(PASopts,imgset);

PD=cls.pos_ICV*(FD-repmat(cls.pos_mean,1,size(FD,2)));
llp=-sum(PD.*PD);

ND=cls.neg_ICV*(FD-repmat(cls.neg_mean,1,size(FD,2)));
lln=-sum(ND.*ND);

confidence=llp-lln;

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
