clear;
clc;
load('hall.mat');
G = hall_gray;
%选取一部分图像
G1 = double(G(1:20,1:20));
[width,length] = size(G1);
D = zeros(width,length);
%计算D
for i = 1:width
    for j = 1:length
        if i == 1
            D(i,j) = sqrt(1/width);
        else
            D(i,j) = sqrt(2/width)*cos((i-1)*pi*(2*j-1)/(2*width));
        end
    end
end
%得到自己编写的DCT
trans1 = D*G1*D';
%调用系统的函数
trans_dct = dct2(G1);
%两者做差
sub = trans1 - trans_dct;

            