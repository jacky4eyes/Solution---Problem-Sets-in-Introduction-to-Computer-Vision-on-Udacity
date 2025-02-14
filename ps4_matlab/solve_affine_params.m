%% solve affine transform parameter vector p
% using the least squares problem formulation (refer to Szeliski's book)
% input the interest points' location in this manner:
% X = [x_1 ... x_n; 
%       y_1 ... y_n]
% X_prime = [x_prime_1 ... x_prime_n;
%            y_prime_1 ... y_prime_n];
%
function p = solve_affine_params(X, X_prime)
    A = zeros([6 6]);
    b = zeros([6 1]);
    for col = 1:size(X,2)
        Jx = [1 0 X(1,col) X(2,col) 0 0;0 1 0 0 X(1,col) X(2,col)];
        A = A + Jx'*Jx;
        Deltax = (X_prime(:,col)-X(:,col));
        b = b + Jx'*Deltax;
    end
    p = (A'*A)\A'*b;

end