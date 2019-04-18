clear;
clc;
load('JpegCoeff.mat');
load('hall.mat');
Q = QTAB;
G = double(hall_gray);
elim = double(ones(size(G))*128);
cons = G - 128;
[width,length] = size(cons);
num_block = width*length/64;
out = zeros(64,num_block);
line = 1;
for i = 1:width/8
    for j = 1:length/8
        test = cons((i-1)*8+1:i*8,(j-1)*8+1:j*8);
        t_dct = dct2(test);
        %进行量化和扫描
        t_dct_lianghua = zig_zag(round(t_dct./Q));
        %将量化和扫描之后的保存在矩阵的一列中
        out(:,line) = t_dct_lianghua';
        line = line +1;
    end
end

%扫描函数
function b = zig_zag(a)
matrix_zig = [1,2,9,17,10,3,4,11,18,25,33,26,19,12,5,6,13,20,27,34,41,...
              49,42,35,28,21,14,7,8,15,22,29,36,43,50,57,58,51,44,37,...
              30,23,16,24,31,38,45,52,59,60,53,46,39,32,40,47,...
              54,61,62,55,48,56,63,64];
m = reshape(a',1,64);
b = m(matrix_zig);
end







