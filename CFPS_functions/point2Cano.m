function [x] = point2Cano(X)
    x = zeros(1,length(X(:)));
    index = 0;
    for i=1:size(X,1)
        index = index +1;
        x(index) = X(i,1);
        index =index +1;
        x(index) = X(i,2);
    end
end