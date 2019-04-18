clear;
clc;
load('hall.mat');
G = double(hall_gray);
elim = double(ones(size(G))*128);
cons = G - elim;
[width,length] = size(cons);
image_trans = zeros(size(cons));
image_rot_90 = zeros(size(cons));
image_rot_180 = zeros(size(cons));
for i = 1:width/8
    for j = 1:length/8
        test = cons((i-1)*8+1:i*8,(j-1)*8+1:j*8);
        t_dct = dct2(test);
        %转置
        t_dct_trans = t_dct';
        image_trans((i-1)*8+1:i*8,(j-1)*8+1:j*8) = idct2(t_dct_trans);
        %旋转90度
        t_dct_rot_90 = rot90(t_dct);
        image_rot_90((i-1)*8+1:i*8,(j-1)*8+1:j*8) = idct2(t_dct_rot_90);
        %旋转180度
        t_dct_rot_180 = rot90(t_dct,2);
        image_rot_180((i-1)*8+1:i*8,(j-1)*8+1:j*8) = idct2(t_dct_rot_180);
    end
end
figure
subplot(2,2,1),imshow(uint8(cons + elim));
subplot(2,2,2),imshow(uint8(image_trans + elim));
subplot(2,2,3),imshow(uint8(image_rot_90 + elim));
subplot(2,2,4),imshow(uint8(image_rot_180 + elim));

