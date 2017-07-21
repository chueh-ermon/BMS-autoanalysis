% close all
% figure('units','normalized','outerposition',[0 0 1 1]), box on, hold on
% for i=1:numel(charge_time)
%     tt80=charge_time{i};
%     mQ=master_capacity{i};
%     [col, mark]=random_color('y','y');
%     scatter(tt80,mQ,100,col,mark,'LineWidth',2)
% end
% xlabel('Time to 80% SOC (minutes)')
% ylabel('Remaining Capacity')
% ylim([0.8 1.0])

close all
figure('units','normalized','outerposition',[0 0 1 1]), box on, hold on
for j=1:500
    for i=1:numel(charge_time)
        tt80=charge_time{i};
        mQ=master_capacity{i};
        [col, mark]=random_color('y','y');
        scatter(tt80,mQ,100,col,mark,'LineWidth',2)
    end
end
xlabel('Time to 80% SOC (minutes)')
ylabel('Remaining Capacity')
ylim([0.8 1.0])

n = 1;
for idx = 1:1000
    plot(xvals2,y)
    hold on
    area(xvals2(idx:end),y(idx:end))
    hold off
    xlabel('Voltage vs Li^0/Li^+ (V)','FontWeight','b')
    ylabel('\DeltadQ/dV ((mAh/g)/V)','FontWeight','b') 
    set(gcf, 'Color' ,'w')
    axis([0 1.2 -120 0])
    drawnow
    frame = getframe(1);
    n = n+1;
    ima{n} = frame2im(frame);
end
close;

filename = 'scatterplot.gif'; % Specify the output file name
for idx = 1:n
    [A,map] = rgb2ind(ima{idx},256);
    if idx == 1
        imwrite(A,map,filename,'gif','LoopCount',1,'DelayTime',0.1);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',0.1);
    end
end