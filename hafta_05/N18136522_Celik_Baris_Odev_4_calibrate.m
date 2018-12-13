function clbhw = calibrateHW4()
    clc, clear

    S = [ 0 80; % 1.
        0 109; % 2.
        103 72; % 3.
        103 111]; % 4.

    ball_position = load('ball_position.txt');
    ball_position_weighted = load('ball_position_weighted.txt');
    calib_im = load('calib_im.txt');
    I = calib_im;
    x = calculate_conformal(I, S, 1);
    H = calculate_reconformal(x, ball_position);
    HW = calculate_reconformal(x, ball_position_weighted);
    teta = atand(x(2)/x(1));
    scale = x(1)/cosd(teta);
    Tx = x(3);
    Ty = x(4);
    
%     figure;
%     subplot(1,2,1)
%     plot(H(:,1),H(:,2), 'ro');axis([0 100 0 160]);axis equal;grid on;
%     subplot(1,2,2)
%     plot(HW(:,1),HW(:,2), 'ko');axis([0 100 0 160]);axis equal;grid on;
    
    deltaT = 1;%2 / 30; % for sec / frame
    V = zeros(numel(H(:,1)), 2);
%     A = zeros(numel(H(:,1)), 2);
    for j = 2:numel(H(:,1))-1
        V(j,1) = (sqrt(sum((H(j+1,:) - H(j-1,:)) .^ 2))) / (2 * deltaT);
        V(j,2) = j;
%         A(j,1) = (sqrt(sum((H(j+1,:) - (2*(H(j,:))) + H(j-1,:)) .^ 2))) / (deltaT * deltaT);
%         A(j,2) = j;
    end
    
    VW = zeros(numel(HW(:,1)), 2);
%     AW = zeros(numel(HW(:,1)), 2);
    for j = 2:numel(HW(:,1))-1
        VW(j,1) = (sqrt(sum((HW(j+1,:) - HW(j-1,:)) .^ 2))) / (2 * deltaT);
        VW(j,2) = j;
%         AW(j,1) = (sqrt(sum((HW(j+1,:) - (2*(HW(j,:))) + HW(j-1,:)) .^ 2))) / (deltaT * deltaT);
%         AW(j,2) = j;
    end
    
    A = zeros(numel(V(:,1)), 2);
    for j = 2:numel(V(:,2))-1
        A(j,1) = (V(j+1,1) - V(j-1,1)) / (2 * deltaT);
        A(j,2) = j;
    end
    
    AW = zeros(numel(VW(:,1)), 2);
    for j = 2:numel(VW(:,1))-1
        AW(j,1) = (VW(j+1,1) - VW(j-1,1)) / (2 * deltaT);
        AW(j,2) = j;
    end
    
    figure;
    subplot(2,2,1)
    plot(V(:,2),V(:,1)*(-50), 'm-s');axis([0 30 -600 0]);grid on;
    title('Hýz - Normal KM');
    
    subplot(2,2,3)
    plot(VW(:,2),VW(:,1)*(-50), 'm-s');axis([0 30 -600 0]);grid on;
    title('Hýz - Aðýrlýklý KM');
    subplot(2,2,2)
    plot(A(:,2),A(:,1)*(-2500), 'b-s');axis([0 30 -1200, 200]);grid on;
    title('Ývme - Normal KM');
    subplot(2,2,4)
    plot(AW(:,2),AW(:,1)*(-2500), 'b-s');axis([0 30 -1200 200]);grid on;
    title('Ývme - Aðýrlýklý KM');
    
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
    [rI, cI] = size(I);
    % Coefficients Matrix
    A =[I(:,1) -I(:,2) ones(rI,1) zeros(rI,1); I(:,2) I(:,1) zeros(rI,1) ones(rI,1)];

    H = A*P;
    H = [H(1:length(H)/2) H((length(H)/2)+1:end)];
end