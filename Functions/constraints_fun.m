function [constraints_index] = constraints_fun(xv,yv,xsensor,ysensor,radius)
%CONSTRAINTS_FUN Exclude inaccessible TALL-3D locations and nearby sensors.
%   TRUE entries are excluded. XV and YV contain candidate coordinates in
%   metres; XSENSOR and YSENSOR contain the selected coordinates in metres.
%   RADIUS is the minimum centre-to-centre spacing. A point at exactly
%   RADIUS remains admissible, matching the original strict inequality.
%
    constraints_index = false(numel(xv),1);

    % Constraint LBE region
    % Constraints 1
    constraints_index(find(xv<1e-10 & xv>-0.25 & yv<0.0085)) = true;

    % Constraints 2
    constraints_index(find(xv>0.2 & xv<0.45 &yv<0.0139)) = true;

    % Constraints 3
    constraints_index(find(xv>1e-10 & xv<0.17 & yv<=0.08)) = true;
    % 
    % Constraints 4
    constraints_index(find(xv>0.18 & xv<0.2 & yv<=0.139)) = true;

    %% Constraint insulation regation
    % Constraints 1
    constraints_index(find(xv<=-0.015 & xv>=-0.25 & yv>0.0115)) = true;

    % Constraints 2
    constraints_index(find(xv>=-0.015 & xv<=0.012 & yv>0.195)) = true;

    % Constraints 3
    constraints_index(find(xv>=0.012 & yv>0.15675)) = true;
    % 
    % Constraints 4
    constraints_index(find(xv>0.206 & yv>0.0167)) = true;

    % Enable external insulation
            % Constraints 4
    constraints_index(find(xv>=-0.05 & xv<= 0.035 &  yv== 0.245)) = false;
    constraints_index(find(xv>= 0.035 &  yv>= 0.2)) = false;
    constraints_index(find(xv== -0.05 &  yv>= 0.2)) = false;
    constraints_index(find(xv== 0.035 &  yv>= 0.2)) = false;

    % Constraints 2, new sensor cannot be too close to each other
    if ~isempty(xsensor)
        for j = 1:numel(xsensor)
            Dij = pdist2([xv,yv],[xsensor(j),ysensor(j)]);
            constraints_index(Dij<radius) = true;
        end
    end
end

