%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) Copyright 2011 - MICC - Media Integration and Communication Center,
% University of Florence. 
% Iacopo Masi and Giuseppe Lisanti  <masi,lisanti> @dsi.unifi.it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
% groundtruth and results are examples. Ricreate these two structures if
% you wanto to use it in your own multi-target tracker.
load groundtruth
load result
VOCscore = 0.5;
dispON  = true;
ClearMOT = evaluateMOT(gt,result,VOCscore,dispON);
%   - INPUT:
%   GROUNDTRUTH is a cell array where the index referst to the i-th frame.
%   GROUNDTRUTH{i} is the set of lablled bounding boxes (bbox). The bbox
%   format is %   bbox = [id tl.x tl.y br.x br.y] where id is the ID of the target; tl
%   is the top-left corner of the bbox and br is the bottom-right one.
%
%   RESULT is the structure array that contains the tracking results. See
%   the resul.mat example for more information.
%
%   DIST is a distance threshold to consider an association as true positive.
%
%   DISPON enable disable display result
%    idxTracks=result(i).trackerData.idxTracks;
%    target=result(i).trackerData.target;