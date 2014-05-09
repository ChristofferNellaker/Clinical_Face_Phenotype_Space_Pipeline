%//////////////////////////////////////////////////////////////////////////
% compute p0p1 for each instance to each class 
% adapted from script_p0p1.m in PROJECT/PVALUE/FINAL/
%//////////////////////////////////////////////////////////////////////////

function [L_predicted_position, unq_syndromes] = global_p0p1_script(entries_of_interest, syndrome_labels, individual_labels)
if isdeployed
else
    addpath('/net/isi-backup/restricted/face/PROJECT/PACS1_CASE/');
end
if isdeployed
else
    addpath('/net/isi-software/tools/matlab_extools/serialize/');
end
    %--------------------------------------------------------------------------    
    
    unq_syndromes = unique(syndrome_labels);
    
    
    unq_syndromes = [unq_syndromes;'self';'multiple_other'];
    
    X = [];
    L = [];
    
    for i=1:numel(entries_of_interest)
        X = [X;deserialize(entries_of_interest(i).fusion_intensity_pca_lmnn_pca)];
        synd_ind = 0;
        for ii=1:numel(unq_syndromes)
            if isequal(syndrome_labels{i},unq_syndromes{ii})
                synd_ind = ii;
                break
            end
        end
        L = [L;synd_ind];
        %L = [L;synd_ind*ones(size(X(end,:)),1)];
    end
    
    %for i=1:numel(listClasses)
    %    load([root listClasses(i).name]);
    %    x = superClass.fusion_lmnn;
    %    X = [X;x];
    %    L = [L;i.*ones(size(x,1),1)];
    %end

    %--------------------------------------------------------------------------

    [IDX,DIST] = knnsearch(X,X,'K',size(X,1));
    
    K = 20;
    
    LMat = L(IDX);
    KLMat = zeros(size(X,1),K+1);
    KDIST = zeros(size(X,1),K+1);
    % Provisions for eliminating subsequent copies of the same individual
    % in the first K neighbours
    Indiv_Mat = individual_labels(IDX);
    [indiv_mat_size,b] = size(Indiv_Mat);
    for i_row=1:indiv_mat_size
        %i_row
        curr_k_counted = 0;
        for i_col=2:indiv_mat_size
            if ismember(Indiv_Mat(i_row,i_col), Indiv_Mat(i_row,1:i_col-1))
                if ismember(Indiv_Mat(i_row,i_col), Indiv_Mat(i_row,1:1))
                    LMat(i_row,i_col) = numel(unq_syndromes)-1;%max(L)-1; % self code
                else
                    LMat(i_row,i_col) = numel(unq_syndromes);%max(L); % multiple_other_code
                end
            else
                curr_k_counted = curr_k_counted+1;
                KLMat(i_row, curr_k_counted) = L(IDX(i_row,i_col));
                KDIST(i_row, curr_k_counted) = DIST(i_row,i_col);
            end
            if curr_k_counted > K
                %i_col
                break
            end
        end
    end
    
    % 
    
    IDX = IDX(:,2:end);
    %LMat = L(IDX);
    LMat = LMat(:,2:end);
    KLMat = KLMat(:,2:end);
    DIST = DIST(:,2:end);
    KDIST = KDIST(:,2:end);
    
    meanDIST = mean(KDIST(:,1:K),2);
    %meanDIST = mean(DIST(:,1:K),2);
    %P0P1 = zeros(size(X,1),max(L));
    %CLASSIFICATION = zeros(size(X,1),max(L));
    P0P1 = zeros(size(X,1),numel(unq_syndromes));
    CLASSIFICATION = zeros(size(X,1),numel(unq_syndromes));
    L_predicted_position = zeros(size(X,1),1);
    

    for i=1:size(X,1)
        %i
        %for group=1:max(L)
        for group=1:numel(unq_syndromes)
            %if ~find(LMat(i,:)==group); end
            idx = find(KLMat(i,:)==group);
            idx = idx(1:min(K,numel(idx)));

            p0p1 = 0;
            for j=1:numel(idx)
                p0p1 = p0p1+DIST(i,idx(j))/sqrt(meanDIST(i)*meanDIST(IDX(i,idx(j))));
            end

            P0P1(i,group) = p0p1/numel(idx);
        end

        [p0p1,idx] = sort(P0P1(i,:),'ascend');
        CLASSIFICATION(i,:) = idx;
        %L_predicted_position(i) = unq_sydromes(L(i));
        L_predicted_position(i) = find(idx==L(i));
        
        
    end

    %--------------------------------------------------------------------------
    
end



