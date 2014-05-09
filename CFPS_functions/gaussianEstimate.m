function [functionCell] = gaussianEstimate(DELTA,KEY_SORTED,XEXT,eye_dist)

    functionCell = cell(1,size(DELTA,2));
    
    for fiducial =1:size(DELTA,2)
        
        f = @(x) 1;
        
        for i=1:size(KEY_SORTED,1)
            Xtmp = XEXT{KEY_SORTED(i,1),KEY_SORTED(i,2)};
            center = Xtmp(fiducial,:);
            variance = DELTA(KEY_SORTED(i,1),fiducial);
            ftmp = @(x) exp(-norm(x-center)^2/(eye_dist*variance)^2);
            f = @(x) f(x)+ftmp(x);
        end
        
        functionCell{fiducial} = f;
        
    end

end