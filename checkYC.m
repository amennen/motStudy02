% check yoking--created to make sure that things are okay
svec = 8:14;
s1 = 200; %this is the YC subject
s2 = findMatch(s1,svec);

base_path = [fileparts(which('mot_realtime01.m')) filesep];
s1_dir = fullfile(base_path, 'BehavioralData', num2str(s1));
s2_dir = fullfile(base_path, 'BehavioralData', num2str(s2));

%% check stimulus assignments

fname = findNewestFile(s1_dir,fullfile(s1_dir, ['mot_realtime01_' 'subj_' num2str(s1) '_stimAssignment'  '*.mat']));
s1_stim = load(fname);

fname = findNewestFile(s2_dir,fullfile(s2_dir, ['mot_realtime01_' 'subj_' num2str(s2) '_stimAssignment'  '*.mat']));
s2_stim = load(fname);

IDX = find(cellfun(@isequal,s2_stim.preparedCues, s1_stim.preparedCues)); %this should be everything except 21-28!
IDX = find(cellfun(@isequal,s2_stim.pics, s1_stim.pics))

s1_stim.pics(21:28); %these should all be in the 00's
s1_stim.preparedCues(21:28); %these should be only the training words

%% check familiarization matches familiarize2

SESSION = 7;


fname = findNewestFile(s1_dir,fullfile(s1_dir, ['mot_realtime01_' num2str(s1) '_' num2str(SESSION)  '*.mat']));
s1_f = load(fname);

fname = findNewestFile(s2_dir,fullfile(s2_dir, ['mot_realtime01_' num2str(s2) '_' num2str(SESSION)  '*.mat']));
s2_f = load(fname);

IDX = find(cellfun(@isequal,s1_f.stim.stim, s2_f.stim.stim)); %this should be ALL
IDX = find(cellfun(@isequal,s1_f.stim.picStim, s2_f.stim.picStim)); %this should be ALL


%% check to criterion matches

SESSION = 8;
fname = findNewestFile(s1_dir,fullfile(s1_dir, ['mot_realtime01_' num2str(s1) '_' num2str(SESSION)  '*.mat']));
s1_f = load(fname);

fname = findNewestFile(s2_dir,fullfile(s2_dir, ['mot_realtime01_' num2str(s2) '_' num2str(SESSION)  '*.mat']));
s2_f = load(fname);

% so for the first 20 trials, should be the same picture and associate

IDXw = find(cellfun(@isequal,s1_f.stim.stim(1:20), s2_f.stim.stim(1:20))) %this should be ALL
IDXp = find(cellfun(@isequal,s1_f.stim.associate(1:20), s2_f.stim.associate(1:20))) %this should be ALL

c = isequal(s1_f.stim.choicePos(1:20,:),s2_f.stim.choicePos(1:20,:))

%% check to see if RSVP is working!

SESSION = 10;

fname = findNewestFile(s1_dir,fullfile(s1_dir, ['mot_realtime01_' num2str(s1) '_' num2str(SESSION)  '*.mat']));
s1_f = load(fname);
fname = findNewestFile(s1_dir,fullfile(s1_dir, ['EK' num2str(SESSION)  '*.mat']));
s1_ek = load(fname);
s1_trials = table2cell(s1_ek.datastruct.trials);
s1_id = cell2mat(s1_trials(:,8));
s1_dur = cell2mat(s1_trials(:,20));

fname = findNewestFile(s2_dir,fullfile(s2_dir, ['mot_realtime01_' num2str(s2) '_' num2str(SESSION)  '*.mat']));
s2_f = load(fname);

fname = findNewestFile(s2_dir,fullfile(s2_dir, ['EK' num2str(SESSION)  '*.mat']));
s2_ek = load(fname);
s2_trials = table2cell(s2_ek.datastruct.trials);
s2_id = cell2mat(s2_trials(:,8));
s2_dur = cell2mat(s2_trials(:,20));

IDi = isequal(s1_id,s2_id)
IDd = max(abs(s1_dur - s2_dur))
abs(s1_dur - s2_dur)
