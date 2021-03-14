 run('D:\PhD\RA\piotr_toolbox_V3.01\AddPitorPaths.m');
 nm='J.png'; I=imread(nm);
prm=struct('imgNm',nm,'modelNm','ChnFtrs01','resize',1,'fast',1);
tic;
bbs=detect(prm);
toc
figure(1);
im(I,[],0);
bbApply('draw',bbs,'g');