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

%% CHANGE THIS SETTING %%%%%%%
batch_date = '2017-06-30'; % Format as 'yyyy-mm-dd'
batch_name = 'batch2';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Run Batch Analysis for all cells
batch = batch_analysis(batch_date);

%% Generate images & results for all cells
make_images(batch, batch_name, batch_date);
[T_cells, T_policies] = make_result_tables(batch, batch_name);
make_summary_images(batch, batch_name, T_cells, T_policies);

%% Run the report generator (in Python)
% This will create the PPT and convert to PDF. It saves in the Box Sync
% folder
cd 'C:\Users\Arbin\Documents\GitHub\BMS-autoanalysis'
python('reportgenerator.py'); % run python code

%% Send email
cd 'C:\Users\Arbin\Box Sync\Data\Reports'
pdf_name = [date '_report.pdf'];
message_body = 'Hot off the press: Check out the latest results!';
email_list = {'chueh-ermon-bms@lists.stanford.edu'};
sendemail(email_list,'BMS project: Updated results', ...
    message_body,char(pdf_name));
cd 'C:\Users\Arbin\Documents\GitHub\BMS-autoanalysis'
disp('Email sent - success!'), toc(init_tic)

%% Make summary gifs (for presentations)
%make_summary_gifs(batch, batch_name, T_cells, T_policies);