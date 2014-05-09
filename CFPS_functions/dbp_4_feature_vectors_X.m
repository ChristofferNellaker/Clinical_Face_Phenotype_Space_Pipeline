%----------------------------------------------------------------------
%  dbp_4_feature_vectors_X
%  written 140203 by ChrisN 
%  Refactoring original MASTERSCRIPT_CREATE_CLASSES_extract_2 to work with
%  SQLite3 database version.
%  Aim to store feature vectors in the database BLOB format
% this version is compatible with the output of PIPELINE_201306
%----------------------------------------------------------------------

if isdeployed()
    init2; %uses varin_3 %ERROR SCALE VAR DIFFERENT
    vgg_startup;
else
    addpath('/net/isi-backup/restricted/face/AAM_2013/functions');
    addpath('/net/isi-software/tools/matlab_extools/serialize/');
    addpath('/net/isi-software/tools/matlab_extools/matlab-sqlite3-driver/');
    path0 = pwd;
    %cd(folderPath);
    here = pwd;
    cd('/net/isi-backup/restricted/face/FACEDETECT/CLASS_facepipe_VJ_29-Sep-08b/');
    init; %WAS PREVIOUSLY init
    cd('/net/isi-backup/restricted/face/vgg_matlab/');
    vgg_startup;
    cd(here);
end

opts.desc.scl = 1;
opts.desc.r = 7;
%init;
%vgg_startup;


%//////////////////////////////////////////////////////////////////////////
% image path
fileID = fopen('varin_image_path.txt','r');
varin_1 = fgets(fileID);
fclose(fileID);
cellStirng = breakString(varin_1,'*');
varin_1 = cellStirng{1};

%model load
if isdeployed
    fileID = fopen('varin_2.txt','r');
    varin_2 = fgets(fileID);
    fclose(fileID);
    cellStirng = breakString(varin_2,'*');
    varin_2 = cellStirng{1};
    load(varin_2);
else
    load('/net/isi-backup/restricted/face/AAM_2013/models/ShapeModel.mat');
end

    
% get the full path of the image:
cellString = breakString(varin_1,'/');
image_path = cellString{1};
for i=2:numel(cellString)-1
    image_path = [image_path '/' cellString{i}];
end
image_path = [image_path '/'];
image_name = cellString{end};
image_path_name = varin_1;

%//////////////////////////////////////////////////////////////////////////

fileID = fopen('var_database.txt','r');
var_database = fgets(fileID); % path to the image
cellStirng = breakString(var_database,'*');
var_database = cellStirng{1};

table1 = 'processing';
table2 = 'meta';

sqlite3.open(var_database);

% look for the row and if the fland exist
%record = sqlite3.execute('SELECT * FROM processing WHERE image_path = ? AND image_name = ?',image_path,image_name);


while true; try; 
        record = sqlite3.execute('SELECT * FROM processing WHERE image_path_name = ?',image_path_name); 
        break; catch;pause(0.5); end; end;

%//////////////////////////////////////////////////////////////////////////

Xtot = []; %will contain the canonical form of the points
X9 = [];
XREG = [];
Images = {}; %will contain the path of each image
cmpImage = 0;

% HACK FOR DEV
record.boolean_badfit = 0;
old_app_int = 0;
appFeature_intensity = 0;

if record.boolean_belhumeur==0 | record.boolean_badfit == 1
    while ~db_mutex('on', var_database); end
    while true; try; sqlite3.execute('UPDATE processing SET boolean_success = 0 WHERE image_path_name = ?', image_path_name); break; catch;pause(0.5); end; end;
    sqlite3.close()
    db_mutex('off', var_database);
else

    Xtot = deserialize(record.belhumeur); %single image belhum
    X9 = deserialize(record.fland);%p_double; % single image fland

    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    % COMPUTE SHAPE & SHAPE
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    
    SHAPE = [];
    APP = [];
    SHAPE9 = [];
    APP9 = [];
    
    X = cano2Points(Xtot);
    
    
    [d,Xp,transform] = procrustes(S0,X);
    shapeFeature = pdist(Xp,'euclidean')./pdist(S0,'euclidean');
    SHAPE = [SHAPE;shapeFeature];

    % appearance features
    P = X([9,11,13,15,19,21,23,24,28],:);
    P = P';
    PTS=zeros(0,0,1);
    PTS(1:size(P,1),1:size(P,2),1)=P;
    I = imread(varin_1);

    appFeature_intensity=extdesc(opts.desc,I,PTS(:,:,1),false);
    appFeature_gradient=extdescdxdy(opts.desc,I,PTS(:,:,1),false,false, false);

    %------------------------------------------------------------------

    x9 = cano2Points(X9); 
    s0 = S0([9,11,13,15,19,21,23,24,28],:);
    [d,Xp,transform] = procrustes(s0,x9);
    shapeFeature = pdist(Xp,'euclidean')./pdist(s0,'euclidean');
    SHAPE9 = [SHAPE9;shapeFeature];

    % appearance features
    P = x9;
    P = P';
    PTS=zeros(0,0,1);
    PTS(1:size(P,1),1:size(P,2),1)=P;

    appFeature_9_intensity=extdesc(opts.desc,I,PTS(:,:,1),false);
    appFeature_9_gradient=extdescdxdy(opts.desc,I,PTS(:,:,1),false,false, false);
    
    %----------------------------------------------------------------------
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % DEV HACK
    %record.processing_id = 1;
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    SHAPE9 = serialize(SHAPE9);
    appFeature_9_intensity = serialize(appFeature_9_intensity'); % Orientation change
    appFeature_9_gradient = serialize(appFeature_9_gradient');
    SHAPE = serialize(SHAPE);
    old_app_int = appFeature_intensity';
    appFeature_intensity = serialize(appFeature_intensity');
    appFeature_gradient = serialize(appFeature_gradient');
    
    
    while ~db_mutex('on', var_database); end
    
    while true; try; record_features = sqlite3.execute('SELECT * FROM features WHERE processing_id = ?', record.processing_id); break; catch;pause(0.5); end; end;   
    
    if isempty(record_features)
        new_insert_str = 'INSERT INTO features (processing_id,shape_9,appearance_9_intensity, appearance_9_gradient, shape, appearance_intensity, appearance_gradient) VALUES (?, ?, ?, ?, ?, ?, ?)';
        while true; try; sqlite3.execute(new_insert_str,record.processing_id, SHAPE9, appFeature_9_intensity,appFeature_9_gradient, SHAPE, appFeature_intensity,appFeature_gradient); break; catch;pause(0.5); end; end;
        %sqlite3.execute(new_insert_str,record.processing_id, SHAPE9, appFeature_9_intensity,appFeature_9_gradient, SHAPE, appFeature_intensity,appFeature_gradient)
        %         while true; try; sqlite3.execute(['INSERT INTO features ('...
        %                             'processing_id,shape_9,appearance_9_intensity, appearance_9_gradient, shape, appearance_intensity, appearance_gradient)'...
        %                             ' VALUES (?, ?, ?, ?, ?, ?, ?)'],...
        %                             record.processing_id, SHAPE9, appFeature_9_intensity,appFeature_9_gradient, SHAPE, appFeature_intensity,appFeature_gradient);...  
        %                 break; catch;pause(0.5); end; end;
    else
        %fprintf('Already existing in the table...UPDATED\n');
        update_str = 'UPDATE features SET shape_9=?,appearance_9_intensity=?,appearance_9_gradient=?, shape=?, appearance_intensity=?, appearance_gradient=? WHERE processing_id = ?';
        while true; try; 
            sqlite3.execute(update_str, SHAPE9, appFeature_9_intensity,appFeature_9_gradient, SHAPE, appFeature_intensity,appFeature_gradient, record.processing_id); 
            break; catch; pause(0.5); end; end;
    end
    

end

sqlite3.close();
db_mutex('off', var_database);

fileID = fopen('varout_1.txt','r');
varout_1 = fgets(fileID); 
cellStirng = breakString(varout_1,'*');
varout_1 = cellStirng{1};

fileID = fopen(varout_1,'w');

fprintf(fileID,'app int %u  %u\n', size(old_app_int));
fprintf(fileID,'app int ser %u  %u\n', size(appFeature_intensity));
%fprintf(fileID,'app int %u  %u\n');
fclose(fileID);


if isdeployed()
    exit;
end

