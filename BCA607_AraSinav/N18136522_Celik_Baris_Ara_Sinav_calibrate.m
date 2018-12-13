function clbhw = N18136522_Celik_Baris_Ara_Sinav_calibrate()
    clc, clear

    % Enter the calibration data from pdf. Real world values as in cm
    S = [ 2.5 190; % 4. point
        2.5 130; % 3. point
        2.5 60; % 2. point
        2.5 30; % 1. point
        108 180; % 8. point
        108 120; % 7. point
        108 80; % 6. point
        108 10]; % 5. point

    %% Read each joints data
    joint1 = load('joint1.txt');
    joint2 = load('joint2.txt');
    joint3 = load('joint3.txt');
    joint4 = load('joint4.txt');
    joint5 = load('joint5.txt');
    joint6 = load('joint6.txt');
    joint7 = load('joint7.txt');
    
    %% Calibrate the data according to real world values
    calib_im = load('calib_im.txt');
    I = calib_im;
    x = calculate_conformal(I, S, 1);
    H1 = calculate_reconformal(x, joint1);
    H2 = calculate_reconformal(x, joint2);
    H3 = calculate_reconformal(x, joint3);
    H4 = calculate_reconformal(x, joint4);
    H5 = calculate_reconformal(x, joint5);
    H6 = calculate_reconformal(x, joint6);
    H7 = calculate_reconformal(x, joint7);
    
    % Butterworth filter parameters. As 1000 samples given and since 6 is
    % the optimal number to filter human movement 6/(1000/2)
    % Also I choose 2 because 3 is too parabolic and 1 is too linear
    [b,a]= butter(2,6/500,'low');
    HF1 = filtfilt(b,a,H1);
    HF2 = filtfilt(b,a,H2);
    HF3 = filtfilt(b,a,H3);
    HF4 = filtfilt(b,a,H4);
    HF5 = filtfilt(b,a,H5);
    HF6 = filtfilt(b,a,H6);
    HF7 = filtfilt(b,a,H7);
    
    %% Calculating Velocity and Accelerations of markers
    deltaT = 1;% for sec / frame
    % First velocity and acceleration
	V1 = zeros(numel(HF1(:,1)), 2);
    for j = 2:numel(HF1(:,1))-1
        V1(j,1) = (sqrt(sum((HF1(j+1,:) - HF1(j-1,:)) .^ 2))) / (2 * deltaT);
        V1(j,2) = j;
    end
    
    A1 = zeros(numel(V1(:,1)), 2);
    for j = 2:numel(V1(:,2))-1
        A1(j,1) = (V1(j+1,1) - V1(j-1,1)) / (2 * deltaT);
        A1(j,2) = j;
    end

    % Second velocity and acceleration
    V2 = zeros(numel(HF2(:,1)), 2);
    for j = 2:numel(HF2(:,1))-1
        V2(j,1) = (sqrt(sum((HF2(j+1,:) - HF2(j-1,:)) .^ 2))) / (2 * deltaT);
        V2(j,2) = j;
    end
    
    A2 = zeros(numel(V2(:,1)), 2);
    for j = 2:numel(V2(:,2))-1
        A2(j,1) = (V2(j+1,1) - V2(j-1,1)) / (2 * deltaT);
        A2(j,2) = j;
    end

    % Third velocity and acceleration
	V3 = zeros(numel(HF3(:,1)), 2);
    for j = 2:numel(HF3(:,1))-1
        V3(j,1) = (sqrt(sum((HF3(j+1,:) - HF3(j-1,:)) .^ 2))) / (2 * deltaT);
        V3(j,2) = j;
    end
    
    A3 = zeros(numel(V3(:,1)), 2);
    for j = 2:numel(V3(:,2))-1
        A3(j,1) = (V3(j+1,1) - V3(j-1,1)) / (2 * deltaT);
        A3(j,2) = j;
    end

    % Fourth velocity and acceleration
    V4 = zeros(numel(HF4(:,1)), 2);
    for j = 2:numel(HF4(:,1))-1
        V4(j,1) = (sqrt(sum((HF4(j+1,:) - HF4(j-1,:)) .^ 2))) / (2 * deltaT);
        V4(j,2) = j;
    end
    
    A4 = zeros(numel(V4(:,1)), 2);
    for j = 2:numel(V4(:,2))-1
        A4(j,1) = (V4(j+1,1) - V4(j-1,1)) / (2 * deltaT);
        A4(j,2) = j;
    end

    % Fifth velocity and acceleration
	V5 = zeros(numel(HF5(:,1)), 2);
    for j = 2:numel(HF5(:,1))-1
        V5(j,1) = (sqrt(sum((HF5(j+1,:) - HF5(j-1,:)) .^ 2))) / (2 * deltaT);
        V5(j,2) = j;
    end
    
    A5 = zeros(numel(V5(:,1)), 2);
    for j = 2:numel(V5(:,2))-1
        A5(j,1) = (V5(j+1,1) - V5(j-1,1)) / (2 * deltaT);
        A5(j,2) = j;
    end

    % Sixth velocity and acceleration
    V6 = zeros(numel(HF6(:,1)), 2);
    for j = 2:numel(HF6(:,1))-1
        V6(j,1) = (sqrt(sum((HF6(j+1,:) - HF6(j-1,:)) .^ 2))) / (2 * deltaT);
        V6(j,2) = j;
    end
    
    A6 = zeros(numel(V6(:,1)), 2);
    for j = 2:numel(V6(:,2))-1
        A6(j,1) = (V6(j+1,1) - V6(j-1,1)) / (2 * deltaT);
        A6(j,2) = j;
    end

    % Seventh velocity and acceleration
	V7 = zeros(numel(HF7(:,1)), 2);
    for j = 2:numel(HF7(:,1))-1
        V7(j,1) = (sqrt(sum((HF7(j+1,:) - HF7(j-1,:)) .^ 2))) / (2 * deltaT);
        V7(j,2) = j;
    end
    
    A7 = zeros(numel(V7(:,1)), 2);
    for j = 2:numel(V7(:,2))-1
        A7(j,1) = (V7(j+1,1) - V7(j-1,1)) / (2 * deltaT);
        A7(j,2) = j;
    end
    
    %% Plotting
    figure;
    subplot(1,3,1)
    hold on
    %% Displacement Plots
    plot(V1(:,2),HF1(:,2), 'y-o');
    plot(V2(:,2),HF2(:,2), 'g-o');
    plot(V3(:,2),HF3(:,2), 'b-o');
    plot(V4(:,2),HF4(:,2), 'm-o');
    plot(V5(:,2),HF5(:,2), 'c-o');
    plot(V6(:,2),HF6(:,2), 'r-o');
    plot(V7(:,2),HF7(:,2), 'k-o');grid on;
    legend('Hand','Elbow','Shoulder','Hip','Knee','Ankle','Tip of Feet')
    title('Displacement');
    xlabel('Time (frame)');
    ylabel('Displacement (cm)');
    subplot(1,3,2)
    hold on
    %% Velocity Plots
    plot(V1(:,2),V1(:,1), 'y-o');
    plot(V2(:,2),V2(:,1), 'g-o');
    plot(V3(:,2),V3(:,1), 'b-o');
    plot(V4(:,2),V4(:,1), 'm-o');
    plot(V5(:,2),V5(:,1), 'c-o');
    plot(V6(:,2),V6(:,1), 'r-o');
    plot(V7(:,2),V7(:,1), 'k-o');grid on;
    legend('Hand','Elbow','Shoulder','Hip','Knee','Ankle','Tip of Feet')
    title('Velocity');
    xlabel('Time (frame)');
    ylabel('Velocity');
    subplot(1,3,3)
    hold on
    %% Acceleration Plots
    plot(A1(:,2),A1(:,1), 'y-o');
    plot(A2(:,2),A2(:,1), 'g-o');
    plot(A3(:,2),A3(:,1), 'b-o');
    plot(A4(:,2),A4(:,1), 'm-o');
    plot(A5(:,2),A5(:,1), 'c-o');
    plot(A6(:,2),A6(:,1), 'r-o');
    plot(A7(:,2),A7(:,1), 'k-o');grid on;
    legend('Hand','Elbow','Shoulder','Hip','Knee','Ankle','Tip of Feet')
    title('Acceleration');
    xlabel('Time (frame)');
    ylabel('Acceleration');
    
end

function P = calculate_conformal(I, S, method)
    [rS, cS] = size(S);
    [rI, cI] = size(I);

    if cS ~= cI || rS ~= rI
        error('matrix dimension');
    end
    % Coefficients Matrix
    A =[I(:,1) -I(:,2) ones(rI,1) zeros(rI,1);
        I(:,2) I(:,1) zeros(rI,1) ones(rI,1)];
    % There are two type of solutions for over determined systems of eq.
    % 1. Least Square Method [ \ ]
    % 2. Psedou Inverse [ pinv() ]
    if method == 1
        P = A\S(:); %S = [S(:)]; % x(1), ... ,x(n) , y(1), ... , y(n)
    elseif method == 2
        P = pinv(A)*S(:);
    else
        disp('missing method!!');
    end
end

function H = calculate_reconformal(P, I)
    [rI, ~] = size(I);
    % Coefficients Matrix
    A =[I(:,1) -I(:,2) ones(rI,1) zeros(rI,1); I(:,2) I(:,1) zeros(rI,1) ones(rI,1)];

    H = A*P;
    H = [H(1:length(H)/2) H((length(H)/2)+1:end)];
end