function make_images(batch, batch_name, batch_date, imagespath)
close all;
%% Function: loops through each battery in 'batch'. Makes images (.pngs)
%  of 2 x 4 plot grids. Saves images.
%  Usage: make_images('2017-05-12-batchdata.mat','2017-05-12')
%  July 2017 Michael Chen
%  Updated October 2017 Peter Attia

disp('Starting make_images'), tic

%% Plotting initialization
% if batch1 or batch4, skip cycle 1 data
if strcmp(batch_date, '2017-05-12') || strcmp(batch_date, '2017-12-04')
    start = 2;
else
    start = 1;
end

%% Preinitialization variables
% plot every nth cycle
n = 100;

% number of batteries in batch
num_cells = length(batch); % get number of batteries

% cd into batch images
cd(imagespath)

% make folder for current date
if exist(batch_name,'dir')
    % Remove existing folder (if it exists) and make a new directory
    rmdir(batch_name,'s')
end

mkdir(strcat(imagespath, '\', batch_name))

% cd into new folder
cd (strcat(imagespath, '\', batch_name))

%% Loops through each battery
for i = 1:num_cells
    close all;
    cell_id = i; % identify each cell
    num_cycles = max(batch(i).summary.cycle); % get number of cycles
    
    % find maxes for normalization
    max_capacity = batch(i).summary.QDischarge;
    
    %% summary plots
    
    % Plot 1: Remaining capacity
    figure(cell_id)
    subplot(2,4,1)
    plot(batch(i).summary.cycle, batch(i).summary.QDischarge, ...
        'Color','r','LineWidth',1.5) % change to raw data
    hold on
    plot(batch(i).summary.cycle, batch(i).summary.QCharge, 'Color', ...
        'b','LineWidth',1.5)
    ylim([0.88 1.12])
    hold on
    title(['Batch started ', batch_date])
    legend('Discharge', 'Charge', 'Location','best')
    xlabel('Cycle Index')
    ylabel('Remaining Capacity (Ah)')
    
    % Plot 2: Charge time
    figure(cell_id)
    subplot(2,4,2)
    plot(batch(i).summary.cycle,batch(i).summary.chargetime, ...
        'LineWidth',1.5)
    hold on
    xlabel('Cycle Index')
    ylabel('Time to 80% SOC (minutes)')
    title(batch(i).policy_readable)
    ylim([8.5 14])
    
    % Plot 3: Temperature as a function of cycle index
    figure(cell_id)
    subplot(2,4,3)
    plot(batch(i).summary.cycle, batch(i).summary.Tmax, 'Color', ...
        [0.800000 0.250000 0.330000],'LineWidth',1.5)
    hold on
    plot(batch(i).summary.cycle, batch(i).summary.Tmin, 'Color', ...
        [0.600000 0.730000 0.890000],'LineWidth',1.5)
    hold on
    plot(batch(i).summary.cycle, batch(i).summary.Tavg, 'Color', ...
        [1.000000 0.620000 0.000000],'LineWidth',1.5)
    xlabel('Cycle Index')
    ylabel('Temperature (°C)')
    ylim([28 45])
    title(batch(i).barcode)
    
    % Plot 4: Internal resistance OR deltaQ
    figure(cell_id)
    subplot(2,4,4)
    if contains(batch_name,'oed')
        if strcmp(batch_name,'oed1')
            plot(batch(i).cycles(98).Qdlin-batch(i).cycles(10).Qdlin, ...
                batch(i).Vdlin,'LineWidth',1.5)
            vline_loc = mean(batch(i).cycles(98).Qdlin-batch(i).cycles(10).Qdlin);
        else
            plot(batch(i).cycles(100).Qdlin-batch(i).cycles(10).Qdlin, ...
                batch(i).Vdlin,'LineWidth',1.5)
            vline_loc = mean(batch(i).cycles(100).Qdlin-batch(i).cycles(10).Qdlin);
        end
        xlabel('Q_{100}(V)-Q{10}(V)')
        ylabel('Voltage (V)')
        vline(0,'k')
        vline(vline_loc,'b-')
        xlim([-0.07 0.03])
    else
        plot(batch(i).summary.cycle,batch(i).summary.IR,'LineWidth',1.5)
        hold on
        title(strcat('Channel', {' '}, batch(i).channel_id))
        xlabel('Cycle Index')
        ylabel('Internal Resistance (Ohms)')
        if strcmp(batch_name, 'batch3')
            ylim([.012 .014])
        else
            ylim([.015 .024])
        end
    end
    
    %% Initialize colors for cycle-based plots
    % max_cycles MUST be divisible by n, and max_cycles/n MUST be odd.
    % e.g. 1700, 2300 for n=100.
    %%%%%%%%%%%%%%%%%
    cycles_for_plotting = [start n:n:num_cycles]; % plot every n cycles
    %%%%%%%%%%%%%%%%%%
    max_cycles = max(cycles_for_plotting);
    if ~mod(max_cycles, 200)
        max_cycles = max_cycles + 100;
    end
    
    if max_cycles <= 2 % <100 cycles completed
        num_colors = 2;
        max_cycles = start;
        step_size = 255;
        color_array_red = {[1,0,0]};
        color_array_blue = {[0,0,1]};
    else
        num_colors = max_cycles/n + 1; % number of colors to plot
        step_size = 256/num_colors*2-1;
        color_array_red = cell(num_colors,1);
        color_array_blue = cell(num_colors,1);
        
        for k1 = 1:num_colors/2
            color_array_red{k1}  = [255,255-k1*step_size,255-k1*step_size]./256;
            color_array_blue{k1} = [255-k1*step_size,255-k1*step_size,255]./256;
        end
        
        for k2 = 1:num_colors/2
            color_array_red{k2+num_colors/2}  = [255-k2*step_size,0,0]./256;
            color_array_blue{k2+num_colors/2} = [0,0,255-k2*step_size]./256;
        end
    end
    
    % Cycle legends
    legend_array = {num2str(start)}; % for n=100, legend_array={'1','100','200','300',...}
    idx = 2;
    for k3 = n:n:max_cycles
        legend_array{idx} = num2str(k3);
        idx = idx + 1;
    end
    
    %% plot every n cycles
    for j = cycles_for_plotting
        
        % Plot 5: current profiles
        figure(cell_id)
        subplot(2,4,5)
        yyaxis left
        % plot I vs. t
        plot(batch(i).cycles(j).t,batch(i).cycles(j).I,'-',...
            'Color', color_array_blue{fix(j/n)+1},'LineWidth',1.5);
        xlabel('Time (minutes)')
        ylabel('Current (C-Rate)')
        hold on
        yyaxis right
        % plot Qc-Qd
        plot(batch(i).cycles(j).t,batch(i).cycles(j).Qc - batch(i).cycles(j).Qd,'-', ...
            'Color', color_array_red{fix(j/n)+1},'LineWidth',1.5);
        ylabel('Charge Capacity (Ah)')
        xlim([0,70]), ylim([0 1.2])
        
        % Plot 6: voltage profiles
        figure(cell_id)
        subplot(2,4,6)
        plot(batch(i).cycles(j).Qc + batch(i).cycles(j).Qd, ...
            batch(i).cycles(j).V, 'Color', color_array_red{fix(j/n)+1}, ...
            'LineWidth',1.5);
        hold on
        xlabel('Capacity (Ah)')
        ylabel('Cell Voltage (V)')
        xlim([0 1.2]) % capacity limits
        ylim([3.1 3.65]) % voltage limits
        
        % Plot 7: temperature profiles
        figure(cell_id)
        subplot(2,4,7)
        plot(batch(i).cycles(j).t,batch(i).cycles(j).T, ...
            'Color', color_array_red{fix(j/n)+1},'LineWidth',1.5);
        hold on
        xlabel('Time (minutes)')
        ylabel('Cell Temperature (°C)')
        xlim([0 70]) % capacity limits TO-DO
        ylim([28 40]) % temperature limits
        
        % Plot 8: IDCA (discharge dQ/dV)
        figure(cell_id)
        set(gcf, 'units','normalized','outerposition', ...
            [0 0 1 1]) % makes figure fullscreen
        set(gcf,'color','w') % make figures white
        subplot(2,4,8)
        plot(batch(i).Vdlin, batch(i).cycles(j).discharge_dQdV,...
            'Color', color_array_red{fix(j/n)+1}, 'LineWidth',1.5);
        hold on
        xlabel('Voltage (Volts)')
        ylabel('dQ/dV (Ah/V)')
    end
    
    % Add number of cycles completed/still running
    if isnan(batch(i).cycle_life)
        subplot(2,4,5)
        title('Cycling in progress')
        subplot(2,4,6)
        title(['Cycles completed: ' num2str(length(batch(i).cycles))])
    else
        subplot(2,4,5)
        title('Cycling completed')
        subplot(2,4,6)
        title(['Cycle life: ' num2str(batch(i).cycle_life)])
    end
    
    % Add cycle number legend
    figure(cell_id)
    subplot(2,4,8)
    legend(legend_array{1:max(fix((j)/n))+1},'Location', ...
        'eastoutside', 'Orientation','vertical')
    %% Save figures
    % add figure/image saving code
    % save into correct folder for
    
    % save in folder
    charging_alg = batch(i).policy;
    barcode = batch(i).barcode;
    file_name = char(strcat(charging_alg,'_',barcode));
    savefig(gcf,file_name)
    print(gcf,file_name,'-dpng')
    
    % cd out into batch images
    % cd ..
    
    % close % close figure
end

disp('Completed make_images'), toc
end