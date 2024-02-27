% pts1: nx2, pts2: nx2
function A_inliers = estimateTransformRansac(pts1,pts2)
Nransac = 10000;
t = 2;

n = size(pts1,1);

k = 4;

nbest = 0;
%Abest = [];
idxbest = [];

for i_ransac = 1:Nransac
    
    % randomly sample set of indices to compute A
    idx = randperm( n,k );

    pts1i = pts1(idx,:);
    pts2i = pts2(idx,:);

    A_test = estimateTransform( pts1i,pts2i );

    pts2e = A_test * [pts1';ones(1,n)];
    pts2e = pts2e(1:2,:) ./ pts2e(3,:);
    pts2e = pts2e';
    
    d = sqrt((pts2e(:,1)-pts2(:,1)).^2 + (pts2e(:,2)-pts2(:,2)).^2);
    
    idxgood = d < t;
    ngood = sum(idxgood);
    %Agood = A_test;

    if ngood > nbest
        nbest = ngood;
        %Abest = Agood;
        idxbest = idxgood;
    end
end

pts1inliers = pts1(idxbest,:);
pts2inliers = pts2(idxbest,:);

A_inliers = estimateTransform( pts1inliers, pts2inliers );
end


