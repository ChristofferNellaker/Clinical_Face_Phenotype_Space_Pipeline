function [dp] = findNextMoveGlobal(I,WM,p,DP,transform,s0,A0,Vs,Ls,Ns,Vt,Nt,r,type_of_feature)
    
    Dr = zeros(size(A0,2),size(DP,2));
    GOOD = [];
    n = size(WM,1);
    
    switch type_of_feature
        case 'rgb'
                 for j=1:size(DP,2)

                    p_temp = p + DP(1:Ns,j)';
                    tprime_temp = DP(Ns+1:end,j)';

                    X = fromP2X(p_temp,transform,tprime_temp,s0,Vs(:,1:Ns),Ls);
                    xmin = min(X);
                    xmax = max(X);

                    if (1<=xmin(1))&&(xmax(1)<=size(I,2))&&(1<=xmin(2))&&(xmax(2)<=size(I,1))

                        GOOD = [GOOD,j];
                        A_temp = zeros(n,3);

                        for i=1:n
                            x_source = WM(i,1)*X(WM(i,2),1)+WM(i,3)*X(WM(i,4),1)+WM(i,5)*X(WM(i,6),1);
                            y_source = WM(i,7)*X(WM(i,8),2)+WM(i,9)*X(WM(i,10),2)+WM(i,11)*X(WM(i,12),2);

                            nx = floor(x_source);
                            mx = ceil(x_source);
                            ex = x_source-nx;
                            ny = floor(y_source);
                            my = ceil(y_source);
                            ey = y_source-ny;


                            a = (1-ex)*(1-ey);
                            b = ex*(1-ey);
                            c =(1-ex)*ey;
                            d = ex*ey; 

                            f1 = I(ny,nx,1);
                            f2 = I(ny,mx,1);
                            f3 = I(my,nx,1);
                            f4 = I(my,mx,1);

                            A_temp(i,1) = a*f1 + b*f2 + c*f3 + d*f4;

                            f1 = I(ny,nx,2);
                            f2 = I(ny,mx,2);
                            f3 = I(my,nx,2);
                            f4 = I(my,mx,2);

                            A_temp(i,2) = a*f1 + b*f2 + c*f3 + d*f4;


                            f1 = I(ny,nx,3);
                            f2 = I(ny,mx,3);
                            f3 = I(my,nx,3);
                            f4 = I(my,mx,3);

                            A_temp(i,3) = a*f1 + b*f2 + c*f3 + d*f4;

                        end

                        A_temp = A_temp(:)';
                        [lambdas,Am_temp] = projectFromX(A_temp,Vt(:,1:Nt),A0);
                        Dr(:,j) = (A_temp-Am_temp)'- r';

                    else
                        fprintf('!grid out of image!\n');
                    end
                    
                end
        case 'gray'
                 for j=1:size(DP,2)

                    p_temp = p + DP(1:Ns,j)';
                    tprime_temp = DP(Ns+1:end,j)';

                    X = fromP2X(p_temp,transform,tprime_temp,s0,Vs(:,1:Ns),Ls);
                    xmin = min(X);
                    xmax = max(X);

                    if (1<=xmin(1))&&(xmax(1)<=size(I,2))&&(1<=xmin(2))&&(xmax(2)<=size(I,1))

                        GOOD = [GOOD,j];
                        A_temp = zeros(1,n);

                        for i=1:n
                            x_source = WM(i,1)*X(WM(i,2),1)+WM(i,3)*X(WM(i,4),1)+WM(i,5)*X(WM(i,6),1);
                            y_source = WM(i,7)*X(WM(i,8),2)+WM(i,9)*X(WM(i,10),2)+WM(i,11)*X(WM(i,12),2);

                            nx = floor(x_source);
                            mx = ceil(x_source);
                            ex = x_source-nx;
                            ny = floor(y_source);
                            my = ceil(y_source);
                            ey = y_source-ny;


                            a = (1-ex)*(1-ey);
                            b = ex*(1-ey);
                            c =(1-ex)*ey;
                            d = ex*ey; 

                            f1 = I(ny,nx,1);
                            f2 = I(ny,mx,1);
                            f3 = I(my,nx,1);
                            f4 = I(my,mx,1);

                            A_temp(1,i) = a*f1 + b*f2 + c*f3 + d*f4;

                        end
                        
                        [lambdas,Am_temp] = projectFromX(A_temp,Vt(:,1:Nt),A0);
                        Dr(:,j) = (A_temp-Am_temp)'- r';

                    else
                        fprintf('!grid out of image!\n');
                    end
                    
                end                   
    end
    
    Dr = Dr(:,GOOD);
    DP = DP(:,GOOD);
    %------------------------------
    % 3 compute the jacobian J = Dr*DP'(Dp*DP')-1
    %------------------------------
    J = Dr*pinv(DP); 
    R = (J'*J)\J';
    %------------------------------
    % 4 dp* = -R*r
    %------------------------------
    dp = -R*r';
    
end