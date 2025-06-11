Vbmax = 100;    % Maximum buffer volume
Vfmax = 5;      % Maximum flow rate
Vhb = 2;        % Buffer inflow rate (assuming Vhb is intended as V̇_hb)

numerical_time = out.yout{1}.Values.Time; % Time points from Simulink
numerical_Vb = out.yout{1}.Values.Data * 100;   % Numerical solution values

Vb_t = (-Vbmax * Vhb / Vfmax) * exp(-Vfmax / Vbmax * numerical_time) + Vbmax * Vhb / Vfmax;
error = Vb_t - numerical_Vb;

figure;
subplot(2, 1, 1);
plot(numerical_time, Vb_t, 'b-', 'LineWidth', 2);
hold on;

plot(numerical_time, numerical_Vb, 'r--', 'LineWidth', 2);
hold off;
xlabel('Time (t)');
ylabel('Buffer Volume V_b(t)');
title('Comparison of Analytical and Numerical Solutions');
set(gca, 'FontSize', 12);
legend({'Analytical', 'Numerical'}, 'Location', 'best', 'FontSize', 10);

subplot(2, 1, 2);
plot(numerical_time, error, 'k-', 'LineWidth', 2);
xlabel('Time (t)');
ylabel('Error (Analytical - Numerical)');
title('Error Between Analytical and Numerical Solutions');
set(gca, 'FontSize', 12);