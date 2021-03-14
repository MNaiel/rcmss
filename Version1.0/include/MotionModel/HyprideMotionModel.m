function [Trobject, X,param]=HyprideMotionModel(Trobject,f,VelocityMotionModel,param,opt,param1,n)
%% use constant veclocity sampling scheme + initialize the velocity of detector particles
% Input
% Trobject            : Tracker object
% f                   : Frame number
% VelocityMotionModel : Options of motion model
% param               : last parameter state at time t-1
% opt                 : options to sample particles state
% param1              : new parameters state of detector at time t,
%                       requires the average speed
% n                   : number of propagated particles
% Output
% Trobject : Tracker object after updates
% X        : Part from the state vector (position and velocity) [x, y, vx ,vy]
% param    : Part from thr state vector, from [1 to 6] [x, y, scale,rotation,aspect ratio, skew ] affine
%%
if Trobject.InOcclusion==0 %|| Trobject.InMergewithOcclusion==0
    W=Trobject.p(3);
    ScaleFactorx=(sqrt(W)/100);
else
    ScaleFactorx=1;
end
if isempty(Trobject.X) || f==Trobject.StartFrame %% initialization
    randMatrix = randn(2,n);
    param.param(1:2,:) = param.param0(1:2,:) + randMatrix.*repmat(opt.affsig(1:2)',[1,n]);
    X1=param.param(1:2,:);% x and y
    X2=zeros(2,size(X1,2)); % vx and vy
    X=[X1;X2];
elseif Trobject.InOcclusion==0 || (Trobject.InMergewithOcclusion==0)
    X=Trobject.X;
    StartValue=Trobject.StartFrame;
    if f-StartValue>VelocityMotionModel.Window || isempty(Trobject.VInitialx)==0
        if isempty(Trobject.VInitialx) || VelocityMotionModel.USeInstantVelocity==1
            [VInitialx VInitialy]=ComputeVelocity(Trobject,VelocityMotionModel);
            Trobject.VInitialx=VInitialx;
            Trobject.VInitialy=VInitialy;
        else
            VInitialx=Trobject.VInitialx;
            VInitialy=Trobject.VInitialy;
        end
        N = size(X, 2);
        if VelocityMotionModel.SumVelocityTwice
            X(3,:)=VInitialx + VelocityMotionModel.SigmaVx * randn(1, N);
            X(4,:)=VInitialy+ VelocityMotionModel.SigmaVy * randn(1, N);
        end
    elseif f-StartValue ==0
        N = size(X, 2);
        X(3,:)=zeros(1,N);
        X(4,:)=zeros(1,N);
    end
elseif Trobject.InOcclusion==1 && Trobject.InMergewithOcclusion==1
    X=Trobject.X;
    if rem(f,4)==0
        X(1:2,:)=param.param0(1:2,:);% x and y
    end
    N = size(X, 2);
    StartValue=Trobject.StartFrame;
    if f-StartValue>VelocityMotionModel.Window || isempty(Trobject.VInitialx)==0
        if isempty(Trobject.VInitialx) ||VelocityMotionModel.USeInstantVelocity==1
            [VInitialx VInitialy]=ComputeVelocity(Trobject,VelocityMotionModel);
            Trobject.VInitialx=VInitialx;
            Trobject.VInitialy=VInitialy;
        else
            VInitialx=Trobject.VInitialx;
            VInitialy=Trobject.VInitialy;
        end
        N = size(X, 2);
        if VelocityMotionModel.SumVelocityTwice
            X(3,:)=VInitialx + VelocityMotionModel.SigmaVx * randn(1, N);
            X(4,:)=VInitialy+ VelocityMotionModel.SigmaVy * randn(1, N);
        end
    elseif f-StartValue ==0
        N = size(X, 2);
        X(3,:)=zeros(1,N);
        X(4,:)=zeros(1,N);
    end
end
F_update = [1 0 1 0; 0 1 0 1; 0 0 1 0; 0 0 0 1];
N = size(X, 2);
X = F_update * X;
X(1,:) = X(1,:) + ScaleFactorx*VelocityMotionModel.Sigmax * randn(1, N);
X(2,:) = X(2,:) + VelocityMotionModel.Sigmay * randn(1, N);
X(3,:) = X(3,:) + VelocityMotionModel.SigmaVx * randn(1, N);
X(4,:) = X(4,:) + VelocityMotionModel.SigmaVy * randn(1, N);
param.param(1:2,:)=X(1:2,:);
randMatrix = randn(4,n);
param.param(3:6,:) = param.param0(3:6,:) + randMatrix.*repmat(opt.affsig(3:6)',[1,n]);
if isempty(param1)==0 %&& isempty(Trobject.X1)==0
    N1=size(param1.param,2);
    Trobject.X1=[];
    Trobject.X1(1:2,:)=param1.param(1:2,:);
    Trobject.X1(3,:)=mean(X(3,:))+VelocityMotionModel.SigmaVx * randn(1, N1);
    Trobject.X1(4,:)=mean(X(4,:))+VelocityMotionModel.SigmaVy * randn(1, N1);
end
Trobject.X=X;
end