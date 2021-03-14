function [bbs,BadIndex]=FilterDetectionsGeometric(bbs,DatasetInfo,DetectorObj,Gti,Im)
% bbs: in Dollar Format
%  Gti=gt{INdex}(:,2:end);
%%
[ms1,ms2,ms3]=size(Im);
BadIndex=[];
switch (DatasetInfo.DatasetName)
    case 'soccer_ICIP08';
        %% filter detections less than min row of Ground truth files
        if size(bbs,1)>1
            MinRowGT=min(Gti(:,2));MinColGT=min(Gti(:,1));MaxRowGT=max(Gti(:,4));MaxColGT=max(Gti(:,3));
            newbbs=convertDollarToLowFormat(bbs)';%clow; rlow;
            BadIndex=(newbbs(:,4)<MinRowGT);
            bbs(BadIndex,:)=[];
        end
    case 'TownCentre'
        if DetectorObj.FilterDetectionsGeo  ==1
            if size(bbs,1)>1 % remove left part in the scene
                xv=[53 404];
                yv=[373 233];
                av=(yv(1)-yv(2))/(xv(1)-xv(2));
                bv=-1*av*xv(1)+yv(1);
                yl = @(xl) av*xl+bv;                
                newbbs=convertDollarToLowFormat(bbs)';%clow; rlow;
                clow=newbbs(:,1); rlow=newbbs(:,2);
                BadIndex=((yl(clow)-rlow)>0 & clow <=426);
                bbs(BadIndex,:)=[];
            end
        elseif DetectorObj.FilterDetectionsGeo ==2
            if size(bbs,1)>1 % remove detections outside the scene                
                newbbs=convertDollarToLowFormat(bbs)';%clow; rlow;
                BadIndex=newbbs(:,1) <5 | newbbs(:,3) >ms2-5 | newbbs(:,2) <5  | newbbs(:,4) >ms1-5;
                bbs(BadIndex,:)=[];
            end
        end
    case 'UCFParkinglot'
        if DetectorObj.FilterDetectionsGeo ==2
            if size(bbs,1)>1 % remove detections outside the scene
                newbbs=convertDollarToLowFormat(bbs)';%clow; rlow;
                BadIndex=newbbs(:,1) <10 | newbbs(:,3) >ms2-10 | newbbs(:,2) <10  | newbbs(:,4) >ms1-10;
                bbs(BadIndex,:)=[];
            end
        end
    case 'PETS2009';
        if DetectorObj.FilterDetectionsGeo ==2
            if size(bbs,1)>1 % remove detections outside the scene
                newbbs=convertDollarToLowFormat(bbs)';%clow; rlow;
                BadIndex=newbbs(:,1) <2 | newbbs(:,3) >ms2-2 | newbbs(:,2) <2  | newbbs(:,4) >ms1-2;
                bbs(BadIndex,:)=[];
            end
        end
    otherwise
end
end