function [ Capacitance, xVoltage] = IDCA(Capacity,Voltage)
%Performs and Tidies ICA
%   Detailed explanation goes here
Capacitance= zeros(1,length(Voltage));
% Calculate Approximate dQdV
for j=2:length(Voltage)
    Capacitance(j)=(Capacity(j)-Capacity(j-1))/(Voltage(j)-Voltage(j-1));
end
 
%Tidy dQdV data for all battery cycles. 
for j=2:length(Capacitance)
    if isnan(Capacitance(j)) 
        Capacitance(j)=0;
    elseif abs(Capacitance(j)) >= 50
        Capacitance(j)=0;
        %Ignore CV location, or shorted battery 
    elseif Capacitance(j) > 0
        Capacitance(j)= Capacitance(j-1);
    elseif Capacitance(j)== 0
        Capacitance(j)=Capacitance(j-1);
    elseif Voltage(j) <= 2
        Capacitance(j)=0;
    else 
        Capacitance(j)=Capacitance(j);
    end
end

%% Interpolate Voltage and dQdV. doesn't work for looping
%Define Voltage Range.
xVoltage=linspace(3.5,2.001,1000);
% Create Array for Initial Voltage Values and empty dQdV
interp_Voltages=3.6;
first_Voltage=Voltage(1)+.0001;
interp_ICA1=0;  
interp_ICA2=-.0001;

%Add Initial Values
continuosVoltage=horzcat(interp_Voltages,first_Voltage,transpose(Voltage));
continuosICA=horzcat(interp_ICA1,interp_ICA2,Capacitance);
%Interpret 
VoltageCurve=continuosVoltage;
ICA_Curve=continuosICA;
[VoltageCurve, index] = unique(VoltageCurve);  
Capacitance=interp1(VoltageCurve,ICA_Curve(index),xVoltage);
Capacitance=transpose(smooth(Capacitance,10));
%Capacitance=transpose(smooth(Capacitance,0.01,'rloess'));
end
