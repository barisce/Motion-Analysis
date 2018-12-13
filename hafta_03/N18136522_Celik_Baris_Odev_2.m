%% get all files
currentDir = pwd; %gets directory
allFiles = dir(fullfile(currentDir,'*.jpg')); % gets all jpg files

for k = 1:length(allFiles)
    %% Read image and get the intensity matrix of the image
    fileName = allFiles(k).name;
    
    RGB = imread(fileName);
    I = rgb2gray(RGB);
    % binaryImage = I > 220; % binarization without tool
    % binaryImage = I > (1-graythresh(I))*255; % binarization without tool
    
    ratioLow = 1.02;
    ratioUp = 1.2;
    
    %% Get logical map of the image and Label the Black/White image and filter the noise (areas in between 55px and 250 px)
    BW = imbinarize(I,graythresh(I));
    %BW = bwareaopen(BW,50);
    BW = bwareafilt(BW,[55 250]);
    
    %% Get the boundry matrix of the image
    [B,L]=bwboundaries(BW,'noholes');
    stats = regionprops(L, 'Area', 'Centroid', 'Perimeter');
    
    drawnow; % forces to update the image. or in other words updates the frame
    imshow(RGB);
    hold on
    %LRGB=label2rgb(L, @jet, [.5 .5 .5]);
    
    %% Iterate through all the boundries and check if they are 
    for j = 1:length(B)
        %% Get the current boundary object
        boundary = B{j};
        perimeter = stats(j).Perimeter;
        area = stats(j).Area;
        ratio = 4*pi*area / perimeter^2;
        ratio_string = sprintf('%2.2f', ratio);
        if (ratio >= ratioLow) && (ratio <= ratioUp)
            %% If this is close to a circle, then get the centroid and plot the boundary and centroid of the object
            marker_centroids = cat(1, stats(j).Centroid);
            %text(centroid(1) - 15, centroid(2) + 5, ratio_string, 'Color','y', 'FontSize',14, 'FontWeight','bold');
            plot(boundary(:,2),boundary(:,1),'w', 'LineWidth',2);
            plot(marker_centroids(:,1), marker_centroids(:,2), 'r+');
        else
            %% if it is not a circle delete the object so Hough Transform performs better
            L(boundary(:,1), boundary(:,2)) = 0;
        end
        %plot(centroid(1), centroid(2),'ko');
    end
    
    %% circle detection via Hough Transform
%     [centers, radii] = imfindcircles(L, [5, 11], 'Sensitivity', .99);
%     viscircles(centers, radii);
end
