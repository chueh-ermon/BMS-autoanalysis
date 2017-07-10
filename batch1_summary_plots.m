function batch2_summary_plots(batch, batch_name, T_cells, T_policies)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

    %% Capacity vs charging time
    
    
    xlabel('Time to 80% SOC (minutes)')
    ylabel('Remaining discharge capacity (Ah)')
    print('summary2_Q_vs_t80','-png')
    
    %% Average degradation vs charging time
    
    xlabel('Time to 80% SOC (minutes)')
    ylabel('Average degradation rate (Ah/cycle)')
    print('summary3_deg_vs_t80','-png')
    
    %% Contour plot
    
    print('summary4_contour','-png')


end

