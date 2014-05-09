function [App,error] = fromX2AGlobalLight(X,I,WM,type_of_feature)
    
    error = 0;
    n = size(WM,1); 
    
    App = [];
    
    switch type_of_feature
    case 'rgb'
                    App = zeros(n,3);
                    xmin = min(X);
                    xmax = max(X);
                    if (1<=xmin(1))&&(xmax(1)<=size(I,2))&&(1<=xmin(2))&&(xmax(2)<=size(I,1))%check if the grid is inside the image
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

                            App(i,1) = a*f1 + b*f2 + c*f3 + d*f4;

                            f1 = I(ny,nx,2);
                            f2 = I(ny,mx,2);
                            f3 = I(my,nx,2);
                            f4 = I(my,mx,2);

                            App(i,2) = a*f1 + b*f2 + c*f3 + d*f4;


                            f1 = I(ny,nx,3);
                            f2 = I(ny,mx,3);
                            f3 = I(my,nx,3);
                            f4 = I(my,mx,3);

                            App(i,3) = a*f1 + b*f2 + c*f3 + d*f4;

                        end
                    else
                        fprintf('!grid out of image!\n');
                        error = 1;
                    end
                    App = App(:)';
    case 'gray'
                    App = zeros(n,1);
                    xmin = min(X);
                    xmax = max(X);
                    if (1<=xmin(1))&&(xmax(1)<=size(I,2))&&(1<=xmin(2))&&(xmax(2)<=size(I,1))%check if the grid is inside the image
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

                            f1 = I(ny,nx);
                            f2 = I(ny,mx);
                            f3 = I(my,nx);
                            f4 = I(my,mx);

                            App(i,1) = a*f1 + b*f2 + c*f3 + d*f4;


                        end
                    else
                        fprintf('!grid out of image!\n');
                        error = 1;
                    end
                    App = App(:)';
    end
  
end