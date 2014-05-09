function [transform] = align2PointConstellations(X1,X2,display)

% X1, X2 contain respectively the constellation 1 and 2
% OUTPUT:
% c = transform.c;
% T = transform.T;
% b = transform.b;
% 
% Z = b*Y*T + c;

% 1) add a third points to X1 and X2

X = X1;
u = X(2,:)-X(1,:);
v = [u(2),-u(1)];
x3 = mean(X)+v; 
X = [X;x3];
X1 = X;

X = X2;
u = X(2,:)-X(1,:);
v = [u(2),-u(1)];
x3 = mean(X)+v; 
X = [X;x3];
X2 = X;

% 2) find the Procrustes transform to align them
[d,Z,transform] = procrustes(X1,X2);

if display
    
    figure
    hold on
    plot(X1(:,1),X1(:,2),'o');
    plot(X1(3,1),X1(3,2),'x');
    plot(X2(:,1),X2(:,2),'ro');
    plot(X2(3,1),X2(3,2),'rx');
    
    c = transform.c;
    T = transform.T;
    b = transform.b;
    
    Z = b*X2*T + c;

    plot(Z(:,1),Z(:,2),'g.');
    hold off
    axis equal
end


end