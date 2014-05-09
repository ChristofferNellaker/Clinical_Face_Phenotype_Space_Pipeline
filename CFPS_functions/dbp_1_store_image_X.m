%var_database.txt
%--------------------------------------------------------------------------
%--path = '/net/isi-backup/restricted/face/';
%--database_name = 'DB_syndrome';

if isdeployed
else
    addpath('/net/isi-software/tools/matlab_extools/matlab-sqlite3-driver');
    %addpath('/net/isi-backup/restricted/face/PROJECT/SQL_UPDATE/matlab-serialization-master/matlab-serialization-master');
    addpath('/net/isi-software/tools/matlab_extools/matlab-serialization/mex');
    %addpath('/net/isi-software/tools/matlab_extools/matlab-serialization/private');
    addpath('/net/isi-backup/restricted/face/AAM_2013/functions');
end

%--------------------------------------------------------------------------

fileID = fopen('var_database.txt','r');
var_database = fgets(fileID); % path to the image
cellStirng = breakString(var_database,'*');
var_database = cellStirng{1};

table1 = 'processing';
table2 = 'meta';

%--------------------------------------------------------------------------

% the only varin in the pipeline
fileID = fopen('varin_image_path.txt','r');
varin_1 = fgets(fileID); % path to the image
cellStirng = breakString(varin_1,'*');
varin_1 = cellStirng{1};

%--------------------------------------------------------------------------

% varin_1_meta = fgets(fileID);
% cellStirng = breakString(varin_1_meta,'*');
% varin_1_meta = cellStirng{1};

fclose(fileID);

cellString = breakString(varin_1,'/');
image_path = cellString{1};
for i=2:numel(cellString)-2 %horrible bug here if facespace_data in inputpath
    image_path = [image_path '/' cellString{i}];
end
image_path = [image_path '/'];
image_name_sp = regexp(cellString{end},'_','split');
image_name = image_name_sp{1};
for i=2:numel(image_name_sp)-1
    image_name = [image_name '_' image_name_sp{i}];
end
image_suffix = regexp(image_name_sp{end},'\.','split');
image_name = [image_name '.' image_suffix{1}]
%image_path_name = varin_1;

% read image:
%image_content = imread(varin_1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileID = fopen('varout_image_path.txt','r');
varout_image_path = fgets(fileID);
cellStirng = breakString(varout_image_path,'*');
varout_image_path = cellStirng{1};
fclose(fileID);
image_path_name = varout_image_path;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DB write mutex
% fill in the database:
%unqid_process = tempname();
sqlite3.open(var_database);
while ~db_mutex('on', var_database); end
%while true; try; sqlite3.execute('select * from processing limit 1'); break; catch;pause(0.5); end; end;
%unqid = regexp(tempname(), '/','split');
%unqid = [unqid{3}, '.request'];
%request_file = ['../', unqid];
%fileID = fopen(request_file,'w');
%fprintf(fileID,'');
%fclose(fileID);
%queue_file = [var_database,'.queue'];
%while true
%	if ~exist(queue_file,'file')
%		pause(1);
%	else
%		fileID = fopen(queue_file,'r');
%		next_in_queue = fgets(fileID);
%		fclose(fileID);
%		if isequal(next_in_queue, unqid)
%			break
%		else
%			pause(0.1);
%		end
%	end
%end 
%image_path
%image_name
%image_path_name
%sqlite3.open(var_database);

%######################################## TRY TO GRAB DB LOCK
%while true
%	try
%		sqlite3.execute('UPDATE processing SET image_path = ? WHERE image_path_name = ?', 'test_lock', 'test_lock');
%		break
%	catch
%	end
%end
% check that the given image is not in the database:

while true; try; record = sqlite3.execute('SELECT * FROM processing WHERE image_path = ? AND image_name = ?', image_path,image_name); break; catch;pause(0.5); end; end;

if isempty(record)
    while true; try; sqlite3.execute('INSERT INTO processing (image_path,image_name,image_path_name) VALUES (?, ?, ?)', image_path, image_name, image_path_name);  break; catch;pause(0.5); end; end;
    %sqlite3.execute('INSERT INTO meta (image_path,image_name,syndrome) VALUES (?, ?, ?)', image_path, image_name, varin_1_meta);
else
    fprintf('Already existing in the table...UPDATED\n');
    while true; try; sqlite3.execute('UPDATE processing SET image_path = ?, image_name = ?, image_path_name = ? WHERE image_path = ? AND image_name = ?', image_path, image_name, image_path_name, image_path,image_name);  break; catch;pause(0.5); end; end;
    %sqlite3.execute('UPDATE processing SET image_path = ?, image_name = ?, syndrome = ? WHERE image_path = ? AND image_name = ?', image_path, image_name, varin_1_meta, image_path,image_name);
end

sqlite3.close();

%delete(request_file);
db_mutex('off',var_database);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileID = fopen('varout_1.txt','r');
varout_1 = fgets(fileID); 
cellStirng = breakString(varout_1,'*');
varout_1 = cellStirng{1};

fileID = fopen(varout_1,'w');
%fprintf(fileID,'%s',image_path);
fprintf(fileID, '');
fclose(fileID);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isdeployed
    exit;
end
