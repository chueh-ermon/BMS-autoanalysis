function make_summary_images(batch, batch_name, T_cells, T_policies)
% make_summary images makes the summary images for each batch. Since each
% batch will have different 'best' ways of presenting data, have
% conditional statements to identify which to use

%% Move to image directory
% cd ['C:/Users//Arbin/Box Sync/Batch images/' batch_name]

%% Q vs n
for i = 1:numel(T_cells)
    x = batteries(i).summary.cycle;
    y = batteries(i).summary.QDischarge;
    [col, mark] = random_color('y','y');
    plot(x,y,'color',col,'marker',mark)
end
xlabel('Cycle number')
ylabel('Remaining discharge capacity (Ah)')
print('summary1_Q_vs_n','-png')

%% Make plots for each
% Batch 1 (2017-05-12)
if batch_name == 'batch1'
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

% Batch 2 (2017-06-30)
elseif batch_name == 'batch2'
    %% Contour plots
    % x = CC1, y = CC2, contours = Q1
    
    saveas(gcf, 'summary2_contour1.png')
    
    
    % x = CC1, y = Q1, contours = CC2
    
    saveas(gcf, 'summary3_contour2.png')
    
else
    warning('Batch name not recognized. No summary figures generated')
end

end