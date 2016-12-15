% analyze pre- and post- MOT recall periods (RT groups post updating only)s
clear all;
projectName = 'motStudy02';
onlyRem = 1; %if should only look at the stimuli that subject answered >1 for remembering in recall 1
onlyForg = 0;
saveNew = 0; % if we want to save classifier output results
RTgroup = 1;
YCgroup = 0;
plotDir = ['/Data1/code/' projectName '/' 'Plots' '/' ]; %should be all
%plot dir?
updated =1; %for only looking at the results recorded after making differences (minimum dot speed, increase starting speed, average over 2)
oldonly = 0;
svec = [8 12 14 15 16 18 20 22 26 27 28 30 31 32];
onlyRem = 0;
RT = [8 12 14 15 18 22 31];
YC = [16 20 26 27 28 30 32];
iRT = find(ismember(svec,RT));
iYC = find(ismember(svec,YC));

RT_m = [8 12 14 15 18 22 31];
YC_m = [16 28 20 26 27 30 32];
iRT_m = find(ismember(svec,RT_m));
%datevec = {'8-10-16', '8-27-16', '8-30-16', '9-7-16', '9-14-16','9-16-16', '9-23-16','10-4-16', '10-6-16', '10-6-16','10-13-16','10-18-16', '10-22-16', '10-26-16' , '10-28-2016'};
datevec = {'8-10-16', '8-27-16', '9-7-16', '9-14-16','9-16-16', '9-23-16','10-4-16',  '10-6-16','10-18-16', '10-22-16', '10-26-16' ,  '11-4-16', '11-4-16', '11-8-16'};

runvec = ones(1,length(svec));
runvec(find(svec==22)) = 2; %subject 22 was run 2
runvec(find(svec==30)) = 2;
% if RTgroup
%     svec = [8 12:15 18 21 22];
%     datevec = {'8-10-16', '8-27-16', '8-30-16', '9-7-16', '9-14-16', '9-23-16', '10-6-16', '10-6-16'};
%     runvec = [1 1 1 1 1 1 1 2];
% elseif YCgroup
%     svec = [16 20 24 26 27 28];
%     datevec = {'9-16-16', '10-4-16', '10-13-16', '10-18-16', '10-22-16', '10-26-16'};
%     runvec = [1 1 1 1 1 1] ;
% end
NSUB = length(svec);


nTRsperTrial = 4 %19; %changed 12/6
if length(runvec)~=length(svec)
    error('Enter in the runs AND date numbers!!')
end

for s = 1:NSUB
    subjectNum = svec(s);
    runNum = runvec(s);
    date = datevec{s};
    featureSelect = 1;
    %normally, scan num for recall 1 is 13 and recall 2 is 21
    recallScan = [13 21];
    if subjectNum == 8
        recallScan = [13 23];
    elseif subjectNum == 14
        recallScan = [17 27];
    elseif subjectNum == 18
        recallScan = [19 27];
    elseif subjectNum == 29
        recallScan = [13 23];
    end
    recallSession = [19 23];
    %date = '7-12-16';
    
    shiftTR = 2;
    
    setenv('FSLOUTPUTTYPE','NIFTI_GZ');
    save_dir = ['/Data1/code/' projectName '/data/' num2str(subjectNum) '/']; %this is where she sets the save directory!
    process_dir = ['/Data1/code/' projectName '/data/' num2str(subjectNum) '/' 'reg' '/'];
    roi_dir = ['/Data1/code/' projectName '/data/'];
    code_dir = ['/Data1/code/' projectName '/' 'code' '/']; %change to wherever code is stored
    locPatterns_dir = fullfile(save_dir, 'Localizer/');
    behavioral_dir = ['/Data1/code/' projectName '/' 'code' '/BehavioralData/' num2str(subjectNum) '/'];
    addpath(genpath(code_dir));
    %scanDate = '7-12-2016';
    subjectName = [datestr(scanDate,5) datestr(scanDate,7) datestr(scanDate,11) num2str(runNum) '_' projectName];
    dicom_dir = ['/Data1/subjects/' datestr(scanDate,10) datestr(scanDate,5) datestr(scanDate,7) '.' subjectName '.' subjectName '/'];
    
    % get recall data from subject
    clear RTorderedPat 
    clear OMITorderedPat
    for i = 1:2
        
        % only take the stimuli that they remember
        if i == 1 %if recall one check
           r = dir(fullfile(behavioral_dir, ['EK' num2str(recallSession(i)) '_' 'SUB'  '*.mat'])); 
           r = load(fullfile(behavioral_dir,r(end).name)); 
           trials = table2cell(r.datastruct.trials);
           stimID = cell2mat(trials(:,8));
           cond = cell2mat(trials(:,9));
           rating = cell2mat(trials(:,12));
           sub.hard = rating(find(cond==1));
           sub.easy = rating(find(cond==2));
           
           scanNum = recallScan(i);
           SESSION = recallSession(i);
           [~,trials,stimOrder] = GetSessionInfoRT(subjectNum,SESSION,behavioral_dir);
           
           sub.Orderhard = sub.hard(stimOrder.hard);
           sub.Ordereasy = sub.easy(stimOrder.easy);
        
           keep.hard = find(sub.Orderhard>1);
           keep.easy = find(sub.Ordereasy>1);
        
        end
        
        scanNum = recallScan(i);
        SESSION = recallSession(i);
        [patterns, t ] = RecallFileProcess(subjectNum,runNum,scanNum,SESSION,date,featureSelect,saveNew); %this will give the category sep for every TR but now we have to pull out the TR's we
        %want and their conditions
        [~,trials,stimOrder] = GetSessionInfoRT(subjectNum,SESSION,behavioral_dir);
        
        sub.Orderhard = sub.hard(stimOrder.hard);
        sub.Ordereasy = sub.easy(stimOrder.easy);
        
        
        testTrials = find(any(patterns.regressor.allCond));
        
        trialPat = patterns.raw_sm_filt_z(testTrials,:);
        trialPat = reshape(trialPat', 4, size(trialPat,2),size(trialPat,1)/4);
        
        RTorderedPat(:,:,:,i) = trialPat(:,:,stimOrder.hard);
        OMITorderedPat(:,:,:,i) = trialPat(:,:,stimOrder.easy);
        allcond = patterns.regressor.allCond(:,testTrials);
        categSep = patterns.categSep(:,union(testTrials,testTrials+shiftTR)); %all testTR's plus 2 before
        %shape by trial
        %ind = union(testTrials,testTrials+shiftTR);
        %z = reshape(ind,8,20);
        z = reshape(categSep,length(categSep)/20,20); %for 20 trials --make sure this works here!
        byTrial = z';
        RTtrials = byTrial(trials.hard,:);
        %now do in that specific order
        RTtrials = RTtrials(stimOrder.hard,:);
        OMITtrials = byTrial(trials.easy,:);
        OMITtrials = OMITtrials(stimOrder.easy,:);
        
        RTevidence(:,:,i) = RTtrials;
        OMITevidence(:,:,i) = OMITtrials;
        
    end
    nTrials = 10;
    for n = 1:nTrials
       RT1 = RTorderedPat(:,:,n,1);
       RT1 = RT1';
       RT2 = RTorderedPat(:,:,n,2);
       RT2 = RT2';
       [r,p] = corr(RT1,RT2);
       RTcorr(n) = mean(diag(r));
       OM1 = OMITorderedPat(:,:,n,1);
       OM1 = OM1';
       OM2 = OMITorderedPat(:,:,n,2);
       OM2 = OM2';
       OMcorr(n) = mean(diag(corr(OM1,OM2)));
    end
    RTavgcorr(s) = mean(RTcorr);
    OMavgcorr(s) = mean(OMcorr);
    
    % now find post - pre difference
    if onlyRem 
        PrePostRT = RTevidence(keep.hard,:,2) - RTevidence(keep.hard,:,1);
        PrePostOMIT = OMITevidence(keep.easy,:,2) - OMITevidence(keep.easy,:,1);
	RTPOSTavg(s,:) = mean(RTevidence(keep.hard,:,2));
	OMITPOSTavg(s,:) = mean(OMITevidence(keep.easy,:,2));
    elseif onlyRem == 0 && onlyForg == 0
        PrePostRT = RTevidence(:,:,2) - RTevidence(:,:,1);
        PrePostOMIT = OMITevidence(:,:,2) - OMITevidence(:,:,1);
        RTPOSTavg(s,:) = mean(RTevidence(:,:,2));
        OMITPOSTavg(s,:) = mean(OMITevidence(:,:,2)); 
    elseif onlyForg
        forg_hard = setdiff(1:size(RTevidence,1),keep.hard);
        forg_easy = setdiff(1:size(RTevidence,1),keep.easy);
        PrePostRT = RTevidence(forg_hard,:,2) - RTevidence(forg_hard,:,1);
        PrePostOMIT = OMITevidence(forg_easy,:,2) - OMITevidence(forg_easy,:,1);
        RTPOSTavg(s,:) = mean(RTevidence(forg_hard,:,2));
        OMITPOSTavg(s,:) = mean(OMITevidence(forg_easy,:,2));
    end
    RTavg(s,:) = mean(PrePostRT,1);
    OMITavg(s,:) = mean(PrePostOMIT,1);
    
end
%% do separately for pre and post RT and yoked
RTavg_RT = RTavg(iRT,:);
OMITavg_RT = OMITavg(iRT,:);
nRT = length(iRT);

h1 = figure;
%alldiffmeans = [RTavg;OMITavg];
%alldiffstd = [std(PrePostRT)/sqrt(size(PrePostRT,1)-1);std(PrePostOMIT)/sqrt(size(PrePostRT,1)-1)];
allRT = nanmean(RTavg_RT);
eRT = nanstd(RTavg_RT,[],1)/sqrt(nRT-1);
allOMIT = nanmean(OMITavg_RT);
eOMIT = nanstd(OMITavg_RT,[],1)/sqrt(nRT-1);
alldiffmeans = [allRT;allOMIT];
alldiffstd = [eRT;eOMIT];
mseb(1:nTRsperTrial,alldiffmeans, alldiffstd)
legend('Realtime', 'Omit')
title(sprintf('RT Post - Pre MOT Classifier Difference'))
set(gca, 'XTick', [1:nTRsperTrial])
%set(gca,'XTickLabel',['-2'; '-1'; ' 0'; ' 1'; ' 2'; ' 3'; ' 4'; ' 5'; '6'; '7'; '8'; '9'; ']);
ylabel('Target - Lure Evidence')
xlabel('TR (2s)')
xlim([1 8])
ylim([-.2 .2])
set(findall(gcf,'-property','FontSize'),'FontSize',16)
%line([3 3], [-1 1], 'Color', 'k', 'LineWidth', 3);
%line([6 6], [-1 1], 'Color', 'k', 'LineWidth', 3);

%xlim([1 nTRsperTrial])
%xlim([1 8])
%ylim([-.25 .25])
print(h1, sprintf('%sRTOnlyPrePost.pdf', plotDir), '-dpdf')

h1 = figure;
%alldiffmeans = [RTavg;OMITavg];
%alldiffstd = [std(PrePostRT)/sqrt(size(PrePostRT,1)-1);std(PrePostOMIT)/sqrt(size(PrePostRT,1)-1)];
allRT = nanmean(RTPOSTavg(iRT,:));
eRT = nanstd(RTPOSTavg(iRT,:),[],1)/sqrt(nRT-1);
allOMIT = nanmean(OMITPOSTavg(iRT,:));
eOMIT = nanstd(OMITPOSTavg(iRT,:),[],1)/sqrt(nRT-1);
alldiffmeans = [allRT;allOMIT];
alldiffstd = [eRT;eOMIT];
mseb(1:nTRsperTrial,alldiffmeans, alldiffstd)
legend('Realtime', 'Omit')
title(sprintf('RT Post MOT Classifier Difference'))
set(gca, 'XTick', [1:nTRsperTrial])
%set(gca,'XTickLabel',['-2'; '-1'; ' 0'; ' 1'; ' 2'; ' 3'; ' 4'; ' 5'; '6'; '7'; '8'; '9'; ']);
ylabel('Target - Lure Evidence')
xlabel('TR (2s)')
set(findall(gcf,'-property','FontSize'),'FontSize',16)
%line([3 3], [-1 1], 'Color', 'k', 'LineWidth', 3);
%line([6 6], [-1 1], 'Color', 'k', 'LineWidth', 3);

xlim([1 nTRsperTrial])
%xlim([1 8])
ylim([-.25 .25])
print(h1, sprintf('%sRTOnlyPost.pdf', plotDir), '-dpdf')
%% do separately for pre and post RT and yoked
RTavg_YC = RTavg(iYC,:);
OMITavg_YC = OMITavg(iYC,:);
nYC = length(iYC);

h1 = figure;
%alldiffmeans = [RTavg;OMITavg];
%alldiffstd = [std(PrePostRT)/sqrt(size(PrePostRT,1)-1);std(PrePostOMIT)/sqrt(size(PrePostRT,1)-1)];
allRT = nanmean(RTavg_YC);
eRT = nanstd(RTavg_YC,[],1)/sqrt(nYC-1);
allOMIT = nanmean(OMITavg_YC);
eOMIT = nanstd(OMITavg_YC,[],1)/sqrt(nYC-1);
alldiffmeans = [allRT;allOMIT];
alldiffstd = [eRT;eOMIT];
mseb(1:nTRsperTrial,alldiffmeans, alldiffstd)
legend('Realtime', 'Omit')
title(sprintf('YC Post - Pre MOT Classifier Difference'))
set(gca, 'XTick', [1:nTRsperTrial])
%set(gca,'XTickLabel',['-2'; '-1'; ' 0'; ' 1'; ' 2'; ' 3'; ' 4'; ' 5'; '6'; '7'; '8'; '9'; ']);
xlim([1 8])
ylim([-.2 .2])
ylabel('Target - Lure Evidence')
xlabel('TR (2s)')
set(findall(gcf,'-property','FontSize'),'FontSize',16)
%line([3 3], [-1 1], 'Color', 'k', 'LineWidth', 3);
%line([6 6], [-1 1], 'Color', 'k', 'LineWidth', 3);

%xlim([1 nTRsperTrial])
%xlim([1 8])
%ylim([-.25 .25])
print(h1, sprintf('%sYCOnlyPrePost.pdf', plotDir), '-dpdf')

h1 = figure;
%alldiffmeans = [RTavg;OMITavg];
%alldiffstd = [std(PrePostRT)/sqrt(size(PrePostRT,1)-1);std(PrePostOMIT)/sqrt(size(PrePostRT,1)-1)];
allRT = nanmean(RTPOSTavg(iYC,:));
eRT = nanstd(RTPOSTavg(iYC,:),[],1)/sqrt(nYC-1);
allOMIT = nanmean(OMITPOSTavg(iYC,:));
eOMIT = nanstd(OMITPOSTavg(iYC,:),[],1)/sqrt(nYC-1);
alldiffmeans = [allRT;allOMIT];
alldiffstd = [eRT;eOMIT];
mseb(1:nTRsperTrial,alldiffmeans, alldiffstd)
legend('Realtime', 'Omit')
title(sprintf('YC Post MOT Classifier Difference, n = %i',NSUB))
set(gca, 'XTick', [1:nTRsperTrial])
%set(gca,'XTickLabel',['-2'; '-1'; ' 0'; ' 1'; ' 2'; ' 3'; ' 4'; ' 5'; '6'; '7'; '8'; '9'; ']);
ylabel('Target - Lure Evidence')
xlabel('TR (2s)')
set(findall(gcf,'-property','FontSize'),'FontSize',16)
%line([3 3], [-1 1], 'Color', 'k', 'LineWidth', 3);
%line([6 6], [-1 1], 'Color', 'k', 'LineWidth', 3);

xlim([1 nTRsperTrial])
%xlim([1 8])
ylim([-.25 .25])
%print(h1, sprintf('%sRTOnlyPost.pdf', plotDir), '-dpdf')    

%% %% try to say it's because of feedback
cats = {'OM RT','MOT RT', 'Omit YC', 'RT YC'};
pl = {OMavgcorr(iRT)', RTavgcorr(iRT)', OMavgcorr(iYC)', RTavgcorr(iYC)'}
clear mp;
%[~,mp(1)] = ttest2(dsDecbySub(iRT)',dsDecbySub(iYC)');[~,mp(2)] = ttest2(dsIncbySub(iRT)',dsIncbySub(iYC)');
%ps = [mp];
yl='Avg Correlation Pre vs. Post Representation'; %y-axis label
h = figure;plotSpread(pl,'xNames',cats,'showMM',2,'yLabel',yl); %this plots the beeswarm
h=gcf;set(h,'PaperOrientation','landscape'); %these two lines grabs some attributes important for plotting significance
xt = get(gca, 'XTick');yt = get(gca, 'YTick');
%hold on;plotSig([1 3],yt,ps,0);hold off; %keep hold on and do plotSig.
%pn=[picd num2str(vers) '-' num2str(scramm) 'ChangeInPrecision'];%print(pn,'-depsc'); %print fig
%ylim([-1.25 1.25])
set(findall(gcf,'-property','FontSize'),'FontSize',16)
title('Representational Changes');
%print(h, sprintf('%sdsbeforemax.pdf', allplotDir), '-dpdf')
