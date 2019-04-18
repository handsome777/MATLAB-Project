load('hall.mat');
C_redcycle = hall_color;
C_chess = hall_color;
G = hall_gray;
center_width = 60;
center_length = 84;

for i = 1:120
    for j = 1:168
        if((i - center_width)^2+(j - center_length)^2 <= center_width^2)
            C_redcycle(i,j,1) = 255; %红色分量
            C_redcycle(i,j,2) = 0;   %绿色分量
            C_redcycle(i,j,3) = 0;   %蓝色分量
        end
    end
end

%imshow(C_redcycle);

interrupt_width = 21;
interrupt_length = 43;
color = 0;

for i = 1:120
    for j = 1:168
        if(mod((floor(i/interrupt_width)+floor(j/interrupt_length)),2) == 0)
            C_chess(i,j,1) = 0;
            C_chess(i,j,2) = 0;
            C_chess(i,j,3) = 0;
        end
    end
end

imshow(C_chess);






