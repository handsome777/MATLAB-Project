clear;
clc;
load('JpegCoeff.mat');
load('hall.mat');
Q = QTAB;
G = double(hall_gray);
elim = double(ones(size(G))*128);
cons = G - elim;
[width,legth] = size(cons);
num_block = width*legth/64;
out = zeros(64,num_block);
line = 1;
for i = 1:width/8
    for j = 1:legth/8
        test = cons((i-1)*8+1:i*8,(j-1)*8+1:j*8);
        t_dct = dct2(test);
        t_dct_lianghua = zig_zag(round(t_dct./Q));
        out(:,line) = reshape(t_dct_lianghua,64,1);
        line = line +1;
    end
end
%结束量化，开始写入信息
secret = dec2bin(double('handsome is QYH'));
secret = [dec2bin(length(secret),7);secret];
secret = str2num(secret(:));
secret = reshape(secret,1,16*7);
[w,l] = size(secret);

for i = 1: l
    m = dec_cvt_bin(out(1,i));
    m(length(m)) = secret(i);
    out(1,i) = bin_cvt_dec(m,2);
end

%DC
a = 1;
b = [-1,1];
DC = out(1,:);
DC_t = filter(b,a,DC);
DC_t(1) = DC(1);
DC_catg = floor(1+log2(abs(DC_t)));
DC_catg(DC_catg == -Inf) = 0;
DC_code = [];
for i = 1:num_block
    len = DCTAB(DC_catg(i)+1,1);%第一列L
    DC_code = [DC_code, DCTAB(DC_catg(i)+1,2:1+len),dec_cvt_bin(DC_t(i))];
end

%AC
EOB = [1,0,1,0];
ZRL = [1,1,1,1,1,1,1,1,0,0,1];
AC_code = [];
for i = 1:num_block
    AC = out(2:64,i);
    Run = 0;
    Num_of_ZRL = 0;
    for j = 1:63
        if AC(j) == 0
            Run = Run +1;
            if Run == 16
                Num_of_ZRL =1;
                Run = 0;
            end
        else
            while Num_of_ZRL > 0
                AC_code = [AC_code, ZRL];
                Num_of_ZRL = Num_of_ZRL -1;
            end
            size = floor(log2(abs(AC(j))))+1;
            len = ACTAB(Run*10+size,3);
            AC_code = [AC_code, ACTAB(Run*10+size,4:3+len),dec_cvt_bin(AC(j))];
            Run = 0;
        end
    end
    AC_code = [AC_code,EOB];
end
L = l;
save('Jpegcodes_32_1.mat','DC_code','AC_code','width','legth','L');

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

function b = zig_zag(a)
matrix_zig = [1,2,9,17,10,3,4,11,18,25,33,26,19,12,5,6,13,20,27,34,41,...
              49,42,35,28,21,14,7,8,15,22,29,36,43,50,57,58,51,44,37,...
              30,23,16,24,31,38,45,52,59,60,53,46,39,32,40,47,...
              54,61,62,55,48,56,63,64];
m = reshape(a',1,64);
b = m(matrix_zig);
end

function dec = bin_cvt_dec(bin,m)
if bin(1) == 0
    if m == 1
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