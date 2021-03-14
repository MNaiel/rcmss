% comment/uncomment 'trackerName' and 'datasetName' to run different
% experiments

clear; close all; clc

%%  Select the tracker name
% trackerName = 'crfbt';
trackerName = 'dpnms';

%% Select the dataset
% datasetName = 'bahnhof';
datasetName = 'sunnyday';

%% Load GT Tracks
if strcmpi(datasetName,'sunnyday')
    path_GT_Tracks = './ground_truth/gt_sunnyday.mat';
    load(path_GT_Tracks);
elseif strcmpi(datasetName,'bahnhof')
    path_GT_Tracks = './ground_truth/gt_bahnhof.mat';
    load(path_GT_Tracks);
end
%%

%% Load Estimated Tracks
if strcmpi(trackerName,'crfbt')
    if strcmpi(datasetName,'bahnhof')
        path_tracks = './est_tracks/crfbt/bahnhof_trackres.mat';
    elseif strcmpi(datasetName,'sunnyday')
        path_tracks = './est_tracks/crfbt/sunnyday_trackres.mat';
    end
    load(path_tracks);
    
elseif strcmpi(trackerName,'dpnms')
    if strcmpi(datasetName,'bahnhof')
        path_tracks = './est_tracks/dpnms/bahnhof_trackres';
    elseif strcmpi(datasetName,'sunnyday')
        path_tracks = './est_tracks/dpnms/sunnyday_trackres';
    end
    load(path_tracks);
end
%%

%% Frame config
if strcmpi(datasetName,'sunnyday')
    startFrame = 1;
    endFrame = 353;
    frameSize = [480,640];
elseif strcmpi(datasetName,'bahnhof')
    startFrame = 1;
    endFrame = 998;
    frameSize = [480,640];
end
%%


METE = [];
IdSwitching = zeros(1,length(1:endFrame));
IDS = zeros(1,size(trajTot,1));
counterIDS = zeros(1,size(trajTot,1));
counter=1;
for i = startFrame:1:endFrame
    if ~mod(i,50);
        disp(['Fame ' num2str(i) ' of ' num2str(endFrame)])
    end
    
    %% METE block
    % get estimated tracks
    estTrack = getEst_TracksCurrentFrame(traj,i);
    % get ground truth tracks
    gtTrack = getGT_TracksCurrentFrame(trajTot,i);
    
    evlScores = computeMeasures(estTrack,gtTrack);
    
    normMatchingError(counter) = evlScores.normMatchingError;
    METE(counter) = evlScores.METE;
    cardErrRate1(counter) = evlScores.cardErrRate1;
    cardErrRate2(counter) = evlScores.cardErrRate2;
    card_estTrk(counter) = evlScores.card_estTrk;
    card_gtTrk(counter) = evlScores.card_gtTrk;
    ae(counter) = evlScores.ae;
    ce(counter) = evlScores.ce;
    %%%%%%%%%%%%%
    
    %% NIDC block
    assgn = evlScores.assgn;
    a = zeros(size(assgn,2),1);
    [a1,b] = find(assgn);
    a(b) = a1;
    
    % IDS computation
    gt_data = squeeze(trajTot(:,i,:));
    gt_id = find(gt_data(:,1));
    gt_data = gt_data(gt_id,:);    
    gt_data = [gt_id gt_data]';
    track_data = estTrack';
    if i~=startFrame
        for id=gt_id'
            if ~isempty(find(a==find(gt_id==id)))
                if IDS(id) == 0
                    IDS(id) = track_data(1,find(a==find(gt_id==id)));
                end
                if IDS(id) ~= track_data(1,find(a==find(gt_id==id)))
                    IdSwitching(i) = IdSwitching(i) + 1;
                    counterIDS(id) = counterIDS(id) + 1;
                    IDS(id) = track_data(1,find(a==find(gt_id==id)));                   
                end                
            end
        end
    end
    %%%%%%%%%%%%
    
    counter = counter + 1;
end

id = find(counterIDS);
NIDC = 0;
for i = 1:length(id)
    tracklen = length(find(squeeze(trajTot(id(i),:,3))));
    NIDC = NIDC + counterIDS(id(i))/tracklen;
end
NIDC = NIDC/length(id);

for i=1:size(trajTot,1)
    lengthTracks(i) = length(find(trajTot(i,:,3)));
end

temp=find(counterIDS~=0);
meanTrkLen = mean(lengthTracks(temp));

disp('***********************')
disp(['Mean METE = ' num2str(mean(METE)) ' - Std METE = ' num2str(std(METE))])
disp(['AER = ' num2str(mean(ae)) ' - Std AE = ' num2str(std(ae))])
disp(['CER = ' num2str(mean(ce)) ' - Std CE = ' num2str(std(ce))])
disp(['NIDC = ' num2str(NIDC)])
disp(['MLT = ' num2str(meanTrkLen)])
disp(['IDC = ' num2str(sum(IdSwitching))])
disp('***********************')