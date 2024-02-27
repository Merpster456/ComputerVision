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















