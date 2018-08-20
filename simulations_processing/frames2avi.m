function frames2avi(Frame,FilenameOutput,n_repeat,fps)
% Save frames into avi file
% 
% Input:
%       - Frame: vector of frames (get with Frame=getframe(gcf) for example)
%       - FilenameOutput: name of the ouput file
%       - n_repeat: (default: 1) number of times the sequence is repeated
%       - fps: (default: 1) number of frames per second
%       - play: 'not' or 'yes' (default) specify if the video must be
%           played
%       - clear: 'keep' or 'clear' (default) specify if frames individual 
%         	images must be cleared or keeped

if nargin<3
    n_repeat = 1;
end
if nargin<4
    fps = 1;
end
% Create temporary folder
N_tests=length(Frame);
workingDir = 'temp';
mkdir(workingDir)
% Create temporary images
for test=1:N_tests
    saveas(Frame(test),strcat(workingDir,'\',num2str(test),'.jpg'));
end
% Write temporary images into video file
outputVideo = VideoWriter(FilenameOutput);
outputVideo.FrameRate = fps;
open(outputVideo)
for time=1:n_repeat
    for test=1:N_tests
        img = imread(strcat(workingDir,'\',num2str(test),'.jpg'));
        writeVideo(outputVideo,img)
    end
end
close(outputVideo)