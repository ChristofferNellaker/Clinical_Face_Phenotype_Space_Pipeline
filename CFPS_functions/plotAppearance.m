function [im] = plotAppearance(app,in,filter)
    
    %close all;
    im = mean(app)*ones(size(size(in,2),size(in,1)));
    index = 0;
    
    for i=1:size(in,1)
    for j=1:size(in,2)   
        if in(i,j)==1
            index = index +1;
            im(j,i) = app(index);
        end
    end
    end
    
    if filter
    H = fspecial('disk',0.5);
    im = imfilter(im,H,'replicate');
    end
    
    %imshow(flipud(im'),[min(app) max(app)]);
    imshow(im,[min(app) max(app)]);
end