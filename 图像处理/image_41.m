clear;
clc;
L = 5;
len = 2^(3*L);
u_r = zeros(1,len);
freq = zeros(1,len);
R = zeros(1,len);
G = zeros(1,len);
B = zeros(1,len);
for i = 1:len
    bin = abs(dec2bin(i-1,3*L)-48);
    R(i) = bin2dec(num2str(bin(1:L)));
    G(i) = bin2dec(num2str(bin(L+1:L*2)));
    B(i) = bin2dec(num2str(bin(2*L+1:L*3)));
end
for i = 1:33
    pic_addr = strcat('Faces\',int2str(i),'.bmp');
    %对当前的脸进行统计识别
    face = imread(pic_addr);
    face = floor(double(face)./(256/2^L));
    [H,W,D] = size(face);
    %进行统计
    for j = 1:len
        freq(j) = sum(sum(face(:,:,1)==R(j) & face(:,:,2)==G(j) & face(:,:,3)==B(j)));
    end
    freq = freq./H./W;
    u_r = u_r + freq;
end
u_r = u_r./33;
%figure;
%plot(u_r);
u_r_5 = u_r;
save('freq_5','u_r_5')



