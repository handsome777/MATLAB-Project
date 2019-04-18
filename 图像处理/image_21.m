clear;
clc;
load('hall.mat');
G = hall_gray;
G1 = double(G(1:20,1:20));
elim = ones(20,20)*128;
%第一种方法
cons = G1 - elim;
%第二种方法
dct2_G1 = dct2(G1);
dct2_elim = dct2(elim);
inv = idct2(dct2_G1-dct2_elim);
%两者做差
sub = cons - inv;
