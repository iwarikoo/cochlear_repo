% 3.1. Create a program to read these files (or some of these files) into
% Matlab and find their sampling rate.

bits = 16;

length_of_rec_using_matlab = 0; % in seconds
% Set this variable to 0 if the recording is in an already saved file and
% you want to use it.
% Set it to some non-zero positive value if you want to record a sound
% right now using Matlab. It is the number of seconds you want your
% recording to last.

if ~length_of_rec_using_matlab
    % Set appropriate file name if length_of_rec_using_matlab == 0.
    audio_filename = 'Whispering.m4a';
    [y, fs] = audioread(audio_filename);
else
    [y, fs, bits] = record_w_matlab(length_of_rec_using_matlab);
end

[fs, y] = process_sound(y, fs, bits);


%% Task 4 & 5

lo_freq = 100; % This is the lower bound of the lowest frequency band.
hi_freq = 8e3; % This is the highest bound of the highest frequency band.

N = 12; % Number of channels.

center_freqs = zeros(1,N); % This is an array which will contain the center
                           % frequencies of each frequency band.
lo_freqs = zeros(1,N); % This is an array which will contain the lower
                       % bound of each frequency band.
hi_freqs = zeros(1,N); % This is an array which will contain the higher
                       % bound of each frequency band.

for channel = 1:N
    % Loading the lower bound of the frequency band for the specified
    % channel.
    % hi_freq-40 and lo_freq+40 are used instead of hi_freq and lo_freq
    % to allow for the bandpass filter
    % with the lowest center frequency to have its lower stop frequency set
    % to lo_freq, to allow for the bandpass filter with the highest
    % center frequency to have its higher stop frequency set to hi_freq.
    lo_freqs(channel) = (hi_freq-40 - (lo_freq+40)) * (channel - 1) / N ...
        + lo_freq+40;
    
    % Loading the upper bound of the same frequency band.
    hi_freqs(channel) = lo_freqs(channel) + (hi_freq-40 - (lo_freq+40)) ...
        / N;
    
    % Loading the center frequency of the corresponding channel.
    center_freqs(channel) = (lo_freqs(channel) + hi_freqs(channel)) / 2;
end

y_channels = zeros(length(y),N); % This 2D matrix will contain the output
                                 % of each channel; each column contains a
                                 % signal; each row is a different time
                                 % value.

% Creating N band-pass filters with stop frequencies of lo_freqs - 40 and
% hi_frequs + 40; lo_freqs and hi_freqs are the cut-off frequencies; the
% first and second stop-band attenuations are 60 dB, and the band-pass
% ripple is 1 dB.
for channel = 1:N
    temp_filt = band_pass(lo_freqs(channel)-40,lo_freqs(channel), ...
        hi_freqs(channel),hi_freqs(channel)+40,60,1,60,fs);
    y_channels(:,channel) = filter(temp_filt,y);
end

% Plotting the amplitude spectrum for the original signal:
figure;hold on;
Y = fft(y);
P2 = abs(Y/length(y));
P1 = P2(1:floor(length(y)/2)+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:(length(y)/2))/length(y);
plot(f,P1);
title('Fourier Transform');
xlabel('f (Hz)');
ylabel('Amplitude');
% Plotting the amplitude spectrums of each channel (over the original
% signal's amplitude spectrum):
for channel = 1:N
    Y = fft(y_channels(:,channel));
    P2 = abs(Y/length(y_channels(:,channel)));
    P1 = P2(1:floor(length(y_channels(:,channel))/2+1));
    P1(2:end-1) = 2*P1(2:end-1);
    f = fs*(0:floor(length(y_channels(:,channel))/2)) ...
        /length(y_channels(:,channel));
    plot(f,P1);
    title('Fourier Transform');
    xlabel('f (Hz)');
    ylabel('Amplitude');
    xlim([100 8e3]);
end

%% Task 6
% Plot the output signal of the lowest and highest frequency channels.
% The lowest frequency channel is colored in orange.
figure; hold on;
time_array = (1/fs:1/fs:size(y_channels(:,1),1)/fs)';
lowest_freq_plot = subplot(2,1,1); plot(lowest_freq_plot,time_array, ...
    y_channels(:,1),'Color', [255/255,127/255,80/255]);
title('Lowest Frequency Channel');
xlabel('Time (s)'); ylabel('Amplitude');

% The highest frequency channel is colored in cyan.
highest_freq_plot = subplot(2,1,2); plot(highest_freq_plot,time_array, ...
    y_channels(:,end),'c'); title('Highest Frequency Channel');
xlabel('Time (s)'); ylabel('Amplitude');

%% Task 7
% Envelope extraction step 1: rectify the output signals of all bandpass
% filters.
y_channels_rectified = abs(y_channels);

%% Task 8
% Envelope extraction step 2: detect the envelopes of all rectified signals
% using a lowpass filter with 400 Hz cutoff. In the design of this filter,
% pay attention to the choices you have (similar to Task 4).
for channel = 1:N
    y_channels_rectified(:,channel) = filter(low_pass_for_envelope(400, ...
        100, fs), y_channels_rectified(:,channel));
end

%% Task 9
% Plot the envelope of the lowest and highest frequency channels.
figure; hold on;
time_array = (1/fs:1/fs:size(y_channels_rectified(:,1),1)/fs)';
lowest_freq_plot = subplot(2,1,1); plot(lowest_freq_plot,time_array, ...
    y_channels_rectified(:,1),'Color', [255/255,127/255,80/255]);
title('Lowest Frequency Channel Envelope');
xlabel('Time (s)'); ylabel('Amplitude');

highest_freq_plot = subplot(2,1,2); plot(highest_freq_plot,time_array, ...
    y_channels_rectified(:,end),'c');
title('Highest Frequency Channel Envelope');
xlabel('Time (s)'); ylabel('Amplitude');




%% PHASE 3

