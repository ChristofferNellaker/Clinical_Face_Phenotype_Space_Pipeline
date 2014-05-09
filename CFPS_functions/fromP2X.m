function [X] = fromP2X(ps,transform,tprime,s0,Vs,Ls)

    V = Vs(:,1:length(ps));
    s = projectFromP(ps,V,Ls,s0);
    s_point = cano2Points(s);
    X = inverseGlobalTransform (s_point,transform);
    
    %%%%%%%%%%%%%%%%%%%%%%%%transfo global;    
    s = 1 + tprime(1);
    theta = tprime(2); 
    tx = tprime(3);
    ty = tprime(4);
    
    M = [s*cos(theta) -s*sin(theta);...
        s*sin(theta) s*cos(theta)];
    
    Y = zeros(size(X));
    for i=1:size(Y,1)
    Y(i,:) = X(i,:) - mean(X);
    end
    
    Y = M*Y'+[tx*ones(1,size(Y,1));ty*ones(1,size(Y,1))];
    Y=Y';
    
    for i=1:size(Y,1)
    Y(i,:) = Y(i,:) + mean(X);
    end
    
    X = Y;
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
end