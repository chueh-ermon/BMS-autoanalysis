function batch1_summary_plots(batch, batch_name, T_cells, T_policies)
%% Function: takes in tabular data to generate summary plots of batch
% Usage: batch1_summary_plots(batteries [struct],'batch_2' [str], T_cells [table],T_policies [table])
% July 2017 Michael Chen and Peter Attia
% Plotting adapted from Nick Perkins' plot_spread function


    %% Initialization and inputs
    
    % pull names from policies
    cell_names = cell(height(T_cells),1);
    for k = 1:numel(batch)
        cell_names{k}=batch(k).policy_readable;
    end
    
    T_policies_array = table2array(T_policies); % convert to array
    T_cells_array = table2array(T_cells); % convert to arrayT
    T_size = size(T_policies);
    colormap jet;
    scalefactor = 1e6; % factor to scale degradation rates by
    maxvalue = max(T_policies_array(:,8))*scalefactor; % scale degradation rate
    
    CC1 = T_cells_array(:,1); % CC1
    Q1 = T_cells_array(:,2); % Q1
    CC2 = T_cells_array(:,3); % CC2 
    degradation_rate = T_cells_array(:,7); % Deg rate
    tt_80 = T_cells_array(:,5); % Time to 80%
    cycle_num = T_cells_array(:,6); % Cycle numbers
    num_cells = length(cycle_num); % Number of indiv. cells
    capacities = zeros(num_cells,1); % Initialize capacities array
    
    % Init figures
    figure_capacity = figure('units','normalized','outerposition',[0 0 1 1]);hold on; box on;
    figure_degradation = figure('units','normalized','outerposition',[0 0 1 1]);hold on; box on;

    % Find Capacities
    for i = 1:num_cells
        cycle = cycle_num(i);
        capacities(i,1) = batch(i).summary.QDischarge(cycle); % pulls the most recent capacity
    end
    
    %% Capacity vs charging time
    [col, mark]=random_color('y','y');
    figure(figure_capacity); hold on;
    for i = 1:num_cells
        scatter(tt_80(i),capacities(i,1),100,col,mark,'LineWidth',2)
        hold on
    end
    leg = columnlegend(2,cell_names,'Location','NortheastOutside','boxoff');
    xlabel('Time to 80% SOC (minutes)')
    ylabel('Remaining discharge capacity (Ah)')
    print('summary3_Q_vs_t80','-dpng')
    
    %% Average degradation vs charging time
    figure(figure_degradation); hold on;
    for i = 1:num_cells
        scatter(tt_80,degradation_rate,200,col,mark,'LineWidth',2); hold on;
    end
    leg = columnlegend(2,cell_names,'Location','NortheastOutside','boxoff');
    xlabel('Time to 80% SOC (minutes)')
    ylabel('Average degradation rate (Ah/cycle)')
    print('summary4_deg_vs_t80','-dpng')
    
    %% Contour plot
    % adapted from Peter Attia    
        
    Q1=5:5:80;
    CC1=3:0.5:10;
    CC2=[3 3.6];
    time = ones(length(CC2),length(CC1),length(Q1));
    figure, set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
    for i=1:length(CC2)
        subplot(1,length(CC2),i), hold on, box on
        xlabel('CC1'),ylabel('Q1 (%)')
        title(['CC2 = ' num2str(CC2(i))])
        axis([min(CC1) max(CC1) min(Q1) max(Q1)])
        
        [X,Y] = meshgrid(CC1,Q1);
        time = (60.*Y./X./100)+(60.*(80-Y)./CC2(i)./100);
        v = [13, 12, 11, 10, 9, 8];
        contour(X,Y,time,v,'LineWidth',2,'ShowText','on')
        hold on;
    end
        
    % prepare for degradation plotting
    % extract data for scatter plot
    CC1_data = table2array(T_policies(:,1)); % CC1
    Q1_data = table2array(T_policies(:,2)); % Q1
    CC2_data = table2array(T_policies(:,3)); % CC2 
    degradation_rate = table2array(T_policies(:,8)); % Deg rate
    
    colormap jet;
    scalefactor = 1e6; % Factor to scale
    maxvalue = max(degradation_rate*scalefactor);

    for i = 1:length(CC1_data)
        if CC2_data(i) == 3.6 && CC1_data(i) ==3.6
            subplot(1, length(CC2), 2)
            scatter(CC1_data(i),Q1_data(i),'square','CData',degradation_rate(i)*scalefactor,'SizeData',200,'LineWidth',5)
        elseif CC2_data(i) == 3.0
            subplot(1, length(CC2), 1)
            scatter(CC1_data(i),Q1_data(i),'o','CData',degradation_rate(i)*scalefactor,'SizeData',200,'LineWidth',5)
        elseif CC2_data(i) == 3.6000
            subplot(1, length(CC2), 2)
            scatter(CC1_data(i),Q1_data(i),'o','CData',degradation_rate(i)*scalefactor,'SizeData',200,'LineWidth',5)
        else
            subplot(1, length(CC2), 1)
            scatter(CC1_data(i),Q1_data(i),'square','CData',degradation_rate(i)*scalefactor,'SizeData',200,'LineWidth',5)
            caxis([0 maxvalue])
            subplot(1, length(CC2), 2)
            scatter(CC1_data(i),Q1_data(i),'square','CData',degradation_rate(i)*scalefactor,'SizeData',200,'LineWidth',5)
            caxis([0 maxvalue])
        end
    end
    
    
    print('summary5_contour','-dpng')


end

