%% get all files
currentDir = pwd; %gets directory
allFiles = dir(fullfile(currentDir,'*.jpg')); % gets all jpg files

fid = fopen('ball_position.txt', 'w+');
if fid < 0
    warning('Can not open file ball_position.txt');
    return;
end

fid2 = fopen('ball_position_weighted.txt', 'w+');
if fid2 < 0
    warning('Can not open file ball_position_weighted.txt');
    return;
end

for k = 1:length(allFiles)
    %% Read image and get the intensity matrix of the image
    fileName = allFiles(k).name;
    
    RGB = imread(fileName);
    I = rgb2gray(RGB);
    %figure,imshow(I), hold on;
    [level EM] = graythresh(I);
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
        % plot(boundary(:,2),boundary(:,1),'g', 'LineWidth',2);
        centroid = stats(j).Centroid;
        plot(centroid(1), centroid(2),'k+');
        WeightedCentroid = stats(j).WeightedCentroid;
        plot(WeightedCentroid(1), WeightedCentroid(2),'b+', WeightedCentroid(1), WeightedCentroid(2),'bo');
        fprintf(fid, '%3.3f,%3.3f\n', centroid(1), numel(RGB(:,1,1)) - centroid(2));
        fprintf(fid2, '%3.3f,%3.3f\n', WeightedCentroid(1), numel(RGB(:,1,1)) - WeightedCentroid(2));
    end
    
end

fclose(fid);
fclose(fid2);
