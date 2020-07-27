%
delete(instrfindall);
%fclose(s);delete(s);
clear all;close all;
clc;


%Open Serial
SerialPort='/dev/cu.usbmodem144101';
s=serial(SerialPort);
fopen(s);

%maps matrix locations to signals

%matmap=1+ [6 4 5 7; 2 0 1 3; 10 8 9 11; 14 12 13 15];
%matmap=1+[0 1 2 3; 4 5 6 7; 8 9 10 11; 12 13 14 15];
%matmap=1+[3 2 0 1; 7 6 4 5; 15 14 12 13; 11 10 8 9];
matmap=1+[5 4 7 6; 1 0 3 2; 13 12 15 14; 9 8 11 10]; %MSS 4X4 board

matmap1=matmap(:);
colors={[1 0 0],[0 1 0],[0 0 1],[1 0 1],[1 0.5 0],[0 1 1],[0.5 0 0],[0 0.5 0],[0 0 0.5],[0.5 0.5 0],[0.5 0 0.5],[0 0.5 0.5],[0.5 0.5 0.5],[0.25 0 0],[0 0.25 0],[0 0 0.25]};

%create cell array to store values for each taxel
vals=cell(16,1);
for i=1:16
    vals{i,1}=zeros(20,1);
end

%Get initial values for delta C/C
for i=1:10*16
    line=fgetl(s);
    loc=1;
    if line(1)=='('
        loc=bin2dec(line(2:5));
        val=str2num(line(7:12));
        vals{loc+1}=[val;vals{loc+1}(1:19)];
    end
end

%avg baseline matrix
valbase=zeros(16,1);
for i=1:16
    tempvals=vals{i}(5:7);
    avgC=mean(tempvals);
    valbase(i)=avgC;
end

%Read in and plot
counter=0;
mat3D=zeros(4,4);
matlin=zeros(16,1);
figure(2);

global KEY_IS_PRESSED
KEY_IS_PRESSED=0;
gcf
set(gcf,'KeyPressFcn',@myKeyPressFcn);
while ~KEY_IS_PRESSED
    line=fgetl(s);
    loc=1;
    if line(1)=='('
        loc=bin2dec(line(2:5));
        val=str2num(line(7:12));
        %vals{loc+1}=[val;vals{loc+1}(1:19)];
        matlin(loc+1)=val;
        counter=counter+1;
    end
    
    %if 16 new values, plot
    if counter==16
        dC_C=100*(matlin-valbase)./valbase;
        %tic
        for i=1:4
            for j=1:4
                loc1=matmap(i,j);
                mat3D(i,j)=dC_C(loc1);
            end
        end
        %toc
        b=bar3(mat3D);
        colormap hot;
        for k=1:length(b)
            zdata=get(b(k),'ZData');
            set(b(k),'CData',zdata);
            set(b(k),'FaceColor','interp');
        end
        zlim([-10 20]);
        caxis([-10 20]);
        h=colorbar;
         counter=0;
         drawnow;
    end
end
disp('loop ended');
fclose(s);
delete(s);


