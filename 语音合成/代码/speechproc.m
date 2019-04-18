function speechproc()
    clear;
    clc
    % 定义常数
    FL = 80;                % 帧长
    FL_v = FL*2;
    WL = 240;               % 窗长
    P = 10;                 % 预测系数个数
    s = readspeech('voice.pcm',100000);             % 载入语音s
    L = length(s);          % 读入语音长度
    FN = floor(L/FL)-2;     % 计算帧数
    % 预测和重建滤波器
    exc = zeros(L,1);       % 激励信号（预测误差）
    zi_pre = zeros(P,1);    % 预测滤波器的状态
    s_rec = zeros(L,1);     % 重建语音
    zi_rec = zeros(P,1);
    zi_s = zeros(P,1);
    zi_s_v = zeros(P,1);
    zi_s_t = zeros(P,1);
    % 合成滤波器
    exc_syn = zeros(L,1);   % 合成的激励信号（脉冲串）
    s_syn = zeros(L,1);     % 合成语音
    % 变调不变速滤波器
    exc_syn_t = zeros(L,1);   % 合成的激励信号（脉冲串）
    s_syn_t = zeros(L,1);     % 合成语音
    % 变速不变调滤波器（假设速度减慢一倍）
    exc_syn_v = zeros(2*L,1);   % 合成的激励信号（脉冲串）
    s_syn_v = zeros(2*L,1);     % 合成语音

    hw = hamming(WL);       % 汉明窗
    
    % 依次处理每帧语音
    for n = 3:FN

        % 计算预测系数（不需要掌握）
        s_w = s(n*FL-WL+1:n*FL).*hw;    %汉明窗加权后的语音
        [A,E] = lpc(s_w, P);            %用线性预测法计算P个预测系数
                                        % A是预测系数，E会被用来计算合成激励的能量

        if n == 27
        % (3) 在此位置写程序，观察预测系统的零极点图
            figure,zplane(A);
        end
        
        s_f = s((n-1)*FL+1:n*FL);       % 本帧语音，下面就要对它做处理

        % (4) 在此位置写程序，用filter函数s_f计算激励，注意保持滤波器状态
        [exc_1,zf]=filter(A,1,s_f,zi_pre);
        zi_pre = zf;
        
        % exc((n-1)*FL+1:n*FL) = ... 将你计算得到的激励写在这里
        exc((n-1)*FL+1:n*FL) = exc_1;
        
        % (5) 在此位置写程序，用filter函数和exc重建语音，注意保持滤波器状态
        [s_r,zf_rec] = filter(1,A,exc_1,zi_rec);
        zi_rec = zf_rec;
        
        % s_rec((n-1)*FL+1:n*FL) = ... 将你计算得到的重建语音写在这里
        s_rec((n-1)*FL+1:n*FL) = s_r;
        
        % 注意下面只有在得到exc后才会计算正确
        s_Pitch = exc(n*FL-222:n*FL);
        PT = findpitch(s_Pitch);    % 计算基音周期PT（不要求掌握）
        G = sqrt(E*PT);           % 计算合成激励的能量G（不要求掌握）

        
        % (10) 在此位置写程序，生成合成激励，并用激励和filter函数产生合成语音
        for i = (n-1)*FL+1:n*FL
            exc_syn(i) = (mod(i,PT)==0)*G;
        end
        [s_syn1,zf_s] = filter(1,A,exc_syn((n-1)*FL+1:n*FL),zi_s);
        zi_s = zf_s;
        s_syn((n-1)*FL+1:n*FL) = s_syn1;
        
        % exc_syn((n-1)*FL+1:n*FL) = ... 将你计算得到的合成激励写在这里
        % s_syn((n-1)*FL+1:n*FL) = ...   将你计算得到的合成语音写在这里

        % (11) 不改变基音周期和预测系数，将合成激励的长度增加一倍，再作为filter
        % 的输入得到新的合成语音，听一听是不是速度变慢了，但音调没有变。
        
        for i = (n-1)*FL_v+1:n*FL_v
            exc_syn_v(i) = (mod(i,PT)==0)*G;
        end
        [s_syn2,zf_s_v] = filter(1,A,exc_syn_v((n-1)*FL_v+1:n*FL_v),zi_s_v);
        zi_s_v = zf_s_v;
        s_syn_v((n-1)*FL_v+1:n*FL_v) = s_syn2;
        
        % exc_syn_v((n-1)*FL_v+1:n*FL_v) = ... 将你计算得到的加长合成激励写在这里
        % s_syn_v((n-1)*FL_v+1:n*FL_v) = ...   将你计算得到的加长合成语音写在这里
        
        % (13) 将基音周期减小一半，将共振峰频率增加150Hz，重新合成语音，听听是啥感受～
        PT_t = floor(PT/2);
        for i = (n-1)*FL+1:n*FL
            exc_syn_t(i) = (mod(i,PT_t)==0)*G;
        end
        [z,p,k]=tf2zp(1,A);
        a = angle(p);
        for i = 1:length(p)
            if(a(i)>0)
                p_t(i) = p(i)*exp(2*pi*1j*150/8000);
            else
                p_t(i) = p(i)*exp(-2*pi*1j*150/8000);
            end
        end
        [e_cvt,s_cvt] = zp2tf(z,p_t,k);
        [s_syn3, zf_s_t] = filter(e_cvt,s_cvt,exc_syn_t((n-1)*FL+1:n*FL),zi_s_t);
        zi_s_t = zf_s_t;
        s_syn_t((n-1)*FL+1:n*FL) = s_syn3;
        
        
        % exc_syn_t((n-1)*FL+1:n*FL) = ... 将你计算得到的变调合成激励写在这里
        % s_syn_t((n-1)*FL+1:n*FL) = ...   将你计算得到的变调合成语音写在这里
        
    end

    % (6) 在此位置写程序，听一听 s ，exc 和 s_rec 有何区别，解释这种区别
    % 后面听语音的题目也都可以在这里写，不再做特别注明
    sound (s/max(s),8000);
    sound (exc/max(exc),8000);
    sound (s_rec/max(s_rec),8000);
    sound(s_syn/max(abs(s_syn)));
    %sound(s_syn_v/max(s_syn_v),8000);
    %sound(s_syn_t/max(abs(s_syn_t)),8000);
    
    figure
    subplot(3,1,1),plot(s),title('s');
    subplot(3,1,2),plot(s_rec),title('s_rec');
    subplot(3,1,3),plot(exc),title('exc');
    subplot(3,1,1),plot(s_syn),title('s_syn');
    subplot(3,1,2),plot(s_syn_v),title('s_syn_v');
    subplot(3,1,3),plot(s_syn_t),title('s_syn_t');
    
    % (7) ）生成一个8kHz 抽样的持续1 秒钟的数字信号，该信号是一个频率为200Hz 的单
    %位样值\串"，用sound 试听这个声音信号。再生成一个300Hz 的单
    %位样值\串"并试听，有何区别？事实上，这个信号将是后面要用到的以基音为周期的人工
    %激励信号e(n)
    Fs = 8000;
    Ns1 = 200;
    Ns2 = 300;
    t = 0:1:Fs-1;
    N1 = Fs/Ns1;
    N2 = floor(Fs/Ns2);
    x1=(mod(t,N1) == 0);
    x2=(mod(t,N2) == 0);

    figure
    subplot(2,1,1),plot(x1),title('200Hz');
    subplot(2,1,2),plot(x2),title('300Hz');
    %sound(double(x1),8000);
    %sound(double(x2),8000);
    
    % (8) 真实语音信号的基音周期总是随着时间变化的。我们首先将信号分成若干个10
    %毫秒长的段，假设每个段内基音周期固定不变，但段和段之间则不同，具体为
    %PT = 80 + 5mod(m; 50)
    %其中PT 表示基音周期，m 表示段序号。生成1 秒钟的上述信号并试听。
    e = zeros(1,Fs);
    n=1;
    while n <=8000
        e(n) =1;
        m = floor(n/80);
        PT = 80+5*mod(m,50);
        n = n+PT;
    end
 %   sound(e);
    %figure,plot(e);
    %（9）用?lter 将（8）中的激励信号e(n) 输入到（1）的系统中计算输出s(n) ，试听和
    %e(n) 有何区别
    b = [1];
    a = [1,-1.3789,0.9506];
    s = filter(b,a,e);
%    sound(s);
    %figure,plot(s)
    
    % 保存所有文件
    writespeech('exc.pcm',exc);
    writespeech('rec.pcm',s_rec);
    writespeech('exc_syn.pcm',exc_syn);
    writespeech('syn.pcm',s_syn);
    writespeech('exc_syn_t.pcm',exc_syn_t);
    writespeech('syn_t.pcm',s_syn_t);
    writespeech('exc_syn_v.pcm',exc_syn_v);
    writespeech('syn_v.pcm',s_syn_v);
return

% 从PCM文件中读入语音
function s = readspeech(filename, L)
    fid = fopen(filename, 'r');
    s = fread(fid, L, 'int16');
    fclose(fid);
return

% 写语音到PCM文件中
function writespeech(filename,s)
    fid = fopen(filename,'w');
    fwrite(fid, s, 'int16');
    fclose(fid);
return

% 计算一段语音的基音周期，不要求掌握
function PT = findpitch(s)
[B, A] = butter(5, 700/4000);
s = filter(B,A,s);
R = zeros(143,1);
for k=1:143
    R(k) = s(144:223)'*s(144-k:223-k);
end
[R1,T1] = max(R(80:143));
T1 = T1 + 79;
R1 = R1/(norm(s(144-T1:223-T1))+1);
[R2,T2] = max(R(40:79));
T2 = T2 + 39;
R2 = R2/(norm(s(144-T2:223-T2))+1);
[R3,T3] = max(R(20:39));
T3 = T3 + 19;
R3 = R3/(norm(s(144-T3:223-T3))+1);
Top = T1;
Rop = R1;
if R2 >= 0.85*Rop
    Rop = R2;
    Top = T2;
end
if R3 > 0.85*Rop
    Rop = R3;
    Top = T3;
end
PT = Top;
return

