%--------------------------------------------------------------------------
% this function is used to use FaceSpace vectors to perform p0p1 diagnosis
% predictions.
% Written by Christoffer Nellaker 140205
% adapted from MASTERSCRIPT_vincent
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

%var_database = '/net/isi-backup/restricted/face/DB_syndrome.sqlite';

sqlite3.open(var_database);

% look for the row and if the fland exist
%record = sqlite3.execute('SELECT * FROM processing WHERE image_path = ? AND image_name = ?',image_path,image_name);

while true; try; 
        %record_features = sqlite3.execute('SELECT processing_id, fusion_intensity_pca_lmnn_pca FROM FS_features');
        record = sqlite3.execute('SELECT M.*, P.image_path, P.processing_id, FS.fusion_intensity_pca_lmnn_pca, FS.appearance_intensity_pca_lmnn_pca, FS.shape_pca_lmnn_pca FROM FS_features FS LEFT JOIN processing P ON FS.processing_id = P.processing_id LEFT JOIN meta M ON P.meta_id = M.id');
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

[L_predicted_position, unq_syndromes] = global_p0p1_script(entries_of_interest, syndrome_labels, individual_labels);


fileID = fopen('varout_1.txt','r');
varout_1 = fgets(fileID); 
cellStirng = breakString(varout_1,'*');
varout_1 = cellStirng{1};

fileID = fopen(varout_1,'w');
%fprintf(fileID,'');
for i=1:numel(syndrome_labels)
    fprintf(fileID, '%s\t%d\n', syndrome_labels{i}, L_predicted_position(i));
end

fclose(fileID);


if isdeployed; exit; end
% % populate the face space
% %--------------------------------------------------------------------------
% %clear all; close all;
% %root = '/net/isi-backup/restricted/face/MATFILES/SUPERCLASS_auto_SSRF/';
% %listClasses = dir([root '*superClass.mat']);
% X = [];
% L = [];
% 
% for i=1:numel(listClasses)
%     load([root listClasses(i).name]);
%     x = superClass.fusion_lmnn;
%     X = [X;x];
%     L = [L;i.*ones(size(x,1),1)];
% end
% 
% % fetch the test data
% %--------------------------------------------------------------------------
% %load('/net/isi-backup/restricted/face/130920_famous/famous_intensity_aut_p201306_superClass.mat');
% load('/net/isi-backup/restricted/face/Clinical_collabs/Nijmegen/Photo''s Noonan_intensity_aut_p201306_superClass.mat');
% Q = superClass.fusion_lmnn;
% 
% % set parameters and compute stats
% %--------------------------------------------------------------------------
% K = 20;
% [IDX,D] = knnsearch(X,Q,'K',K);
% nb_per_class = zeros(1,max(L));
% for i=1:max(L)
%     nb_per_class(i) = numel(find(L==i));
% end
% 
% 
% 
% % --> P0P1
% P0P1 = zeros(size(Q,1),K);
% for i=1:size(Q,1)
%     for nn=1:K
%         idx = IDX(i,nn);
%         [IDX_nn,D_nn] = knnsearch(X,X(idx,:),'K',K+1);
%         P0P1(i,nn) = sqrt(mean(D(i,:))*mean(D_nn))/D(i,nn); 
%     end
% end
% 
% % --> Probability estimate
% 
% fileID = fopen('131204_Noonan_results.txt','w');
% 
% for i=1:size(Q,1)
%     
%     fprintf(fileID,'proba estimate on %s:\n',superClass.images{i});
%     
%     class_in = [];
%     class_nb = [];
%     label = L(IDX(i,:));
%     for nn=1:K
%         idx = find(class_in == label(nn));
%         if isempty(idx)
%             class_in = [class_in, label(nn)];
%             class_nb = [class_nb, 1];
%         else
%             class_nb(idx) = class_nb(idx)+1;
%         end
%     end
%     
%     classInfo = cell(1,numel(class_in));
%     PROBA = zeros(1,numel(class_in));
%     
%     for j=1:numel(class_in)
%         
%         nb_positif = nb_per_class(class_in(j));
%         proba = nchoosek(nb_positif,class_nb(j))*...
%             nchoosek(numel(L)-nb_positif,K-class_nb(j))/...
%             nchoosek(numel(L),K);
%         proba = 1-proba;
%         PROBA(j) = proba;
%         classInfo{1,j} = listClasses(class_in(j)).name;
%         
%     end
%     
%     [v,sorting] = sort(PROBA,'descend');
%     
%     
%     for j=1:numel(class_in)
%         fprintf(fileID,'%f: %s\n',PROBA(sorting(j)),classInfo{1,sorting(j)});
%     end
%     
% end
% 
% fclose(fileID);