function batch1_summary_plots(batch, batch_name, T_cells, T_policies)
%% Function: takes in tabular data to generate summary plots of batch
% Usage: batch1_summary_plots(batteries [struct],'batch_2' [str], T_cells [table],T_policies [table])
% July 2017 Michael Chen and Peter Attia
% Plotting adapted from Nick Perkins' plot_spread function


    %% Initialization and inputs
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
        cycle = max(cycle_num(i)) % pulls the end cycle
        capacities(i) = batteries(i).cycles(cycle).Qd % pulls the most recent capacity
    end
    
    %% Capacity vs charging time
    
    figure(1)
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]) 
    [col, mark]=random_color('y','y');
    scatter(tt_80,capacities,100,col,mark,'LineWidth',2)
    hold on

    xlabel('Time to 80% SOC (minutes)')
    ylabel('Remaining discharge capacity (Ah)')
    print('summary2_Q_vs_t80','-dpng')
    
    %% Average degradation vs charging time
     
    figure(2)
    set(gcf, 'units','normalized','outerposition',[0 0 1 1])
    scatter(tt80,degradation_rate,200,col,mark,'LineWidth',2);
    
    xlabel('Time to 80% SOC (minutes)')
    ylabel('Average degradation rate (Ah/cycle)')
    print('summary3_deg_vs_t80','-dpng')
    
    %% Contour plot
    % adapted from Peter Attia
    % extract from policies
    
    CC1 = T_policies(:,1); % CC1
    Q1 = T_policies(:,2); % Q1
    CC2 = T_policies(:,3); % CC2 
    degradation_rate = T_policies(:,6); % Deg rate
    
    time = ones(length(CC2),length(CC1),length(Q1));
    figure, set(gcf, 'units','normalized','outerposition',[0 0 1 1])
    for i=1:length(CC2)
        subplot(1,length(CC2),i), hold on, box on
        xlabel('CC1'),ylabel('Q1 (%)')
        title(['CC2 = ' num2str(CC2(i))])
        %axis([min(CC1) max(CC1) min(Q1) max(Q1)])
        
        [X,Y] = meshgrid(CC1,Q1);
        time = (60.*Y./X./100)+(60.*(80-Y)./CC2(i)./100);
        v = [13, 12, 11, 10, 9, 8];
        contour(X,Y,time,v,'LineWidth',2,'ShowText','on')
    end
    
    % call to T_cells and T_policies
    
    % prepare for degradation plotting
    colormap jet;
    scalefactor = 1e6; % Factor to scale
    maxvalue = max(list(:,4))*scalefactor;

    for i = 1:length(list(:,1))
        if list(i,3) == 3
            subplot(1, length(CC2), 1)
            %ax(2) = axes;
            scatter(list(i,1),list(i,2),'o','CData',list(i,4)*scalefactor,'SizeData',200,'LineWidth',5)
        elseif list(i,3) == 3.6
            subplot(1, length(CC2), 2)
            scatter(list(i,1),list(i,2),'o','CData',list(i,4)*scalefactor,'SizeData',200,'LineWidth',5)
        else
            subplot(1, length(CC2), 1)
            scatter(list(i,1),list(i,2),'square','CData',list(i,4)*scalefactor,'SizeData',200,'LineWidth',5)
            caxis([0 maxvalue])
            subplot(1, length(CC2), 2)
            scatter(list(i,1),list(i,2),'square','CData',list(i,4)*scalefactor,'SizeData',200,'LineWidth',5)
            caxis([0 maxvalue])
        end
    end

    print('summary4_contour','-dpng')


end

