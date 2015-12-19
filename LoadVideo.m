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
    fprintf('\n Processing Frame Number %d/%d', i, n_frames);
    vidFrame = read(vidObj, i);
    % Considering only the red channel we obtain:
    R_channel = vidFrame(:, :, 1);
    y(i) = sum(sum(R_channel)) / (size(vidFrame, 1) * size(vidFrame, 2));
    y2(i) = mean( sum(R_channel) / (size(vidFrame, 1) * size(vidFrame, 2)));
end

fprintf('\n Signal acquired.');
fprintf('\n You can now run HR_estimate(y, %d)\n', frame_rate);

end
