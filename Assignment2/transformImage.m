%TransformedImage = transformImage(InputImage, TransformMatrix, TransformType);
%InputImage is Hin x Win, TransformedImage is Hout x Wout, 
%TransformMatrix is 3x3 that represents a particular transformation
%TransformType is a string of ‘scaling’, ‘rotation’, ‘translation’, ‘reflection’, ‘shear’, ‘affine’, ‘homography’
%TransformType should be used to specify the inverse matrix computed before

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
    
    %i don't really know what this does
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
    %if an unknown type is given, 0 out the matrix
    else
        Ainv = 0;
    end
    
    %determine hat values
    phat = Ainv * pprime;
    xhat = phat(1,:);
    yhat = phat(2,:);
    what = phat(3,:);

    x = xhat ./ what;
    y = yhat ./ what;
    
    x = reshape( x', hprime, wprime );
    y = reshape( y', hprime, wprime );
end
    %interpolate the image
    TransformedImage = interp2(InputImage, x, y );
end