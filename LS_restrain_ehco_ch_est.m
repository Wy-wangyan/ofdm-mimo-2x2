%只对近端信号进行估计，然后返回主函数，将估计到的信号减去，然后在使用ZF方法来检测远端信号！！！！！！！！！！！！
%与仿真不同点还有没有过 FIR filter!!
%r = Xh + exp(i*w0)FYg + n;但是本仿真中将h ,g都当做了1
%X,Y 均是去掉cp,只保留数据部分的纯有用信息部分
%X = [X1 X2],分别为近端天线1上发送的信号，和近端天线2上发送的信号
%Y = [Y1 Y2],分别为近端天线1上发送的信号，和近端天线2上发送的信号
%F应该为每个载波上具有的相位差，格式为
%初始相位差也设为了w0 = 0;
%w = 0; coffients =i*pi*w;               
% F = diag([1,exp(coffients*1),exp(coffients*2),exp(coffients*3),exp(coffients*4),exp(coffients*5),exp(coffients*6),exp(coffients*7),exp(coffients*8),exp(coffients*(N_sym - 1))]); %发送信号上每一个符号的相位差
%F应该也有一个估计，但是先按照理想情况下，即均取得是0，而实际上w = （f_carrier_near -f_carrier_far）*T/R_rx(T为采样间隔，R_rx:汉宁窗下接收天线的过采样点)
%本来需要第二步，再对h_near进行估计，这样在回波抑制，可以得到更准确的远端节点信号的估计[h(更准确)；exp(i*w0)g(g是远端的频响)]
%function [Y_restraint_ehco_est,X_restraint_ehco_est,R_new_temp,MSE_far_after_ch_est,h_mse_all_ch] = LS_restrain_ehco_ch_est(transmit_signal,transmit_signal_near,recv_signal,PrefixRatio,N_subc,N_sym,N_Rx_ant,F)
function [X_restraint_ehco_est,MSE_near_after_ch_est,h_mse_all_near_ch] = LS_restrain_ehco_ch_est(transmit_signal,transmit_signal_near,recv_signal,PrefixRatio,N_subc,N_sym,N_Rx_ant,F)
%cp长度，近端与远端信号的数据发送长度相同
cp_length = PrefixRatio * N_subc;
data_length = length(transmit_signal);

% cp_far = reshape(transmit_signal,data_length/N_sym,N_sym,N_Rx_ant);   
% cp_far = cp_far(1:cp_length,:,:); %257是去掉cp 数据开始的位置
            
cp_near = reshape(transmit_signal_near,data_length/N_sym,N_sym,N_Rx_ant);
cp_near =cp_near(1:cp_length,:,:);
%%远端节点的信号
% Y_far = reshape(transmit_signal,data_length/N_sym,N_sym,N_Rx_ant);   
% Y_far = Y_far((cp_length + 1):end,:,:); %257是去掉cp 数据开始的位置
% Y1 = Y_far(:,:,(N_Rx_ant - 1));
% Y2 = Y_far(:,:,N_Rx_ant);

%%近端节点的信号(不去导频！！！)
X_near = reshape(transmit_signal_near,data_length/N_sym,N_sym,N_Rx_ant);  %这里的transmit_signal_near 是在接收时，已经成了100的
%X_near = X_near((cp_length + 1):end,:,:);
X1 = X_near(:,:,(N_Rx_ant - 1));  %近端节点天线1上的信号
X2 = X_near(:,:,N_Rx_ant);  %近端节点天线2上的信号
X_est = [X1 X2];

%%接收天线上的信号
R_all = reshape(recv_signal,data_length/N_sym,N_sym,N_Rx_ant);   
%R_all = R_all((cp_length + 1):end,:,:); %257是去掉cp 数据开始的位置
R1 = R_all(:,:,(N_Rx_ant - 1));          %接收节点天线1上的信号
R2 = R_all(:,:,N_Rx_ant);          %接收节点天线2上的信号

%%远端与接收天线、近端与接收天线的信道估计
%近端与接收天线的第一阶段的信道估计
 h11 = inv(X1'*X1)*X1'*R1;
 h21 = inv(X2'*X2)*X2'*R1;
 h12 = inv(X1'*X1)*X1'*R2;
 h22 = inv(X2'*X2)*X2'*R2;
 h_near_est_1stage =[h11 h12;h21 h22];


%近端信号的估计
r_est_near = X_est * h_near_est_1stage;
R_near_est = zeros(N_subc+cp_length,N_sym,N_Rx_ant); 
R_near_est(:,:,(N_Rx_ant - 1)) = r_est_near(:,1:N_sym);
R_near_est(:,:,N_Rx_ant) = r_est_near(:,(N_sym +1):end);

% %第一阶段的回波抑制（R_far_ehco 只包括部分噪声和需要的远端信号）
% R_restrain_ehco = R_all -100 * R_near_est;
%  
% %抑制了近端信号的接收信号
% R_after_restrain_1 = R_restrain_ehco(:,:,(N_Rx_ant - 1)); 
% R_after_restrain_2 = R_restrain_ehco(:,:,N_Rx_ant);
% 
% %(F*[Y1.' Y2.']).' + n = [R_after_restrain_1  R_after_restrain_2]
% R_after_restrain_1_inv_F = inv(F)*R_after_restrain_1.';
% R_after_restrain_1_inv_F =  R_after_restrain_1_inv_F.';
% R_after_restrain_2_inv_F = inv(F)*R_after_restrain_2.';
% R_after_restrain_2_inv_F =  R_after_restrain_2_inv_F.';
% 
% %%远端信道的估计
% h_far11 = inv(Y1'*Y1)*Y1'* R_after_restrain_1_inv_F ;
% h_far21 = inv(Y2'*Y2)*Y2'* R_after_restrain_1_inv_F ;
% h_far12 = inv(Y1'*Y1)*Y1'* R_after_restrain_2_inv_F ;
% h_far22 = inv(Y2'*Y2)*Y2'* R_after_restrain_2_inv_F ;
% h_far_est_1stage = [h_far11 h_far12;h_far21 h_far22];
% 
% %远端信号的估计
% R_after_restrain_inv_F = [R_after_restrain_1_inv_F  R_after_restrain_2_inv_F];
% 
% Y_est_far = R_after_restrain_inv_F * inv(h_far_est_1stage);
% Y_est_far_1 =  Y_est_far(:,1:N_sym);
% Y_est_far_2 =  Y_est_far(:,(N_sym + 1):end);
% 
% %本来需要第二步，再对h_near进行估计，这样在进行上面的步骤，可以得到更准确的远端节点信号的估计
% %本来 A = [r_near_est (F*Y_est_far_1.').' (F*Y_est_far_2.').'];
% %因为F是对角为1的矩阵，所以就没有相乘,
% %X_est = [X1 X2];
% 
% A = [X_est Y_est_far_1 Y_est_far_2];

%%%%求mse 
% %远端信号的估计后的mse
% mean_Y1 = mean(Y1);
% mean_Y2 = mean(Y2);
% mean_Y_est_far_1 = mean(Y_est_far_1);
% mean_Y_est_far_2 = mean(Y_est_far_2);
% e_1 = mean_Y1 - mean_Y_est_far_1;
% e_2 = mean_Y2 - mean_Y_est_far_2;
% mse_1 = mse(abs(e_1));
% mse_2 = mse(abs(e_2));%都在约等于[1.015e-05;1.868e-05;];
% MSE_far_after_ch_est = [mse_1;mse_2];
%近端信号的估计后的mse
mean_X1 = mean(X1);
mean_X2 = mean(X2);
mean_X_est_near_1 = mean(X1);
mean_X_est_near_2 = mean(X2);
e_1 = mean_X1 - mean_X_est_near_1;
e_2 = mean_X2 - mean_X_est_near_2;
mse_1 = mse(abs(e_1));
mse_2 = mse(abs(e_2));%都在约等于[1.015e-05;1.868e-05;];
MSE_near_after_ch_est = [mse_1;mse_2];


% %将估计到需要的远端信号重新组装
% Y_new = cat(3,Y_est_far_1,Y_est_far_2);  %三维，第三维为第几根天线
% Y_new_new = cat(1,cp_far,Y_new);         %因为估计出的是远端信号，所以只用将cp_far与Y_new,在行上连接
% Y_restraint_ehco_est = reshape(Y_new_new,1,data_length,N_Rx_ant);%整合为之前加了cp的信号

%将估计到抑制掉的近端信号重新组装
X_new = cat(3,X1,X2);
% X_new_new = cat(1,cp_near,X_new);
X_restraint_ehco_est = reshape(X_new,1,data_length,N_Rx_ant);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% R_new = cat(3,R_after_restrain_1,R_after_restrain_2);  %三维，第三维为第几根天线
% R_new_new = cat(1,cp_far,R_new);         %因为估计出的是远端信号，所以只用将cp_far与Y_new,在行上连接
% R_new_temp = reshape(R_new_new,1,data_length,N_Rx_ant);%整合为之前加了cp的信号


%信道的mse；
h = zeros((N_sym * N_Rx_ant),(N_sym * N_Rx_ant));
for i =1:(N_sym * N_Rx_ant)
h(i,i) = 1;
end

% h_erro_all_far_ch = mean(h) - mean(h_far_est_1stage);
% %h_erro_all_far_ch = diag(h_erro_all_far_ch);
% %h_erro_all_far_ch = diag(h_erro_all_far_ch);%无论取不取对角，最后的结果都是一样的
% h_erro_all_far_ch = abs(h_erro_all_far_ch);
% h_mse_all_far_ch = mse(h_erro_all_far_ch); %！太大了
h_erro_all_near_ch = mean(h) - mean(h_near_est_1stage);
h_erro_all_near_ch = abs(h_erro_all_near_ch);
h_mse_all_near_ch= mse(h_erro_all_near_ch); %
