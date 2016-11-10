
%cross-validate only--just for checking how the classifier is doing on
%subject data after the fact! ahhh
projectName = 'motStudy02';
subvec = [8 12 14 15 16 18 20 22 26 27 28 30 31 32];
nsub = length(subvec);
featureSelect = 1;
allplotDir = ['/Data1/code/' projectName '/' 'Plots' '/' ];
keepTR = 4;
%training: cross-validation
for s = 1:nsub
    subjectNum = subvec(s);
    SESSION = 18; %localizer task
    behavioral_dir = ['/Data1/code/' projectName '/' 'code' '/BehavioralData/' num2str(subjectNum) '/'];
    loc_dir = ['/Data1/code/' projectName '/' 'data' '/' num2str(subjectNum) '/Localizer/'];
    fname = findNewestFile(loc_dir, fullfile(loc_dir, ['locpreprocpatterns' '*.mat']));
    load(fname);
    %first cross-validate
    %print xval results
    fprintf('\n*********************************************\n');
    fprintf(sprintf('beginning model cross-validation...\n for subject%i',s));
    
    %parameters
    penalty = 100;
    shiftTR = 2;
    startXVAL = tic;
    
    %first get session information
    [newpattern t] = GetSessionInfoRT(subjectNum,SESSION,behavioral_dir,keepTR); %we're only training on 4 TR's
    [tempPats tempT] = GetSessionInfoRT(subjectNum,SESSION,behavioral_dir,15);
    test_regressor = tempPats.regressor.allCond; % here it has all 15 TR's
    test_selector = tempPats.selector.allxval;
    patterns.regressor.allCond = newpattern.regressor.allCond;
    patterns.regressor.twoCond = newpattern.regressor.twoCond;
    patterns.selector.xval = newpattern.selector.xval;
    patterns.selector.allxval = newpattern.selector.allxval;
    nIter = size(patterns.selector.allxval,1);
    %shift regressor
    nCond = size(patterns.regressor.twoCond,1);
    for j = 1:nIter
        selector = patterns.selector.allxval(j,:);
        thisTestSelector = test_selector(j,:);
        %testTE = find(test_regressor(1,:));
        
        %easyIdx = find(patterns.regressor.allCond(2,:));
        %hardIdx = find(patterns.regressor.allCond(1,:));
        trainIdx = find(selector == 1);
        %trainIdx = intersect(hardIdx,trainIdx);
        testIdx = find(thisTestSelector == 2);
        
        % now shift indices forward
        %trainIdx = trainIdx + shiftTR;
        %testIdx = testIdx + shiftTR;
        
        trainPats = patterns.raw_sm_filt_z(trainIdx+shiftTR,:);
        testPats = patterns.raw_sm_filt_z(testIdx+shiftTR,:);
        trainTargs = patterns.regressor.twoCond(:,trainIdx);
        %testTargs = patterns.regressor.twoCond(:,testIdx);
        testTargs = tempPats.regressor.twoCond(:,testIdx);
        testAllCond = tempPats.regressor.allCond(:,testIdx);
        if featureSelect
            thr = 0.1;
            p = run_mathworks_anova(trainPats',trainTargs);
            sigVox = find(p<thr);
            trainPats = trainPats(:,sigVox);
            testPats = testPats(:,sigVox);
        end
        
        scratchpad = train_ridge(trainPats,trainTargs,penalty);
        [acts scratchpad] = test_ridge(testPats,testTargs,scratchpad);
        %acts is nCond x nVoxels in the mask

        %calculate AUC for JUST TARGET vs. LURE
%         for i = 1:length(acts)
%             condition = find(testTargs(:,i));
%             if condition == 1
%                 labels{i} = 'target';
%             elseif condition == 2
%                 labels{i} = 'lure';
%             end
%         end
%         [X,Y,t,AUC(j)] = perfcurve(labels,acts(1,:), 'target');
        
        %calculate AUC SEPARATELY for easy targets vs. lure && hard targets vs.
        %lure
        testTargsFour = tempPats.regressor.allCond(:,testIdx);
        testTH = find(testAllCond(1,:));
        testTE = find(testAllCond(2,:));
        testLH = find(testAllCond(3,:));
        testLE = find(testAllCond(4,:));
        
        actDiff = acts(1,:) - acts(2,:); % targ - lure activation
        TH_timecourse(j,:) = actDiff(testTH);
        TE_timecourse(j,:) = actDiff(testTE);
        LH_timecourse(j,:) = actDiff(testLH);
        LE_timecourse(j,:) = actDiff(testLE);
        
        hardIdx = find(testTargsFour(1,:)==1);
        easyIdx = find(testTargsFour(2,:)==1);
        lureIdx = find(testTargs(2,:)==1);
%         
%         actsHard = acts(1,[hardIdx lureIdx]);
%         actsEasy = acts(1,[easyIdx lureIdx]);
%         for i = 1:length(actsHard)
%             if i <= length(hardIdx)
%                 labelsHard{i} = 'target';
%             else
%                 labelsHard{i} = 'lure';
%             end
%         end
%         [X,Y,t,AUC_hard(j)] = perfcurve(labelsHard,actsHard, 'target');
%         [X,Y,t,AUC_easy(j)] = perfcurve(labelsHard,actsEasy, 'target');
%         fprintf(['* Completed Iteration ' num2str(j) '; AUC = ' num2str(AUC(j)) '\n']);
%         fprintf(['* Hard vs. Lure AUC = ' num2str(AUC_hard(j)) '\n']);
%         fprintf(['* Easy vs. Lure AUC = ' num2str(AUC_easy(j)) '\n']);
    end
    TH_meanTC(s,:) = mean(TH_timecourse);
    TE_meanTC(s,:) = mean(TE_timecourse);
    LH_meanTC(s,:) = mean(LH_timecourse);
    LE_meanTC(s,:) = mean(LE_timecourse);
%     took out cross val with AUC just to get average timecourses
%     average_AUC(s) = mean(AUC);
%     std_AUC(s) = std(AUC)/sqrt(nIter-1);
%     average_hardAUC(s) = mean(AUC_hard);
%     average_easyAUC(s) = mean(AUC_easy);
%     std_hardAUC = std(AUC_hard)/sqrt(nIter-1);
%     std_easyAUC = std(AUC_easy)/sqrt(nIter-1);
%     xvaltime = toc(startXVAL); %end timing
%     %print cross-validation results
%     fprintf('\n*********************************************\n');
%     fprintf('finished cross-validation...\n');
%     fprintf(['* Average AUC over Iterations: ' num2str(average_AUC) ' +- ' num2str(std_AUC) '\n']);
%     fprintf(['* Average Hard vs. Lure AUC over Iterations: ' num2str(average_hardAUC) ' +- ' num2str(std_hardAUC) '\n']);
%     fprintf(['* Average Easy vs. Lure AUC over Iterations: ' num2str(average_easyAUC) ' +- ' num2str(std_easyAUC) '\n']);
%     fprintf('Cross-validation model training time: \t%.3f\n',xvaltime); 
 end

%% now analyze over all subjects
allavg = [mean(average_AUC) ;mean(average_hardAUC); mean(average_easyAUC)];
eallavg = [std(average_AUC)/sqrt(nsub-1); std(average_hardAUC)/sqrt(nsub-1); std(average_easyAUC)/sqrt(nsub-1)];


h = figure;
barwitherr(eallavg,allavg)
set(gca,'XTickLabel' , ['All '; 'Hard'; 'Easy']);
title('Average Crossval AUC')
xlabel('Trial Type')
ylabel('AUC')
ylim([0.5 0.75])
fig=gcf;
set(findall(fig,'-property','FontSize'),'FontSize',20)
%legend('Pre MOT', 'Post MOT')
print(h, sprintf('%sxvalresults.pdf', allplotDir), '-dpdf')

%% now plot average timecourse for each category: mseb plots by subject

timeHigh = [ nanmean(TH_meanTC); nanmean(TE_meanTC) ; nanmean(LH_meanTC) ; nanmean(LE_meanTC)];
eHigh = [nanstd(TH_meanTC,[],1)/sqrt(nsub-1) ;nanstd(TE_meanTC,[],1)/sqrt(nsub-1); nanstd(LH_meanTC,[],1)/sqrt(nsub-1) ;nanstd(LE_meanTC,[],1)/sqrt(nsub-1)];
h = figure;
npts = size(TH_meanTC,2);
mseb(1:npts,timeHigh, eHigh);
title(sprintf('High Timecourse'))
xlim([3 npts-2])
set(gca, 'XTick', [3:npts-2])
set(gca,'XTickLabel',[' 1'; ' 2'; ' 3'; ' 4'; ' 5'; ' 6'; ' 7'; ' 8'; ' 9'; '10'; '11'; '12'; '13'; '14'; '15']);
ylabel('Retrieval - Control Evidence')
xlabel('Time Points')
set(findall(gcf,'-property','FontSize'),'FontSize',16)
legend('Retrieve-Fast', 'Retrieve-Slow', 'Control-Fast', 'Control-Slow')
print(h, sprintf('%sevidenceFOURCAT.pdf', allplotDir), '-dpdf') 

