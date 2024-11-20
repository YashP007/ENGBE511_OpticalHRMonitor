function demodulated_signal = demodulate_signal(sampled_signal, f_modulation, f_sampling)
    % Demodulate the sampled signal to baseband
    % sampled_signal: Input signal
    % f_modulation: Known modulation frequency (Hz)
    % f_sampling: Sampling frequency (Hz)
    
    % Generate reference signals for demodulation
    t = (0:length(sampled_signal)-1) / f_sampling;
    carrier_cos = cos(2 * pi * f_modulation * t);
    carrier_sin = sin(2 * pi * f_modulation * t);

    % Multiply with reference carrier (mixing)
    mixed_cos = sampled_signal .* carrier_cos;
    mixed_sin = sampled_signal .* carrier_sin;

    % Low-pass filter for baseband recovery
    lp_filter = designfilt('lowpassiir', ...
        'FilterOrder', 8, ...
        'HalfPowerFrequency', f_modulation, ...
        'SampleRate', f_sampling);

    demodulated_cos = filter(lp_filter, mixed_cos);
    demodulated_sin = filter(lp_filter, mixed_sin);

    % Combine I and Q components
    demodulated_signal = sqrt(demodulated_cos.^2 + demodulated_sin.^2);
end
