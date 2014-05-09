function [X] = fitAAMGlobal(image,Pini,type_of_model,type_of_feature,percent_for_app,debug)
%Global code to fit AAM model

%--------------------------------------------------------------------------
% 1) load models and toolboxes, charge image
%--------------------------------------------------------------------------

if isdeployed
else
    addpath('/net/isi-backup/restricted/face/PROJECT/functions');
end

fprintf('-->loading MODEL...');

fileID = fopen('varin_3.txt','r');
var_AAM_model_dir = fgets(fileID); % path to the AAM models
cellStirng = breakString(var_AAM_model_dir,'*');
var_AAM_model_dir = cellStirng{1};

load([var_AAM_model_dir 'MODEL_' type_of_model '_' type_of_feature '.mat']);
%load(['/net/isi-backup/restricted/face/AAM_2013/models/MODEL_' type_of_model '_' type_of_feature '.mat']);
fprintf('done\n');
Nt = find95variation(Lt,percent_for_app);

%--------------------------------------------------------------------------
% 2) face detection and landmark initialisation
%--------------------------------------------------------------------------

% ------------------------------FIND LANDMARKS
% fprintf('detecting face and landmarks...');
% [I,P] = landDetec(image);
% pini = P(:);
% Pini = cano2Points(pini);
% Pini = Pini(1:9,:);
% fprintf('done\n');
% ------------------------------

switch type_of_feature
    case 'rgb'
        I = imread(image);
    case 'gray'
        I = imread(image);
        if size(I,3) == 3
            I = rgb2gray(I);
        end
end

% FRAME IMAGE - modif - 20130228
[If,N_frame] = framePicture(I,0.3);
I = If;
Pini = Pini + N_frame;


%--------------------------------------------------------------------------
% 3) GRID initialisation
%--------------------------------------------------------------------------

switch type_of_model
    case 'face'
        positions = [9,11,13,15,19,21,23,24,28];
        S0 = cano2Points(s0);
        S0short = zeros(size(Pini));

        for i=1:size(Pini,1)
            S0short(i,:) = S0(positions(i),:);
        end
    case 'Leye'
        Pini = Pini(1:2,:);
        positions = [1,3];
        S0 = cano2Points(s0);
        S0short = zeros(size(Pini));

        for i=1:size(Pini,1)
            S0short(i,:) = S0(positions(i),:);
        end;
    case 'Reye'
        Pini = Pini(3:4,:);
        positions = [1,3];
        S0 = cano2Points(s0);
        S0short = zeros(size(Pini));

        for i=1:size(Pini,1)
            S0short(i,:) = S0(positions(i),:);
        end;
    case 'nose'
        Pini = Pini([5,6,7],:);
        positions = [2,4,6];
        S0 = cano2Points(s0);
        S0short = zeros(size(Pini));

        for i=1:size(Pini,1)
            S0short(i,:) = S0(positions(i),:);
        end;
    case 'mouth'
        Pini = Pini([6,8,9],:);
        positions = [1,2,6];
        S0 = cano2Points(s0);
        S0short = zeros(size(Pini));

        for i=1:size(Pini,1)
            S0short(i,:) = S0(positions(i),:);
        end;
    case 'improved'
        positions = [9,11,13,15,19,21,23,24,28];
        S0 = cano2Points(s0);
        S0short = zeros(size(Pini));

        for i=1:size(Pini,1)
            S0short(i,:) = S0(positions(i),:);
        end;
end

% register Pini to S0short:
[d,Sini,transform] = procrustes(S0short,Pini);
transform.c = ones(size(S0,1),1)*transform.c(1,:);

%--------------------------------------------------------------------------

tprime = [0 0 0 0];
p = zeros(1,Ns);
Xini = fromP2X(p,transform,tprime,s0,Vs(:,1:Ns),Ls(1:Ns));

% if debug
% 
%      plotImAndGrid(I,Xini,dt1,'r.-');
%      hold on
%      plot(Pini(:,1),Pini(:,2),'gs');
%      hold off
%      %a = input('');
% end

%--------------------------------------------------------------------------

X = Xini; % grid derive from Pini is the initialized grid
fprintf('initialising grid...done\n');



%//////////////////////////////////////////////////////////////////////////
%   END INI
%//////////////////////////////////////////////////////////////////////////

%//////////////////////////////////////////////////////////////////////////
%   FITTING
%//////////////////////////////////////////////////////////////////////////


%--------------------------------------------------------------------------
% 1) save firt frame
%--------------------------------------------------------------------------
if debug
    
    close all;
    figure(1)
    filename = 'output_fitting.gif';
    plotImAndGrid(rgb2gray(I),X,dt1,'g.-');title('ini');
    drawnow
    a = input('');
    
end
%--------------------------------------------------------------------------
% 2) start fitting process
%--------------------------------------------------------------------------

fittingbool = true;
cmp = 0;
        
while (fittingbool==true && cmp < 30);
    
    fittingbool = false;
    cmp = cmp +1;
    
    % 1.0 find p* = [p,tprime] and T = transform
    %------------------------------
    s0_point = cano2Points(s0);
    [d,s_point,transform] = procrustes(s0_point,X);
    s = point2Cano(s_point);
    [p,sprime] = projectFromX(s,Vs(:,1:Ns),s0);
    tprime = [0,0,0,0];
    %------------------------------

    % 1.1 find the resildual r(p*)
    %------------------------------
    [A,error1] = fromX2AGlobalLight(X,I,WM,type_of_feature);
    
    if error1 == 1
            fprintf('fitting stopped : grid outside the face');
            fittingbool =0;
    else
            [lambdas,Am] = projectFromX(A,Vt(:,1:Nt),A0);
            r = A-Am;
            e = r*r';
            fprintf('e ref: %f\n',e);

            %------------------------------
            % 6 print new grid on face
            %------------------------------
            if debug
                subplot(2,2,1);plotImAndGrid(I,X,dt1,'g-');title(['iter: ' int2str(cmp)]);
                switch type_of_feature
                    case 'rgb'
                        subplot(2,2,2);plotAppearanceColor(abs(r),in,false); title(['error: ' num2str(e)]);
                        subplot(2,2,3);plotAppearanceColor(A,in,false); 
                        subplot(2,2,4);plotAppearanceColor(Am,in,false);
                    case 'gray'
                        subplot(2,2,2);plotAppearance(abs(r),in,false); title(['error: ' num2str(e)]);
                        subplot(2,2,3);plotAppearance(A,in,false); 
                        subplot(2,2,4);plotAppearance(Am,in,false);
                end
                drawnow
            end
            %------------------------------

            %------------------------------
            % 2 for each dp* do p* = p* + dp* and find coresponding r
            %------------------------------
            tic
            dp = findNextMoveGlobal(I,WM,p,DP,transform,s0,A0,Vs,Ls,Ns,Vt,Nt,r,type_of_feature);
            toc
            %------------------------------
            % 5 check if this improve the error
            %------------------------------
            K = [1 0.5 0.25 0.05];
            improve = false;
            cmp2= 0;

            while(improve == false && cmp2<numel(K))

                cmp2 = cmp2+1;
                %update p and tprime:
                p_new = p + K(cmp2).*dp(1:Ns)';
                tprime_new = tprime + K(cmp2).*dp(Ns+1:end)';

                X_new = fromP2X(p_new,transform,tprime_new,s0,Vs,Ls);
                [A_new,error1] = fromX2AGlobalLight(X_new,I,WM,type_of_feature);
                [lambdas,Am_new] = projectFromX(A_new,Vt(:,1:Nt),A0);

                e_new = (A_new-Am_new)*(A_new-Am_new)';
                fprintf('e new (k=%f): %f\n',K(cmp2),e_new);
                if e_new < e
                    improve = true;
                    fittingbool = true;
                    X = X_new; 
                end

            end
    end

    
end

X = X-N_frame;

end
