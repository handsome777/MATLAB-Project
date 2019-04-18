%直接用标号，因为是8*8，所以这样效率比较高
clear;
clc;
load('hall.mat');
G = double(hall_gray);
elim = double(ones(size(G))*128);
cons = G - elim;
test = cons(1:8,1:8);
matrix_test = dct2(test);
matrix_zig = [1,2,9,17,10,3,4,11,18,25,33,26,19,12,5,6,13,20,27,34,41,...
              49,42,35,28,21,14,7,8,15,22,29,36,43,50,57,58,51,44,37,...
              30,23,16,24,31,38,45,52,59,60,53,46,39,32,40,47,...
              54,61,62,55,48,56,63,64];
a = reshape(matrix_test,1,64);
b = a(matrix_zig);


