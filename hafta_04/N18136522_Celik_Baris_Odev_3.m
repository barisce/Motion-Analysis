clear;
clc;
renk = 'ygbmcrw';
%% Read Video
vidObj = VideoReader('salto.avi');

video = false;
if video
    aviobj = VideoWriter('jump.avi', 'Uncompressed AVI');
    aviobj.FrameRate = 25;
    open(aviobj);
end

%% While video has frames unprocessed, process another frame
while hasFrame(vidObj)
    %% Read, get the intensity and threshold the image and get the markers' centroids
    frame = readFrame(vidObj);
    I = rgb2gray(frame);
    BW = imbinarize(I,graythresh(I));
    cg = regionprops(BW, 'centroid');
    marker_centroids = cat(1, cg.Centroid);
    %% Estimation - doesn't make much difference
    marker_centroids= sortrows(marker_centroids,2);
    
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
            %% Dissappearing Marker
            elseif (numel(marker_centroids(:,1)) < numel(previous_centroids(:,1)))
                for a = 1:numel(previous_centroids(:,1))
                    for b = 1:numel(previous_centroids(:,1))
                        comparisonSamePointDis = [previous_centroids(b,1),previous_centroids(b,2);previous_centroids(a,1),previous_centroids(a,2)];
                        if a ~= b && pdist(comparisonSamePointDis,'euclidean') < 28 && prune == 0
                            marker_centroids(numel(marker_centroids(:,1))+1,:) = previous_centroids(b,:);
                            i = 1; j = 1;prune = 1;
                            break
                        end
                    end
                end
            %% Reappearing Marker
            elseif (numel(marker_centroids(:,1)) > numel(previous_centroids(:,1)))
                
            end
        end
%         if (numel(marker_centroids(:,1)) < numel(previous_centroids(:,1)))
%             
%         end
    end
    
    %% Show the results
    drawnow;
    imshow(frame);
    hold on
    
    
    
    for i = 1:numel(marker_centroids(:,1))
        plot(marker_centroids(i,1), marker_centroids(i,2), strcat(renk(i),'s'), 'LineWidth',2, 'MarkerSize',10);
        text(marker_centroids(i,1) + 40, marker_centroids(i,2), sprintf('%3.3f,%3.3f', marker_centroids(i,1), numel(frame(:,1,1)) - marker_centroids(i,2)), 'Color', renk(i), 'FontSize',12);
        if (i<numel(marker_centroids(:,1)))
            li = line([marker_centroids(i,1),marker_centroids(i+1,1)],[marker_centroids(i,2),marker_centroids(i+1,2)]);
            set(li, 'Color',[1, 1 ,1])
        end
    end
    
    %% Set previous to current for next iteration
    previous_centroids = marker_centroids;
    
    %% Record the frame if video is set to true
    if video
        frame = getframe(gcf);
        writeVideo(aviobj, getframe(gcf));
    end
end

if video
    close(aviobj);
end
