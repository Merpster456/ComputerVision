function A = estimateTransform( pts1i,pts2i )

% Set up design matrix P: size = 2*size(pts1i,1) x 9
% figure out how the fuck DLT works
N = size(pts1i,1);
assert(N==size(pts2i,1));   %check to ensure equal sizes
P=zeros(2*N,9);
for n=1:N
    xn = pts1i(n,1);
    yn = pts1i(n,2);
    xpn = pts2i(n,1);
    ypn = pts2i(n,2);
    P(2*n-1,:)=[-xn -yn -1 0 0 0 xn*xpn yn*xpn xpn];
    P(2*n,:) = [0 0 0 -xn -yn -1 xn*ypn yn*ypn ypn];
end

if size(P,1) == 8
    [U,S,V] = svd(P);
else
    [U,S,V] = svd(P,'econ');
end

q = V(:,end);

% reshape q to get A
% reshape would make A^T, so transpose it to get A
A=reshape(q,[3,3])';

end