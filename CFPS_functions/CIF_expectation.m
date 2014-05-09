function [Rank,Expectation, Expectations_sim] = CIF_expectation(nbBG, NBX)

    %nbBG = 2754;
    %max_positive = 1000;
    %NBX = [2:1:18,20:20:200,max_positive];
    nbLoop = 1000;

    %EXPECTATIONS = zeros(1,numel(NBX));
    %EXPECTATIONS_SIM = zeros(1,numel(NBX));

    %for i=1:numel(NBX)

    %nbX = NBX(i)-1; % minus the considered instance
    nbX = NBX-1; % minus the considered instance
    nbTotal = nbX+nbBG;

    nbIntruders = zeros(1,nbLoop);
    for l=1:nbLoop
        RS = randsample(nbTotal,nbBG+1);
        LRS = RS<=nbX;
        nbIntruders(l) = find(LRS,1,'first');% size of the bag required to find one match
    end

    %EXPECTATIONS_SIM(i) = mean(nbIntruders);
    Expectations_sim = mean(nbIntruders);
    L = nbBG;
    n = nbX;

    x = 0:L;
    P_min_sup = (1-x./(L+1)).^n;
    P_min = zeros(1,L+1);
    for l=1:L
        P_min(l) = P_min_sup(l)-P_min_sup(l+1);
    end
    P_min(L+1) = P_min_sup(L+1);

    sum(P_min);
    Expectation = sum(x.*P_min);
    Rank = Expectation+1;
    %         EXPECTATIONS(i) = Expectation; 
    % 
    %     end
    % 
    % 
    %     figure(2)
    %     hold on
    %     plot(NBX,EXPECTATIONS,'o'); % expected values
    %     plot(NBX,EXPECTATIONS_SIM,'rx'); % simulated expectated values
    %     hold off
    % 
    %     %NOTE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     % the expectation is the number of intruders between the query and the
    %     % first match. Add +1 to match the real case experiment: size of the space
    %     % to consider to get the first positive match.
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end