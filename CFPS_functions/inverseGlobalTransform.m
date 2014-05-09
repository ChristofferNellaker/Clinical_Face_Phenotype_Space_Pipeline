function [Xprime] = inverseGlobalTransform (xprime,transform)

c = transform.c;
T = transform.T;
b = transform.b;

Xprime = 1/b.*(xprime - c)/T;

end