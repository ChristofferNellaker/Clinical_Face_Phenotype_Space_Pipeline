function [] = plotAppearanceColor(app,in,filter)

    unit = numel(app)/3;
    
    appRed = uint8(app(1:unit));
    appGreen = uint8(app(unit+1:2*unit));
    appBlue = uint8(app(2*unit+1:3*unit));
    
    
    %close all;
    im = uint8(zeros(size(in,2),size(in,1),3));
    index = 0;
    
    for i=1:size(in,1)
    for j=1:size(in,2)   
        if in(i,j)==1
            index = index +1;
            im(j,i,1) = appRed(index);
            im(j,i,2) = appGreen(index);
            im(j,i,3) = appBlue(index);
        end
    end
    end
    
    if filter
    H = fspecial('disk',2);
    im = imfilter(im,H,'replicate');
    end
    
    %imshow(flipud(im'),[min(app) max(app)]);
    imshow(im,[]);
end