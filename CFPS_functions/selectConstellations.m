function [Constellations,avgConf] = selectConstellations(P_CELL,conf,imagePath)

if isdeployed
else
    addpath('/net/isi-backup/restricted/face/PIPELINE_201306/functions');
end
    I = imread(imagePath);
    
    [c,idx] = sort(conf(1,:),'descend'); % sort constelations by confidence
    conf = conf(:,idx);
    
    % remove all negatives
    confPositive = [];
    for i=1:size(conf,2)
        if conf(1,i)>0
            confPositive = [confPositive,conf(:,i)];
        end
    end
    
    if isempty(confPositive)
        avgConf = [];
        Constellations = {};
    else

    fprintf('selectConstellations: nb const = %u, nb positive = %u\n',size(conf,2),size(confPositive,2));
    
    attributed = zeros(size(confPositive,2),1);
    listConst = {};
    
    while(sum(attributed)<size(confPositive,2))
        currentConst = {};
        avgConf = 0;
        
        for i=1:size(confPositive,2)
            if attributed(i) == 0
                if isempty(currentConst)
                    currentConst{numel(currentConst)+1} = P_CELL{confPositive(2,i),confPositive(3,i),confPositive(4,i)};
                    attributed(i)=1;
                    avgConf = avgConf+confPositive(1,i);
                    %fprintf('%u attributed seed\n',i);
                else
                    cons1 = currentConst{1};
                    cons1 = cons1([1 4 9 8],:);
                    cons2 = P_CELL{confPositive(2,i),confPositive(3,i),confPositive(4,i)};
                    cons2 = cons2([1 4 9 8],:);
                    ovl = overlap(cons1,cons2,I);
                    
                    if ovl>0.7
                        currentConst{numel(currentConst)+1} = P_CELL{confPositive(2,i),confPositive(3,i),confPositive(4,i)};
                        attributed(i)=1;
                        avgConf = avgConf+confPositive(1,i);
                        %fprintf('%u attributed\n',i);
                    end
                    
                end
            end
        end
        if isempty(currentConst)==false

            p = size(listConst,2)+1;
            listConst{1,p} = currentConst;
            listConst{2,p} = avgConf;
        end
    end
    

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%     figure(1)
%     imshow(imagePath);
%     hold on
%     for i=1:size(listConst,2)
%         
%         cellTmp = listConst{1,i};
%         fprintf('--set: %u , %u\n',i,numel(cellTmp));
%         color = rand(1,3);
%         for j=1:numel(cellTmp)
%             C = cellTmp{j};
%             plot(C(:,1),C(:,2),'.','color',color);
%         end
%         
%     end
%     hold off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    avgConf = zeros(1,size(listConst,2));
    Constellations = cell(1,size(listConst,2));
    
    for i=1:size(listConst,2)
        
        cellTmp = listConst{1,i};
        avgConf(i) = listConst{2,i}/numel(cellTmp);
        
        avgConst = cellTmp{1};
        for j=2:numel(cellTmp)
            avgConst = avgConst + cellTmp{j};
        end
        Constellations{i} = avgConst./numel(cellTmp);
        
        %fprintf('--set: %u , %u\n',i,numel(cellTmp));
        %fprintf('-----avg: %f\n',listConst{2,i}/numel(cellTmp));
        
    end
    
    [avgConf,idx] = sort(avgConf,'descend');
    Constellations = Constellations(idx);
    end
 
end