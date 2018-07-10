%% auto_analysis.m...
%   - Pulls latest CSVs from AWS S3 bucket to this Workspace
%   - Runs batch_analysis (converts to struct and saves data to .mat)
%   - Runs apply_model (generates predictions)
%   - Runs makes images (cell summary info)
%   - Runs make_result_tables and make_summary_images (batch summary info)
%   - Runs reportgenerator.py (creates PDF report)
%   - Emails results
%   - Syncs results to AWS
% Peter Attia, Nick Perkins, Zi Yang, Michael Chen, Norman Jin

% For this file to successfully run, you must do the following:
%   - Ensure 'python.m' is in the same folder
%   - Also, ensure the required Python libraries are installed (see
%   reportgenerator.py)

%clear, close all
init_tic = tic; % time entire script

%% Load path names
load path.mat
cd(path.code)

%%%%%%% CHANGE THESE SETTINGS %%%%%%%
email_list = {'pattia@stanford.edu','normanj@stanford.edu',...
    'adityag@cs.stanford.edu','bcheong@stanford.edu'};
%email_list = {'chueh-ermon-bms@lists.stanford.edu'};
batch_name = 'oed2';
% IF ADDING A NEW BATCH...
%   - ADD batch_date TO get_batch_date_from_batch_name
%   - CREATE batchx_summary_plots.m AND MODIFY make_summary_images AS NEEDED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Get batch date from batch name
get_batch_date_from_batch_name

%% Pull CSVs if program is running on Amazon Workspace
if path.whichcomp == 'amazonws'
    aws_pulldata = ['aws s3 sync s3://matr.io/experiment/d3batt D:\Data --exclude "*" --include "' batch_date '*"'];
    system(aws_pulldata)
end

%% Delete bad csvs
delete_bad_csvs

%% Run batch_analysis for all cells
batch = batch_analysis2(batch_date);

%% Run predictions
apply_model2(batch, batch_name, path)

%% Generate images & results for all cells
make_images(batch, batch_name, batch_date, path.images);
[T_cells, T_policies] = make_result_tables(batch, batch_name, ...
    path.result_tables, path.code);
make_summary_images(batch, batch_name, T_cells, T_policies);

%% Run the report generator (in Python)
% This will create the PPT and convert to PDF. It saves in the Box Sync
% folder
python('reportgenerator.py', path.images, path.reports, batch_name); % run python code

%% Send email
email_results

%% Sync Data_Matlab folder to AWS
if path.whichcomp == 'amazonws'
    disp('Syncing Data_Matlab from Amazon WS to Amazon S3')
    system('aws s3 sync D:\Data_Matlab s3://matr.io/experiment/d3batt_matlab')
    disp('Sync complete!')
end

%% Clear contents of D:\Data folder
if path.whichcomp == 'amazonws'
    disp('Deleting D:\Data')
    cd('D:\')
    if exist('Data','dir')
        rmdir('Data','s')
    end
    mkdir('Data')
    cd(path.code)
    disp('Delete complete!')
end
toc(init_tic)