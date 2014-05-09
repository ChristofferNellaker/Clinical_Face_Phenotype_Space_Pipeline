% %--------------------------------------------------------------------------
% RUN AAM
% %--------------------------------------------------------------------------
%varin_1 = '/net/isi-backup/restricted/face/FACEDETECT/CLASS_facepipe_VJ_29-Sep-08b/047640.jpg';
%varin_2 = '/net/isi-backup/restricted/face/FACEDETECT/CLASS_facepipe_VJ_29-Sep-08b/047640.fland';
%varout_1 = '/net/isi-backup/restricted/face/FACEDETECT/CLASS_facepipe_VJ_29-Sep-08b/047640.aam';

if isdeployed
else
    addpath('/net/isi-backup/restricted/face/AAM_2013/functions');
    addpath('/net/isi-software/tools/matlab_extools/matlab-sqlite3-driver');
    %addpath('/net/isi-backup/restricted/face/PROJECT/SQL_UPDATE/matlab-serialization-master/matlab-serialization-master');
    %addpath('/net/isi-software/tools/matlab_extools/matlab-serialization');
    addpath('/net/isi-software/tools/matlab_extools/serialize');
end

% image path
fileID = fopen('varin_image_path.txt','r');
varin_1 = fgets(fileID);
fclose(fileID);
cellStirng = breakString(varin_1,'*');
varin_1 = cellStirng{1};

% get the full path of the image:
cellString = breakString(varin_1,'/');
image_path = cellString{1};
for i=2:numel(cellString)-1
    image_path = [image_path '/' cellString{i}];
end
image_path = [image_path '/'];
image_name = cellString{end};
image_path_name = varin_1;


debug = false;
type_of_model = 'face';

I = imread(varin_1);
if size(I,3) == 3
    type_of_feature = 'rgb';
else
    type_of_feature = 'gray';
end

percent_for_app = 0.95;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fileID = fopen('var_database.txt','r');
var_database = fgets(fileID); % path to the image
cellStirng = breakString(var_database,'*');
var_database = cellStirng{1};

table1 = 'processing';
table2 = 'meta';

%unqid_process = tempname();
sqlite3.open(var_database);

% look for the row and if the fland exist
%record = sqlite3.execute('SELECT * FROM processing WHERE image_path = ? AND image_name = ?',image_path,image_name);
while ~db_mutex('on', var_database); end
while true; try; record = sqlite3.execute('SELECT * FROM processing WHERE image_path_name = ?',image_path_name); break; catch;pause(0.5); end; end;
db_mutex('off', var_database);

if isempty(record)
    fprintf('this image is not part of the database\n');
else
    if (isempty(record.boolean_fland)||record.boolean_fland==0)
        fprintf('fland field empty\n');
    else
        
        LAND = deserialize(record.fland);
        Pini = cano2Points(LAND);
        X = fitAAMGlobal(varin_1,Pini,type_of_model,type_of_feature,percent_for_app,debug);

        x = point2Cano(X);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    	% DB write mutex
	% fill in the database:
	while ~db_mutex('on', var_database); end
	%while true; try; sqlite3.execute('select * from processing limit 1'); break; catch;pause(0.5); end; end;

	%unqid = [tempname(), '  ', image_path_name];
	%database_lock = [var_database,'.lock'];
	%while ~db_mutex('on',database_lock, unqid)
	%end

        %sqlite3.execute('UPDATE processing SET aam = ? WHERE image_path = ? AND image_name = ?', serialize(x), image_path, image_name);
        while true; try; sqlite3.execute('UPDATE processing SET aam = ? WHERE image_path_name = ?', serialize(x), image_path_name); break; catch;pause(0.5); end; end;
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
end

sqlite3.close();
%db_mutex('off',database_lock,unqid);
db_mutex('off', var_database);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



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
