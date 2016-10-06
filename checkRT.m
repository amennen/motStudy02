subjectNum = 18;
projectName = 'motStudy02';
behavioral_dir = [fileparts(which('mot_realtime01.m')) '/BehavioralData/' num2str(subjectNum) '/'];
SESSION = 20;
%save_dir = ['/Data1/code/' projectName '/data/' num2str(subjectNum) '/']; %this is where she sets the save directory!
%runHeader = fullfile(save_dir,[ 'motRun' num2str(blockNum) '/']);
fileSpeed = dir(fullfile(behavioral_dir, ['mot_realtime01_' num2str(subjectNum) '_' num2str(SESSION)  '*.mat']));
names = {fileSpeed.name};
dates = [fileSpeed.datenum];
[~,newest] = max(dates);

matlabOpenFile = [behavioral_dir '/' names{newest}];
d = load(matlabOpenFile);
allSpeed = d.stim.motionSpeed; %matrix of TR's
speedVector = reshape(allSpeed,1,numel(allSpeed));
allMotionTRs = convertTR(d.timing.trig.wait,d.timing.plannedOnsets.motion,d.config.TR) ; %row,col = mTR,trialnumber
%allMotionTRs = allMotionTRs + 2;%[allMotionTRs; allMotionTRs(end,:)+1; allMotionTRs(end,:) + 2]; %add in the next 2 TR's for HDF

trial = 5; %what we care about
speed7 = allSpeed(:,trial);
TR7 = allMotionTRs(:,trial);

schange = d.stim.changeSpeed(:,trial);
EV7 = d.rtData.rtDecoding(TR7);
F = d.rtData.rtDecodingFunction(TR7);
SF = d.rtData.smoothRTDecodingFunction(TR7);

%EXAMPLE
TR7 = allMotionTRs(:,trial);
last =  d.rtData.smoothRTDecodingFunction(TR7);

