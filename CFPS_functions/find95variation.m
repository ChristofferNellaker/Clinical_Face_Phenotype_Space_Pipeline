function [n] = find95variation(L,percent)

s = sum(L);

found = false;
cmp = 0;
n=0;

while(found==false && cmp < numel(L))
    cmp = cmp +1;
    s_temp = sum(L(1:cmp));
    
    if (s_temp/s) >= percent
        found = true;
        n = cmp;
    end
end

end