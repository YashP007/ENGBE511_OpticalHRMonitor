function [t, sampled_signal, original_signal] = generate_modulated_signal(f_cut_on, f_cut_off, f_modulation, scalar, f_sampling)
    % Generate a modulated waveform for a heart rate signal.
    % f_cut_on, f_cut_off: Bandpass filter cutoff frequencies (Hz)
    % f_modulation: Modulation frequency of square wave (Hz)
    % scalar: Determines f_sampling if not explicitly provided (f_sampling = scalar * f_cut_off)
    % f_sampling: Sampling frequency, optional (defaults to scalar * f_cut_off)
    %
    % Outputs:
    %   t: Time vector
    %   sampled_signal: Modulated and filtered output
    %   original_signal: Simulated heart rate signal (baseband)
    
    if nargin < 5
        f_sampling = scalar * f_cut_off; % Sampling frequency (Hz)
    end
    
    t_end = 10; % Duration of signal (seconds)
    t = 0:1/f_sampling:t_end; % Time vector
    
    % Simulate a heart rate signal (0 to 5 Hz)
    heart_rate_freq = 1.2; % Example frequency of heartbeats (Hz)
    heart_rate_amplitude = 10; % Example amplitude of heart rate signal
    original_signal = heart_rate_amplitude * sin(2 * pi * heart_rate_freq * t) + 5*sin(pi * heart_rate_freq * t) + 20 + 15*sin(4*pi * heart_rate_freq * t);
    
    % Generate square wave modulation signal
    square_wave = square(2 * pi * f_modulation * t);
    
    % Modulate heart rate signal
    modulated_signal = original_signal .* square_wave;
    
    % Bandpass filter design
    bp_filter = designfilt('bandpassiir', ...
        'FilterOrder', 8, ...
        'HalfPowerFrequency1', f_cut_on, ...
        'HalfPowerFrequency2', f_cut_off, ...
        'SampleRate', f_sampling);

    % Apply bandpass filter
    sampled_signal = filter(bp_filter, modulated_signal);
end
