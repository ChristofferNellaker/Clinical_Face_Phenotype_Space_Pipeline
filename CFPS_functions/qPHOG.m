function [D] = qPHOG(I,edges,nbBin,ROI,level)
% I is gray scale image

%tic;
if edges
    EDGES = edge(I,'canny');
else
    EDGES = I;
end

hx = [-1,0,1];
hy = -hx';
grad_xr = imfilter(double(EDGES),hx);
grad_yu = imfilter(double(EDGES),hy);
angles=atan2(grad_yu,grad_xr);
magnit=((grad_yu.^2)+(grad_xr.^2)).^.5;

binEdges = -pi:2*pi/nbBin:pi;
binClass = zeros(size(angles));

for i=1:nbBin-1
    binClass = binClass + i.*(binEdges(i)<=angles).*(angles<binEdges(i+1));
end
binClass = binClass + nbBin.*(binEdges(nbBin)<=angles).*(angles<=binEdges(nbBin+1));

%--------------------------------------------------------------------------

division = 3;
D = zeros(size(ROI,1),nbBin*division^2*level);

for i=1:size(ROI,1)
    
    rect = ROI(i,:);
    rectX = rect(3)/2;
    rectY = rect(4)/2;
    rectCenter = [rect(1)+rectX,rect(2)+rectY];
    
    for l0 = 1:level
        
        rect0 = [rectCenter(1)-rect(3)/(2*l0),rectCenter(2)-rect(4)/(2*l0),rect(3)/l0,rect(4)/l0];
        
        stepX = rect0(3)/division;
        stepY = rect0(4)/division;
        x = rect0(1):stepX:rect0(1)+2*stepX;
        y = rect0(2):stepY:rect0(2)+2*stepY;
        [X,Y] = meshgrid(x,y);

        C = [X(:),Y(:)];

        for l1=1:size(C,1)
            % binClassCrop
            BCC = imcrop(binClass,[C(l1,1),C(l1,2),stepX,stepY]);
            MAGN = imcrop(magnit,[C(l1,1),C(l1,2),stepX,stepY]);
            bcc = BCC(:);
            magn = MAGN(:);
            
            CMP = zeros(1,nbBin);
            for l2=1:numel(bcc)
                CMP(bcc(l2)) = CMP(bcc(l2))+magn(l2);
            end
            if sum(CMP)>0
                CMP = CMP./sum(CMP);
            end

            position = (l0-1)*division^2*nbBin + (l1-1)*nbBin;
            D(i,position+1:position+nbBin) = CMP;
        end
    end

end

%toc

end