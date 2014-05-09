clear opts;

fileID = fopen('varin_3.txt','r'); % image full path
varin_3 = fgets(fileID);
fclose(fileID);

%varin_3 = '/net/isi-backup/restricted/face/FACEDETECT/CLASS_facepipe_VJ_29-Sep-08b/facefeats/model.mat';

if isdeployed
else
cwd=cd;
cwd(cwd=='\')='/';
addpath([cwd '/utils']);
addpath([cwd '/facedet']);
addpath([cwd '/facefeats']);
addpath([cwd '/descriptor']);
end

%opts=load('facefeats/model.mat','model');
%opts=load('/net/isi-backup/restricted/face/FACEDETECT/CLASS_facepipe_VJ_29-Sep-08b/facefeats/model.mat','model');
opts=load(varin_3,'model');

opts.desc.Pmu=[25.0347   34.1802   44.1943   53.4623   34.1208   39.3564   44.9156   31.1454   47.8747 ;
               34.1580   34.1659   34.0936   33.8063   45.4179   47.0043   45.3628   53.0275   52.7999];
opts.desc.VP=[1 0 ; 2 0 ; 3 0 ; 4 0 ; 5 0 ; 6 0 ; 7 0 ; 8 0 ; 9 0 ; 1 2 ; 3 4 ; 2 3 ; 8 9]';
opts.desc.scl=0.5;
opts.desc.r=14;

