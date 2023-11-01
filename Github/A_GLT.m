clc
clear
close all

% Open the text file for reading
fileID = fopen('A_GLT.txt', 'r');

% Read the data from the file into a matrix
data = fscanf(fileID, '%f', [2 Inf]);

% Close the file
fclose(fileID);

% Transpose the data matrix so that it is in the correct orientation
data = data';

% Delete the second column of the matrix
data(:, 2) = [];

% Display the data
disp(data);

% Define the threshold value
threshold = 2.25E-9;

% Find the elements in the matrix that exceed the threshold
exceeds_threshold = data > threshold;

% Check if any element in the matrix exceeds the threshold
if any(data(:) > threshold)
    disp('At least one element in the matrix exceeds the threshold value.');
else
    disp('No element in the matrix exceeds the threshold value.');
end

% Display the indices and values of the elements that exceed the threshold
[row, col] = find(exceeds_threshold);
disp(['The following elements in the matrix exceed the threshold value of ', num2str(threshold), ':']);
for i = 1:length(row)
    disp(['(', num2str(row(i)), ',', num2str(col(i)), ') = ', num2str(data(row(i), col(i)))]);
end






