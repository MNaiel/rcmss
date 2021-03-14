function [OutImage,PowerOut]=ImageTransformTrack(InImage,Flag,m,n,CLIP,BlockSize,padsize,PowerFlag,AdjustCoefficients)
%pads the matrix InImage with 0's to size m-by-n before transforming. If m or n
%is smaller than the corresponding dimension of A, dct2 truncates A.
% Flag ==1 DCT2 all image without block processing
% Flag ==2 DCT2 all image with block processing + LPF of size CLIP
% Flag ==3 DFT2 all image with block processing + LPF of size CLIP
% Flag ==5 N/A Spatial Domain
% Flag ==6 DFT keep high frequency component

if nargin < 2
    Flag=0;%EnableImageTransform
    
end
if nargin < 3
    m=size(InImage,1);
    n=size(InImage,2);
end
if nargin < 7
    padsize=[0 0 ];
end
if nargin < 8
    PowerFlag=0;
end
if nargin < 9
AdjustCoefficients=0;
end
PowerOut=0;
if Flag==1
%     ImageTransform1=dct2(double(InImage),m,n);
    ImageTransform1=dct2(InImage);
    if nargin <5
        OutImage=ImageTransform1;
    else
        OutImage=ImageTransform1(1:CLIP,1:CLIP);
    end
elseif Flag==2 %use block DCT
    I=double(InImage);
    %     BlockSize=8;
    T = dctmtx(BlockSize);
    compression=1;
    if compression==1
        Imatrix= eye(CLIP,BlockSize);
%         y=@(x)Imatrix*x*Imatrix';
        %         OutImage = blkproc(B,[BlockSize BlockSize],y);
        if padsize(1,1)==0
        dct = @(x)Imatrix*T * x * T'*Imatrix';
        else
%             dct = @(x)Imatrix*T * padarray(x, padsize,'post') * T'*Imatrix';
dct = @(x)Imatrix*T * upsample(upsample(x,BlockSize/(BlockSize-padsize(1)))',BlockSize/(BlockSize-padsize(2)))' * T'*Imatrix';
            
        end
        % padsize=[BlockSize-]
        %         dct = @(x)T *padarray(x, padsize)* T';
        OutImage = blkproc(I,[BlockSize-padsize(1) BlockSize-padsize(2)],dct);%Compute DCT2

        if PowerFlag==1
        dctTotal = @(x)T * x * T';
        OutImageTotal = blkproc(I,[BlockSize BlockSize],dctTotal);%Compute DCT2
%         Power1=sum(sum(OutImage.^2))/(size(OutImage,1)*size(OutImage,2));
%         PowerTotal=sum(sum(OutImageTotal.^2))/(size(OutImageTotal,1)*size(OutImageTotal,2));
                Power1=sum(sum(OutImage.^2));
        PowerTotal=sum(sum(OutImageTotal.^2));
        PowerOut=Power1/PowerTotal*100;
        end
    else
        dct = @(x)T * x * T';
        OutImage = blkproc(I,[BlockSize BlockSize],dct);%Compute DCT2
        mask=MaskType(compression,BlockSize);
        y=@(x)mask.* x;
        OutImage = blkproc(OutImage,[BlockSize BlockSize],y);
    end
elseif Flag==3 %use block DFT
    I=double(InImage);
    %     BlockSize=8;
    T = dftmtx(BlockSize);
    dft = @ (x) (abs(T * x * T'));
    %                 dft = @(x) (abs(fft2(x)));
    
    % padsize=[BlockSize-]
    %         dct = @(x)T *padarray(x, padsize)* T';
    
    compression=1;
    B = (blkproc(I,[BlockSize BlockSize],dft));%Compute DCT2
    
    if compression==1
        
             s1=min(CLIP/2,BlockSize);s2=abs(CLIP/2-BlockSize);
            Imatrix1= [eye(s1,s1),zeros(s1,s2)];
            Imatrix2= [zeros(s1,s2),eye(s1,s1)];
            Imatrix3=Imatrix1';Imatrix4= Imatrix2';
            
%             Imatrix1= eye(m1/2,size(OutImage,1));Imatrix2= fliplr(Imatrix1);
%             Imatrix3=Imatrix1';Imatrix4= Imatrix2';
            y=@(x) cat(1,cat(2,[Imatrix1*x*Imatrix3],[Imatrix1*x*Imatrix4]),cat(2,[Imatrix2*x*Imatrix3],[Imatrix2*x*Imatrix4]));
            
%         Imatrix1= eye(CLIP/2,BlockSize);Imatrix2= fliplr(Imatrix1);
%         Imatrix3=Imatrix1';Imatrix4= Imatrix2';
%         y=@(x) cat(1,cat(2,[Imatrix1*x*Imatrix3],[Imatrix2*x*Imatrix3]),cat(2,[Imatrix1*x*Imatrix4],[Imatrix2*x*Imatrix4]));
        OutImage = blkproc(B,[BlockSize BlockSize],y);
    elseif compression==0
        OutImage=B;
    else
        mask=MaskType(compression,BlockSize);
        y=@(x)mask.* x;
        OutImage = blkproc(B,[BlockSize BlockSize],y);
    end
elseif Flag==4 %use block DFT
    I=double(InImage);
    T = dftmtx(BlockSize);
    
    OutImage=abs(T * I* T');
    %    OutImage=abs(fft2(I));
    
elseif Flag==6 %use block DFT
    I=double(InImage);
    %     BlockSize=8;
    T = dftmtx(BlockSize);
    dft = @ (x) (abs(T * x * T'));
    %                 dft = @(x) (abs(fft2(x)));
    
    % padsize=[BlockSize-]
    %         dct = @(x)T *padarray(x, padsize)* T';
    
    compression=1;
    B = (blkproc(I,[BlockSize BlockSize],dft));%Compute DCT2
%         figure;
%         ShiftTR=0;
%     if ShiftTR==1
%         ImageShifted=fftshift(B);
%     else
%         ImageShifted=(B);
%     end
%     subplot(2,1,1);imshow(ImageShifted,[]);
%     %     figure;
%     S2=log(1+abs(ImageShifted));
%     subplot(2,1,2);imshow(S2,[]);
    if compression==1
        
        s1=min(CLIP/2,BlockSize);s2=abs(CLIP/2-BlockSize);
        Imatrix1= [eye(s1,s1),zeros(s1,s2)];
        Imatrix2= [zeros(s1,s2),eye(s1,s1)];
        Imatrix3=Imatrix1';Imatrix4= Imatrix2';
        cR=BlockSize/2;cC=BlockSize/2;
        Start=cR-CLIP/2+1;
        Final=cR+CLIP/2;
        
        
        %             Imatrix1= eye(m1/2,size(OutImage,1));Imatrix2= fliplr(Imatrix1);
        %             Imatrix3=Imatrix1';Imatrix4= Imatrix2';
%         y=@(x) cat(1,cat(2,[Imatrix1*x*Imatrix3],[Imatrix1*x*Imatrix4]),cat(2,[Imatrix2*x*Imatrix3],[Imatrix2*x*Imatrix4]));
        y=@(x) x(Start:Final,Start:Final);

        
        %         Imatrix1= eye(CLIP/2,BlockSize);Imatrix2= fliplr(Imatrix1);
        %         Imatrix3=Imatrix1';Imatrix4= Imatrix2';
        %         y=@(x) cat(1,cat(2,[Imatrix1*x*Imatrix3],[Imatrix2*x*Imatrix3]),cat(2,[Imatrix1*x*Imatrix4],[Imatrix2*x*Imatrix4]));
        OutImage = blkproc(B,[BlockSize BlockSize],y);
%                 figure;
%         ShiftTR=0;
%     if ShiftTR==1
%         ImageShifted=fftshift(OutImage);
%     else
%         ImageShifted=(OutImage);
%     end
%     subplot(2,1,1);imshow(ImageShifted,[]);
%     %     figure;
%     S2=log(1+abs(ImageShifted));
%     subplot(2,1,2);imshow(S2,[])
    elseif compression==0
        OutImage=B;
    else
        mask=MaskType(compression,BlockSize);
        y=@(x)mask.* x;
        OutImage = blkproc(B,[BlockSize BlockSize],y);
    end
elseif Flag==7 %use block DCT with Overlap
    I=double(InImage);
    %     BlockSize=8;
    T = dctmtx(BlockSize);
    compression=1;
    if compression==1
        Imatrix= eye(CLIP,BlockSize);
%         y=@(x)Imatrix*x*Imatrix';
        %         OutImage = blkproc(B,[BlockSize BlockSize],y);
        if padsize(1,1)==0
        dct = @(x)Imatrix*T * x * T'*Imatrix';
        else
%             dct = @(x)Imatrix*T * padarray(x, padsize,'post') * T'*Imatrix';
dct = @(x)Imatrix*T * upsample(upsample(x,BlockSize/(BlockSize-padsize(1)))',BlockSize/(BlockSize-padsize(2)))' * T'*Imatrix';
            
        end
        % padsize=[BlockSize-]
        %         dct = @(x)T *padarray(x, padsize)* T';
        OutImage = blkproc(I,[BlockSize-padsize(1) BlockSize-padsize(2)],dct);%Compute DCT2

        if PowerFlag==1
        dctTotal = @(x)T * x * T';
        OutImageTotal = blkproc(I,[BlockSize BlockSize],dctTotal);%Compute DCT2
%         Power1=sum(sum(OutImage.^2))/(size(OutImage,1)*size(OutImage,2));
%         PowerTotal=sum(sum(OutImageTotal.^2))/(size(OutImageTotal,1)*size(OutImageTotal,2));
                Power1=sum(sum(OutImage.^2));
        PowerTotal=sum(sum(OutImageTotal.^2));
        PowerOut=Power1/PowerTotal*100;
        end
    else
        dct = @(x)T * x * T';
        OutImage = blkproc(I,[BlockSize BlockSize],dct);%Compute DCT2
        mask=MaskType(compression,BlockSize);
        y=@(x)mask.* x;
        OutImage = blkproc(OutImage,[BlockSize BlockSize],y);
    end
else
    OutImage=double(InImage);
    
end
if AdjustCoefficients==1
    low_out=0.1; high_out=1;
    OutImage = imadjust(OutImage,[;],[low_out; high_out]);
end
end

function mask=MaskType(compression,BlockSize)
if compression==1
    if BlockSize==8
        mask = [1   1   1   1   0   0   0   0
            1   1   1   0   0   0   0   0
            1   1   0   0   0   0   0   0
            1   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0];
    elseif BlockSize==4
        mask = [1   1   1   1
            1   1   1   0
            1   1   0   0
            1   0   0   0 ];
        
    end
else
    mask=ones(BlockSize,BlockSize);
end
end