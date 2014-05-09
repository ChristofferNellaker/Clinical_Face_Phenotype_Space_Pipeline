function [P_CELL,CONF,isEmpty] = fullSearchFland_exhaustive(image)
    
    debug = false;
    isEmpty = true;

    % Load libraries
    %--------------------------------------------------------------------------
    if isdeployed
        init2;
    else
        addpath('/net/isi-backup/restricted/face/AAM_2013/functions');
        here = pwd;
        %cd('/net/isi-backup/restricted/face/FACEDETECT/CLASS_facepipe_VJ_29-Sep-08b/');
        %%comment this cd doesnt work for me. Annoying turned it off
        init2;
        cd(here);
    end
    
    
    LS = breakString(image,'/');
    FOLDER = '';
    
    for i=1:numel(LS)-1
        FOLDER = [FOLDER,LS{i},'/'];
    end
    
    fprintf('folder : %s\n',FOLDER);
    
    root = FOLDER;
    
    % save original and mirror
    %--------------------------------------------------------------------------
    I = imread(image);
    %I = image; %To be used if the image is stored in an SQL database
    I_mirror = zeros(size(I));
    
   for i=1:size(I,3)    
    I_mirror(:,:,i) = fliplr(I(:,:,i));
   end
    
    key = randsample(10000,1);
    key = int2str(key);
    
    created = 0;
    while created ==0
        if exist([root key '_1'],'dir') == 7
            key = randsample(10000,1);
            key = int2str(key);
        else
            mkdir([key '_1']); %root
            mkdir([key '_2']);
            created = 1;
        end
    end
    
    imwrite(uint8(I),[key '_1/im_0.jpg']);%root
    imwrite(uint8(I_mirror),[key '_2/im_0.jpg']);
    
    % core
    %--------------------------------------------------------------------------
    FRAMES = [0.1 0.3 0.5 0.7];
    ANGLES = [-45 -30 -20 -10 0 10 20 30 45];
    P_CELL = cell(2,numel(FRAMES),numel(ANGLES));
    DETS_CELL = cell(2,numel(FRAMES),numel(ANGLES));
    CONF = zeros(2,numel(FRAMES),numel(ANGLES));
    
    for folder=1:2 % original and flipped
        
        I = imread([key '_' int2str(folder) '/im_0.jpg']);%root
        
        for frame_idx = 1:numel(FRAMES)
            
            [If,N] = framePicture(I,FRAMES(frame_idx));
            
            for angle_idx = 1:numel(ANGLES)
                
                Ifr = imrotate(If,ANGLES(angle_idx),'bilinear','crop');
                
                img_tmp = [key '_' int2str(folder) '/im_0_' int2str(frame_idx) '_' int2str(angle_idx) '.jpg'];%root
                imwrite(uint8(Ifr),img_tmp);
                [Pfr,conf,DETS] = findFLAND(img_tmp,opts);
                
                
                if isempty(Pfr) == 0
                    
                    DETS_Points = [DETS(1,1)+DETS(3,1).*[-1 1 1 -1 -1]',DETS(2,1)+DETS(3,1).*[-1 -1 1 1 -1]'];
                    
                    % from Ifr to If
                    %------------------------------------------------------
                    [n,m,d] = size(Ifr);
                    C = [m/2,n/2];

                    P_tmp = Pfr;
                    for i=1:size(P_tmp,1)
                        P_tmp(i,:) = Pfr(i,:)-C;
                    end
                    
                    DETS_Points_tmp = DETS_Points;
                    for i=1:size(DETS_Points,1)
                        DETS_Points_tmp(i,:) = DETS_Points(i,:)-C;
                    end

                    Rot = [cosd(ANGLES(angle_idx)),-sind(ANGLES(angle_idx));...
                        sind(ANGLES(angle_idx)),cosd(ANGLES(angle_idx))];
                    
                    Pf = (Rot*P_tmp')';
                    DETS_Points_tmp = (Rot*DETS_Points_tmp')';
                    

                    [n,m,d] = size(If);
                    C = [m/2,n/2];

                    for i=1:size(Pfr,1)
                        Pf(i,:) = Pf(i,:)+C;
                    end
                    for i=1:size(DETS_Points_tmp,1)
                        DETS_Points_tmp(i,:) = DETS_Points_tmp(i,:)+C;
                    end
                    
                    % from If to I
                    %------------------------------------------------------
                    P = Pf-N;
                    Pflip = P;
                    
                    DETS_Points = DETS_Points_tmp-N;
                    DETS_Points_flip = DETS_Points;
                    
                    % from I to Iorigin
                    %------------------------------------------------------
                    if folder ==2
                        P_back = [size(I,2) - P(:,1),P(:,2)];
                        order = [4;3;2;1;7;6;5;9;8];
                        P_back = P_back(order,:);
                        P= P_back;
                    end

                    P_CELL{folder,frame_idx,angle_idx} = P;
                    DETS_CELL{folder,frame_idx,angle_idx} = DETS_Points;
                    CONF(folder,frame_idx,angle_idx) = conf;
                    isEmpty = false;
                    
                    if debug
                        
                        subplot(2,2,1);
                        imshow(uint8(Ifr));
                        hold on;plot(Pfr(:,1),Pfr(:,2),'g+');hold off;
                        title('framed rotated');
                        
                        subplot(2,2,2);
                        imshow(uint8(If));
                        hold on;plot(Pf(:,1),Pf(:,2),'g+');hold off;
                        title('framed');
                        
                        subplot(2,2,3);
                        imshow(uint8(I));
                        hold on;plot(Pflip(:,1),Pflip(:,2),'g+');hold off;
                        title('flipped');
                        
                        subplot(2,2,4);
                        imshow([key '_1/im_0.jpg']);%root
                        hold on;plot(P(:,1),P(:,2),'g+');
                        plot(DETS_Points(:,1),DETS_Points(:,2),'y');hold off;
                        title('original');
                        
                        drawnow;
                        a = input('');
                    end
                    
                else
                    P_CELL{folder,frame_idx,angle_idx} = [];
                    CONF(folder,frame_idx,angle_idx) = NaN;
                    DETS_CELL{folder,frame_idx,angle_idx} = [];
                end
                
                %fprintf('flip: %u - frame: %u - angle: %u\n',folder,frame_idx,angle_idx);
            end
        end
    end
    % delete folders
    %--------------------------------------------------------------------------
    rmdir([key '_1'],'s');%root
    rmdir([key '_2'],'s');
end
