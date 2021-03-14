function AllFilrecord=TUDreadrecord(filename)
[fd,syserrmsg]=fopen(filename,'rt');
if (fd==-1),
    PASmsg=sprintf('Could not open %s for reading',filename);
    PASerrmsg(PASmsg,syserrmsg);
end;
matchstrs=initstrings;
record=PASemptyrecord;
FileRecordNumber=0;
notEOF=1;
while (notEOF),
    FileRecordNumber=FileRecordNumber+1;
    line=fgetl(fd);
    notEOF=ischar(line);
    tmp=findstr(line,':');
    NumObjects=length(tmp);
    tmpStart=findstr(line,'(');
    tmpEnd=findstr(line,')');
    for i=1:NumObjects
        iend=tmp(i)-1;
        if i==1
            istart=1;
        else
            istart=tmpStart(i-1);
            iend=tmpEnd(i-1);
        end
        if (notEOF),
            matchnum=match(line(istart:iend),matchstrs);
            switch matchnum,
                case 1, [imgname]=strread(line(istart:iend),matchstrs(matchnum).str);
                    record.imgname=char(imgname);
                case 2, [xmin,ymin,xmax,ymax]=strread(line(istart:iend),matchstrs(matchnum).str);
                    obj=i-1;
                    record.objects(obj).bbox=[min(xmin,xmax),min(ymin,ymax),max(xmin,xmax),max(ymin,ymax)];
                case 3, [database]=strread(line,matchstrs(matchnum).str);
                    record.database=char(database);
                case 4, [obj,lbl,xmin,ymin,xmax,ymax]=strread(line(istart:iend),matchstrs(2).str);
                    record.objects(obj).label=char(lbl);
                    record.objects(obj).bbox=[min(xmin,xmax),min(ymin,ymax),max(xmin,xmax),max(ymin,ymax)];
                case 5, tmp=findstr(line,' : ');
                    [obj,lbl]=strread(line(1:tmp),matchstrs(matchnum).str);
                    record.objects(obj).label=char(lbl);
                    record.objects(obj).polygon=sscanf(line(tmp+3:end),'(%d, %d) ')';
                case 6, [obj,lbl,mask]=strread(line,matchstrs(matchnum).str);
                    record.objects(obj).label=char(lbl);
                    record.objects(obj).mask=char(mask);
                case 7, [obj,lbl,orglbl]=strread(line,matchstrs(matchnum).str);
                    record.objects(obj).label=char(lbl);
                    record.objects(obj).orglabel=char(orglbl);
                otherwise, %fprintf('Skipping: %s\n',line);
            end;
        end;
    end
    AllFilrecord.record(FileRecordNumber)=record;
    record=PASemptyrecord;
end;

fclose(fd);
return

function matchnum=match(line,matchstrs)
for i=1:length(matchstrs),
    matched(i)=strncmp(line,matchstrs(i).str,matchstrs(i).matchlen);
end;
matchnum=find(matched);
if isempty(matchnum), matchnum=0; end;
if (length(matchnum)~=1),
    PASerrmsg('Multiple matches while parsing','');
end;
return

function s=initstrings
s(1).matchlen=16;
s(1).str='"DaSide0811-seq6- %q .png';

s(2).matchlen=1;
s(2).str='(%d, %d, %d, %d)';

s(3).matchlen=8;
s(3).str='Database : %q';

s(4).matchlen=8;
s(4).str='Bounding box for object %d %q (Xmin, Ymin) - (Xmax, Ymax) : (%d, %d) - (%d, %d)';

s(5).matchlen=7;
s(5).str='Polygon for object %d %q (X, Y)';

s(6).matchlen=5;
s(6).str='Pixel mask for object %d %q : %q';

s(7).matchlen=8;
s(7).str='Original label for object %d %q : %q';
return