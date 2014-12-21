fp=4.9e6;fs=5e6;Fs=15.36e6;rs=30;
wp=2*fp*pi/Fs;ws=2*fs*pi/Fs;%求归一化数字通带截止频率,求归一化数字阻带起始频率 
Bt=ws-wp;%求过渡带宽
alpha=0.5842*(rs-21)^0.4+0.07886*(rs-21);%计算kaiser窗的控制参数
M=ceil((rs-8)/2.285/Bt);%求出滤波器的阶数
wc=(ws+wp)/2/pi; %求滤波器的截止频率并关于pi归一化 
hk=fir1(M,wc,kaiser(M+1,alpha))%利用 fir1 函数求出滤波器的系数
[Hk,w] = freqz(hk,1);                     %  计算频率响应 HK的长度是512；
mag = abs(Hk);                         %  求幅频特性
db = 20*log10(mag/max(mag));           %  化为分贝值 
db1=db';


figure(1),plot(0:pi/511:pi,db1),grid on
axis([0,4.0,-80,5]),title('数字滤波器——fir1窗函数法')

L = length(Hk);
Gk = Hk;



