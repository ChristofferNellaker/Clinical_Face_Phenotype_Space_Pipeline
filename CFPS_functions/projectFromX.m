function [p,xprime] = projectFromX(x,V,xmean)


    p = zeros(1,size(V,2));

    % each instance
    x_temp = x-xmean;
    
    for j=1:size(V,2)
        p(1,j) = x_temp*V(:,j);
    end
    
    xprime = xmean + p*V';


end
