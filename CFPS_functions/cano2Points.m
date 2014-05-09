function [X] = cano2Points(x)
    X = zeros(length(x)/2,2);
    
    index = 0;
    for i=1:length(x)/2
        index =index +1;
        X(i,1) = x(index);
        index =index +1;
        X(i,2) = x(index);
    end
end