function make_summary_images(batch, batchname)
% make_summary images makes the summary images for each batch. Since each
% batch will have different 'best' ways of presenting data, 


%% Q vs n

xlabel('Cycle number')
ylabel('Remaining discharge capacity (Ah)')
saveas('summary2_Q')

%% Make plots for each
% Batch 1 (2017-05-12)
if batchname == 'batch1'
    %% Capacity vs charging time
    
    
    xlabel('Time to 80% SOC (minutes)')
    ylabel('Remaining discharge capacity (Ah)')
    saveas(gcf, 'summary2_Q_vs_t80.png')
    
    %% Average degradation vs charging time
    
    xlabel('Time to 80% SOC (minutes)')
    ylabel('Average degradation rate (Ah/cycle)')
    saveas(gcf, 'summary3_degrate_vs_t80.png')
    
    
    %% Contour plot
    
    saveas(gcf, 'summary4_contour.png')
    
% Batch 2 (2017-06-30)
elseif batchname == 'batch2'
    %% Contour plots
    % x = CC1, y = CC2, contours = Q1
    
    saveas(gcf, 'summary2_contour1.png')
    
    
    % x = CC1, y = Q1, contours = CC2
    
    saveas(gcf, 'summary3_contour2.png')
    
else
    warning('Batch name not recognized. No summary figures generated')
end

end