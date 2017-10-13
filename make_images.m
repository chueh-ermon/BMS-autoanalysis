function make_images(batch, batch_name, batch_date, imagespath)
close all;
%% Function: loops through each battery in 'batch'. Makes images (.pngs)
%  of 2 x 4 plot grids. Saves images.
%  Usage: make_images('2017-05-12-batchdata.mat','2017-05-12')
%  July 2017 Michael Chen

disp('Starting make_images'), tic

%% Plotting initialization
% max_cycles MUST be divisible by 100, and max_cycles/100 MUST be odd.
% e.g. 1700, 2300. can fix later
max_cycles = 2300; % max number of cycles in the batch - can manually adjust
num_colors = max_cycles/100 + 1; % number of colors to plot
step_size = 256/num_colors*2-1;

color_array_red = cell(num_colors,1);
color_array_blue = cell(num_colors,1);

for i = 1:num_colors/2
    color_array_red{i}  = [255,255-i*step_size,255-i*step_size]./256;
    color_array_blue{i} = [255-i*step_size,255-i*step_size,255]./256;
end

for i = 1:num_colors/2
    color_array_red{i+num_colors/2}  = [255-i*step_size,0,0]./256;
    color_array_blue{i+num_colors/2} = [0,0,255-i*step_size]./256;
end

% Manual color settings - deprecated 10/9/2017 (remove if above code works)
% % 'numColors' increasing darkness reds for cycle results
% color_array_red = {[255,230,230]./256; [255,204,204]./256; ...
%     [255,179,179]./256; [255,153,153]./256; [255,128,128]./256; ...
%     [255,102,102]./256; [255,77,77]./256; [255,0,0]./256; ...
%     [230,0,0]./256; [204,0,0]./256; [179,0,0]./256; [153,0,0]./256; ...
%     [128,0,0]./256; [102,0,0]./256; [77,0,0]./256; [51,0,0]./256; ...
%     [26,0,0]./256; [0,0,0]};
% % 'numColors' increasing darkness blues for cycle results
% color_array_blue = {[230,230,255]./256; [204,204,255]./256; ...
%     [179,179,255]./256; [153,153,255]./256; [128,128,255]./256; ...
%     [102,102,255]./256; [77,77,255]./256; [51,51,255]./256; ...
%     [26,26,255]./256; [0,0,255]./256; [0,0,230]./256; ...
%     [0,0,204]./256; [0,0,179]./256; [0,0,153]./256; [0,0,128]./256; ...
%     [0,0,102]./256; [0,0,77]./256; [0,0,51]./256; [0,0,26]./256; ...
%     [0,0,0]};

% Cycle legends
legend_array = {'1'}; % will look like {'1','100','200','300',...}
idx = 2;
for j = 100:100:max_cycles
    legend_array{idx} = num2str(j);
    idx = idx + 1;
end

%% Preinitialization variables
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
    hold on
    title(['Batch started ', batch_date])
    legend('Discharge', 'Charge')
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
    
    % Plot 4: Internal resistance
    figure(cell_id)
    subplot(2,4,4)
    plot(batch(i).summary.cycle,batch(i).summary.IR,'LineWidth',1.5)
    hold on
    title(strcat('Channel', {' '}, batch(i).channel_id))
    xlabel('Cycle Index')
    ylabel('Internal Resistance (Ohms)')
    if strcmp(batch_name, 'batch1') || strcmp(batch_name, 'batch2')
        ylim([.015 .02])
    else
        ylim([.012 .014])
    end
    
    %% plot every 100 cycles
    for j = [1 100:100:num_cycles] % plot every 100 cycles
        % plot every 100 cycles
        
        % Plot 5: current profiles
        figure(cell_id)
        subplot(2,4,5)
        yyaxis left
        % plot I vs. t
        plot(batch(i).cycles(j).t,batch(i).cycles(j).I,'-',...
            'Color', color_array_blue{fix(j/100)+1},'LineWidth',1.5);
        xlabel('Time (minutes)')
        ylabel('Current (C-Rate)')
        hold on
        yyaxis right
        % plot Qc-Qd
        plot(batch(i).cycles(j).t,batch(i).cycles(j).Q,'-', ...
            'Color', color_array_red{fix(j/100)+1},'LineWidth',1.5);
        ylabel('Charge Capacity (Ah)')
        xlim([0,70]), ylim([0 1.2])
        
        % Plot 6: voltage profiles
        figure(cell_id)
        subplot(2,4,6)
        plot(batch(i).cycles(j).Qc + batch(i).cycles(j).Qd, ...
            batch(i).cycles(j).V, 'Color', color_array_red{fix(j/100)+1}, ...
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
            'Color', color_array_red{fix(j/100)+1},'LineWidth',1.5);
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
        plot(batch(i).cycles(j).discharge_dQdVvsV.V, ...
            batch(i).cycles(j).discharge_dQdVvsV.dQdV,'Color', ...
            color_array_red{fix(j/100)+1}, 'LineWidth',1.5);
        hold on
        xlabel('Voltage (Volts)')
        ylabel('dQ/dV (Ah/V)')
        
    end
    
    % Add cycle number legend
    figure(cell_id)
    subplot(2,4,8)
    legend(legend_array{1:max(fix((j)/100))+1},'Location', ...
        'eastoutside', 'Orientation','vertical')
    %% Save figures
    % add figure/image saving code
    % save into correct folder for
    
    % save in folder
    charging_alg = batch(i).policy;
    barcode = batch(i).barcode;
    %     file_name = strcat(charging_alg, '_' , barcode);
    %     savefig(gcf, filename)
    %     print(file_name, '-dpng')
    %     saveas(gcf, file_name, 'png')
    savefig(gcf,[char(strcat(charging_alg,'_',barcode))])
    print(gcf,[char(strcat(charging_alg,'_',barcode))],'-dpng')
    
    % cd out into batch images
    % cd ..
    
    % close % close figure
end

disp('Completed make_images'), toc
end