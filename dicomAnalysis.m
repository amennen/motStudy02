% ExpSequence: processes everything for multiple subjects in a row (not
% real time version)
motScans = [13 15 17];
motSessions = [20 21 22];
rtData = 2;
recallScans = [11 19];
recallSessions = [19 23];
NSUB = 6;
testMOT= 1;
testRecall = 0;
shiftTR = 2;
accHard = zeros(NSUB,30);
accEasy = zeros(NSUB,30);
accLure = zeros(NSUB,15);

rtHard = zeros(NSUB,30);
rtEasy = zeros(NSUB,30);
rtLure = zeros(NSUB,15);
for s = 1:NSUB
    runNum = 1;
    processNew = 1;
    crossval = 0;
    featureSelect = 1;
    %ProcessMask(s,runNum,processNew);
    %LocalizerFileProcess(s,runNum,crossval,featureSelect);
    if testMOT
        for m = 1:length(motScans)
            %[patterns,t] = RealTimeMemoryFileProcess(s,runNum,motScans(m),motSessions(m),rtData,featureSelect); %where left off: this is where you load everything, do calculations and averages outside of loop
            [~,~,~,hardSpeed(s), acc, rt] = GetSessionInfo(s,motSessions(m));
              instH = 10;
              instL = 5;
            %get accuracies
            accHard(s,(m-1)*instH +1:(m-1)*instH+1 + instH-1) = acc.hard';
            accEasy(s,(m-1)*instH +1:(m-1)*instH+1 + instH-1) = acc.easy';
            accLure(s,(m-1)*instL +1:(m-1)*instL+1 + instL-1) = acc.lure';
            
            rtHard(s,(m-1)*instH +1:(m-1)*instH+1 + instH-1) = rt.hard';
            rtEasy(s,(m-1)*instH +1:(m-1)*instH+1 + instH-1) = rt.easy';
            rtLure(s,(m-1)*instL +1:(m-1)*instL+1 + instL-1) = rt.lure';
            
%             testTrials = find(any(patterns.regressor.allCond));
%             allcond = patterns.regressor.allCond(:,testTrials);
%             %allact = patterns.activations(:,testTrials+shiftTR);
%             allact = patterns.activations(:,union(testTrials,testTrials+shiftTR));
%             hard = find(allcond(1,:));
%             easy = find(allcond(2,:));
%             lure = find(any(allcond(3:4,:)));
%             
%             trialTR = 14;
%             z =allact(1,:);
%             instH = 10;
%             instL = 5;
%             test = reshape(z',trialTR,25);
%             byTrial = test';
%             z2 = allact(2,:);
%             test2 = reshape(z2',trialTR,25);
%             byTrial2 = test2';
%             
%             alldiff= byTrial - byTrial2;
%             
%             hardDiff((m-1)*instH +1:(m-1)*instH+1 + instH-1,:,s) = alldiff(t.hard,:);
%             easyDiff((m-1)*instH +1:(m-1)*instH+1 + instH-1,:,s) = alldiff(t.easy,:);
%             lureDiff((m-1)*instL +1:(m-1)*instL +1 + instL-1,:,s) = alldiff(t.lure,:);
%             
%             
%             hardAct((m-1)*instH +1:(m-1)*instH+1 + instH-1,:,s) = byTrial(t.hard,:);
%             easyAct((m-1)*instH +1:(m-1)*instH+1 + instH-1,:,s) = byTrial(t.easy,:);
%             lureAct((m-1)*instL +1:(m-1)*instL+1 + instL-1,:,s) = byTrial(t.lure,:);
            
        end
    end
    if testRecall
        for r = 1:length(recallScans)
            [~,~,stimOrder] = GetSessionInfo(s,recallSessions(r));
            [patterns,t] = RecallFileProcess(s,runNum,recallScans(r),recallSessions(r),featureSelect);
            testTrials = find(any(patterns.regressor.allCond));
            allcond = patterns.regressor.allCond(:,testTrials);
            %allact = patterns.activations(:,testTrials+shiftTR);
            allact = patterns.activations(:,union(testTrials,testTrials+shiftTR)); %this will take 9 per trial, 2 before and can cut off wherever
            inst = 10; %how many instances in each condition
            trialTR = 9;
            z =allact(1,:);
            test = reshape(z',trialTR,30);
            byTrial = test';
            z2 = allact(2,:);
            test2 = reshape(z2',trialTR,30);
            byTrial2 = test2';
            
            alldiffRecall= byTrial - byTrial2;
            
            hardDiffR((r-1)*inst +1:(r-1)*inst+1 + inst-1,:,s) = alldiffRecall(t.hard(stimOrder.hard),:);
            easyDiffR((r-1)*inst +1:(r-1)*inst+1 + inst-1,:,s) = alldiffRecall(t.easy(stimOrder.easy),:);
            lureDiffR((r-1)*inst +1:(r-1)*inst +1 + inst-1,:,s) = alldiffRecall(t.lure(stimOrder.lure),:);
            
            hardActR((r-1)*inst +1:(r-1)*inst+1 + inst-1,:,s) = byTrial(t.hard(stimOrder.hard),:);
            easyActR((r-1)*inst +1:(r-1)*inst+1 + inst-1,:,s) = byTrial(t.easy(stimOrder.easy),:);
            lureActR((r-1)*inst +1:(r-1)*inst+1 + inst-1,:,s) = byTrial(t.lure(stimOrder.lure),:);
        end
    end
end
if testMOT
    %first take subject averages across all similar trials
    hardAvg = squeeze(mean(hardDiff,1)); %across all trials
    hardAvg = hardAvg';
    easyAvg = squeeze(mean(easyDiff,1));
    easyAvg = easyAvg';
    lureAvg = squeeze(mean(lureDiff,1));
    lureAvg = lureAvg';
    
    h1 = figure;
    alldiffmeans = [mean(hardAvg);mean(easyAvg);mean(lureAvg)];
    alldiffstd = [std(hardAvg)/sqrt(NSUB - 1);std(easyAvg)/sqrt(NSUB - 1);std(lureAvg)/sqrt(NSUB - 1)];
    mseb(1:14,alldiffmeans, alldiffstd)
    legend('Target-Hard', 'Target-Easy', 'Lure-Hard')
    title('Classifier Evidence During MOT')
   set(gca, 'XTick', [1:14])
set(gca,'XTickLabel',['-2'; '-1'; ' 0'; ' 1'; ' 2'; ' 3'; ' 4'; ' 5'; ' 6'; ' 7'; ' 8'; ' 9'; '10'; '11']); 
    ylabel('Target - Lure Evidence')
    xlabel('TR (2s)')
    set(findall(gcf,'-property','FontSize'),'FontSize',16)
    xlim([1 14])
    ylim([-.15 .15])
    filename = 'newplot1';
    print(h1,'-dpdf', filename);
    
    meansubjH = mean(hardAvg(:,3:6),2);
    EmeansubjH = std(hardAvg(:,3:6),[],2)/sqrt(size(hardAvg(:,3:6),2) - 1);
    
    h3 = figure;
    errorbar(hardSpeed,meansubjH, EmeansubjH, 'b.', 'MarkerSize', 10, 'LineWidth', 1.5);
    xlabel('Dot Speed')
    ylabel('Target-Lure Evidence')
    title('Average Recall Evidence by Dot Speed')
    set(findall(gcf,'-property','FontSize'),'FontSize',16)
    
    %now look at recall activation alone (for replicatip = polyfit(hardSpeed,bySubj',1);
    hold on;
    p = polyfit(hardSpeed,meansubjH',1);
    yfit = polyval(p,hardSpeed);
    plot(hardSpeed,yfit, '-r', 'LineWidth', 3)
    legend('Subject', 'Best Fit')
    yresid = meansubjH' - yfit;
    SSresid = sum(yresid.^2);
    SStotal = (length(meansubjH') - 1) * var(meansubjH');
    rsq = 1 - SSresid/SStotal;
    ylim([-.1 .075])
    filename = 'newplot3';
    print(h3,'-dpdf', filename);

    hardAvg = squeeze(mean(hardAct,1)); %across all trials
    hardAvg = hardAvg';
    easyAvg = squeeze(mean(easyAct,1));
    easyAvg = easyAvg';
    lureAvg = squeeze(mean(lureAct,1));
    lureAvg = lureAvg';
    figure;
    alldiffmeans = [mean(hardAvg);mean(easyAvg);mean(lureAvg)];
    alldiffstd = [std(hardAvg)/sqrt(NSUB - 1);std(easyAvg)/sqrt(NSUB - 1);std(lureAvg)/sqrt(NSUB - 1)];
    mseb(1:14,alldiffmeans, alldiffstd,[],.5)
    legend('Targ-Hard', 'Targ-Easy', 'Lure-Hard')
    title('Classifier Evidence During MOT')
    set(gca, 'XTick', [1:14])
set(gca,'XTickLabel',['-2'; '-1'; ' 0'; ' 1'; ' 2'; ' 3'; ' 4'; ' 5'; ' 6'; ' 7'; ' 8'; ' 9'; '10'; '11']); 
ylabel('Target Evidence')
    xlabel('TR (2s)')

    set(findall(gcf,'-property','FontSize'),'FontSize',16)
    xlim([1 14])
    ylim([-.15 .15])
    
    %scatter plot of hard dot speed and hard classifier evidence
    meansubjH = mean(hardAvg(:,3:6,:),2);
    EmeansubjH = std(hardAvg(:,3:6,:),[],2)/sqrt(size(hardAvg,2) - 1);
    meansubjE = mean(easyAvg,2);
    EmeansubjE = std(easyAvg,[],2)/sqrt(size(easyAvg,2) - 1);
    meansubjL = mean(lureAvg,2);
    EmeansubjL = std(lureAvg,[],2)/sqrt(size(lureAvg,2) - 1);
    
    figure;
    errorbar(hardSpeed,meansubjH, EmeansubjH, 'r.');
    hold on;
    errorbar(hardSpeed,meansubjE, EmeansubjE, 'g.');
    errorbar(hardSpeed,meansubjL, EmeansubjL, 'k.');
    xlim([14 26])
    xlabel('Hard Dot Speed')
    ylabel('Target Evidence')
    title('Dot Speed vs. Classifier Evidence by Subject')
    legend('Target-Hard', 'Target-Easy', 'Lure-Hard')
    set(findall(gcf,'-property','FontSize'),'FontSize',16)
    
    figure;
    mseb(hardSpeed',meansubjH, EmeansubjH,[], 0.5);
    
    
    % look at median between two groups
    alltrialdifferences_hard = hardDiff(:,3:6,:);
    alltrialdifferences_easy = easyDiff(:,3:6,:);
    length_vec = numel(alltrialdifferences_hard);
    vecHard = reshape(alltrialdifferences_hard,length_vec,1);
    vecEasy = reshape(alltrialdifferences_easy,length_vec,1);
    %build group names
    figure;
    boxplot([vecHard vecEasy],'Labels', {'Hard', 'Easy'}, 'Symbol', 'k+','Color', 'bc', 'MedianStyle', 'line');
    xlabel('Trial Type')
    ylabel('Target - Lure Evidence')
    title('Distribution of Classifier Evidence')
    set(findall(gcf,'-property','FontSize'),'FontSize',16)
    ylim([-1 1])
%     figure;
%     [nelements ncenters] = hist([vecHard vecEasy], [-1:.1:1]);
%     bar(ncenters,nelements/length_vec)
%     xlabel('Target - Lure Evidence')
%     xlim([-1 1])
%     ylabel('Frequency (%)')
%     title('Evidence by Each Category')
%     legend('hard', 'easy')
%     set(findall(gcf,'-property','FontSize'),'FontSize',16)

end

if testRecall
    for s = 1:NSUB
        subtractHard(:,:,s) = hardDiffR(inst+1:size(hardDiffR,1),:,s) - hardDiffR(1:inst,:,s);
        subtractEasy(:,:,s) = easyDiffR(inst+1:size(hardDiffR,1),:,s) - easyDiffR(1:inst,:,s);
        subtractLure(:,:,s) = lureDiffR(inst+1:size(lureDiffR,1),:,s) - lureDiffR(1:inst,:,s);
    end
    hardAvgR = squeeze(mean(subtractHard,1));
    hardAvgR = hardAvgR';
    easyAvgR = squeeze(mean(subtractEasy,1));
    easyAvgR = easyAvgR';
    lureAvgR = squeeze(mean(subtractLure,1));
    lureAvgR = lureAvgR';
    h2 = figure;
    alldiffmeansR = [mean(hardAvgR);mean(easyAvgR);mean(lureAvgR)];
    alldiffstdR = [std(hardAvgR)/sqrt(NSUB - 1);std(easyAvgR)/sqrt(NSUB - 1);std(lureAvgR)/sqrt(NSUB - 1)];
    mseb(1:trialTR,alldiffmeansR, alldiffstdR)
    legend('Target-Hard', 'Target-Easy', 'Omit')
    title('Classifier Evidence Post-Pre MOT')
    xlabel('TR (2s)')
    xlim([1 8])
    set(gca,'XTickLabel',['-2'; '-1'; ' 0'; ' 1'; ' 2'; ' 3'; ' 4'; ' 5'])
    ylabel('Target - Lure Evidence')
    set(findall(gcf,'-property','FontSize'),'FontSize',16)
    ylim([-.25 .25])
    filename = 'newplot2';
    print(h2, '-dpdf', filename);
    
    
    %now look at recall evidence alone for replication purposes
    for s = 1:NSUB
        subtractHard(:,:,s) = hardActR(inst+1:size(hardActR,1),:,s) - hardActR(1:inst,:,s);
        subtractEasy(:,:,s) = easyActR(inst+1:size(hardActR,1),:,s) - easyActR(1:inst,:,s);
        subtractLure(:,:,s) = lureActR(inst+1:size(lureActR,1),:,s) - lureActR(1:inst,:,s);
    end
    hardAvgR = squeeze(mean(subtractHard,1));
    hardAvgR = hardAvgR';
    easyAvgR = squeeze(mean(subtractEasy,1));
    easyAvgR = easyAvgR';
    lureAvgR = squeeze(mean(subtractLure,1));
    lureAvgR = lureAvgR';
    figure;
    alldiffmeansR = [mean(hardAvgR);mean(easyAvgR);mean(lureAvgR)];
    alldiffstdR = [std(hardAvgR)/sqrt(NSUB - 1);std(easyAvgR)/sqrt(NSUB - 1);std(lureAvgR)/sqrt(NSUB - 1)];
    mseb(1:trialTR,alldiffmeansR, alldiffstdR, [], .5)
    legend('Target-Hard', 'Target-Easy', 'Omit')
    title('Classifier Evidence Post-Pre MOT') 
    xlim([1 8])
    ylim([-.25 .25])
    xlabel('TR (2s)')
    set(gca,'XTickLabel',['-2'; '-1'; ' 0'; ' 1'; ' 2'; ' 3'; ' 4'; ' 5']); 
    
    ylabel('Target Evidence ')
    set(findall(gcf,'-property','FontSize'),'FontSize',16)
    
    %graph with dot speed
    meansubjRH = mean(hardAvgR,2);
    EmeansubjRH = std(hardAvgR,[],2)/sqrt(size(hardAvgR,2) - 1);
    meansubjRE = mean(easyAvgR,2);
    EmeansubjRE = std(easyAvgR,[],2)/sqrt(size(easyAvgR,2) - 1);
    meansubjRL = mean(lureAvgR,2);
    EmeansubjRL = std(lureAvgR,[],2)/sqrt(size(lureAvgR,2) - 1);
    
    figure;
    errorbar(hardSpeed,meansubjRH, EmeansubjRH, 'r.');
    hold on;
    errorbar(hardSpeed,meansubjRE, EmeansubjRE, 'g.');
    errorbar(hardSpeed,meansubjRL, EmeansubjRL, 'k.');
    xlim([14 26])
   
    xlabel('Hard Dot Speed')
    ylabel('R2 - R1 Difference')
    title('Dot Speed vs. Recall Evidence Difference')
    legend('Targ-Hard', 'Targ-Easy', 'Omit')
    set(findall(gcf,'-property','FontSize'),'FontSize',16)
    
    %do pre and post-recall separately
    
    hardR2 = hardDiffR(inst+1:size(hardDiffR,1),:,:);
    hardR1 = hardDiffR(1:inst,:,:);
    easyR2 = easyDiffR(inst+1:size(easyDiffR,1),:,:);
    easyR1 = easyDiffR(1:inst,:,:);
    lureR2 = lureDiffR(inst+1:size(hardDiffR,1),:,:);
    lureR1 = lureDiffR(1:inst,:,:);
    
    
    hardAvgR2 = squeeze(mean(hardR2,1));
    hardAvgR2 = hardAvgR2';
    hardAvgR1 = squeeze(mean(hardR1,1));
    hardAvgR1 = hardAvgR1';
    easyAvgR2 = squeeze(mean(easyR2,1));
    easyAvgR2 = easyAvgR2';
    easyAvgR1 = squeeze(mean(easyR1,1));
    easyAvgR1 = easyAvgR1';
    lureAvgR2 = squeeze(mean(lureR2,1));
    lureAvgR2 = lureAvgR2';
    lureAvgR1 = squeeze(mean(lureR1,1));
    lureAvgR1 = lureAvgR1';
    
    figure;
    alldiffmeansR = [mean(hardAvgR2);mean(easyAvgR2);mean(lureAvgR2)];
    alldiffstdR = [std(hardAvgR2)/sqrt(NSUB - 1);std(easyAvgR2)/sqrt(NSUB - 1);std(lureAvgR2)/sqrt(NSUB - 1)];
    mseb(1:7,alldiffmeansR, alldiffstdR)
    legend('Targ-Hard', 'Targ-Easy', 'Omit')
    title('Classifier Evidence Recall 2')
    
    ylabel('RecallEvidence ')
    set(findall(gcf,'-property','FontSize'),'FontSize',16)
    xlim([1 7])
    xlabel('TR (2s)')
    
    figure;
    alldiffmeansR = [mean(hardAvgR1);mean(easyAvgR1);mean(lureAvgR1)];
    alldiffstdR = [std(hardAvgR1)/sqrt(NSUB - 1);std(easyAvgR1)/sqrt(NSUB - 1);std(lureAvgR1)/sqrt(NSUB - 1)];
    mseb(1:7,alldiffmeansR, alldiffstdR,[], 0.5)
    legend('Targ-Hard', 'Targ-Easy', 'Omit')
    title('Classifier Evidence Recall 1')
    xlabel('TR (2s)')
    ylabel('RecallEvidence ')
    set(findall(gcf,'-property','FontSize'),'FontSize',16)
    xlim([1 7])
    
    
end

%% see if dot accuracy and RT is different across conditions
%dot tracking accuracy
avgHard = mean(accHard,2);
allAvgHard = mean(avgHard);
EallAvgHard = std(avgHard)/sqrt(NSUB - 1);
avgEasy = mean(accEasy,2);
allAvgEasy = mean(avgEasy);
EallAvgEasy = std(avgEasy)/sqrt(NSUB -1);
avgLure = mean(accLure,2);
allAvgLure = mean(avgLure);
EallAvgLure = std(avgLure)/sqrt(NSUB - 1);

figure;
errorbar(1:3,[allAvgHard allAvgEasy allAvgLure], [EallAvgHard,EallAvgEasy,EallAvgLure]);

%dot tracking reaction times
avgHard = nanmean(rtHard,2);
allAvgHard = mean(avgHard);
EallAvgHard = std(avgHard)/sqrt(NSUB - 1);
avgEasy = nanmean(rtEasy,2);
allAvgEasy = mean(avgEasy);
EallAvgEasy = std(avgEasy)/sqrt(NSUB -1);
avgLure = nanmean(rtLure,2);
allAvgLure = mean(avgLure);
EallAvgLure = std(avgLure)/sqrt(NSUB - 1);

figure;
errorbar(1:3,[allAvgHard allAvgEasy allAvgLure], [EallAvgHard,EallAvgEasy,EallAvgLure]);

% figure;
% allmeans = [mean(byTrial(t.hard,:),1);mean(byTrial(t.easy,:),1);mean(byTrial(t.lure,:),1)];
% allstd = [std(byTrial(t.hard,:)/sqrt(size(byTrial(t.hard,:),1)-1));std(byTrial(t.easy,:)/sqrt(size(byTrial(t.hard,:),1)-1));std(byTrial(t.lure,:)/sqrt(size(byTrial(t.lure,:),1)-1))];
% mseb(1:10,allmeans, allstd)
% legend('TH', 'TE', 'LH')
% title('Evidence for Recall Category')
% xlabel('TR (2s)')
% ylabel('Classifier Evidence')
% ylim([-.5 .5])
% xlim([1 10])
% set(findall(gcf,'-property','FontSize'),'FontSize',16)
%
% z =allact(2,:);
% test = reshape(z',10,25);
% byTrial = test';
%
% figure;
% allmeans = [mean(byTrial(t.hard,:),1);mean(byTrial(t.easy,:),1);mean(byTrial(t.lure,:),1)];
% allstd = [std(byTrial(t.hard,:)/sqrt(size(byTrial(t.hard,:),1)-1));std(byTrial(t.easy,:)/sqrt(size(byTrial(t.hard,:),1)-1));std(byTrial(t.lure,:)/sqrt(size(byTrial(t.lure,:),1)-1))];
% mseb(1:10,allmeans, allstd)
% legend('TH', 'TE', 'LH')
% title('Evidence for Lure Category')
% xlabel('TR (2s)')
% ylabel('Classifier Evidence')
% set(findall(gcf,'-property','FontSize'),'FontSize',16)
% xlim([1 10])
% ylim([-.5 .5])
%
% figure;
% alldiffmeans = [mean(alldiff(t.hard,:),1);mean(alldiff(t.easy,:),1);mean(alldiff(t.lure,:),1)];
% alldiffstd = [std(alldiff(t.hard,:)/sqrt(size(alldiff(t.hard,:),1)-1));std(alldiff(t.easy,:)/sqrt(size(alldiff(t.hard,:),1)-1));std(alldiff(t.lure,:)/sqrt(size(alldiff(t.lure,:),1)-1))];
% mseb(1:10,alldiffmeans, alldiffstd)
% legend('TH', 'TE', 'LH')
% title('Evidence for Lure Category')
% xlabel('TR (2s)')
% ylabel('Classifier Evidence Difference Target - Lure')
% set(findall(gcf,'-property','FontSize'),'FontSize',16)
% xlim([1 10])
% ylim([-.5 .5])