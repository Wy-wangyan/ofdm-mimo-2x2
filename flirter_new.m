fp=4.9e6;fs=5e6;Fs=15.36e6;rs=30;
wp=2*fp*pi/Fs;ws=2*fs*pi/Fs;%���һ������ͨ����ֹƵ��,���һ�����������ʼƵ�� 
Bt=ws-wp;%����ɴ���
alpha=0.5842*(rs-21)^0.4+0.07886*(rs-21);%����kaiser���Ŀ��Ʋ���
M=ceil((rs-8)/2.285/Bt);%����˲����Ľ���
wc=(ws+wp)/2/pi; %���˲����Ľ�ֹƵ�ʲ�����pi��һ�� 
hk=fir1(M,wc,kaiser(M+1,alpha))%���� fir1 ��������˲�����ϵ��
[Hk,w] = freqz(hk,1);                     %  ����Ƶ����Ӧ HK�ĳ�����512��
mag = abs(Hk);                         %  ���Ƶ����
db = 20*log10(mag/max(mag));           %  ��Ϊ�ֱ�ֵ 
db1=db';


figure(1),plot(0:pi/511:pi,db1),grid on
axis([0,4.0,-80,5]),title('�����˲�������fir1��������')

L = length(Hk);
Gk = Hk;


