% get regressors (and selectors if want to cross validate)
% inputs are subject number, which session number, if want to cross
% validate or not
function [patterns trials stimOrder ] = GetSessionInfoRT(subjNum,SESSION,behav_dir,varargin)
%subjNum = 1;
%SESSION = 18; %for localizer

%what do we want from this function: we want to make the regressors for
%real time analysis 
%so we need conditions, stim IDs, and TR information

if SESSION == 18
    crossval = 1;
else
    crossval = 0;
end

LOC = 18;
MOT = [18 20:22]; %(can change the way the files are named in the future)
RECALL = [19 23];
MOT_PREP = 5;
MAX_SPEED = 30;
hardSpeed = nan;
acc = nan;
rt = NaN;

%load session information
while ~exist( fullfile(behav_dir, ['SessionInfo' '_' num2str(SESSION) '.mat']), 'file')
    %wait here until it makes the file
end
load(fullfile(behav_dir, ['SessionInfo' '_' num2str(SESSION)]));

if ~isempty(varargin)
    N_TRS_LOC = cell2mat(varargin);
else
    N_TRS_LOC = 15; %set to all if don't specify
end
NCOND = 4;
nTRs = config.nTRs.perBlock + 5; %includes 5 seconds at the end
if SESSION == 18 && subjNum == 16
    nTRs = nTRs + 10;
end
% get hard dot speed
fileSpeed = dir(fullfile(behav_dir, ['mot_realtime01_' num2str(subjNum) '_' num2str(MOT_PREP)  '*.mat']));
if ~isempty(fileSpeed)
    matlabOpenFile = [behav_dir '/' fileSpeed(end).name];
    lastRun = load(matlabOpenFile);
    hardSpeed = MAX_SPEED - lastRun.stim.tGuess(end);
end

VARIATIONS_MAT = zeros(NCOND,nTRs); %regressor with all four conditions
SELECTOR_XVAL = zeros(1,nTRs); %which TRs are for training and testing for cross-validation


nTrials = length(stimCond);
TH = find(stimCond==1); %for recall this is fast dot motion
TE = find(stimCond==2); %for recall this is slow dot motion
LH = find(stimCond==3); %for recall this is omit trials
LE = find(stimCond==4); %for recall there's no condition 4
trials.hard = TH;
trials.easy = TE;
trials.lure = [LH LE];
[~,stimOrder.hard] = sort(stimID(TH));
[~,stimOrder.easy] = sort(stimID(TE));
[~,stimOrder.lure] = sort(stimID(LH));

% now we have to match these to TRs to get the actual regressors
if ismember(SESSION,MOT)
    iTR.start = convertTR(timing.trig.wait,timing.plannedOnsets.motion(1,:),config.TR); %coming from the waiting point so already 10 are taken out
    if SESSION  == 18 && subjNum == 16
        iTR.start = iTR.start + 10;
    end
    if SESSION == 18
    iTR.start = iTR.start - 2;% go 2 TR's behind if plotting AFTERWARDS
    %(put back in later)--IF WANT TO GO 2 IN FRONT (if not comment out and
    %change +8 back to + 2
    end
    trialDur = timing.plannedOnsets.probe(1) - timing.plannedOnsets.motion(1,1) +8; %this was because I wanted to shift forward by 2 and see afterwards 2 TRs but
    % take out now
else
    iTR.start = convertTR(timing.trig.wait,timing.plannedOnsets.prompt,config.TR);
    %trialDur = timing.plannedOnsets.vis(1) - timing.plannedOnsets.prompt(1) +4; %added 4 to go 2 TR's ahead 
    trialDur = timing.plannedOnsets.math(1) - timing.plannedOnsets.prompt(1) + 4; %for entire recall period = 15 TR's total, then go two past
end
trialDurTR = (trialDur/config.TR) - 1; %20s/2 = 10 - 1 = 9 TRs
if SESSION == 18 && N_TRS_LOC > 0 && N_TRS_LOC < 15 %shift over a little bit more
    trialDurTR = N_TRS_LOC - 1;
end

iTR.TH = iTR.start(TH);
iTR.TE = iTR.start(TE);
iTR.LH = iTR.start(LH);
iTR.LE = iTR.start(LE);

%make matrix of target hard, target easy, lure hard, lure easy
for i=1:length(iTR.TH);
    VARIATIONS_MAT(1,iTR.TH(i):iTR.TH(i) + trialDurTR) = 1;
    SELECTOR_XVAL(iTR.TH(i):iTR.TH(i) + trialDurTR)= i;
end
for i=1:length(iTR.TE);
    VARIATIONS_MAT(2,iTR.TE(i):iTR.TE(i) + trialDurTR) = 1; %do this separely! there's no condition 
    SELECTOR_XVAL(iTR.TE(i):iTR.TE(i) + trialDurTR)= i;
end
for i=1:length(iTR.LH)
    VARIATIONS_MAT(3,iTR.LH(i):iTR.LH(i)+trialDurTR) = 1;
    SELECTOR_XVAL(iTR.LH(i):iTR.LH(i) + trialDurTR)= i;
end
for i=1:length(iTR.LE)
    VARIATIONS_MAT(4,iTR.LE(i):iTR.LE(i)+trialDurTR) = 1;
    SELECTOR_XVAL(iTR.LE(i):iTR.LE(i) + trialDurTR)= i;
end


targets = sum(VARIATIONS_MAT(1:2,:));
lures = sum(VARIATIONS_MAT(3:4,:));
patterns.regressor.allCond = VARIATIONS_MAT(:,11:end); %changed 11/9 because don't need this
REGRESSORS = [targets;lures];
patterns.regressor.twoCond = REGRESSORS(:,11:end); %get rid of first 10 TRs

patterns.selector.xval = SELECTOR_XVAL(11:end);
% make the separate selectors
if crossval
    nIterations = length(iTR.TH); %how many of each condition (8)
    for j = 1:nIterations
        allnonzero = find(patterns.selector.xval);
        thisIndex = find(patterns.selector.xval==j);
        temp = patterns.selector.xval;
        temp(allnonzero) = 1;
        temp(thisIndex) = 2;
        patterns.selector.allxval(j,:) = temp;
    end
end
end
