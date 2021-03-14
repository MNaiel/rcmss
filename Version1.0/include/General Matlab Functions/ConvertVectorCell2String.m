function root2=ConvertVectorCell2String(InCellVector,StringType,SeparationMethod)
if nargin < 3
    SeparationMethod='/';
end
if isempty(InCellVector)==0
    C1=length(InCellVector);
    stringNew=[];
    for k=1:C1
        stringNew=strcat(stringNew,StringType,'\t',SeparationMethod);
    end
    root2 = sprintf(stringNew,InCellVector{:});
else
    root2 = '';
end