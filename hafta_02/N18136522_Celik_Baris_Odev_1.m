%% get all files
currentDir = pwd; %gets directory
allFiles = dir(fullfile(currentDir,'*.jpg')); % gets all jpg files

for k = 1:length(allFiles)
    fileName = allFiles(k).name;
    
    RGB = imread(fileName);
    I = rgb2gray(RGB);
    % binaryImage = I > 220; % binarization without tool
    % binaryImage = I > (1-graythresh(I))*255; % binarization without tool
    
    %% Histogram
    % Used histogram size 8 because 2^8 = 256
    histogramSize = 8;
    [counts,x] = imhist(I,histogramSize);
    % stem(x,counts) % comment out to see histogram
    
    %% find the median of the histogram and find the first value that matches it
    index = find(counts <= median(counts),1,'first');
    
    %% test
    % T = otsuthresh(counts);
    % T = adaptthresh(I,0.4);
    % BW = imbinarize(I,(index/histogramSize));
    
    %% Get logical map of the image and Label the Black/White image and filter the noise (salt/pepper)
    L = medfilt2(bwlabel(imbinarize(I,(index/histogramSize))));
    cg = regionprops(L, 'centroid');
    marker_centroids = cat(1, cg.Centroid);
    
    % imshowpair(RGB, filteredL, 'montage');
    %% Draw the image and marker with coordinates
    drawnow; % forces to update the image. or in other words updates the frame
    imshow(RGB);
    hold on
    plot(marker_centroids(:,1), marker_centroids(:,2), 'r+');
    txt = '[x,y]';
    txt = strrep(txt,'x',num2str(marker_centroids(:,1)));
    txt = strrep(txt,'y',num2str(marker_centroids(:,2)));
    h = text(marker_centroids(:,1)+20, marker_centroids(:,2),txt, 'HorizontalAlignment','left', 'Color', 'r');
    set(h, 'Color',[1, 0.6 ,0.2], 'FontSize', 20)
    li = line([marker_centroids(:,1),0],[marker_centroids(:,2),numel(RGB(:,1,1))]);
    set(li, 'Color',[1, 0.6 ,0.2])
end


