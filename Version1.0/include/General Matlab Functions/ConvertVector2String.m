function root2=ConvertVector2String(RescaleFactors,StringType,SeparationMethod)
if nargin < 3,  SeparationMethod='/';end
if isempty(RescaleFactors)==0
    C1=length(RescaleFactors);
    stringNew=[];
    for k=1:C1
        stringNew=strcat(stringNew,StringType,'\t',SeparationMethod);
    end
    root2 = sprintf(stringNew,RescaleFactors);
else
    root2 = '';
end