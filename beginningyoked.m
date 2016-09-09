%read from every subject
%first get stimulus information

%day 1 can't be yoked because we won't know who we're matching with who***
%figure out how we'd do the training--we'd have to have them pause for like
%5 min or train after we match (or match by demographics only)
session =3;
mot_realtime01(100,session,1,0,0)
mot_realtime01b(200,session,1,0,0,100)


fname = findNewestFile(ppt_dir2,fullfile(ppt_dir2, ['mot_realtime01_' num2str(s2) '_' num2str(SESSION)  '*.mat']));
        load(fname);

subjectNum = 5;
behavioral_dir = [fileparts(which('mot_realtime01.m')) '/BehavioralData/' num2str(subjectNum) '/'];
MATLAB_STIM_FILE = [behavioral_dir 'mot_realtime01_subj_' num2str(subjectNum) '_stimAssignment.mat'];
load(MATLAB_STIM_FILE)

SESSION = 2;
sessionFile = dir(fullfile(behavioral_dir, ['mot_realtime01_' num2str(subjectNum) '_' num2str(SESSION)  '*.mat']));
load(fullfile(behavioral_dir, sessionFile(end).name));
%figure out for every session, what information do we need to know to
%replicate it-- just deleete the parts where it randomizes for each person

%for training what do we need: stim.stim, stim.picID, stim.id and that's
%all it does so we don't need any other file
%for training you need to know EVERY PICTURE THAT'S PRESENTED

SETUP = 1; % stimulus assignment 1
FAMILIARIZE = SETUP + 1; % rsvp study learn associates 2
TOCRITERION1 = FAMILIARIZE + 1; % rsvp train to critereon 3
MOT_PRACTICE = TOCRITERION1 + 1;%4
MOT_PREP = MOT_PRACTICE + 1;%5 %going to be yoked after this


%ONLY QAY TO GET AROUND THIS IS WITH FUTURE SUBJECTA OR MATCH YOKED
%BEFOREHAND BY AGE AND GENDER
%SHIT WILL HAVE TO FIND A WAY TO MAKE SURE THAT ANY PAIRS ITS USING AREN'T
%LATER
%%%%YOKE EVERYTHING FROM HERE ON
% day 1
FAMILIARIZE2 = MOT_PREP + 2; % rsvp study learn associates %7
TOCRITERION2 = FAMILIARIZE2 + 1; % rsvp train to critereon
TOCRITERION2_REP = TOCRITERION2 + 1;
RSVP = TOCRITERION2_REP + 1; % rsvp train to critereon 10

% day 2
SCAN_PREP = RSVP + 2; %12
MOT_PRACTICE2 = SCAN_PREP + 1; %13
RECALL_PRACTICE = MOT_PRACTICE2 + 1;
%SCAN_PREP = RECALL_PRACTICE + 1;
RSVP2 = RECALL_PRACTICE + 1; % rsvp train to critereon
FAMILIARIZE3 = RSVP2 + 1; % rsvp study learn associates
TOCRITERION3 = FAMILIARIZE3 + 1; % rsvp train to critereon
MOT_LOCALIZER = TOCRITERION3 + 1; % category classification
RECALL1 = MOT_LOCALIZER + 1;
counter = RECALL1 + 1; MOT = [];
for i=1:NUM_TASK_RUNS
    MOT{i} = counter;
    counter = counter + 1;
end
RECALL2 = MOT{end} + 1; % post-scan rsvp memory test
ASSOCIATES = RECALL2 + 1;


%option: look at all the pictures/words used in the actual exp and see if
%there's enough to make the same training pairs everytime

% now for training to criterion--this is complicated--maybe the first round
% they'll get the same stimuli in the same order, but then after that they
% could either keep getting the same even after getting right/wrong or they
% could follow what they get right
SESSION = 3;
sessionFile = dir(fullfile(behavioral_dir, ['mot_realtime01_' num2str(subjectNum) '_' num2str(SESSION)  '*.mat']));
load(fullfile(behavioral_dir, sessionFile(end).name));
load(fullfile(behavioral_dir,'EK3_OB_13Jul16_1752.mat'))

SESSION = 4; %MOT so this would be under dot EK
sessionFile = dir(fullfile(behavioral_dir, ['mot_realtime01_' num2str(subjectNum) '_' num2str(SESSION)  '*.mat']));
load(fullfile(behavioral_dir, sessionFile(end).name));
%need stim.cond, stim.condString,stim.stim,stim.speed (correct for
%everythign but the realtime trials), realtime:
%stim.motionSpeed(TRcounter,n) is the speed on every TR
%still do make map with those conditions

SESSION = 5; %for recall
%use subjective dot or could just 
%need stim.stim, stim.cond, stim.condString, stim.id

%things to change: have it so they pause, and SAVE all picture orders in
%training to criterion


% not yoked:
SETUP = 1; % stimulus assignment 1
FAMILIARIZE = SETUP + 1; % rsvp study learn associates 2
TOCRITERION1 = FAMILIARIZE + 1; % rsvp train to critereon 3
MOT_PRACTICE = TOCRITERION1 + 1;%4
MOT_PREP = MOT_PRACTICE + 1;%5

% yoked
% day 1
FAMILIARIZE2 = MOT_PREP + 2; % rsvp study learn associates %7
TOCRITERION2 = FAMILIARIZE2 + 1; % rsvp train to critereon (decide how to yoke)
%option: put them in the same order for just the first and let it go from
%there (could try to keep it the same after too but then they'll get some
%wrong rt people didn't and then where to insert)
TOCRITERION2_REP = TOCRITERION2 + 1;
RSVP = TOCRITERION2_REP + 1; % rsvp train to critereon

% day 2
SCAN_PREP = RSVP + 2;
MOT_PRACTICE2 = SCAN_PREP + 1; %12
RECALL_PRACTICE = MOT_PRACTICE2 + 1;
%SCAN_PREP = RECALL_PRACTICE + 1;
RSVP2 = RECALL_PRACTICE + 1; % rsvp train to critereon
FAMILIARIZE3 = RSVP2 + 1; % rsvp study learn associates
TOCRITERION3 = FAMILIARIZE3 + 1; % rsvp train to critereon
MOT_LOCALIZER = TOCRITERION3 + 1; % category classification
RECALL1 = MOT_LOCALIZER + 1;
counter = RECALL1 + 1; MOT = [];
for i=1:NUM_TASK_RUNS
    MOT{i} = counter;
    counter = counter + 1;
end
RECALL2 = MOT{end} + 1; % post-scan rsvp memory test
ASSOCIATES = RECALL2 + 1;