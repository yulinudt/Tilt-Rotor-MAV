function [m, I] = Mav_inertias(n, L, theta, beta)
% computes masse of a n-rotor mav
% numerical values derived from voliro (with 6 rotors) 
mm2m = 10^(-6);
%% Mass of the drone body
mb = 2.166562421*n/6; % make the drone's body mass a fct of the number of propeller

%% Inertia of the drone body
Ibody_x = 7500.003560409*n/6*mm2m; % make the drone's body inertia a fct of the number of propeller
Ibody_y = 10938.848193227*n/6*mm2m; 
Ibody_z = 13694.808991418*n/6*mm2m;
Ibody_yz = -3.882565649*n/6*mm2m;
Ibody_xz =  24.695463703*n/6*mm2m; 
Ibody_xy = -34.208492595*n/6*mm2m;
Ibody = [Ibody_x, Ibody_xy, Ibody_xz; Ibody_xy, Ibody_y, Ibody_yz; Ibody_xz, Ibody_yz, Ibody_z];

%% Mass of an arm
mtspecifict = 0.1; % [kg/m]
mt = mtspecifict*L; % mass of the tube 
mp = (0.276873455-0.03)/2; % mass of one propeller
ma = mt+ mp; % total mass of an arm

%% Inertia of an arm modeled as a tube of length L starting at the origin
r1 = 0.0045; % inner radius of the tube (measured on volro)
r2 = 0.0055; % outer radius of the tube (measured on volro)
%                                      ----^----
%                                          |                          z
%          Arm representation:        h{  |_|________________         |
%                                         |__________________    x____|
%                                          <--L/2--><--L/2--> 
Itube = [mt*(r1^2+r2^2)/2, 0 , 0; ...
        0, mt*(3*(r1^2+r2^2) + L^2)/12, 0; ...
        0, 0, mt*(3*(r1^2+r2^2) + L^2)/12]; % inertia of a tube (arm)
r = [-L/2, 0, 0].'; % distance (from the center of the tube) at which we want the Inertia tensor
Itube = Itube + mt*(norm(r)^2*eye(3)-r*r.'); % parallel axis theorem (Steiner's rule) to get inertia at (0, 0, 0)

%% Inertia of a propeller block modeled as a rectangle parallelepiped
w = 0.03; % width of the rpp               
h = 0.065; % height of the rpp         ----^----
d = 0.03; % depth of the rpp               |                         z
%                                   h/2{  | |                        |
%    Propeller block:               h/2{  |_|_______________    x____|
%                                          <------ L-------> 
Ip = [mp*(h^2+w^2)/12, 0 , 0; ...
        0, mp*((h^2+d^2))/12, 0; ...
        0, 0, mp*(3*(d^2+w^2))/12]; % inertia of a rectangle parallelepipede (propeller block)
r = [-L, 0, -h/2].'; % distance (from the center of the rect. parallel.) at which we want the Inertia tensor
Ip = Ip + mp*(norm(r)^2*eye(3)-r*r.'); % parallel axis theorem (Steiner's rule) to get inertia at (0, 0, 0)

%% calculate the total inertia for all the arms
interval = 2*pi/n; % interval between arms in normal n-copter configuration
Iarms = zeros(3,3);
for i = 1:n
    Rb = Rotz((i-1)*interval)*Rotz(theta(i))*Roty(beta(i)); % Rotation matrix of the arm orientation
    Iarms = Iarms + Rb*(Itube+Ip)*Rb.'; % Add the inertias of the propeller and the tube (in the body frame)
end

%% Total inertia and mass of the MAV
I = Ibody + Iarms;
m = n*ma + mb;
end