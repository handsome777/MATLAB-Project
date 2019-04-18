clear;
clc;
load('hall.mat');
G = hall_gray;
secret = dec2bin(double('handsome'));
secret = [dec2bin(length(secret),7);secret];
[width,legth] = size(secret);
%写入信息
for i = 1:width
    for j = 1: legth
        m = dec2bin(G(i,j));
        m(length(m)) = secret(i,j);
        G(i,j) = uint8(bin2dec(m));
    end
end
imshow(G);
save('mima.mat','G');
%下面解码
out = [];
for i = 1:7
    m = dec2bin(G(1,i));
    m = m(length(m));
    out = [out m];
end
num = bin2dec(out);
mima = zeros(num,7);
jiema = zeros(1,num);
for i = 2:num+1
    m_2 = [];
    for j = 1:7
        m = dec2bin(G(i,j));
        m_2 = [m_2 m(length(m))];
    end
    jiema(i-1) = bin2dec(m_2);
end
disp(char(jiema));




