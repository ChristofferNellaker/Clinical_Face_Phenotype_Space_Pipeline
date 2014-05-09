%--------------------------------------------------------------------------
% this function is used to use FaceSpace vectors to calculate CIF estimates
% for all syndrome groups
%
% refactored by Christoffer Nellaker 140407
% 
%
% --------------------------------------------------------------------------

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

fileID = fopen('var_database.txt','r');
var_database = fgets(fileID); 
cellStirng = breakString(var_database,'*');
var_database = cellStirng{1};

sqlite3.open(var_database);

% look for the row and if the fland exist
%record = sqlite3.execute('SELECT * FROM processing WHERE image_path = ? AND image_name = ?',image_path,image_name);

while true; try; 
        %record_features = sqlite3.execute('SELECT processing_id, fusion_intensity_pca_lmnn_pca FROM FS_features');
        record = sqlite3.execute('SELECT M.*, P.image_path_name, P.image_path, P.processing_id, P.boolean_success, FS.fusion_intensity_pca_lmnn_pca, FS.appearance_intensity_pca_lmnn_pca, FS.shape_pca_lmnn_pca FROM FS_features FS LEFT JOIN processing P ON FS.processing_id = P.processing_id LEFT JOIN meta M ON P.meta_id = M.id');
        %record_processing = sqlite3.execute('SELECT * FROM processing WHERE image_path_name = ?',image_path_name);
        %record_features = sqlite3.execute('SELECT * FROM FS_features WHERE processing_id = ?',record_processing.processing_id);
        break; catch;pause(0.5); end; end;
sqlite3.close();

entries_of_interest = struct();
syndrome_labels = {};
individual_labels = {};
for i=1:numel(record)
    if regexp(record(i).image_path,'SITW_v2_parsed|Gorlin|Bronwyn') %NO IDEA why it needs the _1 on image_path
        %if i==1
        %    break
        %end
        if isequal(record(i).syndrome, 'Control')
        elseif regexp(record(i).image_path_1,'mirror')
        elseif regexp(record(i).image_path_1,'Progeria_new')%getting rid of dupes for this version 140430, will not do anything in later versions.
        elseif isequal(record(i).boolean_success, 0)
        else
            if numel(fieldnames(entries_of_interest))==0
                entries_of_interest = struct(record(i));
            else
                entries_of_interest(end+1) = struct(record(i));
            end
            if record(i).gene; syndrome_labels = [syndrome_labels; record(i).gene];
            else
                try syndrome_labels = [syndrome_labels; record(i).syndrome];
                catch
                    record(i).syndrome
                    i
                    break
                end
            end
            individual_labels = [individual_labels; num2str(record(i).id)];
        end
    end
end

if numel(unique(syndrome_labels)) < 2
    error('Only one syndrome to check, metrics unavailable')
end 

if ~numel(entries_of_interest)==numel(syndrome_labels)
    error('labelsmismatch')
end

[CIF_list, len_list, unq_syndromes] = global_CIF_script(entries_of_interest, syndrome_labels, individual_labels, [])


fileID = fopen('varout_1.txt','r');
varout_1 = fgets(fileID); 
cellStirng = breakString(varout_1,'*');
varout_1 = cellStirng{1};

fileID = fopen(varout_1,'w');
%fprintf(fileID,'');
for i=1:numel(unq_syndromes)
    fprintf(fileID, '%s\t%.1f\n', unq_syndromes{i}, CIF_list(i));
end

fclose(fileID);


if isdeployed; exit; end
