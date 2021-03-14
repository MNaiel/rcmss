% comment/uncomment 'trackerName' and 'datasetName' to run different
% experiments

clear; close all; clc

%%  Select the tracker name
trackerName = 'crfbt';
% trackerName = 'dpnms';

%% Select the dataset
datasetName = 'bahnhof';
% datasetName = 'sunnyday';

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

OVERLAP = zeros(size(trajTot,1),size(trajTot,2),1);
for i = startFrame:endFrame
    if ~mod(i,50);
        disp(['Fame ' num2str(i) ' of ' num2str(endFrame)])
    end
     
    % get estimated tracks
    estTrack = getEst_TracksCurrentFrame(traj,i);
    % get ground truth tracks
    gtTrack = getGT_TracksCurrentFrame(trajTot,i);
    
    evlScores = computeMeasures(estTrack,gtTrack);
   
    %% Overlap computation    
    O = zeros(size(estTrack,1),size(gtTrack,1));
    for ii = 1:size(estTrack,1)
        for jj = 1:size(gtTrack,1)
            estBbox = estTrack(ii,2:end);
            gtBbox = gtTrack(jj,2:end);
            if isempty(estBbox) || isempty(gtBbox)
                Overlap = 0;
            else
                Overlap = overlapping(estBbox,gtBbox);
            end
            O(ii,jj) = 1 - Overlap;
        end
    end
    O(O==1) = Inf;
        
    [assgn,cost] = Hungarian(O);
    [r,c] = find(assgn);
    
    for ii = 1:length(c)
        OVERLAP(gtTrack(c(ii),1),i) = 1-O(r(ii),c(ii));
    end
end

%% MELT computation
thresh = 0.01:0.01:1;
LTR = zeros(size(OVERLAP,1),length(thresh));

%% Calculate Track Lost Ratio
for i = 1:size(OVERLAP,1)
    gtTrackBool = trajTot(i,:,3)~=0;
    gtTrackLength = sum(gtTrackBool);
    if gtTrackLength
        for j = 1:length(thresh)
            LTR(i,j) = length(find(OVERLAP(i,gtTrackBool)<=thresh(j)))/gtTrackLength;
        end
    end
end

bins = 100;
H = zeros(bins,length(thresh));
for i = 1:length(thresh)
    LTR1 = [LTR(:,i) ; 0 ; 1];
    [h,X] = hist(LTR1,bins);
    h(1) = h(1)-1;
    h(end) = h(end)-1;
    H(:,i) = h/size(LTR,1);
end

MELT_t = mean(LTR);
plot(X,MELT_t,'b','LineWidth',2)
xlabel('\tau','FontSize',16)
ylabel('MELT_\tau','FontSize',16)

disp('***********************')
disp(['MELT = ' num2str(mean(MELT_t))])
disp('***********************')
