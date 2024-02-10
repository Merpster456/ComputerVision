%TransformedImage = transformImage(InputImage, TransformMatrix, TransformType);
%InputImage is Hin x Win, TransformedImage is Hout x Wout, 
%TransformMatrix is 3x3 that represents a particular transformation
%TransformType is a string of ‘scaling’, ‘rotation’, ‘translation’, ‘reflection’, ‘shear’, ‘affine’, ‘homography’
%TransformType should be used to specify the inverse matrix computed before

I1 = imread('Image1.png');
I1 = im2double(I1);
I1 = rgb2gray(I1);

[h1,w1] = size(I1);
scale = [1920/w1 0 0;
        0 1080/h1 0;
        0 0 1];
I11 = transformImage(I1,scale,'scaling');
figure(1)
imshow(I11)

flip = [1 0 0;0 -1 0;0 0 1];
figure(2)
I12 = transformImage(I1,flip,'reflection');
imshow(I12)

theta=pi/6;
rotate = [cos(theta) -sin(theta) 0;
          sin(theta) cos(theta) 0;
          0 0 1];
figure(3)
I13 = transformImage(I1,rotate,'rotation');
imshow(I13)

shear = [1 .5 0;0 1 0;0 0 1];
figure(4)
I14 = transformImage(I1,shear,'shear');
imshow(I14)

move = [1 0 300;0 1 500;0 0 1];
phi = -pi/9;
spin = [cos(phi) -sin(phi) 0;
        sin(phi) cos(phi) 0;
        0 0 1];
shrink = [.5 0 0;0 .5 0;0 0 1];
many = shrink*spin*move;
figure(5)
I15 = transformImage(I1,many,'affine');
imshow(I15)

aff1 = [1 .4 .4;.1 1 .3;0 0 1];
figure(6)
I161 = transformImage(I1,aff1,'affine');
imshow(I161)

aff2 = [2.1 -.35 -.1;-.3 .7 .3;0 0 1];
figure(7)
I162 = transformImage(I1,aff2,'affine');
imshow(I162)

homo1 = [.8 .2 .3;-.1 .9 -.1;.0005 -.0005 1];
I171 = transformImage(I1,homo1,'homography');
figure(8)
imshow(I171)

homo2 = [29.25 13.95 20.25;
         4.95 35.55 9.45;
         .045 .09 45];
figure(9)
I172 = transformImage(I1,homo2,'homography');
imshow(I172)

function TransformedImage = transformImage(InputImage,TransformMatrix,TransformType)
    %determine dimensions and corners of the image
    [h,w] = size(InputImage);
    a = [1 1];
    b = [w 1];
    c = [1 h];
    d = [w h];

    cornersprime = TransformMatrix * [a',b',c',d'; 1, 1, 1, 1];
    %handles the case of homographies
    cornersprime1 = cornersprime./cornersprime(3,:);

    %takes min of the min and 1 for cases when the min is >1
    %rounds to create whole numbers for reshape
    minx = round(min(min(cornersprime1(1,:)),1));
    miny = round(min(min(cornersprime1(2,:)),1));
    maxx = round(max(cornersprime1(1,:)));
    maxy = round(max(cornersprime1(2,:)));

    %new width and height
    wprime = maxx - minx + 1;
    hprime = maxy - miny + 1;
    
    [Xprime,Yprime] = meshgrid( minx:maxx, miny:maxy );
    pprime = [Xprime(:)';Yprime(:)';ones(1,numel(Xprime))];

    %determine inverse matrix based on inverse type
    if strcmp('scaling',TransformType)
        Ainv = [1/TransformMatrix(1,1) 0 0;
                0 1/TransformMatrix(2,2) 0;
                0 0 1];
    elseif strcmp('rotation',TransformType)
        Ainv = TransformMatrix.';
    elseif strcmp('translation',TransformType)
        Ainv = [1 0 -1*TransformMatrix(1,3);
                0 1 -1*TransformMatrix(2,3);
                0 0 1];
    elseif strcmp('reflection',TransformType)
        Ainv = TransformMatrix;
    elseif strcmp('shear',TransformType)
        Ainv = [1 -1*TransformMatrix(1,2) 0;
                -1*TransformMatrix(2,1) 1 0;
                0 0 1];
    elseif strcmp('affine',TransformType)
        Ainv = inv(TransformMatrix);
    elseif strcmp('homography',TransformType)
        Ainv = inv(TransformMatrix);
    else
        Ainv = 0;
    end
    
    phat = Ainv * pprime;
    xhat = phat(1,:);
    yhat = phat(2,:);
    what = phat(3,:);

    x = xhat ./ what;
    y = yhat ./ what;
    
    x = reshape( x', hprime, wprime );
    y = reshape( y', hprime, wprime );
    
    %interpolate the image
    TransformedImage = interp2(InputImage, x, y );
end
