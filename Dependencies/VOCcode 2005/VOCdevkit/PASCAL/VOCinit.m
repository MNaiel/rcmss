clear PASopts

% change this path to point to your copy of the PASCAL images
PASopts.imgdir=[cd '/VOCdata/'];

% change this path to a writable directory for your results
PASopts.resultsdir=[cd '/results/'];

% initialize the VOC challenge metaclasses

PASopts.VOCclass(1).label='VOCmotorbikes';
PASopts.VOCclass(1).PASlabels={'PASmotorbike','PASmotorbikeSide'};
PASopts.VOCclass(2).label='VOCbicycles';
PASopts.VOCclass(2).PASlabels={'PASbicycle','PASbicycleSide'};
PASopts.VOCclass(3).label='VOCpeople';
PASopts.VOCclass(3).PASlabels={'PASperson','PASpersonSitting','PASpersonStanding','PASpersonWalking'};
PASopts.VOCclass(4).label='VOCcars';
PASopts.VOCclass(4).PASlabels={'PAScar','PAScarFrontal','PAScarRear','PAScarSide'};

% initialize the VOC challenge options

PASopts.VOCminoverlap=0.5; % minimum area overlap for correct detection
