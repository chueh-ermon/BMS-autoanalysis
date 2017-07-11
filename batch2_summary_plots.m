function batch2_summary_plots(batch, batch_name, T_cells, T_policies)
%% Function: takes in tabular data to generate contour plots of results
% Usage: batch2_summary_plots(batteries,'batch_2', T_cells,T_policies)
% 

    %% Contour plots
    % x = CC1, y = CC2, contours = Q1
w    batch2_summary_plots(batch, batch_name, T_cells, T_policies)
    saveas(gcf, 'summary2_contour1.png')
    
    
    % x = CC1, y = Q1, contours = CC2
    
    saveas(gcf, 'summary3_contour2.png')

end

