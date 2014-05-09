clear all; close all;

addpath('/net/isi-software/tools/matlab_extools/matlab-sqlite3-driver');
addpath('/net/isi-backup/restricted/face/PROJECT/SQL_UPDATE/matlab-serialization-master/matlab-serialization-master');

path = '/net/isi-backup/restricted/face/PIPELINE_201306/SQL_DATABASE/';
database_name = 'DB_syndrome';

table1 = 'processing';
table2 = 'meta';

sqlite3.open([path database_name]);

% check that the given image is not in the database:
record = sqlite3.execute('SELECT * FROM processing');
fileID = fopen('dbp_stats.txt','w');
fprintf(fileID, 'MATCH|image_content|boolean_fland|aam|boolean_belhumeur\n---------------------------------------------------------------------------\n');
for i=1:numel(record)
    
    metadata = sqlite3.execute('SELECT * FROM meta WHERE image_path = ? AND image_name = ?', record(i).image_path,record(i).image_name);
    
    if metadata.id == record(i).id
        fprintf(fileID,'*|');
    else
        fprintf(fileID,'-|');
    end
    
    
    if isempty(record(i).image_content)
        fprintf(fileID,'-');
    else
        fprintf(fileID,'*');
    end
    
    if isempty(record(i).boolean_fland)
        fprintf(fileID,'-');
    elseif record(i).boolean_fland==0
        fprintf(fileID,'+');
    else
        fprintf(fileID,'*');
    end
    
    if isempty(record(i).aam)
        fprintf(fileID,'-');
    else
        fprintf(fileID,'*');
    end
    
    if isempty(record(i).boolean_belhumeur)
        fprintf(fileID,'-');
    elseif record(i).boolean_fland==0
        fprintf(fileID,'+');
    else
        fprintf(fileID,'*');
    end
    
    fprintf(fileID,'|%s|%s|%s\n',record(i).image_name,metadata.syndrome,record(i).image_path);
    
end

fclose(fileID);


sqlite3.close();