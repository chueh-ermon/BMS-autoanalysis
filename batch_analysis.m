function batch = batch_analysis(batch_date)

%% Initialize batch struct
batch = struct('policy', ' ', 'barcode', ' ', 'cycles', ...
        struct('discharge_dQdVvsV', struct('V', [], 'dQdV', []), ...
        'Qvst', struct('t', [], 'Q', [], 'C', []), 'VvsQ', struct('V', [], ...
        'Q', []), 'TvsQ', struct('T', [], 'Q', [])), ...
        'summary', struct('cycle', [], 'QDischarge', [], 'QCharge', ...
        [], 'IR', [], 'Tmax', [], 'Tavg', [], 'Tmin', [], ...
        'chargetime', []));

%% Find CSVs from this batch
cd 'C:/Data'

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

%% Extract Metadata and then remove from filename array
for i = 1:numel(filenames)
    % Finds if .csv is a metadata
    if contains(filenames{i}, 'Meta') == 1
        % If so then read the cell barcode from the metadata
        [~, text_data] = xlsread(filenames{i});
        cell_ID = string(text_data{2, 10});
        % Here would be where to remove other Metadata info 
        barcodes = [barcodes, cell_ID];
        continue
    else 
        % File is a result Data 
        test_files = [test_files, filenames{i}];
        test_name = filenames{i};
        underscore_i = strfind(test_name, '_');
        %Find underscore before and after charging algorithm.
        charging_algorithm = test_name(underscore_i(1) ...
            + 1:underscore_i(end) - 1);
        % Store Charging Algorithm name
        CA_array = [CA_array, charging_algorithm];
    end
end
% Remove any duplicates. 
CA_array = unique(CA_array);

%% Load each file sequentially, save data into struct 
for j = 1:numel(CA_array)
    % Track how many batteries per charging algorithm
    num_batt = 1; % TODO: is this needed
    charging_algorithm = CA_array{j};
    
    for i = 1:numel(test_files)
        % Find tests that are within that charging algorithm.
        filename = test_files{i};
        if contains(filename, charging_algorithm) == 1
            % Update on progress 
            tic
            disp(['Starting processing of file ' num2str(i) ' of ' ...
                num2str(numel(test_files)) ': ' filename])
            
            %% Run CSV Analysis for this file
            result_data = csvread(strcat('C:\Data\',test_files{i}),1,1);
            cd 'C:/Users/Arbin/Documents/GitHub/BMS-autoanalysis'
            battery = cell_analysis(result_data, charging_algorithm);
            batch(i) = battery;
            num_batt = num_batt + 1;
            
            cd 'C:/Data'
            % Close figures if more than 2 are open 
            if num_batt == 3
                close all
            end
        else 
            continue
        end
        toc
    end
end
cd 'C:\Users\Arbin\Box Sync\Batch data'
save(strcat(batch_data, '_batchdata'), 'batch_date', 'batch')
cd 'C:\Users\Arbin\Documents\BMS-autoanalysis'
end
