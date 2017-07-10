function battery = cell_analysis(result_data, charging_algorithm)

%% Initialize battery struct
battery = struct('policy', ' ', 'barcode', ' ', 'cycles', ...
    struct('discharge_dQdVvsV', struct('V', [], 'dQdV', []), ...
    'Qvst', struct('t', [], 'Q', [], 'C', []), 'VvsQ', struct('V', [], ...
    'Q', []), 'TvsQ', struct('T', [], 'Q', [])), ...
    'summary', struct('cycle', [], 'QDischarge', [], 'QCharge', ...
    [], 'IR', [], 'Tmax', [], 'Tavg', [], 'Tmin', [], ...
    'chargetime', []));

cd 'C://Data'

    % Total Test time
    Total_time = result_data(:,1); 
    % Unix Date Time
    Date_time = result_data(:,2);
    
    %{ 
    TODO: delete
    Time for individual step
    Step_Time = result_data(:,3);
    Index of step in Schedule file
    Step_Index = round(result_data(:,4));
    end_cycle = result_data(end,5);
    %}
    
    % Cycle index, 0 is formation cycle
    Cycle_Index = result_data(:,5);
    % All Voltage, current, charge capacity, internal resistance,
    % and temperature variables
    VoltageV = result_data(:,7);
    Current = result_data(:,6);
    Charge_CapacityAh = result_data(:,8);
    Discharge_CapacityAh = result_data(:,9);
    Internal_Resistance = result_data(:,13);
    TemperatureT1 = result_data(:,14);

    % Cell temp is 14, Shelf is 15 and 16
    % Initialize Vector of capacity in and out, maximum temperature, 
    % and discharge dQdV
    C_in = [];
    C_out = [];
    tmax = [];
    dDQdV = [];
    
    % Translate charging algorithm to something we can put in a legend.
    t = charging_algorithm;
    t = strrep(t, '_' , '.' );
    t = strrep(t, '-' , '(' );
    t = strrep(t, 'per.' , '%)-' );
    battery.policy = t;
    
    % Set Figure
    cell_ID1 = figure('units','normalized','outerposition',[0 0 1 1]);
    thisdir = cd;
    cd(charging_algorithm)
    %% Go Through Every Cycle except current running one
    for j = 1:max(Cycle_Index) - 1
        cycle_indices = find(Cycle_Index == j);
        cycle_start = cycle_indices(1); cycle_end = cycle_indices(end);
        % Time in the cycle
        cycle_time = Total_time(cycle_start:cycle_end)-Total_time(cycle_start);
        % Voltage of Cycle J
        Voltage = VoltageV(cycle_start:cycle_end);
        % Current values for cycle J
        Current_J = Current(cycle_start:cycle_end);
        % Charge Capacity for the cycle 
        Charge_cap = Charge_CapacityAh(cycle_start:cycle_end);
        %Discharge Capacity for the cycle 
        Discharge_cap = Discharge_CapacityAh(cycle_start:cycle_end);
        % Temperature of the cycle. 
        temp = TemperatureT1(cycle_start:cycle_end);
        % Index of any charging portion
        charge_indices = find(Current(cycle_start:cycle_end) >= 0); % todo: > or >= ?
        charge_start = charge_indices(1); charge_end = charge_indices(end);
        % Index of discharging portion of the cycle 
        discharge_indices = find(Current(cycle_start:cycle_end) < 0);
        % In case i3 is empty
        if isempty(discharge_indices)
            discharge_start = 1; discharge_end = 2;
        else 
            discharge_start = discharge_indices(1); 
            discharge_end = discharge_indices(end);
        end
        
        % record discharge dQdV vs V
        [IDC,xVoltage2] = IDCA(Discharge_cap(discharge_start: ...
            discharge_end),Voltage(discharge_start:discharge_end));
        battery.cycles(j).discharge_dQdVvsV.V = xVoltage2;
        battery.cycles(j).discharge_dQdVvsV.dQdV = IDC;

        % add VvsQ to batch.battery
        charge_capacity = Charge_cap(charge_start:charge_end);
        volt = Voltage(charge_start:charge_end);
        battery.cycles(j).VvsQ.Q = charge_capacity;
        battery.cycles(j).VvsQ.V = volt;
        
        % add TvsQ to batch.battery
        chrg_cap = Charge_cap(charge_start:charge_end);
        temperature = temp(charge_start:charge_end);
        battery.cycles(j).TvsQ.T = temperature;
        battery.cycles(j).TvsQ.Q = chrg_cap;
        
        % add Qvst to batch.battery
        cycle_t = cycle_time(charge_start:charge_end)./60;
        current = Current_J(charge_start:charge_end)/1.1;
        charge_cap = Charge_cap(charge_start:charge_end);
        battery.cycles(j).Qvst.t = cycle_t;
        battery.cycles(j).Qvst.Q = charge_cap;
        battery.cycles(j).Qvst.C = current;
        
        
        % add 
        %% Plot every 100 cycles
        if mod(j,100) == 0
            %% Plot ICA for Charge
%            figure(fig+1)
%             subplot(2,2,1)
%             [dQdV,xVoltage]=ICA(Charge_cap(i2a:i2b),Voltage(i2a:i2b));
%             plot(xVoltage,dQdV);
%             hold on
%             xlabel('Voltage (Volts)')
%             ylabel('dQ/dV (Ah/V)')
            %% Plot ICA for Discharge
            
            % ADDED
            %{
            figure(cell_ID1)
            subplot(2,4,8)
            [IDC,xVoltage2]=IDCA(Discharge_cap(discharge_start:discharge_end),Voltage(discharge_start:discharge_end));
            plot(xVoltage2,IDC,'Color',color_array{fix(j/100)+1}, ...
                'LineWidth',1.5);
            hold on
            xlabel('Voltage (Volts)')
            ylabel('dQ/dV (Ah/V)')
            % save as mat after each plot
            save(strcat(charging_algorithm, '_', cell_ID, ...
                '_dQdV_cycle', num2str(j)), 'xVoltage2', 'IDC')
            % savefig(strcat(charging_algorithm, '_', cell_ID, '_dQdV'))
            %}
            % ADDED
            
            %% Plot Voltage Curve
            figure(cell_ID1)
            subplot(2,4,6)
            plot(Charge_cap(charge_start:charge_end),Voltage(charge_start:charge_end),'Color',...
                color_array{fix(j/100)+1},'LineWidth',1.5);
            charge_capacity = Charge_cap(charge_start:charge_end);
            volt = Voltage(charge_start:charge_end);
            hold on
            xlabel('Charge Capacity (Ah)')
            ylabel('Cell Voltage (V)')
            xlim([0 1.2])
            ylim([3.1 3.65])
            save(strcat(charging_algorithm, '_', cell_ID, ...
                '_VvsQ_cycle', num2str(j)), 'charge_capacity', 'volt')
            % savefig(strcat(charging_algorithm, '_', cell_ID, '_VvsQ'))
            
            subplot(2,4,7)
            plot(Charge_cap(charge_start:charge_end),temp(charge_start:charge_end),'Color',...
                color_array{fix(j/100)+1},'LineWidth',1.5);
            chrg_cap = Charge_cap(charge_start:charge_end);
            temperature = temp(charge_start:charge_end);
            hold on 
            xlabel('Charge Capacity (Ah)')
            ylabel('Cell Temperature (Celsius)')
            ylim([28 45])
            save(strcat(charging_algorithm , '_' , cell_ID , ...
                '_TvsQ_cycle', num2str(j)), 'chrg_cap','temperature')
            % savefig(strcat(charging_algorithm , '_' , cell_ID , '_TvsQ'))
            
            %% Plot Current Profile 
            figure(cell_ID1)
            subplot(2,4,5)
            yyaxis left
            plot(cycle_time(charge_start:charge_end)./60,Current_J(charge_start:charge_end)/1.1,'-',...
                'Color', color_array_blue{fix(j/100)+1},'LineWidth',1.5);
            cycle_t = cycle_time(charge_start:charge_end)./60;
            current = Current_J(charge_start:charge_end)/1.1;
            charge_cap = Charge_cap(charge_start:charge_end);
            xlabel('Time (minutes)')
            ylabel('Current (C-Rate)')
            hold on
            yyaxis right
            plot(cycle_time(charge_start:charge_end)./60,Charge_cap(charge_start:charge_end),'-',...
                'Color', color_array{fix(j/100)+1},'LineWidth',1.5);
            ylabel('Charge Capacity (Ah)')
            xlim([0,60])
            save(strcat(charging_algorithm , '_' , cell_ID , ...
                '_Qvst_cycle', num2str(j)), 'cycle_t', 'current', 'charge_cap')
            % savefig(strcat(charging_algorithm , '_' , cell_ID , '_Qvst'))
            
        end
        %% Add Cycle Legend
        C_in(j) = max(Charge_cap);
        C_out(j) = max(Discharge_cap);
        tmax(j) = max(temp);
        tmin(j) = min(temp);
        t_avg(j) = mean(temp);
        IR_CC1(j) = Internal_Resistance(cycle_end);
        %% Smooth perform dQdV and add to Discharge PCA
        [dDQdV_j, xVoltage2] = IDCA(Discharge_cap(discharge_start:discharge_end),Voltage(discharge_start:discharge_end));
        dDQdV = vertcat(dDQdV,dDQdV_j);
        %% Find Time to 80%
        discharge_indices = find(Charge_CapacityAh(cycle_start:cycle_end) >= .88,2);
        if isempty(discharge_indices) || length(discharge_indices) == 1 
            tt_80(j) = 1200;
        else
            tt_80(j) = Total_time(discharge_indices(2)+cycle_start)-Total_time(cycle_start);
            Total_time(discharge_indices + cycle_start);
            Total_time(cycle_start);
        end
        % In case an incomplete charge
        if tt_80(j)<300
            tt_80(j) = tt_80(j-1);
        end
    end
    
    %% Plot Summary Statistics
     figure(cell_ID1)
        subplot(2,4,8)
        if fix(j/100) ~= 0
            legend(legend_array{1:(fix(j/100))},'Location', ...
                'eastoutside', 'Orientation','vertical')
        end
        
    % Export Charge Capacity and correct if errant charge
    if j>5
        [sorted_C, ind] = sort(C_in,'descend');
        maxValues = sorted_C(1:5);
        maxValueIndices = ind(1:5);
        median(C_in(maxValueIndices));
        CQ = C_in; %./median(C_in(maxValueIndices));
        DQ = C_out; %./median(C_in(maxValueIndices));
        End_of_life = C_out(j)./median(C_in(maxValueIndices));
    end
    
    %% Plot Capacity Curve
    subplot(2,4,1)
    plot(1:j, C_out, 'Color','r','LineWidth',1.5)%change to raw data
    hold on
    plot(1:j, C_in, 'Color', 'b','LineWidth',1.5)
    hold on
    num_cycles = 1:j;
    legend('Discharge', 'Charge')
    xlabel('Cycle Index')
    ylabel(' Remaining Capacity')
    save(strcat(charging_algorithm , '_' , cell_ID , '_QvsN'), ...
        'num_cycles', 'DQ', 'CQ')
    % savefig(strcat(charging_algorithm , '_' , cell_ID , '_QvsN'))
    
    % ADDED
    battery.summary.cycle = num_cycles;
    battery.summary.QDischarge = DQ;
    battery.summary.QCharge = CQ;
    % ADDED
    
    %% Plot IR during CC1 and CC2
    subplot(2,4,4)
    plot(1:j,IR_CC1,'LineWidth',1.5)
    hold on
    xlabel('Cycle Index')
    ylabel('Internal Resistance (Ohms)')
    ylim([.015 .02])
    save(strcat(charging_algorithm , '_' , cell_ID , '_IR'), ...
        'num_cycles', 'IR_CC1')
    
    battery.summary.IR = IR_CC1; % ADDED
    
    %% Plot Temperature as a function of Cycle Index
    subplot(2,4,3)
    plot(1:j, tmax, 'Color', [0.800000 0.250000 0.330000],'LineWidth',1.5)
    hold on
    plot(1:j, tmin, 'Color', [0.600000 0.730000 0.890000],'LineWidth',1.5)
    hold on 
    plot(1:j, t_avg, 'Color',[1.000000 0.620000 0.000000],'LineWidth',1.5)
    xlabel('Cycle Index')
    ylabel('Temperature (Celsius)')
    ylim([28 45])
    title(cell_ID)
    CE = (100-100.*((C_in-C_out)./C_in));
    save(strcat(charging_algorithm , '_' , cell_ID , '_TvsN'), ...
        'num_cycles', 'tmax', 'tmin', 't_avg')
    
    % ADDED
    battery.summary.Tmax = tmax;
    battery.summary.Tavg = t_avg;
    battery.summary.Tmin = tmin;
    % ADDED

    %% Plot Charge Time 
    subplot(2,4,2)
    plot(1:j,smooth(tt_80./60),'LineWidth',1.5)
    hold on 
    xlabel('Cycle Index')
    ylabel('Time to 80% SOC (minutes)')
    title(alg)
    ylim([8.5 14])
    % Output Charging time in Minutes
    Charge_time = tt_80./60;
    % Output final capacity and cycle count
    cycle = j;
    test_time = max(Date_time);
    test_time = datenum([1970 1 1 0 0 test_time]);
    save(strcat(charging_algorithm , '_' , cell_ID , '_ChargeTime'), ...
        'num_cycles', 'Charge_time')
    battery.summary.chargetime = (tt_80./60)'; % ADDED
    
    cd(thisdir)

end