% Four different simiarity measures, including cosine correlation,
% Chi-square test, histogram intersection and Bhattacharyya distance. 
% Choose one of measures for computing.
Cosine_correlation=1; Chi_square=2; Intersection=3; Bhattacharyya_distance=4;
method=Bhattacharyya_distance;
% Set bin size in histogram.
% Specify the number of quantization levels.
numberOfLevelsForH = 8;
numberOfLevelsForS = 8;
numberOfLevelsForV = 8;
N = numberOfLevelsForH * numberOfLevelsForS * numberOfLevelsForV;

%Get input image
picture1 =imread('1.jpg');
picture2 =imread('2.jpg');
[a1,b1,c1]=size(picture1);
[a2,b2,c2]=size(picture2);

%resize object into the same scale based on smaller one.   
if a1*b1 > a2*b2
     picture1=imresize(picture1,[a2 b2],'bicubic');
     picture2=imresize(picture2,[a2 b2],'bicubic');
     rows=a2; cols=b2;
else picture2=imresize(picture2,[a1 b1],'bicubic');
     picture1=imresize(picture1,[a1 b1],'bicubic');
     rows=a1; cols=b1;
end
imshow(uint8([picture1,picture2]));
image1 = rgb2hsv(picture1);
image2 = rgb2hsv(picture2);

% split image into h, s & v planes
h1 = image1(:, :, 1);
s1 = image1(:, :, 2);
v1 = image1(:, :, 3);

h2 = image2(:, :, 1);
s2 = image2(:, :, 2);
v2 = image2(:, :, 3);

% Find the max.
maxValueForH1 = max(h1(:)); maxValueForS1 = max(s1(:)); maxValueForV1 = max(v1(:));
maxValueForH2 = max(h2(:)); maxValueForS2 = max(s2(:)); maxValueForV2 = max(v2(:));

% create final histogram matrix of size 8x8x8
hsvColorHistogram1 = zeros(numberOfLevelsForH, numberOfLevelsForS, numberOfLevelsForV);
hsvColorHistogram2 = zeros(numberOfLevelsForH, numberOfLevelsForS, numberOfLevelsForV);

% create col vector of indexes for later reference
index1 = zeros(rows*cols, 3);
index2 = zeros(rows*cols, 3);

% Put all pixels into one of the "numberOfLevels" levels.
MH1 = ceil(numberOfLevelsForH * h1/maxValueForH1);
quantizedValueForH1 = reshape(MH1',[rows*cols,1]);
MS1 = ceil(numberOfLevelsForS * s1/maxValueForS1);
quantizedValueForS1 = reshape(MS1',[rows*cols,1]);
MV1 = ceil(numberOfLevelsForV * v1/maxValueForV1);
quantizedValueForV1 = reshape(MV1',[rows*cols,1]);

MH2 = ceil(numberOfLevelsForH * h2/maxValueForH2);
quantizedValueForH2 = reshape(MH2',[rows*cols,1]);
MS2 = ceil(numberOfLevelsForS * s2/maxValueForS2);
quantizedValueForS2 = reshape(MS2',[rows*cols,1]);
MV2 = ceil(numberOfLevelsForV * v2/maxValueForV2);
quantizedValueForV2 = reshape(MV2',[rows*cols,1]);

% keep indexes where 1 should be put in matrix hsvHist
index1(:, 1) = quantizedValueForH1;
index1(:, 2) = quantizedValueForS1;
index1(:, 3) = quantizedValueForV1;

index2(:, 1) = quantizedValueForH2;
index2(:, 2) = quantizedValueForS2;
index2(:, 3) = quantizedValueForV2;
% put each value of h,s,v to matrix 8x8x8
% (e.g. if h=7,s=2,v=1 then put 1 to matrix 8x8x8 in position 7,2,1)
for row = 1:size(index1, 1)
    if (index1(row, 1) == 0 || index1(row, 2) == 0 || index1(row, 3) == 0)
        continue;
    end
    hsvColorHistogram1(index1(row, 1), index1(row, 2), index1(row, 3)) = ... 
        hsvColorHistogram1(index1(row, 1), index1(row, 2), index1(row, 3)) + 1;
end
for row = 1:size(index2, 1)
    if (index2(row, 1) == 0 || index2(row, 2) == 0 || index2(row, 3) == 0)
        continue;
    end
    hsvColorHistogram2(index2(row, 1), index2(row, 2), index2(row, 3)) = ... 
        hsvColorHistogram2(index2(row, 1), index2(row, 2), index2(row, 3)) + 1;
end
% normalize hsvHist to unit sum
hsvColorHistogram1 = hsvColorHistogram1(:)';
hsvColorHistogram1 = hsvColorHistogram1/sum(hsvColorHistogram1);

hsvColorHistogram2 = hsvColorHistogram2(:)';
hsvColorHistogram2 = hsvColorHistogram2/sum(hsvColorHistogram2);

switch method
    case 1
        %compute cosine similarity
        %smaller value, more similar
        hsvColorHistogram1=hsvColorHistogram1-mean(hsvColorHistogram1);
        hsvColorHistogram2=hsvColorHistogram2-mean(hsvColorHistogram2);
        A=sqrt(sum(hsvColorHistogram1.^2));
        B=sqrt(sum(hsvColorHistogram2.^2));
        C=sum(hsvColorHistogram1.*hsvColorHistogram2);
        cos=1-C/(A*B);%cosine value
    case 2
        %calculate Chi-Square
        %smaller value, more similar
        A=(hsvColorHistogram1-hsvColorHistogram2).^2;
        cos=sum(A/hsvColorHistogram1);
    case 3
        %calculate histogram intersection
        %smaller value, more similar
        A=sum(min(hsvColorHistogram1,hsvColorHistogram2));
        cos=1-A;
    case 4
        %calculate Bhattacharyya distance
        %smaller value, more similar
        A=sum(sqrt(hsvColorHistogram1.*hsvColorHistogram2));
        B=sqrt(mean(hsvColorHistogram1).*mean(hsvColorHistogram2)*(N^2));
        cos=sqrt(1-A/B);
end