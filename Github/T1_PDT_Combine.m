clc
clear
close all

% Open the text file for reading
fileID = fopen('T1A_PDT.txt', 'r');
fileID2 = fopen('T1B_PDT.txt', 'r');
fileID3 = fopen('V_PDT.txt', 'r');

% Read the data from the file into a matrix
data1 = fscanf(fileID, '%f', [1 Inf]);
data2 = fscanf(fileID2, '%f', [1 Inf]);
data3 = fscanf(fileID3, '%f', [1 Inf]);

% Close the file
fclose(fileID);
fclose(fileID2);
fclose(fileID3);

% Transpose the data matrix so that it is in the correct orientation
data1 = data1';
data2 = data2';
data3 = data3';

% Set number of rows
numRow1 = size(data1,1);
numRow2 = size(data2,1);
numRow3 = size(data3,1);

% Difference between size of numRow
d1=abs(numRow1-numRow2);
d2=abs(numRow1-numRow3);
d3=abs(numRow2-numRow3);

% Standardize numRow 1 and 2
if numRow1 >= numRow2&&numRow3
    if numRow2 >= numRow3 
    data1 = data1(1:end-d2);
    numRow1 = numRow1-d2; 
    data2 = data2(1:end-d3);
    numRow2 = numRow2-d3; 
    else 
    data1 = data1(1:end-d1);
    numRow1 = numRow1-d1; 
    data3 = data3(1:end-d3);
    numRow3 = numRow3-d3;
    end
elseif numRow2 > numRow1&&numRow3
    if numRow1 > numRow3 
    data1 = data1(1:end-d2);
    numRow1 = numRow1-d2; 
    data2 = data2(1:end-d3);
    numRow2 = numRow2-d3; 
    else 
    data2 = data2(1:end-d1);
    numRow2 = numRow2-d1; 
    data3 = data3(1:end-d2);
    numRow3 = numRow3-d2;
    end
elseif numRow3 > numRow1&&numRow2
    if numRow1 > numRow2
    data1 = data1(1:end-d1);
    numRow1 = numRow1-d1; 
    data3 = data3(1:end-d3);
    numRow3 = numRow3-d3; 
    else 
    data2 = data2(1:end-d1);
    numRow2 = numRow2-d1; 
    data3 = data3(1:end-d2);
    numRow3 = numRow3-d2;
    end
else 
end

% Define the time step and duration
dt = 0.1; % 10 Hz
T1 = (numRow1-dt)/10; % seconds
T2 = (numRow2-dt)/10; % seconds
T3 = (numRow3-dt)/10; % seconds

% Create the time vector
t1 = 0:dt:T1;
t2 = 0:dt:T2;
t3 = 0:dt:T3;

% Transpose the data matrix so that it is in the correct orientation
t1 = t1';
t2 = t2';
t3 = t3';

% Moving average data in the inter
M1 = movmean(data1,20);
M2 = movmean(data2,20);
M3 = movmean(data3,20);

% Combine data 
combinedData1 = horzcat(M1, t1);
combinedData2 = horzcat(M2, t2);
combinedData3 = horzcat(M3, t3);

%% Plot the data on a logarithmic scale
figure(1)
semilogy(t1, M1, 'r-');
hold on
grid on

semilogy(t2, M2, 'b-');
hold on
grid on

semilogy(t3, M3, 'g-');
hold on
grid on

xlabel('Time (s)');
ylabel('Pressure (mbar)');
title('Logarithmic Scale Plot');
grid on;

legend('With Venting','Without Venting','Without Test Flange','Location','northeast')

%% Find difference between initial and final pressure in its own data
% Find the final pump down time 
PDTime = t1(end)/3600;

% Display data for Test 2 Set A (with venting) Pump down test (T1A_PDT)
disp(['atmospheric pressure at T1A_PDT = ',num2str(data1(1)),' mbar']);
disp(['minimum detectable pump down level at T1A_PDT = ',num2str(data1(end)),' mbar at ',num2str(PDTime),' hours']);
disp(' ');

% Display data for Test 2 Set B (without venting) Pump down test (T1B_PDT)
disp(['atmospheric pressure at T1B_PDT = ',num2str(data2(1)),' mbar']);
disp(['minimum detectable pump down level at T1B_PDT = ',num2str(data2(end)),' mbar at ',num2str(PDTime),' hours']);
disp(' ');

% Display data for setup without test flange (V_PDT)
disp(['atmospheric pressure at V_PDT = ',num2str(data3(1)),' mbar']);
disp(['minimum detectable pump down level at V_PDT = ',num2str(data3(end)),' mbar at ',num2str(PDTime),' hours']);
disp(' ');

% Find average convergence gradient 
% Gradient 1
downsample_interval = 300000;
y1A = M1(end);
y2A = M1(end-downsample_interval);
x1A = t1(end);
x2A = t1(end-downsample_interval);
G1 = (y2A-y1A)/(x2A-x1A);
disp(['The convergence gradient, G1 (Venting) = ',num2str(G1)]);

% Gradient 2
y1B = M2(end);
y2B = M2(end-downsample_interval);
x1B = t2(end);
x2B = t2(end-downsample_interval);
G2 = (y2B-y1B)/(x2B-x1B);
disp(['The convergence gradient, G2 (Without Venting) = ',num2str(G2)]);

% Gradient 3
y1V = M3(end);
y2V = M3(end-downsample_interval);
x1V = t3(end);
x2V = t3(end-downsample_interval);
G3 = (y2V-y1V)/(x2V-x1V);
disp(['The convergence gradient, G3 (Without Test Flange) = ',num2str(G3)]);
disp(' ');

%% Define interval and find continuous gradient within interval in V_PDT
% Influence of signal fluctuation in decimal
loop_interval = length(M3);
diff_original_movmean = zeros(loop_interval,1);

for i=1:length(M3)
    diff_original_movmean(i) = abs((M3(i) - data3(i))/data3(i)); % Diff between original data and moving average
end

maxDiff = max(abs(diff_original_movmean)); % find max diff between original data and moving averaged data in decimal

% Define interval between each slope
downsample_interval = 30;

% Define the down_x and down_y values
down_x3 = downsample(t3,downsample_interval);
down_y3 = downsample(M3,downsample_interval);

% Initialize variables
numPoints3 = length(down_y3);
gradient3 = zeros(numPoints3 - 1, 1);

% Calculate the continuous gradient
for i = 1:numPoints3-1
    gradient3(i) = (down_y3(i+1) - down_y3(i)) / (down_x3(i+1) - down_x3(i));
end

maxPositive = max(gradient3).*(1+maxDiff);

%% Define interval and find continuous gradient within interval in A_PDT
% Define the down_x and down_y values
down_x1 = downsample(t1,downsample_interval);
down_y1 = downsample(M1,downsample_interval);

% Initialize variables
numPoints1 = length(down_y1);
gradient1 = zeros(numPoints1 - 1, 1);

% Calculate the continuous gradient
for i = 1:numPoints1 - 1
    gradient1(i) = (down_y1(i+1) - down_y1(i)) / (down_x1(i+1) - down_x1(i));
end

% Check leak 
% Check for positive values
hasPositive1 = any(gradient1 > maxPositive);

% Display the result
if hasPositive1
    disp('There has a virtual leak. (With Venting)');
    indices1 = find(gradient1 > maxPositive);
    disp('Virtual leak happened in the indices of: ');
    disp(indices1);
    disp('Virtual leak happened in the pressure (mbar) of: ');
    disp(down_y1(indices1));
    disp('Virtual leak happened in the time of (seconds): ');
    disp(down_x1(indices1));
    disp(' ');
else
    disp('There do not have virtual leak. (With Venting)');
    disp(' ');
end

%% Define interval and find continuous gradient within interval in B_PDT
% Define the down_x and down_y values
down_x2 = downsample(t2,downsample_interval);
down_y2 = downsample(M2,downsample_interval);

% Initialize variables
numPoints2 = length(down_y2);
gradient2 = zeros(numPoints2 - 1, 1);

% Calculate the continuous gradient
for i = 1:numPoints2 - 1
    gradient2(i) = (down_y2(i+1) - down_y2(i)) / (down_x2(i+1) - down_x2(i));
end

% Check leak 
% Check for positive values
hasPositive2 = any(gradient2 > maxPositive);

% Display the result
if hasPositive2
    disp('There has a virtual leak. (Without Venting)');
    indices2 = find(gradient2 > maxPositive);
    disp('Virtual leak happened in the indices of: ');
    disp(indices2);
    disp('Virtual leak happened in the pressure (mbar) of: ');
    disp(down_y2(indices2));
    disp('Virtual leak happened in the time of (seconds): ');
    disp(down_x2(indices2));
    disp(' ');
else
    disp('There do not have virtual leak. (Without Venting)');
    disp(' ');
end

disp(['max gradient in A_PDT = ',num2str(max(gradient1))]);
disp(['max gradient in B_PDT = ',num2str(max(gradient2))]);
disp(['max gradient in V_PDT = ',num2str(max(gradient3))]);
disp(' ');

%% Plot the data on a logarithmic scale wtih detected leak point
figure(2)
semilogy(down_x1, down_y1, 'r-');
hold on
grid on

semilogy(down_x2, down_y2, 'b-');
hold on
grid on

semilogy(down_x3, down_y3, 'g-');
hold on
grid on

xlabel('Time (s)');
ylabel('Pressure (mbar)');
title('Logarithmic Scale Plot wtih Detected Leak Point');
grid on;

if hasPositive1
    % Plot the point
    semilogy(down_x1(indices1), down_y1(indices1), 'ro'); % 'ro' specifies red color circles for the point
    % Add the label
    label = 'Detected leak point';
    text(down_x1(indices1), down_y1(indices1), label, 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left');
end

if hasPositive2
    % Plot the point
    semilogy(down_x2(indices2), down_y2(indices2), 'ro'); % 'ro' specifies red color circles for the point
    % Add the label
    label = 'Detected leak point';
    text(down_x2(indices2), down_y2(indices2), label, 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left');
end

legend('With Venting','Without Venting','Without Test Flange','Location','northeast')

disp(['thresholding value = ',num2str(maxPositive)]);





