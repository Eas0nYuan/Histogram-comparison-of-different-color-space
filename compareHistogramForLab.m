% Four different simiarity measures, including cosine correlation,
% Chi-square test, histogram intersection and Bhattacharyya distance. 
% Choose one of measures for computing.
Cosine_correlation=1; Chi_square=2; Intersection=3; Bhattacharyya_distance=4;
method=Bhattacharyya_distance;
% Set bin size in histogram.
% Specify the number of quantization levels.
numberOfLevelsForL = 8;
numberOfLevelsFora = 8;
numberOfLevelsForb = 8;
N = numberOfLevelsForL * numberOfLevelsFora * numberOfLevelsForb;

%Get input image
picture1 =imread('1.jpg');
picture2 =imread('2.jpg');
[x1,y1,z1]=size(picture1);
[x2,y2,z2]=size(picture2);
 
% Resize object into the same scale based on smaller one.  
if x1*y1 > x2*y2
     picture1=imresize(picture1,[x2 y2],'bicubic');
     picture2=imresize(picture2,[x2 y2],'bicubic');
     rows=x2; cols=y2;
else picture2=imresize(picture2,[x1 y1],'bicubic');
     picture1=imresize(picture1,[x1 y1],'bicubic');
     rows=x1; cols=y1;
end
%     imshow(uint8([t1,t2]));
c = makecform('srgb2lab');
image1 = double(applycform(picture1,c));
image2 = double(applycform(picture2,c));

% split image into L, a & b planes
L1 = image1(:, :, 1);
a1 = image1(:, :, 2);
b1 = image1(:, :, 3);

L2 = image2(:, :, 1);
a2 = image2(:, :, 2);
b2 = image2(:, :, 3);

% Find the max (uint8).
maxValueForL1 = 255; maxValueFora1 = 255; maxValueForb1 = 255;
maxValueForL2 = 255; maxValueFora2 = 255; maxValueForb2 = 255;

% create final histogram matrix of size 8x8x8
LabColorHistogram1 = zeros(numberOfLevelsForL, numberOfLevelsFora, numberOfLevelsForb);
LabColorHistogram2 = zeros(numberOfLevelsForL, numberOfLevelsFora, numberOfLevelsForb);

% create col vector of indexes for later reference
index1 = zeros(rows*cols, 3);
index2 = zeros(rows*cols, 3);

% Put all pixels into one of the "numberOfLevels" levels.
quantizedValueForL1 = ceil(numberOfLevelsForL * L1/maxValueForL1);
index1(:, 1) = reshape(quantizedValueForL1',[rows*cols,1]);

quantizedValueFora1=ceil(numberOfLevelsFora * a1/maxValueFora1);
index1(:, 2) = reshape(quantizedValueFora1',[rows*cols,1]);

quantizedValueForb1=ceil(numberOfLevelsForb * b1/maxValueForb1);
index1(:, 3) = reshape(quantizedValueForb1',[rows*cols,1]);

quantizedValueForL2 = ceil(numberOfLevelsForL * L2/maxValueForL2);
index2(:, 1) = reshape(quantizedValueForL2',[rows*cols,1]);

quantizedValueFora2= ceil(numberOfLevelsFora * a2/maxValueFora2);
index2(:, 2) = reshape(quantizedValueFora2',[rows*cols,1]);

quantizedValueForb2=ceil(numberOfLevelsForb * b2/maxValueForb2);
index2(:, 3) = reshape(quantizedValueForb2',[rows*cols,1]);

% put each value of L,a,b to matrix 8x8x8
% (e.g. if L=7,a=2,b=1 then put 1 to matrix 8x2x2 in position 7,2,1)
for row = 1:size(index1, 1)
    if (index1(row, 1) == 0 || index1(row, 2) == 0 || index1(row, 3) == 0)
        continue;
    end
    LabColorHistogram1(index1(row, 1), index1(row, 2), index1(row, 3)) = ... 
        LabColorHistogram1(index1(row, 1), index1(row, 2), index1(row, 3)) + 1;
end
for row = 1:size(index2, 1)
    if (index2(row, 1) == 0 || index2(row, 2) == 0 || index2(row, 3) == 0)
        continue;
    end
    LabColorHistogram2(index2(row, 1), index2(row, 2), index2(row, 3)) = ... 
        LabColorHistogram2(index2(row, 1), index2(row, 2), index2(row, 3)) + 1;
end
% normalize LabHist to unit sum
LabColorHistogram1 = LabColorHistogram1(:)';
LabColorHistogram1 = LabColorHistogram1/sum(LabColorHistogram1);

LabColorHistogram2 = LabColorHistogram2(:)';
LabColorHistogram2 = LabColorHistogram2/sum(LabColorHistogram2);

switch method
    case 1
        %compute cosine similarity
        %smaller value, more similar
        LabColorHistogram1=LabColorHistogram1-mean(LabColorHistogram1);
        LabColorHistogram2=LabColorHistogram2-mean(LabColorHistogram2);
        A=sqrt(sum(LabColorHistogram1.^2));
        B=sqrt(sum(LabColorHistogram2.^2));
        C=sum(LabColorHistogram1.*LabColorHistogram2);
        cos=1-C/(A*B);%cosine value
    case 2
        %calculate Chi-Square
        %smaller value, more similar
        A=(LabColorHistogram1-LabColorHistogram2).^2;
        cos=sum(A/LabColorHistogram1);
    case 3
        %calculate histogram intersection
        %smaller value, more similar
        A=sum(min(LabColorHistogram1,LabColorHistogram2));
        cos=1-A;
    case 4
        %calculate Bhattacharyya distance
        %smaller value, more similar
        A=sum(sqrt(LabColorHistogram1.*LabColorHistogram2));
        B=sqrt(mean(LabColorHistogram1).*mean(LabColorHistogram2)*(N^2));
        cos=sqrt(1-A/B);
end
