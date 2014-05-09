function [ol] = overlap(cons1,cons2,I)

    % find roi cons1
    c = cons1(:,1);
    r = cons1(:,2);
    BW1 = roipoly(I,c,r);
    
    % find roi cons2
    c = cons2(:,1);
    r = cons2(:,2);
    BW2 = roipoly(I,c,r);
    
    
%     subplot(1,3,1);
%     imshow(BW1);
%     subplot(1,3,2);
%     imshow(BW2);
%     subplot(1,3,3);
%     imshow(I);
%     a = input('');

    BW3 = (BW1 ==1).*(BW2==1);
    ol = sum(BW3(:))/sum(BW1(:));
    
%     figure(10)
%     subplot(1,3,1);
%     imshow(BW1);
%     subplot(1,3,2);
%     imshow(BW2);
%     subplot(1,3,3);
%     imshow(BW3);
%     
%     fprintf('%u - %u - %u',sum(BW1(:)),sum(BW2(:)),sum(BW3(:)));
%     a = input('');
    
end