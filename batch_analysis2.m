function batch = batch_analysis2(batch_date)

disp('Starting batch_analysis'), batch_tic = tic;

%% Initialize batch struct
batch = struct('policy', ' ', 'policy_readable', ' ', 'barcode', ...
    ' ', 'channel_id', ' ','cycle_life', NaN,...
    'cycles', struct('discharge_dQdV', [], 't', [], 'Qc', [], 'I', [], ...
    'V', [], 'T', [], 'Qd', [], 'Qdlin', [],'Tdlin',[]), ...
    'summary', struct('cycle', [], 'QDischarge', [], 'QCharge', [], ...
    'IR', [], 'Tmax', [], 'Tavg', [], 'Tmin', [], 'chargetime', []), ...
    'Vdlin',[]);

%% Load path names
load path.mat

%% Initialize arrays
% array of charging algorithm names
CA_array = {};
% List of all file names including metadata
test_files = {};
% An array of barcodes for each cell pulled from metadata 
barcodes = {};
channel_ids = {};

%% Find CSVs from this batch
cd(path.csv_data)

batch_file_name = strcat('*', batch_date, '*.csv');
dir_info = dir(char(batch_file_name));
filenames = {dir_info.name};

% Remove deleted filenames from list
deletedcount = 0;
for i = 1:numel(filenames)
    if filenames{i}(1) == '~'
        deletedcount = deletedcount + 1;
    end
end
filenames = filenames(1:numel(filenames) - deletedcount);

% If no files are found, display error and exit
if numel(filenames) == 0
    disp('No files match query')
    return
end

keySet = {};
valueSet = {};

%% Extract metadata and then remove from filename array
for i = 1:numel(filenames)
    % Finds if .csv is a metadata csv
    if contains(filenames{i}, 'Meta')
        % If so, read the cell barcode from the metadata
        [~, ~, text_data] = xlsread(filenames{i});
        cell_ID = string(text_data{2, 11});
        channel_id = string((text_data{2, 4} + 1));
        % Extract metadata 
        barcodes = [barcodes, cell_ID];
        channel_ids = [channel_ids, channel_id];
        
        % Extract charging algorithm
        schedule_file = upper(text_data{2, 9});
        % Find hyphen before charging algorithm
        % Example schedule file:
        % '2017-12-04_tests\20170630-3_6C_30per_6C.sdu'
        % We want the '-' between 0630 and 3_6, or the last hyphen
        underscore_i = strfind(schedule_file, '-');
        underscore_i = underscore_i(end);
        if strcmp(batch_date, '2018-10-02') || strcmp(batch_date, '2018-11-02')
            underscore_i = strfind(schedule_file, '\');
            underscore_i = underscore_i(end);
        end
        % We also want the '.' in '.sdu'
        dot_i = strfind(schedule_file, '.');
        charging_algorithm = schedule_file(underscore_i + 1:dot_i - 1);
        
        % Store charging algorithm name
        CA_array = [CA_array, charging_algorithm];
        
        test_files = [test_files, filenames{i}([1:end-13 end-3:end])];
    end
end

if strcmp(batch_date,'20170412')
    test_files = test_files([1:29 42:end]);
end

k = 1;

%% Load each file sequentially and save data into struct 
n_cells = numel(test_files);
for i = 1:n_cells
    % Find metadata
    filename = test_files{i};
    CA = CA_array{i};
    
    % Update user on progress
    tic
    disp(['Starting processing of file ' num2str(k) ' of ' ...
        num2str(n_cells) ': ' filename])
    k = k + 1;
    
    %% Run cell_analysis for this file
    result_data = csvread(strcat(path.csv_data, '\', filename),1,1);
    cd(path.code)
    
    battery = cell_analysis(result_data, CA, batch_date, path.csv_data);
    battery.barcode = barcodes(i);
    battery.channel_id = channel_ids(i);
    batch(i) = battery;
    
    cd(path.csv_data)
    toc
end

%% Save batch as struct
cd(path.batch_struct)
disp(['Saving batch information to directory ', cd])
tic
save(strcat(batch_date, '_batchdata','_updated_struct_errorcorrect'), 'batch_date', 'batch')
toc
cd(path.code)

disp('Completed batch_analysis'), toc(batch_tic)

end
