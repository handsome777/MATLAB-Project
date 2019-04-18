clear;
clc;
syms z;
a1 = 1.3789;
a2 = -0.9506;
H = 1/(1-a1*z^-1-a2*z^-2);
a = [1 -a1 -a2];
b = 1;

N = 30;
n = 0:1:N-1;
e = (n==0);
figure
zplane(b,a);
%impz(b,a,n);
%hf = filter(b,a,e);
%stem(n,hf);
%freqz(b,a);

%(12)提高共振峰频率
[z,p,k]=tf2zp(b,a);
p_i(1)=p(1)*exp(2*pi*1j*150/8000);
p_i(2)=p(2)*exp(-2*pi*1j*150/8000);
[e,s]=zp2tf(z,p_i,k);
disp (s);
figure
subplot(1,2,1),zplane(b,a);
subplot(1,2,2),zplane(e,s);







