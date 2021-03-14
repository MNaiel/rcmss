function record=ReadAnnotationFile(AnnotationFile,Type)
if Type==1
    record=TUDreadrecord(AnnotationFile);
elseif Type==2
    recordIn=readIDL(AnnotationFile);
    record=ConverttoTUDreadrecord(recordIn);
end