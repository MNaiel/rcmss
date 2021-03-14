function SDir=RemoveDot_DoubleDot(SaveDirectory)
if ischar(SaveDirectory),   SDir=dir(SaveDirectory);else    SDir=(SaveDirectory);end
NoTracks=numel(SDir);
DotIndex=[];doubleDotIndex=[];
for i=1:NoTracks
    switch (SDir(i).name)
        case '.';
            DotIndex=i;
        case '..';
            doubleDotIndex=i;
        otherwise            
    end
end
SDir(doubleDotIndex)=[];
SDir(DotIndex)=[];
