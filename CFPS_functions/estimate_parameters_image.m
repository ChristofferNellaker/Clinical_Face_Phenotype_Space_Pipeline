function [eye_dist,v,w,a0] = estimate_parameters_image(Xman,point_of_interest)
    
    Xman = Xman(point_of_interest,:);
    eye_dist = (norm(Xman(1,:)-Xman(2,:))+norm(Xman(3,:)-Xman(4,:)))/2;

    V = [];
    idx_v = [2 1;3 1;4 1;3 2;4 2;4 3];
    for k=1:size(idx_v,1)
        v = Xman(idx_v(k,1),:)-Xman(idx_v(k,2),:);
        v = v./norm(v);
        V = [V;v];
    end
    v = mean(V);
    v = v./norm(v);
    w = [v(2),-v(1)];
    a0 = acosd(dot(v,[1 0]));
    sign_a0 = sign(asind(dot(v,[0 1])));
    a0 = sign_a0*a0;
    
end