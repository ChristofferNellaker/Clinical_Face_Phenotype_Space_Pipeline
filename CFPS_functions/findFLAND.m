function [P,conf,DETS] = findFLAND(image,opts)
        
        if ischar(image)
            I = imread(image);
        else
            I =image;
        end
        
        %face_detected = 1;
        P = [];
        conf = [];
        DETS = [];
        
        % 1-COMPUTE THE AUTOMATED FLAND
        DETS=runfacedet(I,image);
        if isempty(DETS)
            %error_message = '-bbx 0';
            %face_detected = 0;
        else
            %detect the facial features
            PTS=zeros(0,0,size(DETS,2));
            DESCS=zeros(0,size(DETS,2));
            CONF = zeros(1,size(DETS,2));

            for j=1:size(DETS,2)
                [P,conf]=findparts(opts.model,I,DETS(:,j));
                PTS(1:size(P,1),1:size(P,2),j)=P;
                CONF(j) = conf;
            end

            % select the most probable set of points
            [conf,best_idx] = max(CONF);
            %error_message = ['-bbx ' int2str(size(DETS,2)) ' -conf ' num2str(conf)];

            P = PTS(:,:,best_idx)';
            DETS = DETS(:,best_idx);
        end
        
end