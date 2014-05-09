function DETS = runfacedet(I,imgpath)

fileID = fopen('varin_2.txt','r'); % image full path
varin_2 = fgets(fileID);
fclose(fileID);

tmppath=tempname;
pgmpath=[tmppath '.pgm'];

if nargin<2
    detpath=[tmppath '.vj'];
else
    detpath=[imgpath '.vj'];
end

imwrite(I,pgmpath);

%root=[fileparts(which(mfilename)) '/OpenCV_ViolaJones']
%root = '/net/isi-backup/restricted/face/FACEDETECT/CLASS_facepipe_VJ_29-Sep-08b/facedet/OpenCV_ViolaJones';
root = varin_2;
system(sprintf('%s/Release/OpenCV_ViolaJones %s/haarcascade_frontalface_alt.xml %s %s',root,root,pgmpath,detpath),'-echo');
%root=[fileparts(which(mfilename)) '/OpenCV_ViolaJones'];
%system(sprintf('%s/Release/OpenCV_ViolaJones %s/haarcascade_frontalface_alt.xml %s %s',root,root,pgmpath,detpath),'-echo');


DETS=readfacedets(detpath);
delete(pgmpath);
if nargin<2
    delete(detpath);
end

