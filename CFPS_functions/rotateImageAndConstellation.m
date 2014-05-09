function [Ir,Xr] = rotateImageAndConstellation(I,a0,X)

    Ir = imrotate(I,a0,'bilinear','loose');
    
    [n,m,d] = size(I);
    C = [m/2,n/2];

    X_tmp = X;
    for i=1:size(X_tmp,1)
        X_tmp(i,:) = X(i,:)-C;
    end
    
    a1 = -a0;
    Rot = [cosd(a1),-sind(a1);...
                        sind(a1),cosd(a1)];
                    
    X_tmp_2 = (Rot*X_tmp')';
    [n,m,d] = size(Ir);
    C = [m/2,n/2];

    for i=1:size(X_tmp_2,1)
        X_tmp(i,:) = X_tmp_2(i,:)+C;
    end
    
    Xr = X_tmp;
end