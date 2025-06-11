% Pipe transport test
diameter = 1;
dP = 10e5; 
elevation = 10;
dist = 20000;

rho = 1000;
mu = 1000e-6;
g = 9.81;
dPelev = elevation * g * rho;
dPtot = dP + dPelev; % Corrected: dP is already in Pa, no need for 10^5
Vinit = 1;
Re = rho * diameter * Vinit / mu;

% Initial guess
V = 1; % Initial velocity (m/s)
tol = 1e-6; % Convergence tolerance (m/s)
maxIter = 100; % Maximum iterations

f_values = zeros(1, maxIter);
iter = 1:maxIter;

for i = 1:maxIter
    V_old = V;
    Re = rho * diameter * V / mu;
    
    if Re < 2300
        f = 64 / Re;
        disp("regime 1")
    elseif Re < 1e5
        f = 0.316 * Re^(-0.25);
        disp("regime 2")
    else
        f = 0.186 * Re^(-0.2);
        disp("regime 3")
    end
    
    f_values(i) = f;
    
    V = sqrt(2 * diameter * dPtot / (f * dist * rho));
    
    if abs(V - V_old) < tol
        f_values = f_values(1:i); 
        iter = 1:i;
        break;
    end
end

if i == maxIter
    warning('Maximum iterations reached. Solution may not have converged.');
end

Qmax = (0.5 * diameter)^2 * pi * V * 60 * 60;

figure;
plot(iter, f_values, '-o', 'LineWidth', 2, 'MarkerSize', 6);
xlabel('Iteration');
ylabel('Friction Factor (f)');
title('Convergence of Friction Factor');
grid on;