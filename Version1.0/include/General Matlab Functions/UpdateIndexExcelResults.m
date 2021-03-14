function SystemParametersCellStartNumIndex=UpdateIndexExcelResults(SaveResultsFlag,SaveParametersFileName,sheet)
if SaveResultsFlag==1    
    if  nargin<3
        num = xlsread(SaveParametersFileName);
    else
        num = xlsread(SaveParametersFileName,sheet);
    end
    if isempty(num)
        SystemParametersCellStartNumIndex=1;
       xlswrite(SaveParametersFileName, 'a',sheet,'A1');%Save number 1 on the top left cornor cell to avoid overwrite
    else
        SystemParametersCellStartNumIndex=size(num,1)+1;
    end
else    
    SystemParametersCellStartNumIndex=[];
end