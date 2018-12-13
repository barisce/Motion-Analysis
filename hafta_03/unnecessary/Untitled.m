im = imread('tnesneler.jpg');
im2 = rgb2gray(im);
im3 = imbinarize(im2, 0.1);
im4 = imclose(im3, strel('disk', 4, 4));
im5 = imfill(im4, 'holes');
imshow(im5);
[centers, radii] = imfindcircles(im5, [10, 11], 'Sensitivity', .99);
viscircles(centers, radii);