function y = LoadVideo(video_name)

    if exist(video_name),
        display(['Loading video ' video_name]);
        vidObj = VideoReader(video_name);
    else
        display(['Video not found ']);
    end

    n_frames = vidObj.NumberOfFrames;
    frame_rate = vidObj.FrameRate;

    format short;
    fprintf('\n Total frames: %d \n', n_frames);
    fprintf('\n Frame rate: %f \n', frame_rate);

    y = zeros(n_frames, 1);

    for i = 1:n_frames
        frac = i/n_frames;
        if mod(i,10)==0
            fprintf('\n Pleas wait... %.00f%% done',100*frac);
        end
        vidFrame = read(vidObj, i);
        R_channel = vidFrame(:, :, 1);                  % Red channel
        y(i) = sum(sum(R_channel)) / (size(vidFrame, 1) * size(vidFrame, 2));
    end

    fprintf('\n Video uploaded.');
    HR_estimate(y, frame_rate);

end
