function batch = batch_analysis(batch_date)

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
        schedule_file = text_data{2, 9};
        % Find hyphen before charging algorithm
        % Example schedule file:
        % '2017-12-04_tests\20170630-3_6C_30per_6C.sdu'
        % We want the '-' between 0630 and 3_6, or the last hyphen
        underscore_i = strfind(schedule_file, '-');
        underscore_i = underscore_i(end);
        % We also want the '.' in '.sdu'
        dot_i = strfind(schedule_file, '.');
        charging_algorithm = schedule_file(underscore_i + 1:dot_i - 1);
        
        % Store charging algorithm name
        CA_array = [CA_array, charging_algorithm];
        
        % Create 'container' (aka dictionary) to map charging algorithms to
        % channels
        keySet{end+1} = char(channel_id);
        valueSet{end+1} = charging_algorithm;
        
        continue
    else
        % File is a result csv 
        test_files = [test_files, filenames{i}];
    end
end

% Remove any duplicates
CA_array = unique(CA_array);

% Create map object
mapObj = containers.Map(keySet,valueSet);

if strcmp(batch_date,'20170412')
    test_files = test_files([1:29 42:end]);
end

k = 1;

%% Load each file sequentially and save data into struct 
for j = 1:numel(CA_array)
    charging_algorithm = CA_array{j};
    
    for i = 1:numel(test_files)
        % Find tests that are within that charging algorithm
        filename = test_files{i};
        
        underscore_i = strfind(filename, '_');
        underscore_i = underscore_i(end);
        % We also want the '.' in '.sdu'
        dot_i = strfind(filename, '.');
        channel = char(filename(underscore_i + 3:dot_i - 1));
        
        CA = mapObj(channel);
        
        if strcmp(CA,charging_algorithm)
            % Update user on progress 
            tic
            disp(['Starting processing of file ' num2str(k) ' of ' ...
                num2str(numel(test_files)) ': ' filename])
            k = k + 1;
            
            %% Run cell_analysis for this file
            result_data = csvread(strcat(path.csv_data, '\', test_files{i}),1,1);
            cd(path.code)
            
            if strcmp(batch_date,'20170412')
                battery = cell_analysis_batch0(result_data, charging_algorithm, ...
                    batch_date, path.csv_data);
                battery.barcode = barcodes(i);
                battery.channel_id = channel_ids(i);
                batch(i) = battery;
            else
                battery = cell_analysis(result_data, charging_algorithm, ...
                    batch_date, path.csv_data);
                battery.barcode = barcodes(i);
                battery.channel_id = channel_ids(i);
                batch(i) = battery;
            end
            cd(path.csv_data)
        else 
            continue
        end
        toc
    end
end

%% Save batch as struct
cd(path.batch_struct)
disp(['Saving batch information to directory ', cd])
tic
save(strcat(batch_date, '_batchdata','_updated_struct'), 'batch_date', 'batch')
toc
cd(path.code)

disp('Completed batch_analysis'), toc(batch_tic)

end
