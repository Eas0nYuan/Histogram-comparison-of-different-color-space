% Four different simiarity measures, including cosine correlation,
% Chi-square test, histogram intersection and Bhattacharyya distance. 
% Choose one of measures for computing.
Cosine_correlation=1; Chi_square=2; Intersection=3; Bhattacharyya_distance=4;
method=Bhattacharyya_distance;
% Set bin size in histogram.
N=32;

% Get input image
picture1 =rgb2gray(imread('1.jpg'));
picture2 =rgb2gray(imread('2.jpg'));
[a1,b1]=size(picture1);
[a2,b2]=size(picture2);

% Resize object into the same scale based on smaller one.  
if a1*b1 > a2*b2
picture1=imresize(picture1,[a2 b2],'bicubic');
picture2=imresize(picture2,[a2 b2],'bicubic');
rows=a2; cols=b2;
else picture2=imresize(picture2,[a1 b1],'bicubic');
picture1=imresize(picture1,[a1 b1],'bicubic');
rows=a1; cols=b1;
end

imshow([picture1,picture2]);
picture1=double(picture1);
picture2=double(picture2);
m1=zeros(1,N);
m2=zeros(1,N);
% Get the histogram.
[y1,x1]=hist(picture1(:), N);
[y2,x2]=hist(picture2(:), N);
m1=y1; m2=y2;
m1=m1./sum(m1);
m2=m2./sum(m2);

switch method
case 1
    %claculate cosine similarity
    %smaller value, more similar
    m1=m1-mean(m1);
    m2=m2-mean(m2);
    A=sqrt(sum(m1.^2));
    B=sqrt(sum(m2.^2));
    C=sum(m1.*m2);
    cos=1-C/(A*B);
case 2
    %calculate Chi-Square
    %smaller value, more similar
    A=(m1-m2).^2;
    cos=sum(A/m1);
case 3
    %calculate histogram intersection
    %smaller value, more similar
    A=sum(min(m1,m2));
    cos=1-A;  
case 4
    %calculate Bhattacharyya distance
    %smaller value, more similar
    A=sum(sqrt(m1.*m2));
    B=sqrt(mean(m1).*mean(m2)*(N^2));
    cos=sqrt(1-A/B);
end
