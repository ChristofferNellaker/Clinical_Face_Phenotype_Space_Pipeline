function [xprime] = projectFromP(p,V,L,xmean)
xprime = xmean + p*V';
end
