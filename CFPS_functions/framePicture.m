function [If,N] = framePicture(I,percent)

[n,m,d] = size(I);

N = max(n,m);
N = ceil(N*percent);

If = zeros(n+2*N,m+2*N,d);

If(N+1:N+n,N+1:N+m,:) = I;
If = uint8(If);

end
