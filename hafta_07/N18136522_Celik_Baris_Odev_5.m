%% get all files
currentDir = pwd; %gets directory
allFiles = dir(fullfile(currentDir,'*.jpg')); % gets all jpg files

fid = fopen('ball_position.txt', 'w+');
if fid < 0
    warning('Can not open file ball_position.txt');
    return;
end

for k = 1:length(allFiles)
    %% Read image and get the intensity matrix of the image
    fileName = allFiles(k).name;
    
    RGB = imread(fileName);
    I = rgb2gray(RGB);
    %figure,imshow(I), hold on;
    [level, EM] = graythresh(I);
    bw = imbinarize(I, EM);
    bw= medfilt2(bw,[3 3]);
    bw = bwareaopen(bw, 4);
    [B,L] = bwboundaries(bw,'noholes');
    
    drawnow; % forces to update the image. or in other words updates the frame
    imshow(RGB);
    hold on
    
    stats = regionprops(L, I, 'Area', 'WeightedCentroid', 'Centroid', 'Perimeter');
    for j = 1:length(B)
        boundary = B{j};
        % uncomment if you want centroid rather than weighted_centroid
%         centroid = stats(j).Centroid;
%         plot(centroid(1), centroid(2),'k+');
%         fprintf(fid, '%3.3f,%3.3f\n', centroid(1), numel(RGB(:,1,1)) - centroid(2));
        WeightedCentroid = stats(j).WeightedCentroid;
        plot(WeightedCentroid(1), WeightedCentroid(2),'b+', WeightedCentroid(1), WeightedCentroid(2),'bo');
        fprintf(fid, '%3.3f,%3.3f\n', WeightedCentroid(1), numel(RGB(:,1,1)) - WeightedCentroid(2));
    end
    
end

fclose(fid);

fid2 = fopen('calib_im.txt', 'w+');
if fid2 < 0
    warning('Can not open file calib_im.txt');
    return;
end

calibrationFile = 'calibration/topbirak_calib.jpg';
%% Calculate calibration from topbirak_calib.jpg
RGB = imread(calibrationFile);
I = rgb2gray(RGB);
[level, EM] = graythresh(I);
bw = imbinarize(I, EM);
bw= medfilt2(bw,[3 3]);
bw = bwareaopen(bw, 4);
[B,L] = bwboundaries(bw,'noholes');

stats = regionprops(L, 'Area', 'Centroid', 'Perimeter');
ratioLow = 1.02;
ratioUp = 1.9;
%% Circle Detection from HW2
for j = 1:length(B)
    %% Get the current boundary object
    boundary = B{j};
    perimeter = stats(j).Perimeter;
    area = stats(j).Area;
    ratio = 4*pi*area / perimeter^2;
    if (ratio >= ratioLow) && (ratio <= ratioUp)
        %% If this is close to a circle, then get the centroid and plot the boundary and centroid of the object
        marker_centroids = cat(1, stats(j).Centroid);
        %plot(boundary(:,2),boundary(:,1),'w', 'LineWidth',2);
        %plot(marker_centroids(:,1), marker_centroids(:,2), 'r+');
        fprintf(fid2, '%3.3f,%3.3f\n', marker_centroids(:,1), numel(RGB(:,1,1)) - marker_centroids(:,2));
    else
        L(boundary(:,1), boundary(:,2)) = 0;
    end
end

fclose(fid2);
