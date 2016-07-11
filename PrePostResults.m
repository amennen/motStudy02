% analyze pre- and post- MOT recall periods

%what we want it to do:
% - open session info (pre and post)
% - open trained model
% - open patterns from pre and post scan
% - classify and subtract to see differences
% - plot
% - eventually have this as a function for every subject where date is an
% input, so is run number

% first set filepaths and information

projectName = 'motStudy02';
setenv('FSLOUTPUTTYPE','NIFTI_GZ');
save_dir = ['/Data1/code/' projectName '/data/' num2str(subjectNum) '/']; %this is where she sets the save directory!
process_dir = ['/Data1/code/' projectName '/data/' num2str(subjectNum) '/' 'reg' '/'];
roi_dir = ['/Data1/code/' projectName '/data/'];
code_dir = ['/Data1/code/' projectName '/' 'code' '/']; %change to wherever code is stored
runHeader = fullfile(save_dir,[ 'motRun' num2str(blockNum) '/']);
lastRunHeader = fullfile(save_dir, ['motRun' num2str(blockNum-1) '/']);
locPatterns_dir = fullfile(save_dir, 'Localizer/');
behavioral_dir = ['/Data1/code/' projectName '/' 'code' '/BehavioralData/' num2str(subjectNum) '/'];
addpath(genpath(code_dir));
scanDate = '7-12-2016';
subjectName = [datestr(scanDate,5) datestr(scanDate,7) datestr(scanDate,11) num2str(runNum) '_' projectName];
dicom_dir = ['/Data1/subjects/' datestr(scanDate,10) datestr(scanDate,5) datestr(scanDate,7) '.' subjectName '.' subjectName '/'];

%variables
subjectNum = 3;
runNum = 1;
featureSelect = 1;
%normally, scan num for recall 1 is 13 and recall 2 is 21
recallScan = [13 21];
recallSession = [19 23];
date = '7-12-16';

for i = 1:2
scanNum = recallScan(i);
SESSION = recallSession(i);
[patterns, t ] = RecallFileProcess(subjectNum,runNum,scanNum,SESSION,date,featureSelect); %this will give the category sep for every TR but now we have to pull out the TR's we
%want and their conditions
[~,~,stimOrder] = GetSessionInfoRT(subjNum,SESSION,behavioral_dir);
testTrials = find(any(patterns.regressor.allCond));
allcond = patterns.regressor.allCond(:,testTrials);
categSep = patterns.categSep(:,union(testTrials,testTrials+shiftTR)); %all testTR's plus 2 before
%shape by trial
z = reshape(categSep,trialTR,20); %for 20 trials --make sure this works here!
realtime = find(allcond(1,:));
omit = find(allcond(2,:));

%now make table of all TR's we're looking for (2 before + 4 for vis + 2
%after so 8 total) (or organize by subject)
%save here!
%diffR(1,:,i) = categSep(

end

