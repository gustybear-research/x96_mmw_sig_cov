
%viewer = siteviewer("Buildings", "Asan.osm");
format long

lat = [13.473947 13.473172 13.475753 13.474981 13.474682 13.473682 13.473717 13.471296];
lon = [144.708133 144.708293 144.707848 144.708669 144.708796 144.711611 144.712720 144.706369];

centerLat = 13.473615;
centerLon = 144.709086;

coordinates = [lat; lon] % Combine lat and lon into one variable
starting_freq = 4.7e9;
step_freq = 0.5e9;
end_freq = 9.7e9;
power = 2500000;
centerAntennaHeight = 30;
trapAntennaHeight = 3;

%Calculate the furthest trap
distances = sqrt((coordinates(1,:) - centerLat).^2 + (coordinates(2,:) - centerLon).^2);
[maxDistance, maxDistanceIndex] = max(distances);
maxTrap = coordinates(:,maxDistanceIndex);
% Scan the boundary to find the pixel on it that is
% farthest from the centroid.

resultPower = [];
for start_freq=starting_freq:0.5e9:9.7e9
tx = txsite('Name','Center Site',...
      	'Latitude',centerLat,...
        'Longitude',centerLon,...
        'AntennaHeight', centerAntennaHeight, ...
        'TransmitterFrequency', start_freq, ...
        'TransmitterPower', power, ...
        'AntennaAngle', 1.4);
rx = rxsite('Name','Trap Locations', ...
   	'Latitude',maxTrap(1),...
    'Longitude',maxTrap(2),...
    'AntennaHeight',trapAntennaHeight);
[dBmOut] = raytraceout(tx,rx, 'NumReflections',[0]);
min_dBm = min(dBmOut); 
min_dBm = min_dBm - 3;  % cut in half
txPower = 10.^((min_dBm-30)/10); % Convert dBm to W

txback = txsite('Name','Furthest Receiver',...
      	'Latitude',maxTrap(1),...
        'Longitude',maxTrap(2),...
        'AntennaHeight',trapAntennaHeight, ...
        'TransmitterFrequency', 2*start_freq, ...
        'TransmitterPower', txPower, ...
        'AntennaAngle', 1.4);
rxback = rxsite('Name','Receiving reflected signal', ...
   	'Latitude',centerLat,'Longitude',centerLon,...
    'AntennaHeight',centerAntennaHeight);
lastdBmOut = raytraceout(txback, rxback, "NumReflections",[0]);
lastdBmOut = lastdBmOut(1) + 28.5


while(lastdBmOut < -100.01 || lastdBmOut > -99.99)
if(lastdBmOut < -101)
    power = abs(lastdBmOut/100) * power;
else
    power = abs(lastdBmOut/100) * power;
end
tx = txsite('Name','Center of Asan',...
      	'Latitude',centerLat,...
        'Longitude',centerLon,...
        'AntennaHeight',centerAntennaHeight, ...
        'TransmitterFrequency', start_freq, ...
        'TransmitterPower', power, ...
        'AntennaAngle', trapAntennaHeight);
rx = rxsite('Name','Trap Locations', ...
   	'Latitude',lat,...
    'Longitude',lon,...
    'AntennaHeight',3);
[dBmOut] = raytraceout(tx,rx, 'NumReflections',[0])
min_dBm = min(dBmOut); 
min_dBm = min_dBm - 3;  % cut in half
txPower = 10.^((min_dBm-30)/10); % Convert dBm to W

txback = txsite('Name','Furthest Receiver',...
      	'Latitude',maxTrap(1),...
        'Longitude',maxTrap(2),...
        'AntennaHeight',trapAntennaHeight, ...
        'TransmitterFrequency', 2*start_freq, ...
        'TransmitterPower', txPower, ...
        'AntennaAngle', 1.4);
rxback = rxsite('Name','Receiving reflected signal', ...
   	'Latitude',centerLat,'Longitude',centerLon,...
    'AntennaHeight',centerAntennaHeight);
[lastdBmOut] = raytraceout(txback, rxback, "NumReflections",[0]);
lastdBmOut = lastdBmOut(1) + 28.5
end
resultPower = [resultPower power];

end
resultPower = resultPower.*((1.4/360)*(24/180)*2);
x = 4.7e9:0.5e9:9.7e9;
bar(x,resultPower)
for i1=1:numel(resultPower)
     text(x(i1),resultPower(i1),num2str(resultPower(i1),'%0.0f'),...
                'HorizontalAlignment','center',...
                'VerticalAlignment','bottom',...
                'FontSize',20)
 end
xlabel('Fundamental Frequency')
ylabel('Power (Watts)')
helperAdjustFigure(gcf,"Asan_Park_Freq_vs_Power")