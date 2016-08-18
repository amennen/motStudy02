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

%variables
%subjectNum = 3;
%runNum = 1;
plotDir = ['/Data1/code/' projectName '/' 'Plots' '/' ];
updated =0; %for only looking at the results recorded after making differences (minimum dot speed, increase starting speed, average over 2)
oldonly = 1;
nnew = 3;
nold = 4;
svec = [3:5 7:10];
runvec = [1 1 2 1 1 1 1];
nTRsperTrial = 19;
if length(runvec)~=length(svec)
    error('Enter in the runs AND date numbers!!')
end
datevec = {'7-12-16', '7-14-16', '7-14-16', '7-15-16', '8-10-16', '8-11-16', '8-16-16'};
if updated
    svec = svec(end-nnew +1:end);
    runvec = runvec(end-nnew +1:end);
    datevec = datevec(end-nnew +1:end);
end
if oldonly
    svec = svec(1:nold);
    runvec = runvec(1:nold);
    datevec = datevec(1:nold);
end
NSUB = length(svec);
for s = 1:NSUB
    subjectNum = svec(s);
    runNum = runvec(s);
    date = datevec{s};
    featureSelect = 1;
    %normally, scan num for recall 1 is 13 and recall 2 is 21
    recallScan = [13 21];
    if subjectNum == 8
        recallScan = [13 23];
    end
    recallSession = [19 23];
    %date = '7-12-16';
    
    shiftTR = 2;
    
    projectName = 'motStudy02';
    setenv('FSLOUTPUTTYPE','NIFTI_GZ');
    save_dir = ['/Data1/code/' projectName '/data/' num2str(subjectNum) '/']; %this is where she sets the save directory!
    process_dir = ['/Data1/code/' projectName '/data/' num2str(subjectNum) '/' 'reg' '/'];
    roi_dir = ['/Data1/code/' projectName '/data/'];
    code_dir = ['/Data1/code/' projectName '/' 'code' '/']; %change to wherever code is stored
    locPatterns_dir = fullfile(save_dir, 'Localizer/');
    behavioral_dir = ['/Data1/code/' projectName '/' 'code' '/BehavioralData/' num2str(subjectNum) '/'];
    addpath(genpath(code_dir));
    scanDate = '7-12-2016';
    subjectName = [datestr(scanDate,5) datestr(scanDate,7) datestr(scanDate,11) num2str(runNum) '_' projectName];
    dicom_dir = ['/Data1/subjects/' datestr(scanDate,10) datestr(scanDate,5) datestr(scanDate,7) '.' subjectName '.' subjectName '/'];
    
    % get recall data from subject
    for i = 1:2
        scanNum = recallScan(i);
        SESSION = recallSession(i);
        [patterns, t ] = RecallFileProcess(subjectNum,runNum,scanNum,SESSION,date,featureSelect); %this will give the category sep for every TR but now we have to pull out the TR's we
        %want and their conditions
        [~,trials,stimOrder] = GetSessionInfoRT(subjectNum,SESSION,behavioral_dir);
        testTrials = find(any(patterns.regressor.allCond));
        allcond = patterns.regressor.allCond(:,testTrials);
        categSep = patterns.categSep(:,union(testTrials,testTrials+shiftTR)); %all testTR's plus 2 before
        %shape by trial
        %ind = union(testTrials,testTrials+shiftTR);
        %z = reshape(ind,8,20);
        z = reshape(categSep,nTRsperTrial,20); %for 20 trials --make sure this works here!
        byTrial = z';
        RTtrials = byTrial(trials.hard,:);
        %now do in that specific order
        RTtrials = RTtrials(stimOrder.hard,:);
        OMITtrials = byTrial(trials.easy,:);
        OMITtrials = OMITtrials(stimOrder.easy,:);
        
        RTevidence(:,:,i) = RTtrials;
        OMITevidence(:,:,i) = OMITtrials;
        
    end
    
    % now find post - pre difference
    PrePostRT = RTevidence(:,:,2) - RTevidence(:,:,1);
    RTavg(s,:) = mean(PrePostRT,1);
    PrePostOMIT = OMITevidence(:,:,2) - OMITevidence(:,:,1);
    OMITavg(s,:) = mean(PrePostOMIT,1);
    
    
end

h1 = figure;
%alldiffmeans = [RTavg;OMITavg];
%alldiffstd = [std(PrePostRT)/sqrt(size(PrePostRT,1)-1);std(PrePostOMIT)/sqrt(size(PrePostRT,1)-1)];
allRT = mean(RTavg);
eRT = std(RTavg,[],1)/sqrt(NSUB-1);
allOMIT = mean(OMITavg);
eOMIT = std(OMITavg,[],1)/sqrt(NSUB-1);
alldiffmeans = [allRT;allOMIT];
alldiffstd = [eRT;eOMIT];
mseb(1:nTRsperTrial,alldiffmeans, alldiffstd)
legend('Realtime', 'Omit')
title(sprintf('Post - Pre MOT Classifier Difference, n = %i',NSUB))
set(gca, 'XTick', [1:nTRsperTrial])
%set(gca,'XTickLabel',['-2'; '-1'; ' 0'; ' 1'; ' 2'; ' 3'; ' 4'; ' 5'; '6'; '7'; '8'; '9'; ']);
ylabel('Target - Lure Evidence')
xlabel('TR (2s)')
set(findall(gcf,'-property','FontSize'),'FontSize',16)
%line([3 3], [-1 1], 'Color', 'k', 'LineWidth', 3);
%line([6 6], [-1 1], 'Color', 'k', 'LineWidth', 3);

xlim([1 nTRsperTrial])
ylim([-.25 .25])
print(h1, sprintf('%sresultsAllTR_old.pdf', plotDir), '-dpdf')