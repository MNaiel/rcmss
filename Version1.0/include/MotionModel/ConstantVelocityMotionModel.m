function [wimgs Y param]=ConstantVelocityMotionModel(ImgIn,sz, opt, param,Trobject,f,VelocityMotionModel)
%Input
% ImgIn   : Input image
% sz      : Template size
% f       : current frame number
% opt     : options to sample particles state
% param   : last parameter state at time t-1
% Trobject: Tracker object
%Output
% wimgs    : samples in volume format
% Y        : corresponding in a matrix format 
% param    : proposed states to compute the likelihood
%%
show=0;
n = opt.numsample;                  % Sampling Number
param.param0 = zeros(6,n);          % Affine Parameter Sampling
param.param = zeros(6,n);
param.param0 = repmat(affparam2geom(param.est(:)), [1,n]);
randMatrix = randn(6,n);
param.param = param.param0 + randMatrix.*repmat(opt.affsig(:),[1,n]);
if f>2
    PrevCenter=convertlowFormattoCenter(Trobject.BBresult(:,f-2));%previous-1 Center
    CurrentCenter=convertlowFormattoCenter(Trobject.BBresult(:,f-1));%previous Center        
    if PrevCenter~=0
        StartValue=Trobject.StartFrame;
        Window=VelocityMotionModel.Window;        
        Sigmax= VelocityMotionModel.Sigmax*randn(1,n);
        Sigmay= VelocityMotionModel.Sigmay*randn(1,n);
        SigmaVx= VelocityMotionModel.SigmaVx*randn(1,n);        
        if f-StartValue>Window+2
            FrameInWindow=convertlowFormattoCenter(Trobject.BBresult(:,StartValue:StartValue+Window));%previous-1 Center
            VInitialx=mean(diff(FrameInWindow(1,:)));
            VInitialy=mean(diff(FrameInWindow(2,:)));
            if VelocityMotionModel.UseMarkov==1 % current and initial
                Vx=repmat(mean([diff([PrevCenter(1) CurrentCenter(1)]),VInitialx]), [1,n])+SigmaVx;%./diff(t(1:WindowSize));
            elseif VelocityMotionModel.UseMarkov==2
                Vx=repmat(diff([PrevCenter(1) CurrentCenter(1)]), [1,n])+SigmaVx;%./diff(t(1:WindowSize));
            elseif VelocityMotionModel.UseMarkov==3
                Vx=repmat(VInitialx, [1,n])+SigmaVx;%./diff(t(1:WindowSize));                
            elseif VelocityMotionModel.UseMarkov==5
                if isempty(Trobject.OcclusionFrames)==0 && length(Trobject.OcclusionFrames)>2
                    OcclusionID=Trobject.OcclusionFrames;
                    ConnectedSegments=logical(diff(OcclusionID)==1);
                    ConnectedComponents=bwconncomp(ConnectedSegments);
                    NumberofComponents=1;
                    VBeforeOcclusionx=0;VBeforeOcclusiony=0;
                    for loopKey=[1:NumberofComponents]
                        CurrentKeyIndex=ConnectedComponents.PixelIdxList{loopKey};
                        LastKeyFrame=max(OcclusionID(CurrentKeyIndex));
                        EndValue=min(OcclusionID(CurrentKeyIndex))-1;%start and end of occlusion
                        if   loopKey==1
                            StartValue=EndValue-Window;
                        else
                            LastKeyIndex=ConnectedComponents.PixelIdxList{loopKey-1};
                            StartValue=max(OcclusionID(LastKeyIndex));
                        end
                        FrameInWindow=convertlowFormattoCenter(Trobject.BBresult(:,StartValue:EndValue));%previous-1 Center
                        VBeforeOcclusionx=VBeforeOcclusionx+mean(diff(FrameInWindow(1,:)));
                        VBeforeOcclusiony=VBeforeOcclusiony+mean(diff(FrameInWindow(2,:)));
                    end
                    if NumberofComponents~=0
                        VBeforeOcclusionx=VBeforeOcclusionx./NumberofComponents;
                        VBeforeOcclusiony=VBeforeOcclusiony./NumberofComponents;
                    end
                    Vx=repmat([0.5*VBeforeOcclusionx+0.5*VInitialx], [1,n])+SigmaVx;%./diff(t(1:WindowSize));
                else
                    Vx=repmat(VInitialx, [1,n])+SigmaVx;%./diff(t(1:WindowSize));                    
                end
            elseif VelocityMotionModel.UseMarkov==4 %use Kalman Filter
                VCurrentvx=diff([PrevCenter(1) CurrentCenter(1)]);
                VCurrentvy=diff([PrevCenter(2) CurrentCenter(2)]);                
                ss = 4; % state size
                os = 2; % observation size
                F = [1 0 1 0; 0 1 0 1; 0 0 1 0; 0 0 0 1];
                H = [1 0 0 0; 0 1 0 0];
                Q = 0.5*eye(ss);
                R = 1*eye(os);
                if Trobject.InOcclusion==0
                    initx = [CurrentCenter(1) CurrentCenter(2) mean([VCurrentvx VInitialx]) mean([VCurrentvy VInitialy])]';
                else                    
                    initx = [CurrentCenter(1) CurrentCenter(2) (0.25*VCurrentvx+ 0.75*VInitialx) (0.25*VCurrentvy+ 0.75*VInitialy)]';
                end
                initV = 10*eye(ss);                
                T = 2;
                [x,y] = sample_lds(F, H, Q, R, initx, T);
                [xfilt, Vfilt, VVfilt, loglik] = kalman_filter(y, F, H, Q, R, initx, initV);
                CandidateCenters =repmat([xfilt(1,2) xfilt(2,2)]', [1,n])  + [Sigmax; Sigmay ];                
            end
            if VelocityMotionModel.UseMarkov~=4                
                Dispx=Vx+Sigmax;
                Dispy=Sigmay;
                CandidateCenters =repmat(CurrentCenter, [1,n])  + [Dispx; Dispy ];
            end
        else
            Vx=repmat(diff([PrevCenter(1) CurrentCenter(1)]), [1,n])+SigmaVx;%./diff(t(1:WindowSize));
            Dispx=Vx+Sigmax;
            Dispy=Sigmay;
            CandidateCenters =repmat(CurrentCenter, [1,n])  + [Dispx; Dispy ];
        end        
        param.param0(1:2,:)=CandidateCenters;
        param.param=param.param0;
    end
end
o = affparam2mat(param.param);      % Extract or Warp Samples which are related to above affine parameters
if show==1
    SHOWBBonImage(uint8(ImgIn),Trobject.BBresult(:,f-1));
    hold_was_on = ishold; hold on;
    SizePoint=3;
    scatter(CandidateCenters(1,:)',CandidateCenters(2,:)',SizePoint,[0 0 1],'filled');
    hold off;
end
[wimgs wimgsColor o BadExample]= warpimgFunction(ImgIn, o, sz,opt);
param.param(:,BadExample)=[];
param.param0(:,BadExample) =[];
n=size(o,2);
Y= ConcatenateWarpImage(wimgsColor,opt,n);