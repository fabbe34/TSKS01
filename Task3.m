% Define parameters
clear all;
rng(42);
N =1e5; % Number of transmitted symbols
EbN0_dB = linspace(-4, 8, 16); % Range of Eb/N0 values in dB
EbN0 = 10.^(EbN0_dB / 10); % Convert to linear scale

%% Monte carlo, hope you like my for-loop approch :)
G = [  1 0 0 0 1 0 1;  % Generator matrix
       0 1 0 0 1 1 1;
       0 0 1 0 1 1 0;
       0 0 0 1 0 1 1]; 
coderate = 4/7;
Average_packet = zeros(size(EbN0)); % Pre-set array
EcN0_dB = EbN0_dB +10*log10(coderate) ; %% Ec = Eb * coderate
EcN0 = (10.^(-EcN0_dB / 20)); %%convert to linear scale
for i = 1:length(EbN0)
    errors = 0; % Counter for symbol errors
    Emax = 1000; % Adjusting energy per codeword
    N0 = (Emax  / EbN0(i)) *EcN0(i); % Convert Eb/N0 to SNR with scaling
    for j = 1:N
        %Encoding
        message_bits = randi([0, 1], 1, 4); % Create a random message of length k=4
        codeword = mod(message_bits * G,2);% Encode the message using a Hamming [7,4,3]
        
        %creating channel   
        noise = sqrt(N0/2) * randn(size(codeword)); % Noise from AWGN, MEAN = 0, Variance = N0/2
        received_symbols =sqrt(Emax)*(1- 2 * codeword) + noise  ; %recived signal over channel
       
        %Decoding
        llr = -(4 * (received_symbols .*codeword)*sqrt(Emax)) / (N0); %LLR, equation from book
        decoded_bits = llr > 0; % Perform soft decoding
        if any(decoded_bits(1:4) ~= message_bits)  % Check if decoded bits are correct
            errors = errors + 1;
        end  
    end
    Average_packet(i) = (errors) / N; % Monte Carlo, average
end
%%  4 bits over the AWGN
nU= 4;
kU = 4;
qU= qfunc(sqrt( 2 *EbN0));
PeUncoded =1-(1-qU).^kU;

%% Coded transmission using the Hamming [7,4] code
nH= 7;
kH= 4;
qH= qfunc(sqrt(kH/nH)*sqrt( 2 *EbN0));
%PeHard = (nH *(nH-1)*qH.^2 ) /2;
PeHard =1-(1-qH).^nH - nH.*qH.*(1-qH).^(nH-1);

%% Create a semilog plot
semilogy(EbN0_dB, PeUncoded, 'o-','DisplayName', 'Uncoded');
hold on;
semilogy(EbN0_dB, PeHard,'o-', 'DisplayName', 'Hard');
semilogy(EbN0_dB, Average_packet,'o-', 'DisplayName', 'Soft');
grid on;
title('Hamming coded BPSK');
xlabel('Eb/N0 (dB)');
ylabel('Packet Error Probability');
yticks(10.^(-5:1:0));
ylim([1e-5, 1]);
legend('Location', 'southwest'); 