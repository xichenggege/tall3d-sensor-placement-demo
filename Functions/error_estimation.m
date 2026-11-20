function [nmse_mean,nmse] = error_estimation(ref,pred)
%error_estimation: Evaulate normalized mean square error between reference and prediction
% residual sum of squares
    for i = 1:numel(ref(1,:))
        nmse(i) = NMSE(ref(:,i),pred(:,i));
    end
    nmse_mean    =  sum(nmse)/numel(ref(1,:)); 
 
    function [nmse] = NMSE(ref,pred)
    %NMSE: Evaulate normalized mean square error between reference and prediction
    % residual sum of squares
        res     = norm(ref(:)-pred(:),2).^2;
        tot     = norm(ref(:),2).^2;
        nmse    = res/tot;
    end
end



