
% to be uncommented
fileID = fopen('varin_3.txt','r'); % CoE Models
varin_3 = fgets(fileID);
fclose(fileID);

%varin_3 = '/net/isi-backup/restricted/face/SITW_v2_parsed/controles_intensity_bl_man.mat';

% %varin_3	CoE models	in here and in function_BELHUMER
% %varin_4        Parts models LPFuCE     function_BELHUMER
% %varin_5        P DELTA examples     function_BELHUMER
% 
% fileID = fopen('varout_1.txt','r'); % path to the .bfland
% varout_1 = fgets(fileID);
% fclose(fileID);
% 
% fileID = fopen('varout_2.txt','r'); % path to the display
% varout_2 = fgets(fileID);
% fclose(fileID);

%//////////////////////////////////////////////////////////////////////////
if isdeployed
else
    addpath('/net/isi-backup/restricted/face/AAM_2013/functions'); %cano&point
    addpath('/net/isi-backup/restricted/face/FFE/LPFuCE/functions'); %utils
    addpath('/net/isi-backup/restricted/face/FFE/LPFuCE/sift'); %sift
    addpath('/net/isi-backup/restricted/face/FFE/LPFuCE/libsvm-3.17/matlab');
    addpath('/net/isi-backup/restricted/face/FFE/LPFuCE/phog/phog');
    addpath('/net/isi-backup/restricted/face/FFE/LPFuCE/');
    addpath('/net/isi-backup/restricted/face/PIPELINE_201306');
    
    addpath('/net/isi-software/tools/matlab_extools/matlab-sqlite3-driver');
    %addpath('/net/isi-backup/restricted/face/PROJECT/SQL_UPDATE/matlab-serialization-master/matlab-serialization-master');
    %addpath('/net/isi-software/tools/matlab_extools/matlab-serialization');
    addpath('/net/isi-software/tools/matlab_extools/serialize');
end
%//////////////////////////////////////////////////////////////////////////


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
while ~db_mutex('on', var_database); end
while true; try; record = sqlite3.execute('SELECT * FROM processing WHERE image_path_name = ?',image_path_name); break; catch;pause(0.5); end; end;
db_mutex('off', var_database);
%//////////////////////////////////////////////////////////////////////////



%run /net/isi-backup/restricted/face/FFE/LPFuCE/parameters;
%root = '/net/isi-backup/restricted/face/SITW_v2_parsed/'; % to data

%ext_man = '_intensity_bl_man';
%ext_aut = '_intensity_bl_aut_imp';% not used

% select the target points + the idx of the 9 inner facial points in those
% target points:
point_select = 0;
switch(point_select)
    case 0
        point_of_interest = 1:36;
        points9 = [9 11 13 15 19 21 23 24 28];
    case 1
        point_of_interest = [1,4,5,8,9,11,13,15,18,19,21,23,24,26,28,29];
        points9 = [5 6 7 8 10 11 12 13 15];
    case 2
        point_of_interest = [9 11 13 15 19 21 23 24 28];
        points9 = 1:9;
end

% training 
nbNegative = 2;

% PHOG
nbBin = 8;
level=3;

% initial Xinit
nbRand = 500;
nbExample = 20;
%load([root 'controles' ext_man '.mat']);
load(varin_3);
class_images = class.images;
class_anno = class.annotations_m;

% example selection
nbLoop_0 = 1000;
nbLoop_1 = 5;
top_k = 5;

K_example = 20;

%//////////////////////////////////////////////////////////////////////////

working = 0;

% 1) find the initial Xinit for the given image
%--------------------------------------------------------------------------
imgPath = varin_1;
P9 = [];

if isempty(record.boolean_fland)||record.boolean_fland == 0
    working = 1;
else
    LAND = deserialize(record.fland);
    P9 = cano2Points(LAND);
    fprintf('%u %u',size(LAND));
end
%--------------------------------------------------------------------------
if working == 0
    display = false;
    verbose = false;
    Xinit = findInitialConstellation_X9(imgPath,P9,class_anno,points9,nbRand,nbExample,display,verbose);

    if isempty(Xinit)
        if isempty(P9)
            working = 21;
        else
            working = 22;
        end
    else
        % check constellation is inside the image
        in = isConstellationInImage(imgPath,Xinit);
        if sum(in==0)>0
            working = 30;
        end
        
    end

end
%--------------------------------------------------------------------------

% % 2) run the function
% %--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define varout_2

fileID = fopen('varout_2.txt','r');
varout_2 = fgets(fileID);
cellStirng = breakString(varout_2,'*');
varout_2 = cellStirng{1};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%unqid_process = tempname();
%unqid_process = [unqid_process,'Belheumur_'];

if working == 0
    display = false;
    verbose = false;
    [Xfinal,disparity,Ir,Xr,Xfinal_ini] = function_BELHUMER(imgPath,Xinit,display,verbose);
    
    
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   	% DB write mutex
	% fill in the database:
	while ~db_mutex('on', var_database); end
	%while true; try; sqlite3.execute('select * from processing limit 1'); break; catch;pause(0.5); end; end;
	
        %sqlite3.execute('UPDATE processing SET boolean_belhumeur = ? WHERE image_path = ? AND image_name = ?', 1, image_path, image_name);
        while true; try; sqlite3.execute('UPDATE processing SET boolean_belhumeur = ? WHERE image_path_name = ?', 1, image_path_name); break; catch;pause(0.5); end; end;
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%     LAND = point2Cano(Xfinal);
%     fileID2 = fopen(varout_1,'w');
%     fprintf(fileID2,'WORK*\n');
%     for i=1:numel(LAND)-1
%         fprintf(fileID2,'%f,',LAND(i));
%     end
%     fprintf(fileID2,'%f',LAND(end));
%     
%     fprintf(fileID2,'\n');
%     LAND = point2Cano(Xr);
%     for i=1:numel(LAND)-1
%         fprintf(fileID2,'%f,',LAND(i));
%     end
%     fprintf(fileID2,'%f',LAND(end));
% 
%     fprintf(fileID2,'\n');
%     LAND = point2Cano(Xfinal_ini);
%     for i=1:numel(LAND)-1
%         fprintf(fileID2,'%f,',LAND(i));
%     end
%     fprintf(fileID2,'%f',LAND(end));
%     fclose(fileID2);
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        LAND = point2Cano(Xfinal_ini);
        %sqlite3.execute('UPDATE processing SET belhumeur = ? WHERE image_path = ? AND image_name = ?', serialize(LAND), image_path, image_name);
        while true; try; sqlite3.execute('UPDATE processing SET belhumeur = ? WHERE image_path_name = ?', serialize(LAND), image_path_name); break; catch;pause(0.5); end; end;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    	sqlite3.close();
	db_mutex('off', var_database);

    imwrite(Ir,varout_2);
    
    
    h = figure('Visible','off');
    image(Ir);
    hold on
    plot(Xfinal(:,1),Xfinal(:,2),'go','MarkerFaceColor','g','MarkerSize',2);
    hold off
    axis image;
    saveas(h,varout_2);
    
    
    
else
%     fileID2 = fopen(varout_1,'w');
%     fprintf(fileID2,'FAIL*\n');
%     fprintf(fileID2,'%u',working);
%     fclose(fileID2);
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    	% DB write mutex
	% fill in the database:
	while ~db_mutex('on', var_database); end
	%while true; try; sqlite3.execute('select * from processing limit 1'); break; catch;pause(0.5); end; end;
	%unqid = [tempname(), '  ', image_path_name];
	%database_lock = [var_database,'.lock'];
	%while ~db_mutex('on',database_lock, unqid)
	%end

        %sqlite3.execute('UPDATE processing SET boolean_belhumeur = ? WHERE image_path = ? AND image_name = ?', 0, image_path, image_name);
        while true; try; sqlite3.execute('UPDATE processing SET boolean_belhumeur = ? WHERE image_path_name = ?', 0, image_path_name); break; catch;pause(0.5); end; end;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    	sqlite3.close();
	%db_mutex('off',database_lock,unqid);
	db_mutex('off', var_database);

    imwrite(zeros(100),varout_2);
    
    
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%sqlite3.close();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileID = fopen('varout_1.txt','r');
varout_1 = fgets(fileID); 
cellStirng = breakString(varout_1,'*');
varout_1 = cellStirng{1};

fileID = fopen(varout_1,'w');
fprintf(fileID,'');
fclose(fileID);

%fileID = fopen('varout_2.txt','r');
%varout_2 = fgets(fileID); 
%cellStirng = breakString(varout_2,'*');
%varout_2 = cellStirng{1};

%fileID = fopen(varout_2,'w');
%fprintf(fileID,'');
%fclose(fileID);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isdeployed
    exit;
end
