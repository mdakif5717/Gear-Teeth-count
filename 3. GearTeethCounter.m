
% Gear Teeth Counting using Masking Technique (Live Camera Version)
% Author: ChatGPT

clc;
clear;
close all;

% Initialize webcam
cam = webcam;  % Connect to webcam

% Capture a frame
img = snapshot(cam);

% Show captured image
imshow(img);
title('Captured Image from Camera');
pause(1);

% Release camera
clear cam;

% Step 2: Convert to grayscale
gray = rgb2gray(img);

% Step 3: Threshold to create a binary mask
bw = imbinarize(gray, 'adaptive', 'Sensitivity', 0.5);
bw = imcomplement(bw); % invert if needed

% Step 4: Morphological operations to clean mask
bw = imfill(bw, 'holes');    % fill holes
bw = bwareaopen(bw, 500);     % remove small noise
bw = imclose(bw, strel('disk', 5)); % smooth edges

figure;
imshow(bw);
title('Binary Mask');

% Step 5: Find edges
edges = edge(bw, 'Canny');

figure;
imshow(edges);
title('Edges');

% Step 6: Find boundaries
[B, L] = bwboundaries(bw, 'noholes');

% Assume the largest boundary is the gear
stats = regionprops(L, 'Area');
[~, idx] = max([stats.Area]);
gearBoundary = B{idx};

% Step 7: Analyze boundary to find peaks
x = gearBoundary(:,2);
y = gearBoundary(:,1);

% Convert to polar coordinates (relative to center)
centerX = mean(x);
centerY = mean(y);

theta = atan2(y - centerY, x - centerX);
r = sqrt((x - centerX).^2 + (y - centerY).^2);

% Smooth radius to reduce noise
rSmooth = smooth(r, 10);

% Find peaks
[peakValues, peakLocs] = findpeaks(rSmooth, 'MinPeakProminence', 5, 'MinPeakDistance', 10);

% Step 8: Count teeth
numTeeth = length(peakLocs);

% Step 9: Display results
figure;
imshow(img);
hold on;
plot(centerX, centerY, 'r*', 'MarkerSize', 10);
plot(x, y, 'g-', 'LineWidth', 1);
plot(x(peakLocs), y(peakLocs), 'ro', 'MarkerFaceColor', 'r');
title(['Detected Teeth: ', num2str(numTeeth)]);
hold off;

disp(['Number of Gear Teeth Detected: ', num2str(numTeeth)]);
