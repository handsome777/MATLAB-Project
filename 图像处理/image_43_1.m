clear;
clc;
load('freq_3.mat');
test = imread('test3.bmp');
test = imrotate(test,270);
[H,W,D] = size(test);
v = 0.25;
L = 3;
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

A = 40;
C = 40;

for i = 1:floor(H/A)
    for j = 1:floor(W/C)
        face = test((i-1)*A+1:i*A,(j-1)*C+1:j*C,1:3);
        pre_face = face;
        face = floor(double(face)./(256/2^L));
        [H1,W1,D1] = size(face);
        for z = 1:len
            freq(z) = sum(sum(face(:,:,1)==R(z) & face(:,:,2)==G(z) & face(:,:,3)==B(z)));
        end
        freq = freq./H1./W1;
        %d = 1 - sum(sqrt(u_r_3(:).*freq(:)));
        d = 0;
        for h = 1:length(u_r_3)
            d = d + sqrt(u_r_3(h)*freq(h));
        end
        d = 1 - d;
        
        if d <= v
            
            face = pre_face;
            face(1,:,1) = 255;
            face(:,1,1) = 255;
            face(H1,:,1) = 255;
            face(:,W1,1) = 255;
            face(1,:,2) = 0;
            face(:,1,2) = 0;
            face(H1,:,2) = 0;
            face(:,H1,2) = 0;
            face(1,:,3) = 0;
            face(:,1,3) = 0;
            face(H1,:,3) = 0;
            face(:,H1,3) = 0;

            
            test((i-1)*A+1:i*A,(j-1)*C+1:j*C,1:3) = face;
        end
        
    end
end
imshow(test);
