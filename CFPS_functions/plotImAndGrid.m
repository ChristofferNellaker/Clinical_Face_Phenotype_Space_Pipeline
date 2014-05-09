function [] = plotImAndGrid(I,X,dt,parametre)

imshow(I,[]);
hold on

for i=1:size(dt,1)
    
    X_line = [X(dt(i,1),:);X(dt(i,2),:)];
    plot(X_line(:,1),X_line(:,2),parametre);
    X_line = [X(dt(i,2),:);X(dt(i,3),:)];
    plot(X_line(:,1),X_line(:,2),parametre);
    X_line = [X(dt(i,3),:);X(dt(i,1),:)];
    plot(X_line(:,1),X_line(:,2),parametre);
    
end

end