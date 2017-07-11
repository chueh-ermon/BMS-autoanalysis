function make_images(batch, batch_name)
close all;
%% Function: loops through each battery in 'batch'. Makes images (.pngs) 
%  of 2 x 4 plot grids. Saves images.
%  Usage: make_images('2017-05-12-batchdata.mat','2017-05-12')
%  July 2017 Michael Chen

%% Plotting initialization 
% 18 increasing darkness reds for cycle results
color_array = {[255,230,230]./256; [255,204,204]./256; ...
    [255,179,179]./256; [255,153,153]./256; [255,128,128]./256; ...
    [255,102,102]./256; [255,77,77]./256; [255,0,0]./256; ...
    [230,0,0]./256; [204,0,0]./256; [179,0,0]./256; [153,0,0]./256; ...
    [128,0,0]./256; [102,0,0]./256; [77,0,0]./256; [51,0,0]./256; ...
    [26,0,0]./256; [0,0,0]};
% 18 increasing darkness blues for cycle results
color_array_blue = {[230,230,255]./256; [204,204,255]./256; ...
    [179,179,255]./256; [153,153,255]./256; [128,128,255]./256; ...
    [102,102,255]./256; [77,77,255]./256; [51,51,255]./256; ...
    [26,26,255]./256; [0,0,255]./256; [0,0,230]./256; ...
    [0,0,204]./256; [0,0,179]./256; [0,0,153]./256; [0,0,128]./256; ...
    [0,0,102]./256; [0,0,77]./256; [0,0,51]./256; [0,0,26]./256; ...
    [0,0,0]};
% Cycle legends
legend_array = {'1'; '100'; '200'; '300'; '400'; '500'; '600'; '700'; ...
    '800'; '900'; '1000'; '1100'; '1200'; '1300'; '1400'; '1500'; ...
    '1600'; '1700'; '1800'};

%% Preinitialization variables
% number of batteries in batch
num_cells = length(batch); % get number of batteries

%% Loops through each battery
for i = 1:num_cells
    cell_id = i; % identify each cell 
    num_cycles = max(batch(i).summary.cycle); % get number of cycles
    
    % find maxes for normalization
    max_capacity = batch(i).summary.QDischarge;
    
    %% plot every 100 cycles
    for j = [1 100:100:num_cycles] % plot every 100 cycles
        % plot every 100 cycles
        % Plot IDCA (discharge dQ/dV)
        figure(cell_id)
        set(gcf, 'units','normalized','outerposition', ...
            [0 0 1 1]) % makes figure fullscreen
        set(gcf,'color','w') % make figures white
        subplot(2,4,8)
        plot(batch(i).cycles(j).discharge_dQdVvsV.V, ...
            batch(i).cycles(j).discharge_dQdVvsV.dQdV,'Color', ...
            color_array{fix(j/100)+1}, 'LineWidth',1.5);
        hold on
        xlabel('Voltage (Volts)')
        ylabel('dQ/dV (Ah/V)')

        % Plot voltage profiles
        figure(cell_id)
        subplot(2,4,6)
        plot(batch(i).cycles(j).VvsQ.Q,batch(i).cycles(j).VvsQ.V, ...
            'Color', color_array{fix(j/100)+1}, 'LineWidth',1.5);
        hold on
        xlabel('Charge Capacity (Ah)')
        ylabel('Cell Voltage (V)')
        xlim([0 1.2]) % capacity limits
        ylim([3.1 3.65]) % voltage limits

        % Plot temperature profiles
        figure(cell_id)
        subplot(2,4,7)
        plot(batch(i).cycles(j).TvsQ.Q,batch(i).cycles(j).TvsQ.T, ...
            'Color', color_array{fix(j/100)+1},'LineWidth',1.5); % changed indexing 
        hold on 
        xlabel('Charge Capacity (Ah)')
        ylabel('Cell Temperature (°C)')
        xlim([0 1.2]) % capacity limits
        ylim([28 45]) % temperature limits

        % Plot current profiles 
        figure(cell_id)
        subplot(2,4,5)
        yyaxis left
        plot(batch(i).cycles(j).Qvst.t,batch(i).cycles(j).Qvst.C,'-',...
            'Color', color_array_blue{fix(j/100)+1},'LineWidth',1.5);
        xlabel('Time (minutes)')
        ylabel('Current (C-Rate)')
        hold on
        yyaxis right
        plot(batch(i).cycles(j).Qvst.t,batch(i).cycles(j).Qvst.Q,'-', ...
            'Color', color_array{fix(j/100)+1},'LineWidth',1.5);
        ylabel('Charge Capacity (Ah)')
        xlim([0,70])
    end
                    
    % Plot remaining capacity
    figure(cell_id)
    subplot(2,4,1)
    plot(batch(i).summary.cycle, batch(i).summary.QDischarge, ...
        'Color','r','LineWidth',1.5) % change to raw data
    hold on
    plot(batch(i).summary.cycle, batch(i).summary.QCharge, 'Color', ...
        'b','LineWidth',1.5)
    hold on
    legend('Discharge', 'Charge')
    xlabel('Cycle Index')
    ylabel('Remaining Capacity (Ah)')
    
    % Plot internal resistance
    figure(cell_id)
    subplot(2,4,4)
    plot(batch(i).summary.cycle,batch(i).summary.IR,'LineWidth',1.5)
    hold on
    xlabel('Cycle Index')
    ylabel('Internal Resistance (Ohms)')
    ylim([.015 .02])       
    
    % Plot temperature as a function of cycle index
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
  
    
    % Plot charge time 
    figure(cell_id)
    subplot(2,4,2)
    plot(batch(i).summary.cycle,batch(i).summary.chargetime, ...
        'LineWidth',1.5)
    hold on 
    xlabel('Cycle Index')
    ylabel('Time to 80% SOC (minutes)')
    title(batch(i).policy)
    ylim([8.5 14])
    
      
    % Add cycle number legend
    subplot(2,4,8)
    legend(legend_array{1:max(fix((j)/100))+1},'Location', ...
                        'eastoutside', 'Orientation','vertical')
    %% Save figures
    % add figure/image saving code
    % save into correct folder for 
    
    % cd into batch images
    cd 'C:/Users//Arbin/Box Sync/Batch images'
    
    % make folder for current date
    
    mkdir (strcat('C:/Users/Arbin/Box Sync/Batch images/','batch_name'))
    
    % cd into new folder
    cd (strcat('C:/Users/Arbin/Box Sync/Batch images/','batch_name'))

% % test code on mike's computer
% 	% cd into batch images
%     % cd '/Users/MichaelChen/Documents/Chueh BMS/2017-05-12 Data'
%         
%     % make folder for current date
%     mkdir(strcat('/Users/MichaelChen/Documents/Chueh BMS/2017-05-12 Data/Batch Images/',batch_name));
%     
%     % cd into new folder
%     cd (strcat('/Users/MichaelChen/Documents/Chueh BMS/2017-05-12 Data/Batch Images/',batch_name));
%     
%     % save in folder
    print([batch(i).policy, '_',batch(i).barcode],'-dpng')
%    saveas(gcf,strcat(batch(i).policy,'_',batch(i).barcode), 'png')
%     
%     % cd out into batch images
%     cd ..
    
    % cd to batch images
    % cd('/Users/MichaelChen/Documents/Chueh BMS/2017-05-12 Data')

    close % close figure
end   
end



