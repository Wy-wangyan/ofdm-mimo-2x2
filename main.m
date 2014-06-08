clc;
clear all;
%close all;
N_Tx_ant = 2;  %��������Ϊ2
N_Rx_ant = 2;  %��������Ϊ2
N_user = 1;    %�û���Ϊ4

N_sym = 20;     %  ÿ֡��OFDM������,����������ǰ׺OFDM���� LTE��һ֡����Ϊ6~7��OFDM����
N_frame = 10;   %  �����֡����
% ����ѭ����ʼ��Eb_No,����Ϊÿ���ص�����Eb
% �������ĵ��߹������ܶ�No�ı�ֵ, dBֵ
Eb_NoStart = 0;                                                          
Eb_NoInterval = 2;      % ����Eb/No�ļ��ֵ(dB)
Eb_NoEnd = 24;          % ����Eb/No����ֵֹ(dB)   
%�������ѡ�����LTEϵͳ����Ϊ10MHzʱ����
fc = 5e9;                               %  �ز�Ƶ��(Hz)   5GHz
%  Bw = 20e6;                              %  ����ϵͳ����(Hz) 10MHz
Bw = 10e6;                              %  ����ϵͳ����(Hz) 10MHz
fs = 15.36e6;                           %  ��������Ƶ�� 1024*15KHz=15360000Hz
T_sample = 1/fs;                        %  ����ʱ��������(s)
N_subc = 1024;                          %  OFDM ���ز���������FFT����
Idx_used = [-300:-1 1:300];             %  ʹ�õ����ز���ţ�һ��ʹ��600�����ز�
Idx_pilot = [-300:25:-25 25:25:300];    %  ��Ƶ���ز����,��Ƶ���Ϊ24����Ӧ������Ϊ0�����ز���ӳ�����ݻ��ߵ�Ƶ��Ϊ��LTE��׼
N_used = length(Idx_used);              % ʹ�õ����ز��� 600
N_pilot = length(Idx_pilot);            % ��Ƶ�����ز���
N_data = N_used - N_pilot;              % һ��OFDM�����������û����͵����ݵ����ز���
Idx_data = zeros(1,N_data);
N_tran_sym = 0;                         %ǰ�����еĳ��� �˴�Ϊ������ǰ������
w0 = 0;
phase_intial_err = exp(i*w0);           %��ʼ��λ��
w = 0;
coffients =i*pi*w;               
%F = diag([1,exp(coffients*1),exp(coffients*2),exp(coffients*3),exp(coffients*4),exp(coffients*5),exp(coffients*6),exp(coffients*7),exp(coffients*8),exp(coffients*(N_sym - 1))]); %�����ź���ÿһ�����ŵ���λ��
F = eye(20);




% �õ��������ز��ı��
        m = 1; n = 1;
    for k  = 1:length(Idx_used)        
        if Idx_used(k) ~= Idx_pilot(m);
            Idx_data(n) = Idx_used(k); 
            n = n + 1;
        else
            if m ~= N_pilot
                m = m + 1;
            end
        end
    end
    %  Ϊ���ʹ�÷���,�������ز����Ϊ��1��ʼ,�����ز�����
Idx_used = Idx_used + N_subc/2 +1;    %ʹ�õ����ز�����   
Idx_pilot = Idx_pilot + N_subc/2 +1;  %��Ƶ���ز�����                                                  
Idx_data = Idx_data + N_subc/2 +1;    %�������ز����꣬����0+1024/2+1=513���ز�Ϊ�գ��Ȳ������ݣ�Ҳ���ǵ�Ƶ
PilotValue = ones(N_pilot,1);%��ƵֵΪȫ1
PrefixRatio = 1/4;           %ѭ��ǰ׺��ռ����     
T_sym = T_sample*( (1 + PrefixRatio)*N_subc );%һ��OFDM���ţ�����ѭ��ǰ׺���ĳ���ʱ��
fprintf('���Ʒ�ʽѡ��2--QPSK����, 3--8PSK,4--16QAM����,6--64QAM\n\n');
Modulation = input('Modulation = \n'); %���Ʒ�ʽѡ��2--QPSK����, 3--8PSK,4--16QAM����,6--64QAM

Es = 1;                 % ��QPSK, 16QAM���Ʒ�ʽ��,��������������һ�� 
Eb = Es/Modulation;     % ÿ��������
N_ant_pair = N_Tx_ant * N_Rx_ant;   % �շ����߶Ե���Ŀ
%ST_Code = 1;   % ��ʱ���룺 , 1--��ʱ������
ST_Code = 0;   % ��ʱ���룺 , 1--��ʱ������

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

snr_idx = 1;
for Eb_No_dB = Eb_NoStart:Eb_NoInterval:Eb_NoEnd  
    Eb_No = 10^(Eb_No_dB/10);       %���������
    var_noise = Eb/(2*Eb_No);       % ��������Ĺ���   NoΪ���߹��� No=2*var_noise

    
     for frame = 1:N_frame          %��֡ѭ������
         %�����Ӷྶ�ŵ�������������Ӧ���룬���ŵ����Ƶ�
         [user_bit,user_bit_cnt]  = user_bit_gen( N_user, N_data ,N_sym , Modulation );% ���û���������ģ�飬ÿ���û�һ֡������
         [user_bit_near,user_bit_near_cnt]  = user_bit_gen( N_user, N_data ,N_sym , Modulation );% ���û���������ģ�飬ÿ���û�һ֡������
         
         coded_user_bit=user_bit;%���ŵ����룬RS�룬�������
         coded_user_bit_near=user_bit_near;
         
         AllocMethod=1;%���ز����䷽��:���ڷ���
         %���ز����䣬��Ӧ��������Ӧ���ƵĹ̶����ز����䷽��
         [user_subc_alloc , mod_subc ,pwr_subc, pad_bit_cnt]  = adpt_mod_para...
                ( coded_user_bit,N_sym,Idx_data ,AllocMethod ); 
            
         [user_subc_alloc_near , mod_subc_near ,pwr_subc_near, pad_bit_cnt_near]  = adpt_mod_para...
                ( coded_user_bit_near,N_sym,Idx_data ,AllocMethod );    
            
         TurnOn.AdptMod=0;%������Ӧ����
         % ���ո�����ÿ�û�,ÿ���ز��ĵ��Ʒ�ʽ,���е���
         mod_sym =  modulator(coded_user_bit,user_subc_alloc,mod_subc,...
            pwr_subc, pad_bit_cnt ,N_subc, N_sym,TurnOn.AdptMod );
         mod_sym_near =  modulator(coded_user_bit_near,user_subc_alloc_near,mod_subc_near,...
            pwr_subc_near, pad_bit_cnt_near ,N_subc, N_sym,TurnOn.AdptMod );
        
        % ���ͷּ�, ʹ�ÿ�ʱ����
         st_coded = st_coding( mod_sym,N_Tx_ant,ST_Code); 
         st_coded_near = st_coding( mod_sym_near,N_Tx_ant,ST_Code); 
 
        
        % �ӵ�Ƶ
        pilot_added = pilot_insert(st_coded,Idx_pilot,PilotValue);
        pilot_added_near = pilot_insert(st_coded_near,Idx_pilot,PilotValue);
        
        % OFDM����,��ѭ��ǰ׺����ǰ������. ���ʹ�÷��ͷּ�,������������ߵ��ź�
        [transmit_signal] = ofdm_mod(pilot_added,PrefixRatio,N_subc,N_sym,N_used,...
            Idx_used,N_Tx_ant,N_tran_sym);%ʵ�ʺ����в�����ǰ������
        [transmit_signal_near] = ofdm_mod(pilot_added_near,PrefixRatio,N_subc,N_sym,N_used,...
            Idx_used,N_Tx_ant,N_tran_sym);%ʵ�ʺ����в�����ǰ������
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        transmit_signal_power = var(transmit_signal);%�����źŹ���
        transmit_signal_near_power = var(transmit_signal);%�����źŹ���
         P = 10*log10(abs(10000*transmit_signal_near_power)./abs(transmit_signal_power));
        length_noise=size(transmit_signal,2);
        noise=gausnoise(Eb_No_dB,transmit_signal_power,length_noise);%��������������
   
        recv_signal =  transmit_signal+ 100*transmit_signal_near + noise;%���յ����źż�����%%%%%%%%%%%%%%%%���100,ֻ��ָ�Ľ��յ����źű�ԭ���ĸ��˶��٣��Ȳ���ָ�ŵ����ŵ���ֻ��1������
        
      
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for u = 1:N_user        % ����û����ջ���ѭ��
             
            % ���յ����źŽ���LS�ŵ�����
            [X_restraint_ehco_est,MSE_near_after_ch_est,h_mse_all_near_ch] = LS_restrain_ehco_ch_est(transmit_signal,transmit_signal_near,recv_signal,PrefixRatio,N_subc,N_sym,N_Rx_ant,F);%%%%���ڵ��õĺ������ڼ����˵�Ƶ��ĶԽ����źŵĹ�����ȫһ������������!!!!
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Ҳ�п�������Ϊ�ŵ�����1����ȫ����������,���Ǽ���������������������������������
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Ҳ��������Ϊ������Ͻ����ź���˵��Ҳ�ǱȽ�С�ģ�ȷʵÿ�������ڵ���(��ѭ��ǰ)�����˾��ǲ���100��Ҳ��1e+4,��ʹ��ѭ������
            %for i = 1:2   v_1(i,1) =
            %10*log10(v(:,:,i)/v_new(:,:,i));end��ÿ�������ϻ�����30dB����
            %ֻ�Խ����źŽ��й��ƣ�Ȼ�󷵻��������������Ƶ����źż�ȥ��Ȼ����ʹ��ZF���������Զ���źţ�����������������������
            Y_restraint_ehco = recv_signal - 100 * X_restraint_ehco_est;  %���100 ���Լӵ����ú�����
            
            %%%%%%%%%%%%%%%%%%%%SINR = �����Զ���ź�/�����ź�+����������Ŀǰ��ʣ������ź�Ϊ0��Ҳ����˵
            %%%%%%%%%%%%%%%%%%%%SINR = �����Զ���ź�/ʣ���������= ���Ƴ���Զ�� -ʵ�������Զ�ˣ������ڶ�Զ���źŹ�����֪�������
            %%%%%%%%%%%%%%%%%%%%Ҫ������ѭ���ó���ֵ�������ֻ�ܵõ����һ��ѭ���ĵõ���ֵ
            
            
            %Զ���źŵĹ��ƺ��mse
            mean_Y_est = mean(Y_restraint_ehco);
            mean_tran_far = mean(transmit_signal);
            erro_est_far = mean_Y_est - mean_tran_far;
            MSE_far_after_ch_est = mse(abs(erro_est_far));
            
            
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%             %���ֵѹ�˴�Լ40�ֱ���!!!!!̫���ˣ�Ӧ����70dB,ԭ�����Ƴ���Yȷʵ��ѹ��70dB!!!!%%%%%%%%
%             X_est_power = var(X_restraint_ehco_est);
%             Y_est_power = var(Y_restraint_ehco);
%             P_after_ehco = 10*log10(X_est_power./Y_est_power);  %���˱�Զ�����������ϵı���-20.9��-20.6dB��
            
            % OFDM���,ȥǰ������
            [data_sym] = ofdm_demod(Y_restraint_ehco,PrefixRatio,N_subc,N_sym,N_tran_sym,N_Rx_ant);
            [data_sym_near] = ofdm_demod(X_restraint_ehco_est,PrefixRatio,N_subc,N_sym,N_tran_sym,N_Rx_ant);
            
            
            %[data_sym] = ofdm_demod(recv_signal,PrefixRatio,N_subc,N_sym,N_tran_sym,N_Rx_ant);
            %[data_sym_another] = ofdm_demod(recv_signal_another ,PrefixRatio,N_subc,N_sym,N_tran_sym,N_Rx_ant);
            %channel_est=1;%���ŵ����ƣ�ͬ����
            
             %ZF��� ------�ڹ����˽����źź��ڽ��յ����ź��м�ȥ���õ��ĵ�һ�׶ε�Զ���źŹ��ƣ�����ZF��⣬�õ�����ȷ��Զ���ź�     
            I = eye(N_subc);
            data_sym_1 = data_sym(:,:,1);
            data_sym_2 = data_sym(:,:,2);

 
           x11 = inv(I)*data_sym_1;
           x12 = inv(I)*data_sym_2;
           data_sym_est(:,:,1) =x11; 
           data_sym_est(:,:,2) =x12;
           
           X_power = var(data_sym_near);
            Y_power = var(data_sym);
            P_after = 10*log10(X_power./Y_power);  %���˱�Զ�����������ϵı���0dB���ң�
            % ���ջ��ּ������Ϳ�ʱ����  %%��Ϊ������ź�û�г���Ӧ�����ӣ����Ի��ǰ������������
            
            channel_est=ones(N_subc,1,N_ant_pair);%����Ϊ�����ŵ����ŵ�����Ϊ�Խ�����Ϊ1�ľ���  %%%%%%%Ƶ����ŵ�
              

           
           %�ɼ�һ��ƽ���������ģ��������㻬������x1 = [0 0 x];x2 = [0 x 0]; x3 = [x 0 0]
           %y = 1/3 *(x1+x2+x3);
            
            st_decoded = st_decoding( data_sym_est,channel_est,N_Tx_ant, N_Rx_ant ,ST_Code ,Idx_data);%2X2MIMO%%%%%%%%%data_sym(:,:,1)�ϰ��������ֵģ�һ������Զ�˽ڵ��ϵģ�һ�����ǽ��˽ڵ��ϵ�
          
            % ����ÿ�û�,ÿ���ز��ĵ��Ʒ�ʽ,���н��
            demod_user_bit = demodulator( st_decoded, user_subc_alloc{u} ,mod_subc{u} ,...
                pad_bit_cnt(u),N_sym,TurnOn.AdptMod);   
            decoded_user_bit{u}= demod_user_bit;%�� �ŵ�����, ����RS����, ������Viterbi�����
            % ��֡,���������,���û�������ͳ��
            bit_err = sum(abs(decoded_user_bit{u} - user_bit{u}));%�����ʼ���
            user_bit_err{u}(frame,snr_idx) = bit_err ;  
    
                
           %�ŵ�����
           C{u}(snr_idx) =  Bw * log2(1 + Eb_No);   %��ũ����������
            
        end  % ����û����ջ���ѭ������ 
        % ʵʱ��ʾ��������
        fprintf('Eb/No:%d dB\tFrame No.:%d  Err Bits:%d \n',...
            Eb_No_dB, frame, bit_err);
     end     % OFDM֡/���ݰ�ѭ������   
     snr_idx = snr_idx + 1;
   
end      % Eb/No�����ѭ������  
performance_eval;% ��ͼ


                        
     
            
            
        
            
            
         
         







    