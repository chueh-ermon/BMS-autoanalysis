%% email_results sends the report and the predictions to the mailing list
% Peter Attia, last updated May 7, 2018

attachments = cell(2,1);
attachments{1} = [path.reports '\' date '_report.pdf'];
attachments{2} = [path.result_tables '\' date '_' batch_name '_predictions.csv'];
message_body = {['Hot off the press: Check out the latest ' batch_name ...
    ' results, now including predictions!']; path.message; ''; ''};
email_list = {'chueh-ermon-bms@lists.stanford.edu'};
if email_group
    sendemail(email_list,'BMS project: Updated results', ...
        message_body, attachments);
    disp('Email sent - success!')
else
    email_list_debugging = {'pattia@stanford.edu'};
    sendemail(email_list_debugging,'BMS project: Updated results', ...
        message_body, attachments);
    disp('Email sent - success!')
end
