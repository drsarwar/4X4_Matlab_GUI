%Description: Live plots 2d C values for 4x4 sensor for all 16 taxels
%               This has been updated as of Sep 19, 2018 to be less latent
%               than the previous version provided prior to v1.0.0
%Author: Claire Preston
%Date: Sep 19, 2018
%Version: sview2d 1.0.0


%%%%Clear serial port variables, workspace variables
delete(instrfindall);
clear all;close all;
clc;

%%%Open Serial COnnection
%%USER: SPECIFY YOUR SERIAL PORT
SerialPort='/dev/cu.usbmodem144101';
s=serial(SerialPort);
fopen(s);

%%USER: Specify number of values to display/store on each plot
numvalsp=40;
%%USER: Set y range to plot
ylim=[0.25 1];


%%%Maps matrix locations according to board used
%%USER: Uncomment the board version you are using
%matmap=1+ [6 4 5 7; 2 0 1 3; 10 8 9 11; 14 12 13 15]; %Board V1
%matmap=1+[0 1 2 3; 4 5 6 7; 8 9 10 11; 12 13 14 15]; %Board V2
%matmap=1+[3 2 0 1; 7 6 4 5; 15 14 12 13; 11 10 8 9]; %Board V3
%matmap=1+[2 3 1 0; 6 7 5 4; 14 15 13 12; 10 11 9 8]; %Board V4
%matmap=1+[0 1 3 2; 4 5 7 6; 12 13 15 14; 8 9 11 10]; %Board V5
%matmap=1+[3 1 0 2; 7 5 4 6; 15 13 12 14; 11 9 8 10]; %Board V6
matmap=1+[5 4 7 6; 1 0 3 2; 13 12 15 14; 9 8 11 10]; %MSS 4X4 board

matmap1=matmap(:);

%%%Create cell array to store values for each taxel
vals=cell(16,1);
for i=1:16
    vals{i,1}=zeros(numvalsp,1);
end

%%%%Creates figure for 4x4 plots
figure(1);
ha=[];%subplot handle array
hl=[];%line plot array
for i=1:16
    ha(i)=subplot(4,4,i);
    hl(i)=line(nan,nan);
    set(hl(i),'LineWidth',3);
    set(ha(i),'YLim',ylim);
    set(ha(i),'XLim',[0 numvalsp]);
    set(ha(i),'DrawMode','fast');
    set(ha(i),'NextPlot','replacechildren');
end
drawnow;

%%%Read in values and plot
%%USER: Ensure figure is active and press any key to terminate
loc=1;%initialize location variable to taxel address 1
global KEY_IS_PRESSED
KEY_IS_PRESSED=0;
gcf
set(gcf,'KeyPressFcn',@myKeyPressFcn); %Set keypress listener to figure
while ~KEY_IS_PRESSED  
    line=fgetl(s); %get next line
    %store in vals{} 
    if line(1)=='('
        loc=bin2dec(line(2:5));
        val=str2num(line(7:12));
        vals{loc+1}=[val;vals{loc+1}(1:numvalsp-1)];
    end
    %match with correct address on plot
    tem=matmap';
    tem=tem(:);
    i=find(tem==(loc+1));
    set(hl(i), 'XData',1:numvalsp,'YData',vals{loc+1});
    %draw after all 16 are updated
    %saves on latency rather than plotting every time 1 is updated
    if(i==1)
        drawnow;
    end    
end
disp('loop ended')

%Close serial connection
fclose(s);
delete(s);
    
