function h = wallfilter(N,ord)
%Generate a filter that can return the residue of a signal after
%subtracting its order N polynomal approximation
xx=linspace(-1,1,N).';
A = ones(size(xx));
for ii=1:ord
    A(:,ii+1) = xx.^ii;
end
Q = orth(A);
hi = Q*Q.';%This is the projection matrix to a subspace of signals of length N that are polynomials of order d
h = (eye(N) - hi)';