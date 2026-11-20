function [Q,R,pivote] = qr_pivote_udf(X,constraints_type,constraints_fun,xv,yv,constraints_radius,p)
%% 'qr_pivote_udf' is for QR decomposition with pivoting using Householder transformation
%  Refer to "https://en.wikipedia.org/wiki/QR_decomposition"
%  [Q,R,pivote] = qr_pivote_udf(X) == [Q,R,P] = qr(X,0) 
% -------------------------------------------------------------------------
% By Xicheng Wang, xicheng@kth.se
% version 1.0 
% 2024-09-16
% -------------------------------------------------------------------------
%  Input
% -------------------------------------------------------------------------
% X: Matrix to be decomposed
% -------------------------------------------------------------------------
%  Output
% -------------------------------------------------------------------------
% Q*R = X*P
% pivote: order of sensor ranked by importance

% -------------------------------------------------------------------------
% Start here
% -------------------------------------------------------------------------
% m: number of desired sensors, i.e. number of extracted modes (normally
% the number of placed sensors >= extracted modes

% n: dimensions of a snapshot 
[m,n] = size(X); 

% initialization 
R      = X;
Q      = eye(m);
% P      = eye(n);
pivote = 1:n;

xsensor = [];
ysensor = [];

for k = 1:p    
    
    % refer to <https://www.netlib.org/lapack/lug/node42.html>
    % search the maximum two-norm of the column in R22, i.e., R(k:m,k:n)
    dlens = vecnorm(R(k:m,k:n),2,1);     % calculate 2-norm of R(k:m,k:n) along columns ⬇

    % Enforce constraints 
    if ~isempty(constraints_type)
        constraints_index = constraints_fun(xv(k:n),yv(k:n),xsensor,ysensor,constraints_radius);
        switch constraints_type
            case 'region-constraints'
                dlens(constraints_index) = 0;
            otherwise
                error('Please use valid constraint type e.g. region-constraints')
        end   
    end

    [~,l] = max(dlens);
    
    % Swap the maximum column to k th column
    idx1 = k;
    idx2 = k-1+l;
    
    % Swap R
    % R(k:m,[idx1, idx2])    = R(k:m,[idx2,idx1]);
    R(:,[idx1, idx2])      = R(:,[idx2,idx1]);

    % Swap pivote
    pivote(:,[idx1, idx2]) = pivote(:,[idx2,idx1]);

    % Swap the permutation information, so that Q*R = X*P
    % P(:,[idx1, idx2]) = P(:,[idx2,idx1]);

    if ~isempty(constraints_type)
        % Assign sensor coordination
        xsensor(k,1) = xv(pivote(k));
        ysensor(k,1) = yv(pivote(k));
        
        % Swap the coordinates
        xv([idx1, idx2])      = xv([idx2,idx1]);
        yv([idx1, idx2])      = yv([idx2,idx1]);
    end

    % Householder transformation  -> make a function
    % refer to <https://en.wikipedia.org/wiki/QR_decomposition#Column_pivoting>
    % and <https://ww2.mathworks.cn/matlabcentral/answers/169648-qr-factorization-using-householder-transformations>
    [~,R] = householder([],R,k,m,n);
end

end


function [Q,R] = householder(Q,R,k,m,n)
% Householder transformation takes a vector and reflects it about sym plane or hyperplane. 
% Householder projections effectively zero out the subdiagonal components of column vectors 
% in each iteration to induce upper-triangular structure
% We can use this operation to calculate the QR factorization of an m-by-n matrix 

    % u = v - alpha*e1,  alpha = norm(v）
    e1    = zeros(size(R(k:m,k)));
    e1(1) = 1;  % only deal with first component

    % 'sign' to ensure same sign as 'qr.m' in matlab
    % Note QR decomposition is not unique
    v     = R(k:m,k);
    v     = v + sign(v(1))*norm(v)*e1;
    u     = v/norm(v);
    H     = (eye(size(u*u'))-2*u*u');
    % householder transformation
    R(k:m,k:n) = H*R(k:m,k:n);
    % Q(:,k:m)   = Q(:,k:m)-2*Q(:,k:m)*u*u';
end




