function HR_estimate(y, frame_rate)
    
    % Band-pass FIR filter (zero-phase distortion)
    HR_hp = 0.667; HR_lp = 3.833;                       % range of interest [Hz]
    b = fir1(128, [2*(HR_hp)/frame_rate 2*(HR_lp)/frame_rate]);
    p = filtfilt(b, 1, y');
    y = p; raw_data = p;

    % Windowing
    window_length = 6;                                  % window length [s]
    shift_time = 0.5;                                   % time between consecutive estimates [s]
    num_fpw = round(window_length * frame_rate);        % integer number of frames per window [frames]
    num_fps = round(shift_time * frame_rate);           % integer number of frames in shit_time [frames]
    
    num_iter = floor((size(y, 2) - num_fpw) / num_fps);
    
    bpm = [];
    bpm_smooth = [];
    tmin_bpm = 50; tmax_bpm = 100; 

    % Processing for each window
    for i= 1:num_iter

        window_ls = (i-1)* num_fps + 1;
        y_currwind = raw_data( window_ls : window_ls + num_fpw);   % current window
        y = y_currwind .* hann(size(y_currwind, 2))';              % hanning - to reduce leakage
        F_transform = abs(fft(y));

        low_limit = floor(HR_hp * (size(y, 2) / frame_rate))+1; 
        upper_limit = ceil(HR_lp * (size(y, 2) / frame_rate))+1;
        roi = low_limit:upper_limit;

        % SUBPLOT #1 - Power Spectral Density (PSD)for each window
        figure(1);
        subplot(2, 1, 1);
        hold off;
        
        fft_plot = plot((roi-1) * (frame_rate / size(y, 2)) * 60, F_transform(roi), 'b');
        hold on;    
        axis([HR_hp*60 HR_lp*60 0 1]);
        grid on;
        xlabel('Heart Rate (BPM)'); ylabel('PSD');

        % Absolute Peak finding
        [lm, lm_posix] = findpeaks(F_transform(roi));
        [abs_max, am_posix] = max(lm);
        plot(am_posix, abs_max, 'ro');
        max_f_index = roi(lm_posix(am_posix));
        bpm(i) = (max_f_index-1) * (frame_rate / size(y, 2)) * 60;

        f_res = 1 / window_length;
        lowf = bpm(i) / 60 - 0.5 * f_res;
        freq_inc = 1 / 60;
        test_freqs = round(f_res / freq_inc);
        power = zeros(1, test_freqs);
        freqs = (0:test_freqs-1) * freq_inc + lowf;
        for h = 1:test_freqs,
            re = 0; im = 0;
            for j = 0:(size(y, 2) - 1),
                phi = 2 * pi * freqs(h) * (j / frame_rate);
                re = re + y(j+1) * cos(phi);
                im = im + y(j+1) * sin(phi);
            end
            power(h) = re * re + im * im;
        end
        [abs_max, am_posix] = max(power);
        bpm_smooth(i) = 60*freqs(am_posix);

        % SUBPLOT #2 - BPM Over The Entire Inverval
        subplot(2, 1, 2);
        t = (0:i-1) * ((size(raw_data, 2) / frame_rate) / (num_iter - 1));
        hold off;
        plot(t, bpm_smooth, 'r');
        axis([0 ((size(raw_data, 2)-1) / frame_rate) tmin_bpm tmax_bpm]);
        grid on;
        xlabel('Time [s]'); ylabel('Heart Rate [bpm]');

        drawnow();
        pause(shift_time/4);

    end
    disp(['Estimated smooth HR: ' num2str(mean(bpm)) ' bpm']);
end
