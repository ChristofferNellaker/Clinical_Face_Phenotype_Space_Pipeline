function [Xinit] = findInitialConstellation_X9(imgPath,P9,Xex,index9,nbRand,nbExample,display,verbose)

if isdeployed
else
    addpath('/net/isi-backup/restricted/face/AAM_2013/functions');
    addpath('/net/isi-backup/restricted/face/PIPELINE_201306/functions');
end

P = P9;

if isempty(P)
    if verbose
        fprintf('cannot find the 9 landmarks\n');
    end
    Xinit = [];
else
    if verbose
        fprintf('found the 9 landmarks\n');
    end
    
    if display
    %////////////////////////
    figure
    imshow(imgPath);
    hold on
    plot(P(:,1),P(:,2),'go');
    plot(P(:,1),P(:,2),'g+');
    %////////////////////////
    end
    
    % select a list of random example among the Xex
    idxEx = randsample(size(Xex,1),min(nbRand,size(Xex,1)));
    
    % procrustes to P and estimate the error d
    D = zeros(numel(idxEx),1);
    TRANSFORMS = cell(1,numel(idxEx));
    for i=1:numel(idxEx)

        X36 = cano2Points(Xex(idxEx(i),:));
        X9 = X36(index9,:);
        [d,Z,transform] = procrustes(P,X9);
        D(i) = d;
        TRANSFORMS{i} = transform;
        
        if display
        %////////////////////////
        plot(Z(:,1),Z(:,2),'w+');
        %////////////////////////
        end
    end
    
    %sort example per D
    [Ds,top] = sort(D,'ascend');
    top = top(1:min(nbExample,numel(top))); %top D
    topD = D(top);
    topIdxEx = idxEx(top); %top example
    topTRANSFORMS  = TRANSFORMS(top); %top transform
    W = topD./sum(topD);
    
    
    Xinit = zeros(size(X36));
    for i=1:numel(topIdxEx)
         
         X36 = cano2Points(Xex(topIdxEx(i),:));
         transform = topTRANSFORMS{i};
         
         c = transform.c;
         C = zeros(size(X36));
         for j=1:size(X36,1)
             C(j,:) = c(1,:);
         end
         T = transform.T;
         b = transform.b;
               
         X36P = b*X36*T + C;
         
         if display
         %////////////////////////
         plot(X36P(:,1),X36P(:,2),'ro');
         %////////////////////////
         end
        
         for j=1:size(Xinit,1)
             Xinit(j,:) = Xinit(j,:) + W(i).*X36P(j,:);
         end
    end
    
    if display
    %////////////////////////
    plot(Xinit(:,1),Xinit(:,2),'b.');
    %////////////////////////
    hold off
    end
end

end