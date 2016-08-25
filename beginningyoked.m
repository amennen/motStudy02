%read from every subject
%first get stimulus information

subjectNum = 5;
behavioral_dir = [fileparts(which('mot_realtime01.m')) '/BehavioralData/' num2str(subjectNum) '/'];
MATLAB_STIM_FILE = [behavioral_dir 'mot_realtime01_subj_' num2str(subjectNum) '_stimAssignment.mat'];
load(MATLAB_STIM_FILE)

SESSION = 4;
sessionFile = dir(fullfile(behavioral_dir, ['mot_realtime01_' num2str(subjectNum) '_' num2str(SESSION)  '*.mat']));
load(fullfile(behavioral_dir, sessionFile(end).name));
%figure out for every session, what information do we need to know to
%replicate it-- just deleete the parts where it randomizes for each person