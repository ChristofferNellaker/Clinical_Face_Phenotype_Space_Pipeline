
%--------------------------------------------------------------------------
% this function is used to convert feature vectors into FaceSpace vectors.
% Written by Christoffer Nellaker 140205
% adapted from createSuperClassFromPath
%
% HACK AT THE MOMENT ONLY USES INTENSITY - design choice needed separate
% tables or just sep. columns?
%--------------------------------------------------------------------------

if isdeployed
else
    % addpaths
    %--------------------------------------------------------------------------
    addpath('/net/isi-backup/restricted/face/AAM_2013/functions');
    addpath('/net/isi-backup/restricted/face/PIPELINE/pipe_function');
    addpath('/net/isi-backup/restricted/face/PROJECT/functions');
    addpath('/net/isi-backup/restricted/face/PROJECT/functions/clustering');
    addpath('/net/isi-software/tools/matlab_extools/serialize/');
    addpath('/net/isi-software/tools/matlab_extools/matlab-sqlite3-driver/');
    
    %--------------------------------------------------------------------------
end

% load the model
%--------------------------------------------------------------------------
%load(['/net/isi-backup/restricted/face/PROJECT/SIM_DIST_201306/MODELS/MODEL_PCA_LMNN' ext '.mat']);
%--------------------------------------------------------------------------

%model load
fileID = fopen('varin_2.txt','r');
varin_2 = fgets(fileID);
fclose(fileID);
cellStirng = breakString(varin_2,'*');
varin_2 = cellStirng{1};
load(varin_2);

% image path
fileID = fopen('varin_image_path.txt','r');
varin_1 = fgets(fileID);
fclose(fileID);
cellStirng = breakString(varin_1,'*');
varin_1 = cellStirng{1};
image_path_name = varin_1;

fileID = fopen('var_database.txt','r');
var_database = fgets(fileID); % path to the image
cellStirng = breakString(var_database,'*');
var_database = cellStirng{1};

sqlite3.open(var_database);

% look for the row and if the fland exist
%record = sqlite3.execute('SELECT * FROM processing WHERE image_path = ? AND image_name = ?',image_path,image_name);

while true; try; 
        record_processing = sqlite3.execute('SELECT * FROM processing WHERE image_path_name = ?',image_path_name);
        record_features = sqlite3.execute('SELECT * FROM features WHERE processing_id = ?',record_processing.processing_id);
        break; catch;pause(0.5); end; end;

if isempty(record_features)
else
    TR_shape = deserialize(record_features.shape);
    TR_app = deserialize(record_features.appearance_intensity);
    anno = deserialize(record_processing.belhumeur);
    
    % project in PCA shape and appearance
    TR_pca_shape = [];
    for i=1:size(TR_shape,1)
        TR_pca_shape = [TR_pca_shape; projectFromX(TR_shape(i,:),Vs_shape(:,1:n_pca_shape),TRmean_shape)];
    end
    TR_pca_app = [];
    for i=1:size(TR_app,1)
        TR_pca_app = [TR_pca_app; projectFromX(TR_app(i,:),Vs_app(:,1:n_pca_app),TRmean_app)];
    end
    
    %superClass.shape_pca = TR_pca_shape;
    %superClass.app_pca = TR_pca_app;
    
    % project into the face space
    TR_pca_lmnn_shape = TR_pca_shape*L_shape';
    TR_pca_lmnn_app = TR_pca_app*L_app';
    TR_pca_lmnn_fusion = [TR_pca_shape,TR_pca_app]*L_fusion';
    
    %superClass.shape_lmnn = TR_pca_lmnn_shape;
    %superClass.app_lmnn = TR_pca_lmnn_app;
    %superClass.fusion_lmnn = TR_pca_lmnn_fusion;
    
    % project in PCA shape face space and appearance face space
    TR_pca_lmnn_pca_shape = [];
    for i=1:size(TR_pca_lmnn_shape,1)
        TR_pca_lmnn_pca_shape = [TR_pca_lmnn_pca_shape; projectFromX(TR_pca_lmnn_shape(i,:),Vs_shape_lmnn,TRmean_shape_lmnn)];
    end
    
    TR_pca_lmnn_pca_app = [];
    for i=1:size(TR_pca_lmnn_app,1)
        TR_pca_lmnn_pca_app = [TR_pca_lmnn_pca_app; projectFromX(TR_pca_lmnn_app(i,:),Vs_app_lmnn,TRmean_app_lmnn)];
    end
    
    TR_pca_lmnn_pca_fusion = [];
    for i=1:size(TR_pca_lmnn_fusion,1)
        TR_pca_lmnn_pca_fusion = [TR_pca_lmnn_pca_fusion; projectFromX(TR_pca_lmnn_fusion(i,:),Vs_fusion_lmnn,TRmean_fusion_lmnn)];
    end
    
    %superClass.shape_lmnn_pca = TR_pca_lmnn_pca_shape;
    %superClass.app_lmnn_pca = TR_pca_lmnn_pca_app;
    %superClass.fusion_lmnn_pca = TR_pca_lmnn_pca_fusion;
    %superClass.ext = ext;
    
    %save([path ext '_superClass.mat'],'superClass');
    shape_pca = serialize(TR_pca_shape);
    appearance_intensity_pca = serialize(TR_pca_app);
    %appearance_gradient_pca
    shape_pca_lmnn = serialize(TR_pca_lmnn_shape);
    appearance_intensity_pca_lmnn = serialize(TR_pca_lmnn_app);
    %appearance_gradient_pca_lmnn
    fusion_intensity_pca_lmnn = serialize(TR_pca_lmnn_fusion);
    %fusion_gradient_pca_lmnn
    shape_pca_lmnn_pca = serialize(TR_pca_lmnn_pca_shape);
    appearance_intensity_pca_lmnn_pca = serialize(TR_pca_lmnn_pca_app);
    %appearance_gradient_pca_lmnn_pca
    fusion_intensity_pca_lmnn_pca = serialize(TR_pca_lmnn_pca_fusion);
    %fusion_gradient_pca_lmnn_pca
    
    
    while ~db_mutex('on', var_database); end
    
    while true; try; 
            record_FS_features = sqlite3.execute('SELECT * FROM FS_features WHERE processing_id = ?', record_processing.processing_id); 
            break; catch;pause(0.5); end; end;   
    
    if isempty(record_FS_features)
        new_insert_str = 'INSERT INTO FS_features (processing_id, shape_pca, appearance_intensity_pca, shape_pca_lmnn, appearance_intensity_pca_lmnn, fusion_intensity_pca_lmnn, shape_pca_lmnn_pca, appearance_intensity_pca_lmnn_pca, fusion_intensity_pca_lmnn_pca) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)';
        while true; try; sqlite3.execute(new_insert_str,record_processing.processing_id, shape_pca, appearance_intensity_pca, shape_pca_lmnn, appearance_intensity_pca_lmnn, fusion_intensity_pca_lmnn, shape_pca_lmnn_pca, appearance_intensity_pca_lmnn_pca, fusion_intensity_pca_lmnn_pca); break; catch;pause(0.5); end; end;
        
    else
        %fprintf('Already existing in the table...UPDATED\n');
        update_str = 'UPDATE FS_features SET shape_pca=?, appearance_intensity_pca=?, shape_pca_lmnn=?, appearance_intensity_pca_lmnn=?, fusion_intensity_pca_lmnn=?, shape_pca_lmnn_pca=?, appearance_intensity_pca_lmnn_pca=?, fusion_intensity_pca_lmnn_pca=? WHERE processing_id = ?';
        while true; try; 
            sqlite3.execute(update_str, shape_pca, appearance_intensity_pca, shape_pca_lmnn, appearance_intensity_pca_lmnn, fusion_intensity_pca_lmnn, shape_pca_lmnn_pca, appearance_intensity_pca_lmnn_pca, fusion_intensity_pca_lmnn_pca, record_processing.processing_id); 
            break; catch; pause(0.5); end; end;
    end
    
    
end

sqlite3.close();
db_mutex('off',var_database);

fileID = fopen('varout_1.txt','r');
varout_1 = fgets(fileID); 
cellStirng = breakString(varout_1,'*');
varout_1 = cellStirng{1};

fileID = fopen(varout_1,'w');
fprintf(fileID,'');
fclose(fileID);


if isdeployed; exit; end
