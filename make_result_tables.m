function [T_cells, T_policies] = make_result_tables( batch, batch_name, ...
    tablespath, codepath )
%make_result_table makes tables of results for OED.
%   Parses policy parameters (e.g. CC1, CC2, Q1) and
%   calculates charging time and average degradation rate.
%   In this function, we make two result tables - one for each cell (T), 
%   and one for each policy (in which results for policies with multiple 
%   cells are averaged). 
%   It then writes the results to a CSV.
%   Peter Attia, July 2017

disp('Starting make_result_tables'),tic

n = numel(batch); % number of batteries in the batch

%% Preinitialize variables
policies = cell(n,1);
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
for i = 1:numel(batch)
    % Parses file name. Two-step policy names are in this format:
    % 8C(35%)-3.6C
    policy = batch(i).policy_readable;
    policies{i} = policy;
    experimental = ['discharge','dod','restattop','ratetest'];
    TF = contains(policy,experimental); % logical to check if the tests are experimental
    if TF == 1
        continue % skip if test is experimental
    else
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
            warning(['Policy names cannot be parsed by MATLAB. Ensure the ' ...
                'policy names follow the format 8C(35%)-3.6C'])
        end
        
        %% Charging time - calculated and measured
        t80calc(i) = 60./CC1(i) .* Q1(i)./100 + 60./CC2(i) .* (80-Q1(i))./100;
        if length(batch(i).summary.chargetime) > 100
            t80meas100(i) = mean(batch(i).summary.chargetime(1:100));
        else
            t80meas100(i) = mean(batch(i).summary.chargetime);
        end
        
        %% Cycles. Cycle life, or number of cycles completed
        if batch(i).summary.QDischarge(end) < 0.88
            cycles(i) = find(batch(i).summary.QDischarge < 0.88,1);
        else
            cycles(i) = max(batch(i).summary.cycle);
        end
        
        %% Degradation rate. Defined as (max(capacity) - min(capacity))/cycles
        degrate(i) = (max(batch(i).summary.QDischarge) -  ...
            min(batch(i).summary.QDischarge))/ ...
            cycles(i);
        
        if length(batch(i).summary.chargetime) > 100
            initdegrate(i) = (max(batch(i).summary.QDischarge(1:100)) -  ...
                min(batch(i).summary.QDischarge(1:100)))/ 100;
            
            finaldegrate(i) = (max(batch(i).summary.QDischarge(end-100:end)) -  ...
                min(batch(i).summary.QDischarge(end-100:end)))/ 100;
        else
            initdegrate(i) = degrate(i);
            
            finaldegrate(i) = degrate(i);
        end
    end
end

%% Creates table (for each cell)
T_cells = table(CC1, Q1, CC2, t80calc, t80meas100, cycles, degrate, ...
    initdegrate,finaldegrate);

%% Saves files on a cell basis
cd(tablespath)
results_table_file = [date '_' batch_name '_results_table_allcells.xlsx'];
writetable(T_cells,results_table_file) % Save to CSV
% Re-writes column headers
col_headers = {'CC1' 'Q1' 'CC2' ...
    'Time to 80% - calculated (min)' ...
    'Time to 80% - measured, median of first 100 cycles (min)', ...
    'Cycles completed', 'Average degradation rate (Ah/cycle)', ...
    'Initial degradation rate (Ah/cycle)', ...
    'Final degradation rate (Ah/cycle)'};
try
    xlswrite(results_table_file,col_headers,'Sheet1','A1')
catch
    warning('xlswrite error')
end
cd(codepath)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% POLICY-SPECIFIC TABLES %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Creates table for each policy
% Identify all unique policy names
unique_policies = unique(policies);
num_policies = length(unique_policies);

% Preinitialize vectors. Same as before, but for the policies
numcells = zeros(num_policies,1); % number of cells for a given policy
CC1_policies = zeros(num_policies,1);
CC2_policies = zeros(num_policies,1);
Q1_policies  = zeros(num_policies,1);
t80calc_policies  = zeros(num_policies,1); % time to 80% (calculated from policy parameters)
t80meas100_policies  = zeros(num_policies,1); % time to 80% (measured - median of first 100 cycles)
cycles_policies  = zeros(num_policies,1); % number of cycles completed
degrate_policies  = zeros(num_policies,1); % average deg rate (Ah/cycles)
initdegrate_policies  = zeros(num_policies,1); % initial deg rate (Ah/cycles)
finaldegrate_policies  = zeros(num_policies,1); % final deg rate (Ah/cycles)

% Loop through each policy, find all cells with that policy, and then
% compute the parameters
for i = 1:num_policies
    battery_index = [];
    for j = 1:n
        if strcmp(unique_policies{i}, batch(j).policy_readable)
            numcells(i) = numcells(i) + 1;
            battery_index = [battery_index j];
        end
    end
    
    CC1_policies(i) = CC1(battery_index(1));
    CC2_policies(i) = CC2(battery_index(1));
    Q1_policies(i)  = Q1(battery_index(1));
    t80calc_policies(i)  = t80calc(battery_index(1));
    t80meas100_policies(i)  = mean(t80meas100(battery_index)); % time to 80% (measured - median of first 100 cycles)
    cycles_policies(i)  = mean(cycles(battery_index)); % number of cycles completed
    degrate_policies(i)  = mean(degrate(battery_index)); % average deg rate (Ah/cycles)
    initdegrate_policies(i)  = mean(initdegrate(battery_index)); % initial deg rate (Ah/cycles)
    finaldegrate_policies(i)  = mean(finaldegrate(battery_index)); % final deg rate (Ah/cycles)
end

%% Create table (for each policy)
T_policies = table(CC1_policies, Q1_policies, CC2_policies, numcells, ...
    t80calc_policies, t80meas100_policies, cycles_policies, ...
    degrate_policies, initdegrate_policies, finaldegrate_policies);

%% Saves files on a policy basis
cd(tablespath)
results_table_file2 = [date '_' batch_name '_results_table_allpolicies.xlsx'];
writetable(T_policies,results_table_file2) % Save to CSV
% Re-writes column headers
col_headers = {'CC1' 'Q1' 'CC2','Number of cells' ...
    'Time to 80% - calculated (min)' ...
    'Time to 80% - measured, median of first 100 cycles (min)', ...
    'Cycles completed', 'Average degradation rate (Ah/cycle)', ...
    'Initial degradation rate (Ah/cycle)', ...
    'Final degradation rate (Ah/cycle)'};
try
    xlswrite(results_table_file2,col_headers,'Sheet1','A1')
catch
    warning('xlswrite error')
end

%% Save both result tables as .mat
save([date '_' batch_name '_result_tables'],'T_cells', 'T_policies')
cd(codepath)

disp('Completed make_result_tables'),toc
end