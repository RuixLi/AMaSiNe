function [ tform_mat ] = transform_matrix_0822( ANGLE,rot_axis )
%UNTITLED8 이 함수의 요약 설명 위치
%   자세한 설명 위치
ANGLE=deg2rad(ANGLE);

a_x = rot_axis(1,1);
a_y = rot_axis(1,2);
a_z = rot_axis(1,3);

c = cos(ANGLE);
s = sin(ANGLE);

t1 = c + a_x^2*(1-c);
t2 = a_x*a_y*(1-c) - a_z*s;
t3 = a_x*a_z*(1-c) + a_y*s;
t4 = a_y*a_x*(1-c) + a_z*s;
t5 = c + a_y^2*(1-c);
t6 = a_y*a_z*(1-c)-a_x*s;
t7 = a_z*a_x*(1-c)-a_y*s;
t8 = a_z*a_y*(1-c)+a_x*s;
t9 = c+a_z^2*(1-c);

tform_mat = [t1 t2 t3 0
    t4 t5 t6 0
    t7 t8 t9 0
    0  0  0  1];

end

