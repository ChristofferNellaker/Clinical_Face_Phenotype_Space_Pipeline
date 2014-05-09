% used to create .jpeg file
%--------------------------------------------------------------------------
if isdeployed
else
    addpath('/net/isi-backup/restricted/face/AAM_2013/functions');
end

fileID = fopen('varin_image_path.txt','r');
varin_1 = fgets(fileID); % path to the image
cellStirng = breakString(varin_1,'*');
varin_1 = cellStirng{1};

fileID = fopen('varout_image_path.txt','r');
varout_1 = fgets(fileID);
cellStirng = breakString(varout_1,'*');
varout_1 = cellStirng{1};
fclose(fileID);

imwrite(imread(varin_1), varout_1);

if isdeployed
    exit;
end