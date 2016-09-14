%cross-validate only--just for checking how the classifier is doing on
%subject data after the fact! ahhh
projectName = 'motStudy02';
subvec = 8:15;
nsub = length(subvec);
featureSelect = 1;
allplotDir = ['/Data1/code/' projectName '/' 'Plots' '/' ];

%% training: cross-validation
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
    fprintf('beginning model cross-validation...\n');
    
    %parameters
    penalty = 100;
    keepTR = 4; %should change to 8 maybe???? from 4 because we increased MOT
    shiftTR = 2;
    startXVAL = tic;
    
    %first get session information
    [newpattern t] = GetSessionInfoRT(subjectNum,SESSION,behavioral_dir,keepTR);
    patterns.regressor.allCond = newpattern.regressor.allCond;
    patterns.regressor.twoCond = newpattern.regressor.twoCond;
    patterns.selector.xval = newpattern.selector.xval;
    patterns.selector.allxval = newpattern.selector.allxval;
    nIter = size(patterns.selector.allxval,1);
    %shift regressor
    nCond = size(patterns.regressor.twoCond,1);
    for j = 1:nIter
        selector = patterns.selector.allxval(j,:);
        easyIdx = find(patterns.regressor.allCond(2,:));
        hardIdx = find(patterns.regressor.allCond(1,:));
        trainIdx = find(selector == 1);
        %trainIdx = intersect(hardIdx,trainIdx);
        testIdx = find(selector == 2);
        
        % now shift indices forward
        %trainIdx = trainIdx + shiftTR;
        %testIdx = testIdx + shiftTR;
        
        trainPats = patterns.raw_sm_filt_z(trainIdx+shiftTR,:);
        testPats = patterns.raw_sm_filt_z(testIdx+shiftTR,:);
        trainTargs = patterns.regressor.twoCond(:,trainIdx);
        testTargs = patterns.regressor.twoCond(:,testIdx);
        
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
        for i = 1:length(acts)
            condition = find(testTargs(:,i));
            if condition == 1
                labels{i} = 'target';
            elseif condition == 2
                labels{i} = 'lure';
            end
        end
        [X,Y,t,AUC(j)] = perfcurve(labels,acts(1,:), 'target');
        
        %calculate AUC SEPARATELY for easy targets vs. lure && hard targets vs.
        %lure
        testTargsFour = patterns.regressor.allCond(:,testIdx);
        hardIdx = find(testTargsFour(1,:)==1);
        easyIdx = find(testTargsFour(2,:)==1);
        lureIdx = find(testTargs(2,:)==1);
        
        actsHard = acts(1,[hardIdx lureIdx]);
        actsEasy = acts(1,[easyIdx lureIdx]);
        for i = 1:length(actsHard)
            if i <= length(hardIdx)
                labelsHard{i} = 'target';
            else
                labelsHard{i} = 'lure';
            end
        end
        [X,Y,t,AUC_hard(j)] = perfcurve(labelsHard,actsHard, 'target');
        [X,Y,t,AUC_easy(j)] = perfcurve(labelsHard,actsEasy, 'target');
        fprintf(['* Completed Iteration ' num2str(j) '; AUC = ' num2str(AUC(j)) '\n']);
        fprintf(['* Hard vs. Lure AUC = ' num2str(AUC_hard(j)) '\n']);
        fprintf(['* Easy vs. Lure AUC = ' num2str(AUC_easy(j)) '\n']);
    end
    
    average_AUC(s) = mean(AUC);
    std_AUC(s) = std(AUC)/sqrt(nIter-1);
    average_hardAUC(s) = mean(AUC_hard);
    average_easyAUC(s) = mean(AUC_easy);
    std_hardAUC = std(AUC_hard)/sqrt(nIter-1);
    std_easyAUC = std(AUC_easy)/sqrt(nIter-1);
    xvaltime = toc(startXVAL); %end timing
    %print cross-validation results
    fprintf('\n*********************************************\n');
    fprintf('finished cross-validation...\n');
    fprintf(['* Average AUC over Iterations: ' num2str(average_AUC) ' +- ' num2str(std_AUC) '\n']);
    fprintf(['* Average Hard vs. Lure AUC over Iterations: ' num2str(average_hardAUC) ' +- ' num2str(std_hardAUC) '\n']);
    fprintf(['* Average Easy vs. Lure AUC over Iterations: ' num2str(average_easyAUC) ' +- ' num2str(std_easyAUC) '\n']);
    fprintf('Cross-validation model training time: \t%.3f\n',xvaltime); 
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
