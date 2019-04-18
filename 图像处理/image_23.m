clear;
clc;
load('hall.mat');
G = double(hall_gray);
elim = double(ones(size(G))*128);
cons = G - elim;
[width,length] = size(cons);
image_left = zeros(size(cons));
image_right = zeros(size(cons));
for i = 1:width/8
    for j = 1:length/8
        %8*8的一个小块
        test = cons((i-1)*8+1:i*8,(j-1)*8+1:j*8);
        %对原图进行DCT变化
        t_dct = dct2(test);
        %左侧清零
        t_dct_left = [zeros(8,4),t_dct(:,5:8)];
        image_left((i-1)*8+1:i*8,(j-1)*8+1:j*8) = idct2(t_dct_left);
        %右侧清零
        t_dct_right = [t_dct(:,1:4),zeros(8,4)];
        image_right((i-1)*8+1:i*8,(j-1)*8+1:j*8) = idct2(t_dct_right);
    end
end
figure
subplot(1,3,1),imshow(uint8(cons + elim));
subplot(1,3,2),imshow(uint8(image_left + elim));
subplot(1,3,3),imshow(uint8(image_right + elim));



