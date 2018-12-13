clear;
clc;
renk = 'ygbmcrw';
%% get all files
currentDir = pwd; %gets directory
allFiles = dir(fullfile(currentDir,'*.jpg')); % gets all jpg files

%% Initialize figure so videoRecorder doesn't bug out
fileName = allFiles(1).name;
RGB = imread(fileName);
drawnow;
cla;
imshow(RGB);
hold on

%% Open the files that we are going to write data into
fpos1 = fopen('joint1.txt', 'w+');
if fpos1 < 0
    warning('Can not open file joint1.txt');
    return;
end
fpos2 = fopen('joint2.txt', 'w+');
if fpos2 < 0
    warning('Can not open file joint2.txt');
    return;
end
fpos3 = fopen('joint3.txt', 'w+');
if fpos3 < 0
    warning('Can not open file joint3.txt');
    return;
end
fpos4 = fopen('joint4.txt', 'w+');
if fpos4 < 0
    warning('Can not open file joint4.txt');
    return;
end
fpos5 = fopen('joint5.txt', 'w+');
if fpos5 < 0
    warning('Can not open file joint5.txt');
    return;
end
fpos6 = fopen('joint6.txt', 'w+');
if fpos6 < 0
    warning('Can not open file joint6.txt');
    return;
end
fpos7 = fopen('joint7.txt', 'w+');
if fpos7 < 0
    warning('Can not open file joint7.txt');
    return;
end

video = true;
if video
    aviobj = VideoWriter('jump.avi', 'Uncompressed AVI'); % 'Motion JPEG AVI' for lower size 50 Mb % Uncompressed AVI for high quality 3.49 GB
    aviobj.FrameRate = 1000;
    open(aviobj);
end

swapOnce = 1;

for k = 1:length(allFiles)
    %% Read image and get the intensity matrix of the image
    fileName = allFiles(k).name;
    
    RGB = imread(fileName);
    I = rgb2gray(RGB);
    [level, EM] = graythresh(I);
    bw = imbinarize(I, EM-0.2);
    bw= medfilt2(bw,[3 3]);
    bw = bwareaopen(bw, 4);
    [B,L] = bwboundaries(bw,'noholes');
    
    stats = regionprops(L, I, 'Area', 'WeightedCentroid', 'Centroid', 'Perimeter');
    %% Actually taking WeightedCentroid instead of Centroid to ease off the raw data
    marker_centroids = cat(1, stats.WeightedCentroid);
    %% Sort rows so its easier to swap places
    marker_centroids= sortrows(marker_centroids,2);
    
    %% This is for swapping hand and shoulder so they link correctly
    if swapOnce == 1
        temp = marker_centroids(1,:);
        marker_centroids(1,:) = marker_centroids(3,:);
        marker_centroids(3,:) = temp;
        swapOnce = 0;
    end
    
    %% If first iteration, previous is the same with current
    if exist('previous_centroids','var') == 0
        previous_centroids = marker_centroids;
    end
    
    %% Check previous locations
    for i = 1:numel(previous_centroids(:,1))
        for j = 1:numel(marker_centroids(:,1))
            prune = 0;
            %% Ignore missing markers
            if (numel(marker_centroids(:,1)) == numel(previous_centroids(:,1)))
                comparison = [marker_centroids(j,1),marker_centroids(j,2);previous_centroids(i,1),previous_centroids(i,2)];
                %% If found close values, swap the index to that position
                if pdist(comparison,'euclidean') < 20
                    temp = marker_centroids(j,:);
                    marker_centroids(j,:) = marker_centroids(i,:);
                    marker_centroids(i,:) = temp;
                    break
                end
            elseif (numel(marker_centroids(:,1)) < numel(previous_centroids(:,1))) 
                %% Dissappearing Marker
                for a = 1:numel(previous_centroids(:,1))
                    for b = 1:numel(previous_centroids(:,1))
                        comparisonSamePointDis = [previous_centroids(b,1),previous_centroids(b,2);previous_centroids(a,1),previous_centroids(a,2)];
                        if a ~= b && (pdist(comparisonSamePointDis,'euclidean') < 65 && (pdist(comparisonSamePointDis,'euclidean') > 42 || pdist(comparisonSamePointDis,'euclidean') < 40)) && prune == 0
                            marker_centroids(numel(marker_centroids(:,1))+1,:) = previous_centroids(b,:);
                            i = 1; j = 1;prune = 1;
                            break
                        end
                    end
                end
            end
        end
    end
    
    %% Reevaluate with the new estimated points.
    for i = 1:numel(previous_centroids(:,1))
        for j = 1:numel(marker_centroids(:,1))
            %% Ignore missing markers
            comparison2 = [marker_centroids(j,1),marker_centroids(j,2);previous_centroids(i,1),previous_centroids(i,2)];
            %% If found close values, swap the index to that position
            if pdist(comparison2,'euclidean') < 30
                temp = marker_centroids(j,:);
                marker_centroids(j,:) = marker_centroids(i,:);
                marker_centroids(i,:) = temp;
                break
            end
        end
    end
    
    %% Plot, label and connect markers
    for i = 1:numel(marker_centroids(:,1))
        plot(marker_centroids(i,1), marker_centroids(i,2), strcat(renk(i),'s'), 'LineWidth',2, 'MarkerSize',10);
        text(marker_centroids(i,1) + 40, marker_centroids(i,2), sprintf('%3.3f,%3.3f', marker_centroids(i,1), numel(RGB(:,1,1)) - marker_centroids(i,2)), 'Color', renk(i), 'FontSize',12);
        if (i<numel(marker_centroids(:,1)))
            li = line([marker_centroids(i,1),marker_centroids(i+1,1)],[marker_centroids(i,2),marker_centroids(i+1,2)]);
            set(li, 'Color',[1, 1 ,1])
        end
    end
    
    %% Write the data into files
    fprintf(fpos1, '%3.3f,%3.3f\n', marker_centroids(1,1), numel(RGB(:,1,1)) - marker_centroids(1,2));
    fprintf(fpos2, '%3.3f,%3.3f\n', marker_centroids(2,1), numel(RGB(:,1,1)) - marker_centroids(2,2));
    fprintf(fpos3, '%3.3f,%3.3f\n', marker_centroids(3,1), numel(RGB(:,1,1)) - marker_centroids(3,2));
    fprintf(fpos4, '%3.3f,%3.3f\n', marker_centroids(4,1), numel(RGB(:,1,1)) - marker_centroids(4,2));
    fprintf(fpos5, '%3.3f,%3.3f\n', marker_centroids(5,1), numel(RGB(:,1,1)) - marker_centroids(5,2));
    fprintf(fpos6, '%3.3f,%3.3f\n', marker_centroids(6,1), numel(RGB(:,1,1)) - marker_centroids(6,2));
    fprintf(fpos7, '%3.3f,%3.3f\n', marker_centroids(7,1), numel(RGB(:,1,1)) - marker_centroids(7,2));
    
    %% Set previous to current for next iteration
    previous_centroids = marker_centroids;
    
    %% Record the frame if video is set to true
    if video
        frame = getframe(gcf);
        writeVideo(aviobj, getframe(gcf));
    end
    
    %% Show the frame
    drawnow;
    cla; % Cleans the figure so that it doesn't lag
    imshow(RGB);
    hold on
end

%% Close the files
if video
    close(aviobj);
end

fclose(fpos1);
fclose(fpos2);
fclose(fpos3);
fclose(fpos4);
fclose(fpos5);
fclose(fpos6);
fclose(fpos7);

%% Open the calibration txt file
fid2 = fopen('calib_im.txt', 'w+');
if fid2 < 0
    warning('Can not open file calib_im.txt');
    return;
end

calibrationFile = 'Kalibrasyon.tif';
%% Calculate calibration from Kalibrasyon.tif
RGB = imread(calibrationFile);
I = rgb2gray(RGB);
[level, EM] = graythresh(I);
bw = imbinarize(I, EM-0.58);
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
