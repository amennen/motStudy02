% purpose: check how different PID systems would change the dot speed-don't
% want something that is too reactive
clear all;

PID = 1;
TI = 0.25;
TD = .5;
TP = .25;

SUBJECT = 30; %experimental subject number
allDates = {'11-4-16'};
runNum = 1;
projectName = 'motStudy02';
SESSION = 20;
%allDates = {'7-1-2016' '3-26-2016', '3-29-2016', '4-1-2016', '4-27-2016', '4-29-2016', '5-05-2016'};
subjectName = [datestr(allDates{1},5) datestr(allDates{1},7) datestr(allDates{1},11) num2str(runNum) '_' projectName];
save_dir = ['/Data1/code/' projectName '/data/' num2str(SUBJECT) '/']; %this is where she sets the save directory!
documents_path = '/Data1/code/motStudy02/code/';
data_dir = fullfile(documents_path, 'BehavioralData');

ppt_dir = [data_dir filesep num2str(SUBJECT) filesep];


NUM_TASK_RUNS = 3;
% orientation session
SETUP = 1; % stimulus assignment 1
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

if SESSION >= MOT{1}
    runNum = SESSION - MOT{1} + 1;
    classOutputDir = fullfile(save_dir,['motRun' num2str(runNum)], 'classOutput/');
end

stim.maxspeed = 30;
stim.minspeed = 0.3; %changed 8/8
fileSpeed =  dir(fullfile(ppt_dir, ['mot_realtime01_' num2str(SUBJECT) '_' num2str(SESSION)  '*.mat']));
names = {fileSpeed.name};
dates = [fileSpeed.datenum];
[~,newest] = max(dates);
matlabOpenFile = [ppt_dir '/' names{newest}];
load(matlabOpenFile);

%%




base_path = [fileparts(which('mot_realtime01.m')) filesep];
load(fullfile(ppt_dir, ['SessionInfo' '_' num2str(SESSION) '.mat']));
addTR = 0;
rtData.classOutputFileLoad = nan(1,config.nTRs.perBlock + addTR);
rtData.classOutputFile = cell(1,config.nTRs.perBlock + addTR);
rtData.rtDecoding = nan(1,config.nTRs.perBlock+ addTR);
rtData.smoothRTDecoding = nan(1,config.nTRs.perBlock+ addTR);
rtData.rtDecodingFunction = nan(1,config.nTRs.perBlock+ addTR);
rtData.smoothRTDecodingFunction = nan(1,config.nTRs.perBlock+ addTR);
rtData.fileList = cell(1,config.nTRs.perBlock + addTR);
rtData.newestFile = cell(1,config.nTRs.perBlock + addTR);
% repeat
% stim.lastSpeed = nan(1,stim.num_realtime);%going to save it in a matrix of run,stimID
% stim.lastRTDecoding = nan(1,stim.num_realtime); %file 9 that's applied now
% stim.lastRTDecodingFunction = nan(1,stim.num_realtime);
mTr = 15;
stim.changeSpeed = nan(mTr,length(stim.cond));
stim.motionSpeed = nan(mTr,length(stim.cond));




%rt parameters
Scale = 100; %parameter for function
OptimalForget = 0.1;
maxIncrement = 1.25;
config.initFeedback = 0.1; %make it so there's change in speed for the first 4 TR's
config.initFunction = tancubed(config.initFeedback,Scale,OptimalForget,maxIncrement);
initFeedback = config.initFeedback;
initFunction = config.initFunction;
allMotionTRs = convertTR(timing.trig.wait,timing.plannedOnsets.motion,config.TR); %row,col = mTR,trialnumber
nTrials = 10;
for n = 1:nTrials
    error = 0;
    current_speed = 2;
    for TRcounter = 1:15
        % first look for file
        if TRcounter >= 4 %the first time we're looking is during TR 4
            thisTR = allMotionTRs(TRcounter,n); %this is the TR we're actually on KEEP THIS WAY--starts on 4, ends on 10
            fileTR = thisTR - 1; %this is what should be shown in the long arrays--for ex TR 3 found in TR 4 corresponding to TR 1 will be indexed at 3
            %thisTR = thisTR; %look forward 2 TR's
            
            allFn = dir([classOutputDir 'vol' '*']);
            dates = [allFn.datenum];
            names = {allFn.name};
            [~,newestIndex] = max(dates);
            [rtData.classOutputFileLoad(fileTR), rtData.classOutputFile{fileTR}] = GetSpecificClassOutputFile(classOutputDir,fileTR);
            if rtData.classOutputFileLoad(fileTR)
                tempStruct = load(fullfile(classOutputDir, rtData.classOutputFile{fileTR}));
                rtData.rtDecoding(fileTR) = tempStruct.classOutput;
                rtData.rtDecodingFunction(fileTR) = tancubed(rtData.rtDecoding(fileTR),Scale,OptimalForget,maxIncrement);
                
                if TRcounter > 4  %this is the second file collected
                    rtData.smoothRTDecoding(fileTR) = nanmean([rtData.rtDecoding(fileTR-1:fileTR)]);
                    rtData.smoothRTDecodingFunction(fileTR) = nanmean([rtData.rtDecodingFunction(fileTR-1:fileTR)]);
                elseif TRcounter == 4 %this is the first file collected
                    rtData.smoothRTDecoding(fileTR) = nanmean([initFeedback rtData.rtDecoding(fileTR)]);
                    rtData.smoothRTDecodingFunction(fileTR) = nanmean([initFunction rtData.rtDecodingFunction(fileTR)]);
                end
            end
             if TRcounter > 4  %we look starting in 4, but we update starting at TR 5 AND make sure that it's not nan--if it is don't change speed
                
                if PID
                    eI = TRcounter-3;
                    error(eI) = rtData.rtDecoding(fileTR) - OptimalForget;
                    if eI > 1
                        integral = trapz(error);
                        derivative = error(eI) - error(eI-1);
                    else
                        integral = 0;
                        derivative = 0;
                    end
                current_speed = current_speed + TP*error(eI) + TI*integral + TD*derivative;
                changeinspeed = rtData.rtDecodingFunction(fileTR) + TI*integral + TD*derivative;
                else
                    current_speed = current_speed + rtData.smoothRTDecodingFunction(allMotionTRs(TRcounter-2,n)); % apply in THIS TR what was from 2 TR's ago (indexed by what file it is) so file 3 will be applied at TR5!
                    changeinspeed = rtData.smoothRTDecodingFunction(allMotionTRs(TRcounter-2,n));
                
                end
                stim.changeSpeed(TRcounter,n) = changeinspeed; %speed changed ON that TR
%             else
%                 stim.changeSpeed(TRcounter,n) = 0;
%             end
            % make sure speed is between [stim.minspeed
            % stim.maxspeed] (0,30) right now
            current_speed = min([stim.maxspeed current_speed]);
            current_speed = max([stim.minspeed current_speed]);
            stim.motionSpeed(TRcounter,n) = current_speed;
             end
        end
    end
end

%% plot 
allFn = allMotionTRs - 1;
allFn = allFn(5:end,:);
allMotion = reshape(allFn, 1, numel(allFn));
changedS = stim.motionSpeed(5:end,:);
figure;
subplot(2,1,1)
plot(rtData.rtDecoding(allMotion))
hold on;
line([0 120], [OptimalForget OptimalForget], 'color', 'k', 'LineWidth', 2);
subplot(2,1,2)
plot(reshape(changedS,1,numel(changedS)));
ylim([0 30])
set(findall(gcf,'-property','FontSize'),'FontSize',16)
nTRs = 11;
for rep = 1:10
   line([rep*nTRs+.5 rep*nTRs + .5], [0 30], 'color', 'c', 'LineWidth', 1);
end

%%
%save(MATLAB_SAVE_FILE,'stim', 'timing', 'config');
