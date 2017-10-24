%% auto_analysis.m...
%   - Runs batch_analysis (converts to struct and saves data to .mat)
%   - Runs makes images (cell summary info)
%   - Runs make_result_tables and make_summary_images (batch summary info)
%   - Runs reportgenerator.py (creates PDF report)
%   - Emails results
% Nick Perkins, Zi Yang, Michael Chen, Peter Attia

% For this file to successfully run, you must do the following:
%   - Ensure 'python.m' is in the same folder
%   - Also, ensure the required Python libraries are installed (see
%   reportgenerator.py)

clear, close all
init_tic = tic; % time entire script

%%%%%%% CHANGE THESE SETTINGS %%%%%%%
email_group = false;
batch_name = 'batch3';
% ALSO, CHANGE:
%   - LINE 40 OF THIS SCRIPT - 'INCLUDE' DATE
%   - LINE 21 OF REPORTGENERATOR.PY
% IF ADDING A NEW BATCH, ADD batch_date TO THE SWITCH/CASE STATEMENT BELOW
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get batch_date from batch_name
switch batch_name % Format as 'yyyy-mm-dd'
    case 'batch0'
        batch_date = '20170412';
    case 'batch1'
        batch_date = '2017-05-12';
    case 'batch2'
        batch_date = '2017-06-30';
    case 'batch3'
        batch_date = '2017-08-14';
    otherwise
        warning('batch_date not recognized')
end

%% Load path names
load path.mat

%% Pull CSVs if program is running on Amazon Workspace
if path.whichcomp == 'amazonws'
    system('aws s3 sync s3://matr.io/experiment/d3batt D:\Data --exclude "*" --include "2017-08*"')
end

%% Workaround for bad csvs %%%%%%%
if strcmp(batch_name, 'batch2')
    delete([path.csv_data '\' '2017-06-30_CH14.csv'])
    delete([path.csv_data '\' '2017-06-30_CH14_Metadata.csv']')
elseif strcmp(batch_name, 'batch3')
    delete([path.csv_data '\' '2017-08-14_2C-5per_3_8C_CH4.csv'])
    delete([path.csv_data '\' '2017-08-14_2C-5per_3_8C_CH4_Metadata.csv']')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Run Batch Analysis for all cells
batch = batch_analysis(batch_date);

%% Generate images & results for all cells
make_images(batch, batch_name, batch_date, path.images);
[T_cells, T_policies] = make_result_tables(batch, batch_name, ...
    path.result_tables, path.code);
make_summary_images(batch, batch_name, T_cells, T_policies);

%% Run the report generator (in Python)
% This will create the PPT and convert to PDF. It saves in the Box Sync
% folder
python('reportgenerator.py', path.images, path.reports); % run python code

%% Send email
cd(path.reports)
pdf_name = [date '_report.pdf'];
message_body = {['Hot off the press: Check out the latest ' batch_name ' results!']; ...
    path.message; ''; ''};
email_list = {'chueh-ermon-bms@lists.stanford.edu'};
if email_group
    sendemail(email_list,'BMS project: Updated results', ...
        message_body, char(pdf_name));
    disp('Email sent - success!')
else
    sendemail({'pattia@stanford.edu'},'BMS project: Updated results', ...
        message_body, char(pdf_name));
    disp('Email sent - success!')
end
cd(path.code)

%% Sync Data_Matlab folder to AWS
if path.whichcomp == 'amazonws'
    disp('Syncing Data_Matlab from Amazon WS to Amazon s3')
    system('aws s3 sync D:\Data_Matlab s3://matr.io/experiment/d3batt_matlab')
    disp('Sync complete!')
end
toc(init_tic)

%% Make summary gifs (for presentations)
%make_summary_gifs(batch, batch_name);