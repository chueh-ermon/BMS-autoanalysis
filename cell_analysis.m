function battery = cell_analysis(result_data, charging_algorithm, ...
    batch_date, csvpath)

%% Initialize battery struct
battery = struct('policy', ' ', 'policy_readable', ' ', 'barcode', ...
    ' ', 'channel_id', ' ','cycle_life', NaN,...
    'cycles', struct('discharge_dQdV', [], 't', [], 'Qc', [], 'I', [], ...
    'V', [], 'T', [], 'Qd', [], 'Qdlin', [], 'Tdlin',[]), ...
    'summary', struct('cycle', [], 'QDischarge', [], 'QCharge', [], ...
    'IR', [], 'Tmax', [], 'Tavg', [], 'Tmin', [], 'chargetime', []), ...
    'Vdlin',[]);

cd(csvpath)

% Total test time
Total_time = result_data(:,1);
% Unix date time (currently unused)
%Date_time = result_data(:,2);

% Cycle index, 0 is formation cycle
Cycle_Index = result_data(:,5);
% Extract all columns of interest
Voltage = result_data(:,7);
Current = result_data(:,6);
Charge_Capacity = result_data(:,8);
Discharge_Capacity = result_data(:,9);
Internal_Resistance = result_data(:,13);
Temperature = result_data(:,14);
% batch0 attempts
%Internal_Resistance = ones(length(result_data(:,1)),1);
%TemperatureT1 = ones(length(result_data(:,1)),1);
% Cell temp is 14, Shelf is 15 and 16

% if batch1 or batch4, skip cycle 1 data
if strcmp(batch_date, '2017-05-12') || strcmp(batch_date, '2017-12-04')
    start = 2;
else
    start = 1;
end

% Pre-initialize vectors
C_in  = zeros(max(Cycle_Index) - start - 1,1);
C_out = zeros(max(Cycle_Index) - start - 1,1);
T_max = zeros(max(Cycle_Index) - start - 1,1);
T_min = zeros(max(Cycle_Index) - start - 1,1);
T_avg = zeros(max(Cycle_Index) - start - 1,1);
DQ = zeros(max(Cycle_Index) - start - 1,1);
CQ = zeros(max(Cycle_Index) - start - 1,1);
IR_CC1 = zeros(max(Cycle_Index) - start - 1,1);
tt_80 = zeros(max(Cycle_Index) - start - 1,1);

% Parse battery.policy into a "readable" policy, battery.policy_readable
t = charging_algorithm;
battery.policy = t;
if datetime(batch_date) < datetime('2018-06-04') % pre-oed
    t = strrep(t, 'C_','C(');
    t = strrep(t, '_' , '.' );
    t = strrep(t, 'PER.' , '%)-' );
    t = strrep(t, '(NEWSTRUCTURE','-newstructure'); % new to batch6
    t = strrep(t, 'VARCHARGE.','VarCharge-'); % new to batch6
    t = strrep(t, '(100CYCLES','-100cycles'); % new to batch6
    % For 3-step policies:
    %   Replace '6C(20%)-0.1C20.1%)-5C' with '6C(20%)-0.1C(20.1%)-5C'
    matchStr = regexp(t,'C\d','match');
    if ~isempty(matchStr)
        matchStr = matchStr{1};
        c2 = matchStr(2:end);
        t = regexprep(t,'C\d',['C(' c2]);
    end
else
    t = strrep(t, '_' , '-' );
    t = strrep(t, 'pt' , '.' );
    t = strrep(t, 'PT' , '.' );
end
battery.policy_readable = t;

thisdir = cd;

%% Go through every cycle except current running one
for j = start:max(Cycle_Index) - 1
    cycle_indices = find(Cycle_Index == j);
    cycle_start = cycle_indices(1);
    cycle_end = cycle_indices(end);
    
    %% Add full per-cycle information
    battery.cycles(j).Qd = Discharge_Capacity(cycle_indices);
    battery.cycles(j).Qc = Charge_Capacity(cycle_indices);
    battery.cycles(j).V = Voltage(cycle_indices);
    battery.cycles(j).T = Temperature(cycle_indices);
    battery.cycles(j).t = (Total_time(cycle_indices) - Total_time(cycle_start))./60;
    battery.cycles(j).I = Current(cycle_indices)/1.1;
    
    %% Correct for negative times from Patrick's script
    if battery.cycles(j).t(end) < 0
        negidx = find(battery.cycles(j).t < 0, 1);
        constant = battery.cycles(j).t(negidx - 1) - battery.cycles(j).t(negidx);
        battery.cycles(j).t(negidx:end) = battery.cycles(j).t(negidx:end) + constant;
    end
    
    %% dQdV vs V for discharge
    % Indices of discharging portion of the cycle
    discharge_indices = find(battery.cycles(j).I < 0);
    % In case i3 is empty
    if isempty(discharge_indices)
        discharge_start = 1; discharge_end = 2;
    else
        discharge_start = discharge_indices(1);
        discharge_end = discharge_indices(end);
    end
    
    [IDC,~] = IDCA( battery.cycles(j).Qd(discharge_start:discharge_end), ...
        battery.cycles(j).V(discharge_start:discharge_end) );
    battery.cycles(j).discharge_dQdV = IDC';
    
    %% Apply VQlinspace3 function to obtain Qdlin, Vdlin, and Tdlin
    [Qdlin,Vdlin,Tdlin] = VQlinspace3(battery.cycles(j));
    battery.cycles(j).Qdlin = Qdlin;
    battery.cycles(j).Tdlin = Tdlin;
    
    %% Update summary information
    C_in(j) = max(battery.cycles(j).Qc);
    C_out(j) = max(battery.cycles(j).Qd);
    T_max(j) = max(battery.cycles(j).T);
    T_min(j) = min(battery.cycles(j).T);
    T_avg(j) = mean(battery.cycles(j).T);
    IR_CC1(j) = Internal_Resistance(cycle_end);
    
    %% Find time to 80%
    chargetime_indices = find(Charge_Capacity(cycle_start:cycle_end) >= 0.88,2);
    if isempty(chargetime_indices) || length(chargetime_indices) == 1
        tt_80(j) = 1200;
    else
        tt_80(j) = Total_time(chargetime_indices(2)+cycle_start)-Total_time(cycle_start);
        Total_time(chargetime_indices + cycle_start);
        Total_time(cycle_start);
    end
    % In case of an incomplete charge
    if tt_80(j)<300
        tt_80(j) = tt_80(j-1);
    end
end

% Update static voltage variables
battery.Vdlin = Vdlin';

% Export charge capacity and correct if errant charge
if j > 5
    %[~, ind] = sort(C_in,'descend');
    %maxValueIndices = ind(1:5);
    %median(C_in(maxValueIndices));
    CQ = C_in;
    DQ = C_out;
end

% Add vectors to battery.summary
battery.summary.cycle = (1:j)';
battery.summary.QDischarge = DQ;
battery.summary.QCharge = CQ;
battery.summary.IR = IR_CC1;
battery.summary.Tmax = T_max;
battery.summary.Tavg = T_avg;
battery.summary.Tmin = T_min;
battery.summary.chargetime = tt_80./60; % Convert to minutes

% Update cycle life, if applicable
batches_cycleto80 = {'2017-05-12', '2017-06-30', '2018-04-12'};
if battery.summary.QDischarge(end) < 0.88
    battery.cycle_life = find(battery.summary.QDischarge<0.88, 1);
elseif sum(strcmp(batch_date,batches_cycleto80)) && ...
        battery.summary.QDischarge(end) - 0.88 < 0.01
    % Special case for batches 1 and 8, where we don't cycle past failure
    battery.cycle_life = j + 1;
end

cd(thisdir)
end
