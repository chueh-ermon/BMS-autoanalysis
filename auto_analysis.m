%% auto_analysis.m...
%   - Runs Batch_Analysis
%   - Saves data to .mat
%   - Makes images
%   - Makes PPT & converts to PDF
%   - Emails results
% Nick Perkins, Zi Yang, Michael Chen, Peter Attia

% For this file to successfully run, you must do the following:
%   - Ensure 'python.m' is in the same folder
%   - Also, ensure the required Python libraries are installed (see
%   reportgenerator.py)

%% CHANGE THIS SETTING %%%%%%%
batch_date = '2017-06-30'; % Format as 'yyyy-mm-dd'
batch_name = 'batch2';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Run Batch Analysis for all cells
batch = batch_analysis(batch_date);

%% Generate images & results for all cells
make_images(batch, batch_name)
make_result_tables(batch, batch_name)
make_summary_images(batch, batch_name)

%% Run the report generator (in Python)
% This will create the PPT and convert to PDF. It saves in the Box Sync
% folder
python('reportgenerator.py'); % run python code

%% Send email
cd 'C:\Users/Arbin/Box Sync/Reports'
pdf_name = [date '_report'];
message_body = 'Hot off the press: Check out the latest results!';
sendemail('mchen18','BMS project: Updated results', ...
    message_body,char(pdf_name));
cd 'C://Data//chueh-ermon-battery'