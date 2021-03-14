function root2=ConvertVector2StringWithoutSpace(RescaleFactors,StringType,SeparationMethod)
if nargin < 3
    SeparationMethod='/';
end
C1=length(RescaleFactors);
stringNew=[];
for k=1:C1
    stringNew=strcat(stringNew,StringType,SeparationMethod);
end
root2 = sprintf(stringNew,RescaleFactors);