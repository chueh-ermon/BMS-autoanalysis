%% email_results sends the report and the predictions to the mailing list
% Peter Attia, last updated June 25, 2018

batch_size = length(batch);
num_complete = 0;
for k = 1:batch_size
    if length(batch(k).cycles) > 99
        num_complete = num_complete + 1;
    end
end

%attachments = [path.reports '\' date '_report.pdf'];
attachments = cell(2,1);
attachments{1} = [path.reports '\' date '_report.pdf'];
attachments{2} = [path.result_tables '\' date '_' batch_name '_predictions.csv'];
message_body = {['Hot off the press: Check out the latest ' batch_name ...
    ' results, now including predictions!']; path.message; 
    [num2str(num_complete) ' out of ' num2str(batch_size) ' cells complete'];
    ''; ''; ''};
email_list = {'chueh-ermon-bms@lists.stanford.edu'};
if email_group
    sendemail(email_list,'BMS project: Updated results', ...
        message_body, attachments);
    disp('Email sent - success!')
else
    email_list_debugging = {'pattia@stanford.edu','kseverso@mit.edu'};
    sendemail(email_list_debugging,'BMS project: Updated results', ...
        message_body, attachments);
    disp('Email sent - success!')
end
