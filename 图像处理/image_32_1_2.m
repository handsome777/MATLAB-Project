clear;
clc;
load('hall.mat');
load('JpegCoeff.mat');
load('Jpegcodes_32_1.mat');
flag = 1;
DC_decode = [];
image = 8*legth*width;
after_process = length(AC_code)+ length(DC_code) + length(dec_cvt_bin(width))+ length(dec_cvt_bin(legth));
rate = image/after_process;

while flag <= length(DC_code)
    for i = 1:12
        len = DCTAB(i,1);
        if flag-1+len <= length(DC_code) && any(DC_code(flag:flag-1+len)-DCTAB(i,2:1+len))==0
            if i == 1
                bin = DC_code(flag+len);
                flag = flag +1+len;
            else
                bin = DC_code(flag+len:flag+len-2+i);
                flag = flag-1+i+len;
            end
            %decode
            DC_decode = [DC_decode,bin_cvt_dec(bin,i)];
            break;
        end
    end
end

for i =2:length(DC_decode)
    DC_decode(i) = DC_decode(i-1) - DC_decode(i);
end
%AC²¿·Ö
flag = 1;
num_of_block = 1;
EOB = [1,0,1,0];
ZRL = [1,1,1,1,1,1,1,1,0,0,1];
AC_decode = zeros(63,floor(width/8)*floor(legth/8));
AC_decode_m =[];
while flag <= length(AC_code)
    if flag+10 <= length(AC_code) && any(AC_code(flag:flag+10) - ZRL) == 0
        AC_decode_m = [AC_decode_m,zeros(1,16)];
        flag = flag +11;
    elseif flag+3 <= length(AC_code) && any(AC_code(flag:flag+3)-EOB) == 0
        AC_decode(1:length(AC_decode_m),num_of_block) = AC_decode_m';
        AC_decode_m = [];
        num_of_block = num_of_block +1;
        flag =flag +4;
    else
        for i = 1:160
            len = ACTAB(i,3);
            if flag-1+len <= length(AC_code) && any(AC_code(flag:flag-1+len)-ACTAB(i,4:3+len)) == 0
                Run = ACTAB(i,1);
                size = ACTAB(i,2);
                bin = AC_code(flag+len:flag+len-1+size);
                AC_decode_m = [AC_decode_m,zeros(1,Run),bin_cvt_dec(bin,size+1)];
                flag = flag+len+size;
                break;
            end
        end
    end
end

decode = [DC_decode;AC_decode];
img = zeros(width,legth);
num_o_b = 1;
for i = 1:(width/8)
    for j = 1:(legth/8)
        b = decode(:,num_o_b)';
        b = reshape(b,8,8);
        b_v = inv_zigzag(b).*QTAB;
        image((i-1)*8+1:i*8,(j-1)*8+1:j*8) = idct2(b_v);
        num_o_b = num_o_b+1;
    end
end
figure
subplot(1,2,1),imshow(uint8(hall_gray));
subplot(1,2,2),imshow(uint8(image+128));
%rate

MSE = 1/width/legth*sum(sum((double(image+128)-double(hall_gray)).^2));
PSNR = 10*log10(255^2/MSE);

re_msg = [];
for i = 1:L
    r = dec_cvt_bin(decode(1,i));
    re_msg = [re_msg,r(length(r))];
end
re_msg = reshape(re_msg,L/7,7);
msg = [];
for i = 2:L/7
    a = re_msg(i,:);
    a_dec = bin_cvt_dec(a,2);
    msg = [msg,a_dec];
end
msg_1 = char(msg);
disp(msg_1);

function r = inv_zigzag(b)
matrix_zig = [1,2,6,7,15,16,28,29;
              3,5,8,14,17,27,30,43;
              4,9,13,18,26,31,42,44;
              10,12,19,25,32,41,45,54;
              11,20,24,33,40,46,53,55;
              21,23,34,39,47,52,56,61;
              22,35,38,48,51,57,60,62;
              36,37,49,50,58,59,63,64];
r = b(matrix_zig);
end

function dec = bin_cvt_dec(bin,i)
if bin(1) == 0
    if i == 1
        bin_inv = [];
        dec = 0;
    else
        bin_inv = ~bin;
        dec = -1;
    end
else
    bin_inv = bin;
    dec = 1;
end
N = length(bin_inv);
dec_m = 0;
for i = 1:N
    dec_m = dec_m + bin_inv(i)*2^(N-i);
end
dec = dec*dec_m;
end

function bin = dec_cvt_bin(a)
bit = floor(log2(abs(a)))+1;
bit(bit == -Inf) =1;
bin = zeros(1,bit);
remain = abs(a);
num =0;
while remain ~=0
    bin(bit-num) = mod(remain,2);
    remain = floor(remain/2);
    num = num+1;
end
if a < 0
    bin = ~bin;
end
end