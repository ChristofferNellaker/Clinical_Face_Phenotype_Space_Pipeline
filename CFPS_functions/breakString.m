function stringCell = breakString(s,charactere)
    stringCell={};
    currentString = '';
    cmp = 0;
    for i=1:numel(s)
        if s(i)==charactere
            cmp = cmp + 1;
            stringCell{cmp} = currentString;
            currentString = '';
        else
            currentString = [currentString s(i)];
            if i==numel(s)
                cmp = cmp + 1;
                stringCell{cmp} = currentString;
            end
        end
    end
    
end