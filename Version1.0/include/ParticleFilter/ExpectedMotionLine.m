function Y=ExpectedMotionLine(X,t)
% Compute the expected motion at time t
% X: (x,y, vx,vy)
% Y: updated state
%%
F_update = [1 0 1 0; 0 1 0 1; 0 0 1 0; 0 0 0 1];
Y=zeros(4,t+1);
Y(:,1)=X;
for i=2:t+1
    X = F_update * X;
    Y(:,i)=X;
end