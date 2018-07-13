function [y, fs, bits] = record_w_matlab(time_in_seconds)

desired_rec_freq = 16e3;
recObj = audiorecorder(desired_rec_freq, 16, 1);
disp('Start speaking.');
recordblocking(recObj, time_in_seconds);
disp('End of Recording.');
y = getaudiodata(recObj);
fs = recObj.SampleRate;
bits = recObj.BitsPerSample;

end