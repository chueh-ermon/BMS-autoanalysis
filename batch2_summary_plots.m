function batch2_summary_plots(batch, batch_name, T_cells, T_policies)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

    %% Contour plots
    % x = CC1, y = CC2, contours = Q1
    batch2_summary_plots(batch, batch_name, T_cells, T_policies)
    saveas(gcf, 'summary2_contour1.png')
    
    
    % x = CC1, y = Q1, contours = CC2
    
    saveas(gcf, 'summary3_contour2.png')

end

