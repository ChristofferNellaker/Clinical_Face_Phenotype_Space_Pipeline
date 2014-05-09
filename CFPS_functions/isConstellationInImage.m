function [in] = isConstellationInImage(imgPath,X)

    I = imread(imgPath);
    dimX = size(I,2);
    dimY = size(I,1);
    
    in = ones(size(X,1),1);
    for i=1:size(X,1)
        
        if (X(i,1)<1)||(X(i,1)>dimX)||(X(i,2)<1)||(X(i,2)>dimY)
            in(i) = 0;
        end
        
    end

end