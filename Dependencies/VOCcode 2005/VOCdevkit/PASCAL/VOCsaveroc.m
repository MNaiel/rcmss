function VOCsaveroc(PASopts,roc,expt)

path=[PASopts.resultsdir 'VOCroc_' expt '_' roc.label '_' roc.subset '.txt'];
fid=fopen(path,'w');
if ~fid
    error('error creating ROC file %s',path);
end

fprintf(fid,'# PASCAL VOC ROC Version 1.00\n\n');
fprintf(fid,'VOC label : "%s"\n', roc.label);
fprintf(fid,'VOC subset : "%s"\n', roc.subset);
fprintf(fid,'confidence : %d\n', length(roc.confidence));
fprintf(fid,'%g\n',roc.confidence);
fprintf(fid,'ROC [FP TP] : %d\n', length(roc.fp));
fprintf(fid,'%g %g\n',[roc.fp(:) roc.tp(:)]');

fclose(fid);
