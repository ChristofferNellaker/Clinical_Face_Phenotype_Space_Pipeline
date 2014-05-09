function [Factors,Nb_intrudors,m_factor] = SSRF_compute_factor(BG,X)

% X should at least have two instances 


% size of the sets
nbX = size(X,1);
nbBG = size(BG,1);

% find nearest neighbors
[IDX,D] = knnsearch(X,X,'K',nbX);
[IDX] = rescue_knn(IDX);

IDX = IDX(:,2:end);
D = D(:,2:end);



[IDX_bg,D_bg] = knnsearch(BG,X,'K',nbBG);


% find the Ns to achieve 95% confidence to sample a positive
%Ns = nbBG+1;
%P = 1;
%
%while(P>=0.95)
%    Ns = Ns - 1;
%    [P] = SSRF_at_least_one_proba(nbX+nbBG-1,nbX-1,Ns);    
%end
[Rank,Expectation, Expectations_sim] = CIF_expectation(nbBG, nbX);

Factors = zeros(nbX,1);
Nb_intrudors = zeros(nbX,1);

for i=1:nbX
    
    % find the intruders
    Nb_intrudors(i) = sum(D_bg(i,:) < D(i,1));
    %Factors(i) = (Nb_intrudors(i)+1)/Rank;
    Factors(i) = Rank/(Nb_intrudors(i)+1);
end


%Rank;
%m_factor = 1/mean(Factors);
m_factor = mean(Factors);


end