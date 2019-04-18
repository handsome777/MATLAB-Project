%压缩比
clear;
clc;
load('Jpegcodes.mat');
image = 8*legth*width;
after_process = length(AC_code)+ length(DC_code) + length(dec_cvt_bin(width))+ length(dec_cvt_bin(legth));
rate = image/after_process;
%十进制转二进制函数
function code = dec_cvt_bin(data)
data_abs = abs(data);
code_tmp = dec2bin(data_abs);
if(data >= 0)
    code = code_tmp;
else
    code = ~code_tmp;
    code = code +1;
end
end
