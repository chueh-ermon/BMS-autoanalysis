%% email_results sends the report and the predictions to the mailing list
% Peter Attia, last updated June 25, 2018

batch_size = length(batch);
num_complete = 0;
if strcmp(batch_name,'oed1')
    cycles_completed = 97;
else
    cycles_completed = 99;
end
for k = 1:batch_size
    if length(batch(k).cycles) > cycles_completed
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
sendemail(email_list,'BMS project: Updated results', ...
    message_body, attachments);
disp('Email sent - success!')