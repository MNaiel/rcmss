function [VInitialx VInitialy BBInWindow]=ComputeInstantVelocity(Trobject,Window)
% Compute Instant Velocity
% Input:
% Trobject      : Tracker object
% Window        : size of the window to compute the average velocity over it
% Output
% VInitialx     : velocity component in x- direction
% VInitialy     : velocity component in y- direction
% BBInWindow    : BB exist in the window
%%
StartValue=Trobject.StartFrame;
if (Trobject.Last_f-StartValue)-Window>0
    BBInWindow=convertlowFormattoCenter(Trobject.BBresult(:,Trobject.Last_f-Window:Trobject.Last_f));%previous-1 Center
    VInitialx=mean(diff(BBInWindow(1,:)));
    VInitialy=mean(diff(BBInWindow(2,:)));
else
    TempW=Trobject.Last_f-StartValue;
    BBInWindow=convertlowFormattoCenter(Trobject.BBresult(:,Trobject.Last_f-TempW:Trobject.Last_f));%previous-1 Center
    VInitialx=mean(diff(BBInWindow(1,:)));
    VInitialy=mean(diff(BBInWindow(2,:)));
end
if isnan(VInitialx)==1
    VInitialx=0.01;
    VInitialy=0.01;
end
