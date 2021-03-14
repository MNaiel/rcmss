function [VInitialx VInitialy FrameInWindow]=ComputeVelocity(Trobject,VelocityMotionModel)
if VelocityMotionModel.USeInstantVelocity==1
    [VInitialx VInitialy FrameInWindow]=ComputeInstantVelocity(Trobject,VelocityMotionModel.Window);
else
    StartValue=Trobject.StartFrame;
    FrameInWindow=convertlowFormattoCenter(Trobject.BBresult(:,StartValue:StartValue+VelocityMotionModel.Window));%previous-1 Center
    VInitialx=mean(diff(FrameInWindow(1,:)));
    VInitialy=mean(diff(FrameInWindow(2,:)));
end