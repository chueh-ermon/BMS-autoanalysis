function props = sendemail(email_list,subject,message,attachment)
%% sendemail: send email from gmail account
 
% Pradyumna
% June 2008
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Your gmail ID and password 
%(from which email ID you would like to send the mail)
mail = 'chuehbatteries@gmail.com';    %Your GMail email address
password = 'fake_password';           %Your GMail password
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 1
    message = subject;
    subject = '';
elseif nargin == 2
    message = '';
    attachment = '';
elseif nargin == 3
    attachment = '';
end

%% Set up Gmail SMTP service.
% Then this code will set up the preferences properly:
setpref('Internet','E_mail',mail);
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username',mail);
setpref('Internet','SMTP_Password',password);

% Gmail server.
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');
props.setProperty('mail.smtp.starttls.enable', 'true');

%% Send the email
for i=1:numel(email_list)
    if nargin == 4
        sendmail(email_list{i},subject,message,attachment)
    else
        sendmail(email_list{i},subject,message)
    end
end
