base_path = [fileparts(which('mot_realtime01.m')) filesep];
cd(base_path);

SUBJECT = 19;
SVEC = [12:15 18];

NUM_TASK_RUNS = 3;
% orientation session
SETUP = 1; % stimulus assignment 
FAMILIARIZE = SETUP + 1; % rsvp study learn associates 2
TOCRITERION1 = FAMILIARIZE + 1; % rsvp train to critereon 3
MOT_PRACTICE = TOCRITERION1 + 1;%4
MOT_PREP = MOT_PRACTICE + 1;%5

% day 1
FAMILIARIZE2 = MOT_PREP + 2; % rsvp study learn associates %7
TOCRITERION2 = FAMILIARIZE2 + 1; % rsvp train to critereon
TOCRITERION2_REP = TOCRITERION2 + 1;
RSVP = TOCRITERION2_REP + 1; % rsvp train to critereon

% day 2
SCAN_PREP = RSVP + 2;
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

%% first practice set
mot_realtime01b(SUBJECT, 4, [], 0, 0);

%for testing
%mot_realtime01b(SUBJECT,TOCRITERION1,[],0,0);
% this will continue to train test and practice MOT, then move on to
% MOT_Practice, MOT_PREP
s2 = findMatch(SUBJECT,SVEC);
% TESTING TAKE OUT
%mot_realtime01b(SUBJECT,RECALL2, 1, 0, 0,s2); %continue because want to not go through the break

mot_realtime01b(SUBJECT, FAMILIARIZE2, [], 0, 0,s2); %continue because want to not go through the break

%% now train on actual stimulus pairs
mot_realtime01b(SUBJECT, FAMILIARIZE2, [], 0, 0);

%% after scanner, test associates
s2 = findMatch(SUBJECT,SVEC)

mot_realtime01b(SUBJECT,ASSOCIATES, [], 0, 0,s2);