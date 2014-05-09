%//////////////////////////////////////////////////////////////////////////
% Computes CIF (clustering improvement factor) across syndrome_labels given an arbitrary struct of entries of interest
%
% adapted from ./PROJECT/PACS1_CASE/TEST_CODE_PROOF/MASTERSCRIPT.m
% adapted 140319 to use SSRF_compute_factor_multiple.m which was rewritten
% by Q
%
%This file is the MASTERSCRIPT to compute the SSRF on a large set of
% syndromes (exp GORLIN database)
%--------------------------------------------------------------------------


function [CIF_list, len_list, unq_syndromes] = global_CIF_script(entries_of_interest, syndrome_labels, individual_labels, unq_syndromes)

    %NAME = syndrome_labels;
    
    if isequal(unq_syndromes, [])
        unq_syndromes = unique(syndrome_labels);
    end
    
    unq_syndromes = [unq_syndromes;'self';'multiple_other'];


    %--------------------------------------------------------------------------
    % compute SSRF
    %--------------------------------------------------------------------------
    CIF_list = zeros(size(unq_syndromes));
    len_list = zeros(size(unq_syndromes));
    
    for synd_i=1:numel(unq_syndromes)
        %synd_i=91;
        BG = cell(1,2);
        X = cell(1,2);
        for i=1:numel(entries_of_interest)
            if isequal(syndrome_labels(i), unq_syndromes(synd_i))
                %X = [X;deserialize(entries_of_interest(i).fusion_intensity_pca_lmnn_pca)];
                X{1} = [X{1};deserialize(entries_of_interest(i).fusion_intensity_pca_lmnn_pca)];
                %X{1} = [X{1};deserialize(entries_of_interest(i).shape_pca_lmnn_pca)];
                %X{2} = [X{2};deserialize(entries_of_interest(i).appearance_intensity_pca_lmnn_pca)];
            else
                %BG = [BG;deserialize(entries_of_interest(i).fusion_intensity_pca_lmnn_pca)];
                BG{1} = [BG{1};deserialize(entries_of_interest(i).fusion_intensity_pca_lmnn_pca)];
                %BG{1} = [BG{1};deserialize(entries_of_interest(i).shape_pca_lmnn_pca)];
                %BG{2} = [BG{2};deserialize(entries_of_interest(i).appearance_intensity_pca_lmnn_pca)];
            end
        end
        if size(X{1},1)>=2
            %[Factors, Impostors,CIF_mean] = SSRF_compute_factor_multiple(BG,X);%CIF_compute(BG,X);
            [Factors, Impostors,CIF_mean] = SSRF_compute_factor(BG{1},X{1});
        else
            %CIF = [0,0,0];
            CIF_mean = 0
        end
        %CIF = [unq_syndromes(synd_i),CIF];
        %CIF_cell{synd_i} = [unq_syndromes(synd_i),CIF];
        %for ii=1:3
        %    CIF_list(synd_i,ii) = CIF(ii);
        %end
        CIF_list(synd_i) = CIF_mean;
        len_list(synd_i) = numel(X{1});
    end

end