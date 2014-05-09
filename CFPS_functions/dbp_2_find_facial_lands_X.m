%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isdeployed
    init2;
    vgg_startup;
else
    addpath('/net/isi-backup/restricted/face/PIPELINE_201306/functions');
    addpath('/net/isi-backup/restricted/face/AAM_2013/functions');
    here = pwd;
    cd('/net/isi-backup/restricted/face/FACEDETECT/CLASS_facepipe_VJ_29-Sep-08b/');
    init2;
    cd('/net/isi-backup/restricted/face/vgg_matlab/');
    vgg_startup;
    cd(here);
    addpath('/net/isi-software/tools/matlab_extools/matlab-sqlite3-driver');
    %addpath('/net/isi-backup/restricted/face/PROJECT/SQL_UPDATE/matlab-serialization-master/matlab-serialization-master');
    addpath('/net/isi-software/tools/matlab_extools/serialize')
    %addpath('/net/isi-software/tools/matlab_extools/matlab-serializationgfh');
    
end
%--------------------------------------------------------------------------

fileID = fopen('varin_image_path.txt','r'); % image full path
varin_1 = fgets(fileID);
fclose(fileID);
cellStirng = breakString(varin_1,'*');
varin_1 = cellStirng{1};


%% get the full path of the image:   %%% NO LONGER NEEDED
%cellString = breakString(varin_1,'/');
%image_path = cellString{1};
%for i=2:numel(cellString)-1
%    image_path = [image_path '/' cellString{i}];
%end
%image_path = [image_path '/'];
%image_name = cellString{end};
image_path_name = varin_1;

%--------------------------------------------------------------------------

fileID = fopen('var_database.txt','r');
var_database = fgets(fileID); % path to the image
cellStirng = breakString(var_database,'*');
var_database = cellStirng{1};

table1 = 'processing';
table2 = 'meta';

%sqlite3.open(var_database);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%
% TO BE USED IF THE IMAGE IS STORED IN SQL DATABASE
%image_content_ser = sqlite3.execute('SELECT image_content FROM processing WHERE image_path = ? AND image_name = ?', image_path,image_name);
%image_content = deserialize(image_content_ser);
%
% 1) take the image and submit it to full search
%[P_CELL,CONF,isEmpty] = fullSearchFland_exhaustive(image_content);%(imagePath);
%%%%%%%%%%%%%%%%%
% 1) take the image and submit it to full search

[P_CELL,CONF,isEmpty] = fullSearchFland_exhaustive(image_path_name);


% 1.2) select best constellation
[n,m,p] = size(CONF);
conf = [];

for i=1:n
    for j=1:m
        for k=1:p
            
            if isnan(CONF(i,j,k))
            else
                conf = [conf,[CONF(i,j,k);i;j;k]];
            end
            
        end
    end
end


% DB write mutex
% fill in the database:
%unqid_process = tempname();
while ~db_mutex('on', var_database); end


sqlite3.open(var_database)
%while true; try; sqlite3.execute('select * from processing limit 1'); break; catch;pause(0.5); end; end;

if isempty(conf)    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %sqlite3.execute('UPDATE processing SET boolean_fland = ? WHERE image_path = ? AND image_name = ?', 0, image_path, image_name);
    while true; try; sqlite3.execute('UPDATE processing SET boolean_fland = ? WHERE image_path_name = ?', 0, image_path_name);  break; catch;pause(0.5); end; end;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    
    [Constellations,avgConf] = selectConstellations(P_CELL,conf,image_path_name);
    
    if isempty(Constellations)
       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        while true; try; sqlite3.execute('UPDATE processing SET boolean_fland = ? WHERE image_path_name = ?', 0, image_path_name);  break; catch;pause(0.5); end; end;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    else
         
%         fileID = fopen(varout_1,'w');
%         fprintf(fileID,'WORK* %u',numel(Constellations));
%         
%         for i=1:numel(Constellations)
%             fprintf(fileID,' %f',avgConf(i));
%         end
%         
%         
%         for i=1:numel(Constellations)
%             LAND = point2Cano(Constellations{i});
%             fprintf(fileID,'\n');
%             for j=1:numel(LAND)-1
%                 fprintf(fileID,'%f,',LAND(j));
%             end
%             fprintf(fileID,'%f',LAND(end));
%         end
%         fclose(fileID);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        LAND = point2Cano(Constellations{1});
        %sqlite3.execute('UPDATE processing SET boolean_fland = ?, fland = ? WHERE image_path = ? AND image_name = ?', 1, serialize(LAND), image_path, image_name);
        while true; try; sqlite3.execute('UPDATE processing SET boolean_fland = ?, fland = ? WHERE image_path_name = ?', 1, serialize(LAND), image_path_name);  break; catch;pause(0.5); end; end;
        %error(serialize(LAND))

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
    end    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sqlite3.close();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
db_mutex('off', var_database);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileID = fopen('varout_1.txt','r');
varout_1 = fgets(fileID); 
cellStirng = breakString(varout_1,'*');
varout_1 = cellStirng{1};

fileID = fopen(varout_1,'w');
fprintf(fileID,'');
fclose(fileID);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isdeployed
    exit;
end
