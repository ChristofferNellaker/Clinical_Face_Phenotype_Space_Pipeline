

function [Xfinal,disparity,I,X,Xfinal_ini] = function_BELHUMER(imgPath,Xinit,display,verbose)
% turns /net/isi-backup/restricted/face/FFE/LPFuCE/v1_1.m into a function
%--------------------------------------------------------------------------
% INPUTS:
% imgPath: path to the image
% Xinit: rough position of the 36 landmarks in a 36*2 matrix
% display,verbose: boolean for display and print output
% OUTPUTS:
% Xfinal: n*2 matrix of the predicted position of the n landmarks in the
% rotated image
% disparity: measure of the overlap between the registered constellations
% I,X: rotated image and Xinit

fileID = fopen('varin_3.txt','r'); % path to models for belhumeur
varin_3 = fgets(fileID);
fclose(fileID);

fileID = fopen('varin_4.txt','r'); % parts models LPFuCE
varin_4 = fgets(fileID);
fclose(fileID);

fileID = fopen('varin_5.txt','r'); % P DELTA exampels
varin_5 = fgets(fileID);
fclose(fileID);


if isdeployed
else 
    addpath('/net/isi-backup/restricted/face/AAM_2013/functions'); %cano&point
    addpath('/net/isi-backup/restricted/face/FFE/LPFuCE/functions'); %utils
    addpath('/net/isi-backup/restricted/face/FFE/LPFuCE/sift'); %sift
    addpath('/net/isi-backup/restricted/face/FFE/LPFuCE/libsvm-3.17/matlab');
    addpath('/net/isi-backup/restricted/face/FFE/LPFuCE/phog/phog');
    addpath('/net/isi-backup/restricted/face/PIPELINE_201306/functions');
end

%root = '/net/isi-backup/restricted/face/SITW_v2_parsed/'; % to data
%root = varin_4

ext_man = '_intensity_bl_man';
ext_aut = '_intensity_bl_aut_imp';

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


I = imread(imgPath);
X = Xinit;
X = X(point_of_interest,:); % get the initial position of  the target points
    
% 1) rotate image and annotation
%--------------------------------------------------------------------------
    [eye_dist,v,w,a0_ini] = estimate_parameters_image(X,points9);
    [Ir,Xr] = rotateImageAndConstellation(I,a0_ini,X);
    
    % Ir and I are saved for later: work is done on Ir and derived
    % constellation is then mapped back to I
    Irot = Ir;
    Iini = I;
    
    % Now we use Ir and Xr
    I = Ir;
    X = Xr;
    [eye_dist,v,w,a0] = estimate_parameters_image(X,points9);
    
% 2) compute decision values for each window at each landmark    
%--------------------------------------------------------------------------  
    
    % load the models for each parts:
    %load('/net/isi-backup/restricted/face/FFE/LPFuCE/MODELS.mat');
    load(varin_4);

    % fro each part we select a grid of sampling points. All the sampling
    % points are then submitted to the part classifier giving a decision
    % value vector stored in Di{part}:
    Di = cell(1,numel(point_of_interest));
    
    % the sampling grid is going to be 2*radius*2*radius centered on the
    % initial point. step for the grid is the same for X and Y and is
    % 2*radius/nbStep:
    radius = eye_dist;
    nbStep = 30;
    bbx = zeros(numel(point_of_interest),4);
    
    for fiducial = 1:numel(point_of_interest)
        
        if verbose %-->
            fprintf('doing %u of %u\n',fiducial,numel(point_of_interest));
        end
        
        xsteps = X(fiducial,1)-radius:2*radius/nbStep:X(fiducial,1)+radius;
        ysteps = X(fiducial,2)-radius:2*radius/nbStep:X(fiducial,2)+radius;
        [Xsteps,Ysteps] = meshgrid(xsteps,ysteps);
        Xsample = [Xsteps(:),Ysteps(:)];
        
        R = eye_dist; % radisu of the cropped patch for feature extraction
        ROI = zeros(size(Xsample,1),4);

        for j=1:size(Xsample,1)
            ROI(j,:) = [Xsample(j,1)-R,Xsample(j,2)-R,2*R,2*R];
        end
        
        % feature extraction is done over each ROI: the image is cropped
        % and the patch is described using PHOG:
        D = qPHOG(I,false,nbBin,ROI,level);
        
        % D is submitted to the MODELfor that part:
        [predict_label, accuracy, DV] = svmpredict(ones(size(D,1),1),sparse(D),MODELS{fiducial});
        
        
        if display % <-->
            minDV = min(DV);
            maxDV = max(DV);
            DVplot = DV;
            
            subplot(6,6,fiducial);
            imshow(I);
            hold on
            for j=1:size(Xsample,1)
                
                if isnan(DV(j))
                    plot(Xsample(j,1),Xsample(j,2),'.','color',[1 0 0]);
                else
                    plot(Xsample(j,1),Xsample(j,2),'.','color',[0 (DVplot(j)-minDV)/(maxDV-minDV) 0]);
                end
                
            end
            hold off
            drawnow
        end
        
        
        % fix the nan bug
        minDV = min(DV);
        for i=1:numel(DV)
            if isnan(DV(i))
                DV(i) = minDV;
            end
        end
        
        % DV is scale between 0 and 1:
        DV = 1/(max(DV)-min(DV)).*(DV-min(DV));
        
        
        % DV is sorted max to min:
        [v,idx] = sort(DV,'descend');
        
        di = [Xsample,DV,predict_label];
        
        % di is stored sorted by DV descending:
        Di{fiducial} = di(idx,:);
        
        % store the grid boundaries for fiducial:
        bbx(fiducial,1) = min(Di{fiducial}(:,1));
        bbx(fiducial,2) = max(Di{fiducial}(:,1));
        bbx(fiducial,3) = min(Di{fiducial}(:,2));
        bbx(fiducial,4) = max(Di{fiducial}(:,2));
        
        %save(['/net/isi-backup/restricted/face/tmp_zNpc3q/DATA' fiducial '.mat']);
        
    end

% 3) find good example    
%--------------------------------------------------------------------------    
    %nbLoop_0 = 1000;
    %nbLoop_1 = 5;
    %top_k = 5;
    
    % contain the id of te nbLoop_0= examplar slected 
    IDX_EX = zeros(nbLoop_0,1);
    % here we store the constellation obtained at nbLoop_0=,nbLoop_1=;
    XEXT = cell(nbLoop_0,nbLoop_1);
    
    for l0 = 1: nbLoop_0
        
        if verbose %-->
            fprintf('..example selection loop:%u\n',l0);
        end
        
        % randomly select an example
        idxEx = randsample(numel(class_images),1);
        IDX_EX(l0) = idxEx;
        
        % get the target point for this examplar
        XEx = cano2Points(class_anno(idxEx,:));
        XEx = XEx(point_of_interest,:);
        

        for l1 =1:nbLoop_1

            % select randomly 2/3 fiducials and find procrustes match transform
            POINTS = randsample(numel(point_of_interest),3);
            % select the amongst the highest CL for those parts

            Xpot = zeros(3,2);
            for i=1:3
                di = Di{POINTS(i)};
                Xpot(i,:) = di(randsample(top_k,1),1:2);
            end

            [transform] = align2PointConstellations(Xpot,XEx(POINTS,:),false);
            
            % 3.2) align XEx to X
            c = transform.c;
            C = zeros(size(X));
            for i=1:size(X,1)
                C(i,:) = c(1,:);
            end
            T = transform.T;
            b = transform.b;
            
            
            XEXT{l0,l1} = b*XEx*T + C;

            % check that the constellation is in the image and bbx (ROI)
            % for each point:
            [ouput] = checkIfinBBX(XEXT{l0,l1},bbx,I);
            if ouput==0
                XEXT{l0,l1} = [];
            end

        end
    end

    
% 4) gather all part estimates of the same part together for
% classification    
%--------------------------------------------------------------------------

    DVfusion = [];
    
    for fiducial = 1:numel(point_of_interest)
        
        if verbose %-->
            fprintf('gathering landmark:%u\n',fiducial);
        end
        
        
        LOCATION = [];
        KEY = [];
        
        for l0 = 1: nbLoop_0
            for l1 =1:nbLoop_1
                
                Xext = XEXT{l0,l1};
                if isempty(Xext)==0
                    KEY = [KEY;[l0,l1]];
                    LOCATION = [LOCATION;Xext(fiducial,:)];
                end
                
            end
        end
        
        di = Di{fiducial};
        [IDX] = knnsearch(di(:,1:2),LOCATION);
        DVfusion = [DVfusion,di(IDX,3)];
        
    end
    
    % at this point:
    % KEY give the position in XEXT of non empty constellations
    % DVfusion number of non-empty*nb of points of interest contains the decision values 
    
    
    SortExMatrix = zeros(nbLoop_0,2); % score of the example, best constellation for this example
    
    for i=1:size(KEY,1)
        if SortExMatrix(KEY(i,1),1)<sum(DVfusion(i,:))
            SortExMatrix(KEY(i,1),1) = sum(DVfusion(i,:));
            SortExMatrix(KEY(i,1),2) =  KEY(i,2);
        end
    end
    
    [v,IDX] = sort(SortExMatrix(:,1),'descend');
    KEY_SORTED = [IDX,SortExMatrix(IDX,2)];
    
    
    

% 5) P(dx,xk)   
%--------------------------------------------------------------------------

    %K_example = 20;
    KEY_SORTED = KEY_SORTED(1:K_example,:);
    
    % generate a way to compute P(delta x,xk)
    %load('/net/isi-backup/restricted/face/FFE/LPFuCE/DELTA_example.mat');
    load(varin_5);
    
    functionCell = gaussianEstimate(DELTA,KEY_SORTED,XEXT,eye_dist);
    
    if display % <-->
        figure
        imshow(I)
        hold on
        for i=1:size(KEY_SORTED,1)

            xext = XEXT{KEY_SORTED(i,1),KEY_SORTED(i,2)};
            plot(xext(:,1),xext(:,2),'+');

        end
        hold off
    end
    
    
    %//////////////////////////////////////////////////////////////////////
    %CHECK POINT - END
    %//////////////////////////////////////////////////////////////////////
    
    % choose the final position of points 
    % note that the optimisation here is poor because it is an ex search of
    % an area.
    
    if verbose %-->
            fprintf('generating final constellation\n');
    end
    
    Xfinal = zeros(numel(point_of_interest),2);
    
    for fiducial=1:numel(point_of_interest)
        
        di = Di{fiducial};
        f = functionCell{fiducial};
        C = zeros(size(di,1),1);
        for i=1:size(di,1)
            C(i) = f(di(i,1:2));
        end
        C = C./max(C);
        V = C.*di(:,3);
        [v,IDX] = sort(V,'descend');
        Xfinal(fiducial,:) = di(IDX(1),1:2);
    end
    
    if display % <-->
        figure
        imshow(I)
        hold on
        plot(Xfinal(:,1),Xfinal(:,2),'g.');
        plot(Xfinal(:,1),Xfinal(:,2),'g+');
        plot(Xfinal(:,1),Xfinal(:,2),'go');
        hold off
    end
    
    % check for consistence between the example constellations
    
    if verbose %-->
            fprintf('computing disparity\n');
    end
    
    disparity = zeros(1,size(Xfinal,1));
    for i=1:K_example
            Xtemp = XEXT{KEY_SORTED(i,1),KEY_SORTED(i,2)};
            for j=1:size(Xfinal,1)
                disparity(j) = disparity(j)+norm(Xtemp(j,:)-Xfinal(j,:))/eye_dist;
            end
    end
    
    disparity=disparity/K_example;
    
    [Xfinal_ini] = rotateBackConstellation(Iini,Irot,a0_ini,Xfinal);

end
