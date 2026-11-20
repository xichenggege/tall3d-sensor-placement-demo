function sensorsInd = find_sensorInd(x_coord,y_coord,xF_,yF_)
%sensorsInd Summary of this function goes here
%   find index of proposed sensor coordination in column-wise xF, yF
    for i = 1:numel(x_coord)
        interval = 0.002;
        while isempty(find(abs(x_coord(i)-xF_)<(interval/2)))
            interval = interval*1.5;
        end
        xInd = find(abs(x_coord(i)-xF_)<(interval/2));
    
        interval = 0.002;
        while isempty(find(abs(y_coord(i)-yF_)<(interval/2)))
            interval = interval*1.5;
        end
        yInd = find(abs(y_coord(i)-yF_)<(interval/2));
    
        ind  = intersect(xInd,yInd);
        sensorsInd(i) = ind(1);
    end
end
