Vi = 10;        % Initial volume or offset
A = 2;          % Amplitude coefficient
B = 5;          % Period scaling factor for slow oscillation
C1 = 1;         % Linear coefficient 1
C2 = 0.5;       % Linear coefficient 2

numerical_time = out.yout{1}.Values.Time; % Time points from Simulink
numerical_Vs = out.yout{1}.Values.Data;   % Numerical solution values

Vs = Vi + A*(B-1) - A*B*cos(numerical_time/B) + A*cos(numerical_time) + (C1 - C2)*numerical_time;
error = Vs - numerical_Vs;

figure;

subplot(2, 1, 1);
plot(numerical_time, Vs, 'b-', 'LineWidth', 2);
hold on;
plot(numerical_time, numerical_Vs, 'r--', 'LineWidth', 2);
hold off;
xlabel('Time (t)');
ylabel('V_s(t)');
title('Comparison of Analytical and Numerical Solutions');
set(gca, 'FontSize', 12);

legend({'Analytical', 'Numerical'}, 'Location', 'best', 'FontSize', 10);

subplot(2, 1, 2);
plot(numerical_time, error, 'k-', 'LineWidth', 2);

xlabel('Time (t)');
ylabel('Error (Analytical - Numerical)');
title('Error Between Analytical and Numerical Solutions');
set(gca, 'FontSize', 12);