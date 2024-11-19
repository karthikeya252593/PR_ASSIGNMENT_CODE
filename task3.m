% Set the path to the dataset
dataset_path = 'D:\datasets';  % Replace with the actual path if needed

% Initialize a cell array to store the label vectors for each subject
label_vectors = containers.Map;

% Get the list of subject folders (e.g., sub1, sub2, ...)
subjects = dir(dataset_path);
subjects = subjects([subjects.isdir] & ~ismember({subjects.name}, {'.', '..'}));  % Get only directories

for i = 1:length(subjects)
    subject = subjects(i).name;
    subject_path = fullfile(dataset_path, subject);
    label_vector = [];  % Initialize an empty array to store labels for this subject

    for activity_type = {'normal', 'aggressive'}
        activity_path = fullfile(subject_path, activity_type{1}, 'txt');

        if isfolder(activity_path)
            % Get the list of .txt files in the directory
            text_files = dir(fullfile(activity_path, '*.txt'));
            text_files = sort({text_files.name});  % Sort the files alphabetically

            % Generate labels (1 to n) based on the number of files
            num_files = length(text_files);
            labels = 1:num_files;

            % Add these labels to the subject's label vector
            label_vector = [label_vector, labels];

            % Print the labels for the current activity
            fprintf('Labels for %s - %s: %s\n', subject, activity_type{1}, mat2str(labels));
        end
    end

    % Save the label vector for the subject
    label_vectors(subject) = label_vector;
end

% Concatenate the label vectors from all subjects into a single label vector
all_labels = [];
keys = label_vectors.keys;
for i = 1:length(keys)
    subject = keys{i};
    all_labels = [all_labels, label_vectors(subject)];
end

% Print the concatenated labels
disp('Concatenated Labels:');
disp(all_labels);  % Display the concatenated labels in the command window
