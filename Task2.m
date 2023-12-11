%% Simulation parameters
N = 1e5; % Number of simulations
EbN0_dB = linspace(-5, 10, 16); % Range of Eb/N0 values in dB
EbN0 = 10.^(EbN0_dB / 10); % Convert to linear scale

%% montecarlo 4-OPSK
symbols = [1, 1i, -1, -1i];% Symbol mapping
ser = zeros(size(EbN0_dB));% Initialize the array to store symbol error rates
M = 4; % modulation order

for i = 1:length(EbN0_dB)
    %Encoding
    transmitted_symbols = symbols(randi(M, 1, N));    % Generate random symbols
 
    %creating channel
    noise_variance = (1 / (2*EbN0(i)));
    noise = sqrt(noise_variance/2) * (randn(1, N) + 1i * randn(1, N)); % Noise from AWGN, MEAN = 0, Variance = N0/2
    received_symbols = transmitted_symbols + noise;%recived signal over channel
    
    %Decoding
    [~, estimated_symbols] = min(abs(received_symbols - symbols.'), [], 1); %Find the nearest symbol to the received symbols
    symbol_errors = sum(transmitted_symbols ~= symbols(estimated_symbols)); % Check if errors occurred
    ser(i) = symbol_errors / N;     % Calculate the Error  
end

%% Pe for Exact
PeExact = 2 * qfunc(sqrt(2*EbN0)) - qfunc(2*sqrt(EbN0)).^2;

%% Pe for Nearest Neighbor
PeNearest = 2*qfunc(sqrt(2* EbN0));

%% Pe for Union Bound
PeUnionBound = 2 * qfunc(sqrt(2*EbN0)) + qfunc(sqrt(4*EbN0));

%% Create a semilog plot
figure;
% First subplot for Monte Carlo results
subplot(1, 2, 1);
semilogy(EbN0_dB, ser, '-o', 'DisplayName', 'Monte Carlo');
grid on;
xlabel('Eb/N0 (dB)');
ylabel('Pe');
title('Monte Carlo Results');
legend('Location', 'southwest');

% Second subplot for theoretical and other results
subplot(1, 2, 2);
semilogy(EbN0_dB, PeExact, '-o', 'DisplayName', 'Theoretical');
hold on;
semilogy(EbN0_dB, PeNearest, '-o', 'DisplayName', 'Nearest Neighbor');
semilogy(EbN0_dB, PeUnionBound, '-o', 'DisplayName', 'Union Bound');
grid on;
xlabel('Eb/N0 (dB)');
ylabel('Pe');

yticks(10.^(-4:1:0));
ylim([1e-4, 1]);
title('Theoretical and Other Results');
legend('Location', 'southwest');
