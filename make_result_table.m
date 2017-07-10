function T = make_result_table( batch )
%make_result_table makes a table of results for OED.
%   Parses policy parameters (e.g. CC1, CC2, Q1) and
%   calculates charging time and average degradation rate (if multiple cells).
%   Writes the results to a CSV.

n = numel(batch); % number of batteries in the batch

%% Preinitialize variables
CC1 = zeros(n,1);
CC2 = zeros(n,1);
Q1  = zeros(n,1);
t80calc  = zeros(n,1); % time to 80% (calculated from policy parameters)
t80meas100  = zeros(n,1); % time to 80% (measured - median of first 100 cycles)
cycles  = zeros(n,1); % number of cycles completed
degrate  = zeros(n,1); % average deg rate (Ah/cycles)
initdegrate  = zeros(n,1); % initial deg rate (Ah/cycles)
finaldegrate  = zeros(n,1); % final deg rate (Ah/cycles)

%% Loops through each battery 
for i = 1:46
    % Parses file name. Two-step policy names are in this format:
    % 8C(35%)-3.6C
    policy = batch(i).policy;
    %% Identify CC1, CC2, Q1
    try
        % CC1 is the number before the first 'C'
        C_indices = strfind(policy,'C');
        CC1(i) = str2double(policy(1:C_indices(1)-1));
        % CC2 is the number after '-' but before the second 'C'
        dash_index = strfind(policy,'-');
        CC2(i) = str2double(policy(dash_index+1:C_indices(2)-1));
        % Q1 is the number between '(' and '%'
        paren_index = strfind(policy,'(');
        percent_index = strfind(policy,'%');
        Q1(i) = str2double(policy(paren_index+1:percent_index-1));
    catch
        warning(['Policy names cannot be parsed by MATLAB. Ensure the ' 
            'policy names follow the format 8C(35%)-3.6C'])
    end
    
    %% Charging time - calculated and measured
    t80calc(i) = 60./CC1(i) .* Q1(i)./100 + 60./CC2(i) .* (80-Q1(i))./100;
    t80meas100(i) = mean(batch(i).summary.chargetime(1:100));
    
    %% Cycles. Number of cycles completed
    cycles(i) = max(batch(i).summary.cycle);
    
    %% Degradation rate. Defined as (max(capacity) - min(capacity))/cycles
    degrate(i) = (max(batch(i).summary.QDischarge) -  ...
        min(batch(i).summary.QDischarge))/ ...
        cycles(i);
    
    initdegrate(i) = (max(batch(i).summary.QDischarge(1:100)) -  ...
        min(batch(i).summary.QDischarge(1:100)))/ 100;
    
    finaldegrate(i) = (max(batch(i).summary.QDischarge(end-100:end)) -  ...
        min(batch(i).summary.QDischarge(end-100:end)))/ 100;
end

%% Creates table
T = table(CC1, Q1, CC2, t80calc, t80meas100, cycles, degrate, ...
    initdegrate,finaldegrate);
disp(T)

%% Saves files
% cd 'C:/Users/Arbin/Box Sync/Batch data'
results_table_file = [date '_results_table.xlsx'];
writetable(T,results_table_file)
% Re-writes column headers
col_headers = {'CC1' 'Q1' 'CC2' ...
    'Time to 80% - calculated (min)' ...
    'Time to 80% - measured, median of first 100 cycles (min)', ...
    'Cycles completed', 'Average degradation rate (Ah/cycle)', ...
    'Initial degradation rate (Ah/cycle)', ...
    'Final degradation rate (Ah/cycle)'};
% xlswrite(results_table_file,col_headers,'A1')
% cd 'C:/Users/Arbin/Documents/GitHub/BMS-autoanalysis'

end