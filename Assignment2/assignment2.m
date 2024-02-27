%load the first image
i1 = imread("Image1.jpg");
i1 = im2double(i1);
i1 = rgb2gray(i1);
%load the second image
i2 = imread("Image2.jpg");
i2 = im2double(i2);
i2 = rgb2gray(i2);

%Obtaining Correspondences

%determine points of interest in images
pts1 = detectSURFFeatures(i1);
pts2 = detectSURFFeatures(i2);
%get the features of the images
fts1 = extractFeatures(i1, pts1);
fts2 = extractFeatures(i2, pts2);
%matches features of the images
indexPairs = matchFeatures(fts1,fts2,'Unique',true);
%extract objects for the matched points
matchedPts1 = pts1(indexPairs(:,1));
matchedPts2 = pts2(indexPairs(:,2));
%convert point objects to coordinates
im1pts = matchedPts1.Location;
im2pts = matchedPts2.Location;

%Estimating the Homography
A = estimateTransformRansac(im1pts,im2pts);

%Apply the Homography
Ainv = inv(A);
im2transformed = transformImage(i2,Ainv,'homography');
nanlocations = isnan(im2transformed);
im2transformed(nanlocations) = 0;

figure(1)
imshow(im2transformed)

%Expanding Image 1
% needs matlab 2023b to function
% i1resize = paddata(i1,size(im2transformed)); 
% works otherwise
im1resize = zeros(size(im2transformed));
[n,m] = size(i1);
im1resize(1:n,1:m) = i1;

%Blend the Images
figure(2)
% get da ramp info
imshow(im1resize);
[x_overlap,y_overlap]=ginput(2);
overlapleft=round(x_overlap(1));
overlapright=round(x_overlap(2));
% build ramp parts
zeros_till_overlapleft = zeros(1,overlapleft-1);
ones_till_overlapright = ones(1,size(im1resize,2)-overlapright);
stepvalue = 1/(overlapright-overlapleft);
% assemble ramp
ramp=[zeros_till_overlapleft, 0 : stepvalue : 1, ones_till_overlapright];

% apply da ramp
h = size(im2transformed,1);
im2blend = im2transformed .* repmat(ramp,h,1);
flip_ramp = ones(size(ramp)) - ramp;
im1blend = im1resize .* repmat(flip_ramp,h,1);

% put dem together
impanorama=im1blend+im2blend;

% test calls
figure(3)
imshow(im1blend)
figure(4)
imshow(im2blend)
figure(5)
imshow(impanorama)












