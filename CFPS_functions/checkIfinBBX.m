function [ouput] = checkIfinBBX(X,bbx,I)

 CX = (X(:,1) <= size(I,2)).*(X(:,1) >= 1);
 CY = (X(:,2) <= size(I,1)).*(X(:,2) >= 1);
 
 Cbbx = 1;
 
 for i=1:size(X,1)
     
     if  (bbx(i,1)<=X(i,1))&&(bbx(i,2)>=X(i,1))&&(bbx(i,3)<=X(i,2))&&(bbx(i,4)>=X(i,2))
         
     else
         Cbbx = 0;
     end
     
 end
 ouput = prod(CX)*prod(CY)*Cbbx;
 
end