function [ Capacitance, xVoltage] = ICA(Capacity,Voltage)
%Performs and Tidies ICA
%   Detailed explanation goes here
Capacitance= zeros(length(Voltage),1);
   %Calculate Approximate dQdV
for j=2:length(Voltage)
    Capacitance(j)=(Capacity(j)-Capacity(j-1))/(Voltage(j)-Voltage(j-1));
end

%Tidy dQdV data for all battery cycles. 
for j=2:length(Capacitance)
    if isnan(Capacitance(j)) 
        Capacitance(j)=0;
    elseif Capacitance(j)<0
          Capacitance(j)=Capacitance(j-1);
    elseif abs(Capacitance(j)) >= 25
        Capacitance(j)=0;
        %Ignore CV location, or shorted battery 
    elseif Voltage(j) >= max(Voltage)-.001
        Capacitance(j)=0;
    elseif Capacitance(j)== 0
        Capacitance(j)=Capacitance(j-1);
    elseif Voltage(j) <= 2.5
        Capacitance(j)=0;
    else 
        Capacitance(j)=Capacitance(j);
    end
end

Capacitance=smooth(Capacitance,10);%,0.05,'rloess');
Capacitance=smooth(Capacitance,0.01,'rloess');
xVoltage=Voltage;
end

