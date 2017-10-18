function batch = batch_analysis(batch_date)

disp('Starting batch_analysis'), batch_tic = tic;

%% Initialize batch struct
batch = struct('policy', ' ', 'policy_readable', ' ', 'barcode', ...
    ' ', 'channel_id', ' ', 'cycles', struct('discharge_dQdVvsV', ...
    struct('V', [], 'dQdV', []), 't', [], 'Qc', [], 'I', [],'V', [], ...
    'T', [], 'Qd', [], 'Q', []), 'summary', struct('cycle', [], ...
    'QDischarge', [], 'QCharge', [], 'IR', [], 'Tmax', [], 'Tavg', ...
    [], 'Tmin', [], 'chargetime', []));

%% Load path names
load path.mat

%% Initialize Summary Arrays and values
% An Array of Charging Algorithm names
CA_array = {};
%List of all file names including Metadata
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

%% Extract metadata and then remove from filename array
for i = 1:numel(filenames)
    % Finds if .csv is a metadata
    if contains(filenames{i}, 'Meta') == 1
        % If so then read the cell barcode from the metadata
        [~, ~, text_data] = xlsread(filenames{i});
        cell_ID = string(text_data{2, 11});
        channel_id = string((text_data{2, 4} + 1));
        % Eextract metadata 
        barcodes = [barcodes, cell_ID];

        channel_ids = [channel_ids, channel_id];
        continue
    else 
        % File is a result csv 
        test_files = [test_files, filenames{i}];
        test_name = filenames{i};
        

        if strcmp(batch_date,'20170412')
            underscore_i = strfind(test_name, '_');
            charging_algorithm = test_name(10:underscore_i - 1);
        else
            % Find underscore before and after charging algorithm
            underscore_i = strfind(test_name, '_');
            charging_algorithm = test_name(underscore_i(1) ...
                + 1:underscore_i(end) - 1);
        end
        
        % Store charging algorithm name
        CA_array = [CA_array, charging_algorithm];
    end
end
% Remove any duplicates
CA_array = unique(CA_array);

if strcmp(batch_date,'20170412')
    test_files = test_files([1:29 42:end]);
end

%% Load each file sequentially, save data into struct 
for j = 1:numel(CA_array)
    charging_algorithm = CA_array{j};
    
    for i = 1:numel(test_files)
        % Find tests that are within that charging algorithm
        filename = test_files{i};
        if contains(filename, charging_algorithm)
            % Update user on progress 
            tic
            disp(['Starting processing of file ' num2str(i) ' of ' ...
                num2str(numel(test_files)) ': ' filename])
            
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
cd(path.batch_struct)
disp(['Saving batch information to directory ', cd])
tic
save(strcat(batch_date, '_batchdata'), 'batch_date', 'batch')
toc
cd(path.code)

disp('Completed batch_analysis'), toc(batch_tic)

end
