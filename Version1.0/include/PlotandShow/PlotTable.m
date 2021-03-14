function PlotTable(PercentEachSubject,StringCell,TableHead)
% display on the command window of matlab the results
%%
N=length(StringCell);
NString=zeros(N,1);
for i=1:N,    NString(i)=length(StringCell{i});end
MaxLength=max(NString);
for i=1:N
    Residual=MaxLength-length(StringCell{i});
    if i==1
        Sting2=[];
        for j=1:length(TableHead)
            R2=MaxLength-length(TableHead{j});
            if j==1, Sting2=strcat('%s'); else Sting2=strcat('%',num2str((floor(R2+15))),'s ');   end;
            fprintf(Sting2, TableHead{j});
        end
        fprintf('\n');
        fprintf('---------------- \n');
    end
    Sting=strcat('%s ',concatenateSpace2(Residual+10,2),'%%',' \n');
    fprintf(Sting, StringCell{i},PercentEachSubject(i));
end

end
function String=concatenateSpace(l)
index=0;
String=[];
while index<l
    index=index+1;
    String=strcat(String,' ');
end
end
function String=concatenateSpace2(l,Precision)
String=strcat('%',num2str(l),'.',num2str(Precision),'f');
end