% Simulation parameters
N = 1e5; % Number of simulations
EbN0_dB = linspace(-5, 10, 16); % Range of Eb/N0 values in dB
EbN0 = 10.^(EbN0_dB / 10); % Convert to linear scale

%% Monte Carlo simulations average pe
Average_pe = zeros(size(EbN0)); % Pre-set array

for i = 1 : 16
    % Encoding
    transmitted_symbols = 2 * randi([0, 1], 1, N) - 1; % Create transmitted symbols
    
    % Channel
    N0 = 1 / (EbN0(i));
    noise = sqrt(N0/2) * randn(1, N); % Noise from AWGN, MEAN = 0, Variance = N0/2
    received_symbols = transmitted_symbols + noise; % Create the channel, received = transmitted + noise
   
    % Decoding
    detected_symbols = 2 * (received_symbols >= 0) - 1; % Implement ML detector (Maximum Likelihood)
    errors = sum(detected_symbols ~= transmitted_symbols); % Count symbol errors
    Average_pe(i) = errors / N; % Monte Carlo, average
end

%% Pe for theoretical
Pe_theoretical = qfunc(sqrt(2 * EbN0));

%% Create a semilog plot
semilogy(EbN0_dB, Pe_theoretical, '-o', 'DisplayName', 'Theoretical');
hold on; 
semilogy(EbN0_dB, Average_pe, '-o', 'DisplayName', 'Monte Carlo');
grid on;

xlabel('Eb/N0 (dB)');
ylabel('Pe');
title('Symbol Error Probability for BPSK (Theoretical vs. Monte Carlo)');

yticks(10.^(-4:1:0));
ylim([1e-4, 1]);
legend('Location', 'southwest'); 
hold off;
