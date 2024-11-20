% Main script to showcase modulation and demodulation
clc;
clear;
close all;

% Parameters
f_modulation = 200; % Modulation frequency (Hz)
deltaF_interest = 10; % Hz
f_cut_on = f_modulation - deltaF_interest; % Bandpass lower cutoff frequency (Hz)
f_cut_off = f_modulation + deltaF_interest; % Bandpass upper cutoff frequency (Hz)
scalar = 10; % Sampling scalar (f_sampling = scalar * f_cut_off)

% Generate modulated signal
[t, sampled_signal, original_signal] = generate_modulated_signal(f_cut_on, f_cut_off, f_modulation, scalar);
f_sampling = scalar * f_cut_off;

% Demodulate signal
demodulated_signal = demodulate_signal(sampled_signal, f_modulation, f_sampling);

%% Plot resultsde
figure;

% Modulated Signal
subplot(3,1,1);
plot(t, sampled_signal);
title('Sampled Signal (Modulated)');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% Frequency Spectrum of Modulated Signal
subplot(3,1,2);
N = length(sampled_signal);
frequencies = (0:N-1) * (f_sampling / N);
Y = abs(fft(sampled_signal));
plot(frequencies, Y);
title('Frequency Spectrum of Sampled Signal');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;
xlim([0, f_sampling/2]);

% Demodulated Signal
subplot(3,1,3);
plot(t, demodulated_signal);
title('Demodulated Signal (Baseband)');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

%% Plotting all w. FFTs
%% Plot results
figure;

% Parameters for FFT
N_modulated = length(sampled_signal); % Length of modulated signal
N_unmodulated = length(original_signal); % Length of original signal
N_demodulated = length(demodulated_signal); % Length of demodulated signal

frequencies_modulated = (0:N_modulated-1) * (f_sampling / N_modulated); % Frequency axis
frequencies_unmodulated = (0:N_unmodulated-1) * (f_sampling / N_unmodulated); % Frequency axis
frequencies_demodulated = (0:N_demodulated-1) * (f_sampling / N_demodulated); % Frequency axis

% 1. Unmodulated Signal (Baseband) - Time Domain
subplot(3,2,1);
plot(t, original_signal);
title('Unmodulated Signal (Baseband) - Time Domain');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% 2. Unmodulated Signal (Baseband) - Frequency Domain
subplot(3,2,2);
Y_unmodulated = abs(fft(original_signal));
plot(frequencies_unmodulated, Y_unmodulated);
title('Unmodulated Signal (Baseband) - Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;
xlim([0, f_sampling/2]);

% 3. Modulated Signal - Time Domain
subplot(3,2,3);
plot(t, sampled_signal);
title('Modulated Signal - Time Domain');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% 4. Modulated Signal - Frequency Domain
subplot(3,2,4);
Y_modulated = abs(fft(sampled_signal));
plot(frequencies_modulated, Y_modulated);
title('Modulated Signal - Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;
xlim([0, f_sampling/2]);

% 5. Demodulated Signal - Time Domain
subplot(3,2,5);
stem(t(1:N_demodulated), demodulated_signal, 'filled'); % Use stem for discrete signal
title('Demodulated Signal - Time Domain');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% 6. Demodulated Signal - Frequency Domain
subplot(3,2,6);
Y_demodulated = abs(fft(demodulated_signal));
plot(frequencies_demodulated, Y_demodulated);
title('Demodulated Signal - Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;
xlim([0, f_sampling/2]);
