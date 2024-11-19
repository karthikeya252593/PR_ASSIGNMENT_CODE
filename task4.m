% Define paths for features and labels
feature_dir = 'D:\feature'; % Directory containing the feature files

% Initialize cell arrays to store all feature data and keep track of file shapes
all_features = {};
file_shapes = containers.Map;

% Step 1: Load all feature files and log their shapes
feature_files = dir(fullfile(feature_dir, '*.txt'));
for i = 1:length(feature_files)
    file_name = feature_files(i).name;
    file_path = fullfile(feature_dir, file_name);
    
    try
        % Load feature data, skipping the first row if necessary
        fid = fopen(file_path, 'r');
        lines = textscan(fid, '%s', 'Delimiter', '\n');
        fclose(fid);
        
        lines = lines{1};
        
        % Check and skip header if non-numeric
        if isempty(str2double(strsplit(lines{1})))  % If first line is non-numeric
            lines = lines(2:end);  % Skip the first line
        end
        
        % Convert valid lines to an array
        feature_data = [];
        for j = 1:length(lines)
            feature_data = [feature_data; str2double(strsplit(lines{j}))'];
        end
        
        % Store the shape of each file for debugging
        file_shapes(file_name) = size(feature_data);
        
        % Ensure 2D format for single-row cases
        if size(feature_data, 1) == 1
            feature_data = feature_data';
        end
        
        all_features{end + 1} = feature_data;
    catch ME
        fprintf('Skipping %s due to non-numeric content or format issues. Error: %s\n', file_name, ME.message);
    end
end

% Print the shapes of all files for inspection
disp('File shapes:');
keys = file_shapes.keys;
for i = 1:length(keys)
    fprintf('%s: (%d, %d)\n', keys{i}, file_shapes(keys{i})(1), file_shapes(keys{i})(2));
end

% Step 2: Handle labels
% Check if the label file exists, if not create dummy labels
label_file_path = 'D:\feature\concatenated_labels.txt';  % Define your label file path here

if isfile(label_file_path)
    % Load the actual labels if file exists
    all_labels = load(label_file_path);
else
    % If no labels file, create a dummy labels array with the same length as feature samples
    disp('Label file not found. Generating dummy labels.');
    total_samples = sum(cellfun(@(x) size(x, 1), all_features));  % Calculate total samples
    all_labels = randi([0, 1], total_samples, 1);  % Generate random labels (0 or 1) as a placeholder
end

% Step 3: Verify the number of samples matches the number of labels
num_samples = sum(cellfun(@(x) size(x, 1), all_features));
if size(all_labels, 1) ~= num_samples
    error('The number of feature samples does not match the number of labels.');
end

% Combine all features into a single 2D array
all_features_combined = [];
for i = 1:length(all_features)
    all_features_combined = [all_features_combined; all_features{i}];
end

% Combine features and labels into one array
combined_data = [all_features_combined, all_labels];

% Print combined data shape and sample rows
fprintf('\nCombined input-output data prepared for classification:\n');
fprintf('Combined Data Shape: (%d, %d)\n', size(combined_data, 1), size(combined_data, 2));

% Display the first 5 samples
disp('First 5 samples:');
for i = 1:5
    fprintf('Sample %d: Features: ', i);
    disp(combined_data(i, 1:end-1));  % Display features
    fprintf('Label: %d\n', combined_data(i, end));  % Display label
end
