function VOCsavepr(PASopts,pr,expt)

path=[PASopts.resultsdir 'VOCpr_' expt '_' pr.label '_' pr.subset '.txt'];
fid=fopen(path,'w');
if ~fid
    error('error creating precision/recall file %s',path);
end

fprintf(fid,'# PASCAL VOC precision/recall Version 1.00\n\n');
fprintf(fid,'VOC label : "%s"\n', pr.label);
fprintf(fid,'VOC subset : "%s"\n', pr.subset);
fprintf(fid,'PR [recall precision] : %d\n', length(pr.recall));
fprintf(fid,'%g %g\n',[pr.recall(:) pr.precision(:)]');

fclose(fid);
