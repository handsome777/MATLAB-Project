clear;
clc;
load('hall.mat');
G = hall_gray;
%ѡȡһ����ͼ��
G1 = double(G(1:20,1:20));
[width,length] = size(G1);
D = zeros(width,length);
%����D
for i = 1:width
    for j = 1:length
        if i == 1
            D(i,j) = sqrt(1/width);
        else
            D(i,j) = sqrt(2/width)*cos((i-1)*pi*(2*j-1)/(2*width));
        end
    end
end
%�õ��Լ���д��DCT
trans1 = D*G1*D';
%����ϵͳ�ĺ���
trans_dct = dct2(G1);
%��������
sub = trans1 - trans_dct;

            