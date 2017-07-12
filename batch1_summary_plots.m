function batch1_summary_plots(batch, batch_name, T_cells, T_policies)
%% Function: takes in tabular data to generate summary plots of batch
% Usage: batch1_summary_plots(batteries [struct],'batch_2' [str], T_cells [table],T_policies [table])
% July 2017 Michael Chen and Peter Attia
% Plotting adapted from Nick Perkins' plot_spread function


    %% Initialization and inputs
    
    % pull names from policies
    cell_names = cell(numel(batch),1);
    for k = 1:numel(batch)
        cell_names{k}=batch(k).policy_readable;
    end
    
    T_policies = table2array(T_policies); % convert to array
    T_cells = table2array(T_cells); % convert to arrayT
    T_size = size(T_policies);
    colormap jet;
    scalefactor = 1e6; % factor to scale degradation rates by
    maxvalue = max(T_policies(:,8))*scalefactor; % scale degradation rate
    
    CC1 = T_cells(:,1); % CC1
    Q1 = T_cells(:,2); % Q1
    CC2 = T_cells(:,3); % CC2 
    degradation_rate = T_cells(:,7); % Deg rate
    tt_80 = T_cells(:,5); % Time to 80%
    cycle_num = T_cells(:,6); % Cycle numbers
    num_cells = length(cycle_num); % Number of indiv. cells
    capacities = zeros(num_cells); % Initialize capacities array
    
    % Find Capacities
    for i = num_cells
        cycle = cycle_num(i);
        capacities(i) = batch(i).summary.QDischarge(cycle); % pulls the most recent capacity
    end
    
    %% Capacity vs charging time
    
    figure(1)
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]) 
    [col, mark]=random_color('y','y');
    scatter(tt_80,capacities,100,col,mark,'LineWidth',2)
    hold on
    
    columnlegend(2,cell_names,'Location','NortheastOutside','boxoff');
    xlabel('Time to 80% SOC (minutes)')
    ylabel('Remaining discharge capacity (Ah)')
    print('summary3_Q_vs_t80','-dpng')
    
    %% Average degradation vs charging time
     
    figure, set(gcf, 'units','normalized','outerposition',[0 0 1 1])
    scatter(tt80,degradation_rate,200,col,mark,'LineWidth',2);
    
    columnlegend(2,cell_names,'Location','NortheastOutside','boxoff');
    xlabel('Time to 80% SOC (minutes)')
    ylabel('Average degradation rate (Ah/cycle)')
    print('summary4_deg_vs_t80','-dpng')
    
    %% Contour plot
    % adapted from Peter Attia    
    
    % extract data for scatter plot
    CC1 = table2array(T_policies(:,1)); % CC1
    Q1 = table2aray(T_policies(:,2)); % Q1
    CC2 = table2array(T_policies(:,3)); % CC2 
    degradation_rate = table2array(T_policies(:,8)); % Deg rate
        
    % initialize for contour lines
    figure, set(gcf, 'units','normalized','outerposition',[0 0 1 1])
    Q1_array=5:5:80;
    CC1_array=3:0.5:10;
    CC2_array=[3 3.6];
    time = ones(length(CC2_array),length(CC1_array),length(Q1_array));

    for i=1:length(CC2)
        subplot(1,length(CC2),i), hold on, box on
        xlabel('CC1'),ylabel('Q1 (%)')
        title(['CC2 = ' num2str(CC2(i))])
        %axis([min(CC1) max(CC1) min(Q1) max(Q1)])
        
        [X,Y] = meshgrid(CC1_array,Q1_array);
        time = (60.*Y./X./100)+(60.*(80-Y)./CC2_array(i)./100);
        v = [13, 12, 11, 10, 9, 8];
        contour(X,Y,time,v,'LineWidth',2,'ShowText','on')
    end
        
    % prepare for degradation plotting
    colormap jet;
    scalefactor = 1e6; % Factor to scale
    maxvalue = max(degradation_rate*scalefactor);

    for i = 1:length(CC1)
        if CC2(i) == 3
            subplot(1, length(CC2), 1)
            %ax(2) = axes;
            scatter(CC1(i),Q1(i),'o','CData',degradation_rate(i)*scalefactor,'SizeData',200,'LineWidth',5)
        elseif CC2(i) == 3.6
            subplot(1, length(CC2), 2)
            scatter(CC1(i),Q1(i),'o','CData',degradation_rate(i)*scalefactor,'SizeData',200,'LineWidth',5)
        else
            subplot(1, length(CC2), 1)
            scatter(CC1(i),Q1(i),'square','CData',degradation_rate(i)*scalefactor,'SizeData',200,'LineWidth',5)
            caxis([0 maxvalue])
            subplot(1, length(CC2), 2)
            scatter(CC1(i),Q1(i),'square','CData',degradation_rate(i)*scalefactor,'SizeData',200,'LineWidth',5)
            caxis([0 maxvalue])
        end
    end
    
    columnlegend(2,policy_names,'Location','NortheastOutside','boxoff');
    
    print('summary5_contour','-dpng')


end

