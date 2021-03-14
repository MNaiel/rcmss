function y=GetColorWeight(x,xfinal ,xStart)
%input xfinal: last frame number
%      xStart: first frame number
%        x: current frame number
%%
yfinal=0.5;
ystart=1;
if xfinal-xStart==0
    Slope=(yfinal-ystart);
else
    Slope=(yfinal-ystart)/(xfinal-xStart);
end
y=  Slope*(x-xStart)+ystart;
