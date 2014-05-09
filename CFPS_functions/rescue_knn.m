function [Xr] = rescue_knn(X)

    Xr = X;
    for i=1:size(Xr,1)
        if Xr(i,1)~=i
            position = 1;
            for j=1:size(Xr,2)
                if Xr(i,j)==i
                    position = j;
                end
            end
            fprintf('pb, %u', position);
            intrudor = Xr(i,1);
            Xr(i,1) = i;
            Xr(i, position) = intrudor;
        end
        
        
    end

end