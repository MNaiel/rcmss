function VOCsavedet(PASopts,DET,expt)

path=[PASopts.resultsdir 'VOCdet_' expt '_' DET.label '_' DET.subset '.txt'];
fid=fopen(path,'w');
if ~fid
    error('error creating DET file %s',path);
end

fprintf(fid,'# PASCAL VOC DET Version 1.00\n\n');
fprintf(fid,'VOC label : "%s"\n', DET.label);
fprintf(fid,'VOC subset : "%s"\n', DET.subset);
fprintf(fid,'DET [fp mr] : %d\n', length(DET.fp));
fprintf(fid,'%g %g\n',[DET.fp(:) DET.mr(:)]');

fclose(fid);
