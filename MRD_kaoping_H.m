clear all;clc;close all;format compact

[filename pathname] = uigetfile({'*.asc';'*.txt';'*xls';'*.*'},'please choice your file','MultiSelect','on');


fileID = fopen('RDD.asc','w');
fclose(fileID);

%%
for i = 1 
    y = A_ReadVelocityASCII_Data(filename, pathname);
    [N l] = size(y);
 
    dt = 1/100;  %取樣頻率100 HZ
    TimeSec=900
    t = ( dt:dt:TimeSec )' ;    % time series
%%    
%    [t ym w F1 f1] = HWF(y,dt);  %VEL
        [t ym w F1 f1] = HWF(y*981,dt);  %ACC

    figure(i);
    plot(t,ym,'b-');
    axis([0 (N*dt) -1 1]);
    ydid = -1 : 0.1 : 1
    xt = [0:5]*120;

    xtl = {'0','5','10','15','20','25','30'};  
    xlabel('Time(sec)','FontSize',12,'FontName','Times New Roman'); 
    ylabel('y(t)','FontSize',12,'FontName','Times New Roman');
    title('Time history');
    set(gcf,'position',[11,0,2000,600]); %設定座標軸在圖中的邊距[左邊界 右邊界 寬  高]

    figure(100+i);

    semilogy(w,F1,'b-');
    axis([0 12 1E-2 1E5]);

    xlabel('Frequency(Hz)','FontSize',12,'FontName','Times New Roman');  
    ylabel('Fourier Amplitude(cm)','FontSize',12,'FontName','Times New Roman');
    title('Fourier amplitude spectrum');
    yline(1E5,'color',[0 0 0],'LineWidth',1,'HandleVisibility','off'); % 黑線Y
    xline(12,'-k','LineWidth',1.5,'HandleVisibility','off'); % 黑線X
    set(gcf,'position',[11,0,2000,600]);

end

%% input  _ Mode Separate range

SeparateType = 2        ;  % 【】1:指定範圍 or 2:指定間距

switch SeparateType
    case 1  % 指定範圍0.61
        CutFrequency_min =   2.931   ; %不切割min  
        CutFrequency_max =    3.189  ; %不切割max
        
    case 2  % 指定間距  %CutFrequency = [ ] 填頻率 %CutFrequency_range = [ ] 填與左間距，往右切割對稱

%	CutFrequency=	0.517	;	% f1
%	CutFrequency=	1.017	;	% f2
%	CutFrequency=	1.531	;	% f3
%	CutFrequency=	2.037   ;	% f4
%	CutFrequency=	2.548	;	% f5
	CutFrequency=	3.060	;	% f6
	CutFrequency_range=	0.129	
	
	
	
	
	





%%
        CutFrequency_min = CutFrequency-CutFrequency_range ;
        CutFrequency_max = CutFrequency+CutFrequency_range  ; 
  
%%     
        otherwise
        error('Invalid SeparateType. Please set DataType to 1, 2.  1:指定範圍 2:指定間距');
        end
%%
CutFrequency_mean = (CutFrequency_min + CutFrequency_max)/2 ;
FL = [CutFrequency_min ,0.01;  CutFrequency_mean ,0.1; CutFrequency_max,0.1];

mode = [w' F1];  
for i = 1:length(FL)
    k(i) = F_FindApproximateNumberPosition( w(:)  , FL(i) );
end
m = [ 0 0 ];
m(1) = k(1);
m(2) = k(3);
N2 = f1(length(f1)/2+1); m = round(m);


for i = 2:length(m)
    Fft = f1(m(i-1):m(i),1);
    Fft = [zeros(round(m(i-1))-1,1);Fft;zeros(length(f1)/2-m(i),1)];
    Fft1 = flipud(conj(Fft(2:end,:)));
    Fft2 = [Fft;N2;Fft1];
    fFt = ifft(Fft2).*(1/dt);
    time_history(:,i-1) = fFt;
    figure(i)
    t = 0:dt:(N-1)*dt;
    plot(t,fFt);
    xlabel('Time(sec)','FontSize',12,'FontName','Times New Roman');  
    ylabel('y(t)','FontSize',12,'FontName','Times New Roman');
    title('Time history');
       
    set(gcf,'position',[0,30,1100,600]); %設定座標軸在途中的邊距[左邊界 右邊界 寬  高]

hold on;
%plot([0 600],[0.1582 0.1582],'-m','LineWidth',1);
hold off;

    %axis([0 600 -inf inf]);  % RD前歷時圖，改範圍，範圍鎖死
%%    
    axis([0 900 -inf inf]); %TimeHistory %RD前歷時圖

    figure(100+i)


    plot(w,abs(Fft2));
    
    %axis([0 12 0 inf]); %傅立葉圖範圍

%%
 axis([CutFrequency_min CutFrequency_max 0 inf]); %傅立葉圖範圍
xticks([CutFrequency_min : CutFrequency_range : CutFrequency_max]); %改X軸(1)
   
    xlabel('Frequency(Hz)','FontSize',12,'FontName','Times New Roman');  
    ylabel('Fourier Amplitude(cm)','FontSize',12,'FontName','Times New Roman');
    title('Fourier amplitude spectrum');
set(gcf,'Units','Pixel','position',[11,0,450,550]);
S=std(time_history)
end

%%
mode_1 = time_history(0/dt+1:899.9/dt,1); %%% 改自由震盪的範圍 %取0-600秒-400

Td = 50;
y = mode_1; mode_number = 1; %最大振態是第N振態
RDn = 1; %%%隨機遞減次數回合數 
a = 1;

for kk = 1:RDn
    for move = 3 %%% 改m
        mean_y = mean(y);
        y = y-mean_y; [m,n] = size(y);
        standard = 1*(std(y)); %%% 標準要改
        point = Td/dt; 
        for i = 2:m-point
            if  standard < y(i) &&  standard > y(i-1) ||  standard > y(i) &&  standard < y(i-1)
                if abs(y(i)-standard) < abs(y(i-1)-standard)
                    history(a,:) = y(i:i+point-1);
                else
                    history(a,:) = y(i-1:i+point-2);
                end               
                a = a+1;
            end
        end
        N1 = sum(history)/(a-1);
        n1 = abs(fft(N1))*dt;
        x = 1:length(history); t = 0:(1/dt)/(length(n1)-1):(1/dt);

        plot_figure(kk+1,x,N1,Td,dt,a); 
        %axis([0 3 0 inf]); %傅立葉圖範圍
   % axis([0.74  1.117 0 5]); %傅立葉圖範圍
   % xticks([0.74  : 0.1885 : 1.117]); %改X軸(1)

 axis([CutFrequency_min CutFrequency_max 0 inf]); %傅立葉圖範圍

 xticks([CutFrequency_min : CutFrequency_range : CutFrequency_max]); %改X軸(1)
set(gcf,'Units','Pixel','position',[11,0,450,550]);
        k1 = k(mode_number+1); F = w(k1);
        [Fre,d] = ITD_method(N1,move,dt,F);
        frequency(kk) = Fre; damping(kk) = d;

        %y = N1'; Td = Td/2; a = 1; clear history; 
    end
end
yTimeHistory=round(max(time_history),6);
aaaRDSTD=round(std(N1),6);
aamaxValue = round(max(N1),6);
%%
ModeData(1, :) = num2cell(frequency(1, :));
ModeData(2, :) = num2cell(damping(1, :));

freq=ModeData(1,1)
damp=ModeData(2,1)
aN=a-1
N1=N1(:)
%%
save('ACC14_0000_f6test.asc','-ascii','N1');
