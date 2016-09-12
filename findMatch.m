%function to find the yoked control match after subject finishes
%staircasing (session 5) and right before they go on to train for actual
%stimuli (session 7)

function [subject2, allSpeed] = findMatch(thisSubj,svec)

% find yoked match for subject
MOT_PREP = 5;
MAX_SPEED = 30;

%svec = 8:14;
%first go through all subjects and find their dot speeds
for s = 1:length(svec)
    subj = svec(s);
    behavioral_dir = [fileparts(which('mot_realtime01.m')) '/BehavioralData/' num2str(subj) '/'];
    fileSpeed = dir(fullfile(behavioral_dir, ['mot_realtime01_' num2str(subj) '_' num2str(MOT_PREP)  '*.mat']));
    matlabOpenFile = [behavioral_dir '/' fileSpeed(end).name];
    lastRun = load(matlabOpenFile);
    allSpeed(s) = MAX_SPEED - lastRun.stim.tGuess(end);
end

behavioral_dir = [fileparts(which('mot_realtime01.m')) '/BehavioralData/' num2str(thisSubj) '/'];
fileSpeed = dir(fullfile(behavioral_dir, ['mot_realtime01_' num2str(thisSubj) '_' num2str(MOT_PREP)  '*.mat']));
matlabOpenFile = [behavioral_dir '/' fileSpeed(end).name];
lastRun = load(matlabOpenFile);
hardSpeed = MAX_SPEED - lastRun.stim.tGuess(end);

alldiff = abs(allSpeed - hardSpeed);
[~,ind] = min(alldiff);
subject2 = svec(ind);

end

