function y=PadIndexWithZeros(Index)
% input Index= integer number
% output y- zero padded index
%%
if ischar(Index),   UseLength=1;else     UseLength=0;end;
if UseLength==0
    if Index<10
        y=strcat('000000',num2str(Index));
    elseif Index<10^2
        y=strcat('00000',num2str(Index));
    elseif Index<10^3
        y=strcat('0000',num2str(Index));
    elseif Index<10^4
        y=strcat('000',num2str(Index));
    elseif Index<10^5
        y=strcat('00',num2str(Index));
    elseif Index<10^6
        y=strcat('0',num2str(Index));
    elseif Index<10^7
        y=strcat('',num2str(Index));
    end    
else
    if length(Index)<1
        y=strcat('000000',num2str(Index));
    elseif length(Index)<2
        y=strcat('00000',num2str(Index));
    elseif length(Index)<3
        y=strcat('0000',num2str(Index));
    elseif length(Index)<4
        y=strcat('000',num2str(Index));
    elseif length(Index)<5
        y=strcat('00',num2str(Index));
    elseif length(Index)<6
        y=strcat('0',num2str(Index));
    elseif length(Index)<7
        y=strcat('',num2str(Index));        
    end   
end