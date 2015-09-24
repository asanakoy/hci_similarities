function [ sequenceIndex, newImageIndex ] = getSequenceIndex( frameId,  lookupTable )
    assert(1 <= frameId && frameId <= lookupTable(end).end, 'Incorrect frameId');
    
    l = 1;
    r = length(lookupTable);
    sz = r - l + 1;
    m = l + floor(sz / 2);
    
    while (l ~= r)
        
        if (lookupTable(m).begin <= frameId && frameId <= lookupTable(m).end)
            break; % return m
        elseif (lookupTable(m).begin > frameId)
            r = m - 1;
        elseif (lookupTable(m).end < frameId)
            l = m + 1;
        else
            l 
            m
            r
            lookupTable(m)
            assert(false, 'incorrect input! index: %d', frameId);
        end
        
        sz = r - l + 1;
        m = l + floor(sz / 2);
    
    end
    
    assert(m >= 1 && m <= length(lookupTable));
    newImageIndex = frameId - lookupTable(m).begin + 1;
    sequenceIndex = m;
end