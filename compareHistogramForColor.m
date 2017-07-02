% Four different simiarity measures, including cosine correlation,
% Chi-square test, histogram intersection and Bhattacharyya distance. 
% Choose one of measures for computing.
Cosine_correlation=1; Chi_square=2; Intersection=3; Bhattacharyya_distance=4;
method=Bhattacharyya_distance;
% quantize each R,G,B equivalently to 8x8x8
% Set bin size in histogram. Specify the number of quantization levels.
numberOfLevelsForR = 8;
numberOfLevelsForG = 8;
numberOfLevelsForB = 8;
N = numberOfLevelsForR * numberOfLevelsForG * numberOfLevelsForB;

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

imshow([picture1,picture2]);
% split image into R, G & B planes
R1 = double(picture1(:, :, 1));
G1 = double(picture1(:, :, 2));
B1 = double(picture1(:, :, 3));

R2 = double(picture2(:, :, 1));
G2 = double(picture2(:, :, 2));
B2 = double(picture2(:, :, 3));

% create final histogram matrix of size 8x8x8
hist1 = zeros(numberOfLevelsForR, numberOfLevelsForG, numberOfLevelsForB);
hist2 = zeros(numberOfLevelsForR, numberOfLevelsForG, numberOfLevelsForB);

% create col vector of indexes for later reference
index1 = zeros(rows*cols, 3);
index2 = zeros(rows*cols, 3);

MR1 = ceil(numberOfLevelsForR * R1/255);
quantizedValueForR1 = reshape(MR1',[rows*cols,1]);
MG1 = ceil(numberOfLevelsForG * G1/255);
quantizedValueForG1 = reshape(MG1',[rows*cols,1]);
MB1 = ceil(numberOfLevelsForB * B1/255);
quantizedValueForB1 = reshape(MB1',[rows*cols,1]);

MR2 = ceil(numberOfLevelsForR * R2/255);
quantizedValueForR2 = reshape(MR2',[rows*cols,1]);
MG2 = ceil(numberOfLevelsForG * G2/255);
quantizedValueForG2 = reshape(MG2',[rows*cols,1]);
MB2 = ceil(numberOfLevelsForB * B2/255);
quantizedValueForB2 = reshape(MB2',[rows*cols,1]);

% keep indexes where 1 should be put in matrix hsvHist
index1(:, 1) = quantizedValueForR1;
index1(:, 2) = quantizedValueForG1;
index1(:, 3) = quantizedValueForB1;

index2(:, 1) = quantizedValueForR2;
index2(:, 2) = quantizedValueForG2;
index2(:, 3) = quantizedValueForB2;

% put each value of R,G,B to matrix 8x8x8
% (e.g. if R=7,G=2,B=1 then put 1 to matrix 16x16x16 in position 7,2,1)
for row = 1:size(index1, 1)
if (index1(row, 1) == 0 || index1(row, 2) == 0 || index1(row, 3) == 0)
    continue;
end
hist1(index1(row, 1), index1(row, 2), index1(row, 3)) = ... 
    hist1(index1(row, 1), index1(row, 2), index1(row, 3)) + 1;
end
for row = 1:size(index2, 1)
if (index2(row, 1) == 0 || index2(row, 2) == 0 || index2(row, 3) == 0)
    continue;
end
hist2(index2(row, 1), index2(row, 2), index2(row, 3)) = ... 
    hist2(index2(row, 1), index2(row, 2), index2(row, 3)) + 1;
end
% normalize rgbHist to unit sum
hist1 = hist1(:)';
hist1 = hist1/sum(hist1);

hist2 = hist2(:)';
hist2 = hist2/sum(hist2);


switch method
case 1
    %claculate cosine similarity
    %smaller value, more similar
    hist1=hist1-mean(hist1);
    hist2=hist2-mean(hist2);
    A=sqrt(sum(hist1.^2));
    B=sqrt(sum(hist2.^2));
    C=sum(hist1.*hist2);
    cos=1-C/(A*B);
case 2
    %calculate Chi-Square
    %smaller value, more similar
    A=(hist1-hist2).^2;
    cos=sum(A/hist1);
case 3
    %calculate histogram intersection
    %smaller value, more similar
    A=sum(min(hist1,hist2));
    cos=1-A;  
case 4
    %calculate Bhattacharyya distance
    %smaller value, more similar
    A=sum(sqrt(hist1.*hist2));
    B=sqrt(mean(hist1).*mean(hist2)*((3*N)^2));
    cos=sqrt(1-A/B);
end


