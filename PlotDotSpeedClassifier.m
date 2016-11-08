% want to plot the dot speed and category separation timecourse
% need: speed (from behavioral file)
% category separation (can also pull from behavioral file)
close all;
clear all;
projectName = 'motStudy02';
allspeeds = [];
allsep = [];
nstim = 10;
nTRs = 15;
nblock = 3;
svec = [8 12 14 15 16 18 20:22 26 27 28 29 30];
RT = [8 12 14 15 18 21 22];
YC = [16 20 26 27 28 29 30];
RT_m = [8 12 14 15 18 21 22];
YC_m = [16 28 20 26 27 29 30];
iRT = find(ismember(svec,RT));
iYC = find(ismember(svec,YC));
%svec = 8:13;
nsub = length(svec);
sepbystim = zeros(nstim,nTRs*3);
speedbystim = zeros(nstim,nTRs*3);
MOT_PREP = 5;
colors = [207 127 102;130 161 171; 207 64 19]/255;

%colors = [110 62 106;83 200 212; 187 124 181]/255;
plotstim = 1; %if you want trial by trial plots
plotmixedstim = 0; %if you want trial by trial plots with mixed stimuli
allplotDir = ['/Data1/code/' projectName '/' 'Plots' '/' ];

for s = 1:nsub
    subjectNum = svec(s);
     allsep = [];
     fbsep = [];
     allspeeds = [];
    for iblock = 1:nblock
        
        blockNum = iblock;
        SESSION = 19 + blockNum;
        %blockNum = SESSION - 20 + 1;
        behavioral_dir = ['/Data1/code/' projectName '/' 'code' '/BehavioralData/' num2str(subjectNum) '/'];
        behavioral_dir = [fileparts(which('mot_realtime01.m')) '/BehavioralData/' num2str(subjectNum) '/'];
        save_dir = ['/Data1/code/' projectName '/data/' num2str(subjectNum) '/']; %this is where she sets the save directory!
        classOutputDir = fullfile(save_dir,['motRun' num2str(blockNum)], 'classOutput/');
        runHeader = fullfile(save_dir,[ 'motRun' num2str(blockNum) '/']);
        fileSpeed = dir(fullfile(behavioral_dir, ['mot_realtime01_' num2str(subjectNum) '_' num2str(SESSION)  '*.mat']));
        %get hard speed
        prep = dir([behavioral_dir 'mot_realtime01_' num2str(subjectNum) '_' num2str(MOT_PREP)  '*.mat']);
        prepfile = [behavioral_dir prep(end).name];
        lastRun = load(prepfile);
        hardSpeed(s) = 30 - lastRun.stim.tGuess(end);
        plotDir = ['/Data1/code/' projectName '/' 'Plots' '/' num2str(subjectNum) '/'];
        if ~exist(plotDir, 'dir')
            mkdir(plotDir);
        end
        matlabOpenFile = [behavioral_dir '/' fileSpeed(end).name];
        d = load(matlabOpenFile);
        allSpeed = d.stim.motionSpeed; %matrix of TR's
        speedVector = reshape(allSpeed,1,numel(allSpeed));
        allMotionTRs = convertTR(d.timing.trig.wait,d.timing.plannedOnsets.motion,d.config.TR); %row,col = mTR,trialnumber
        TRvector = reshape(allMotionTRs,1,numel(allMotionTRs));
        for i=1:length(TRvector)
            fileTR = TRvector(i) + 2;
            [~, tempfn{fileTR}] = GetSpecificClassOutputFile(classOutputDir,fileTR);
            tempStruct = load(fullfile(classOutputDir, tempfn{fileTR}));
            categsep(i) = tempStruct.classOutput;
        end
        run = dir([runHeader 'motpatternsdata_' num2str(SESSION) '*']);
        run = load(fullfile(runHeader,run(end).name));
        zcategsep = run.patterns.categsep(TRvector - 10 + 2); %minus 10 because we take out those 10
        %categsep = 
        sepbytrial = reshape(categsep,15,10);
        sepbytrial = sepbytrial'; %results by trial number, TR number
        fbsepbytrial = sepbytrial(:,5:end);

       % sepbytrial = sepbytrial(:,5:end);%take only the ones once fb starts
        sepvec = reshape(sepbytrial,1,numel(sepbytrial));
        fbsepvec = reshape(fbsepbytrial, 1, numel(fbsepbytrial));
        
        speedbytrial = reshape(speedVector,nTRs,nstim);
        speedbytrial = speedbytrial';
        [~,indSort] = sort(d.stim.id);
        sepinorder = sepbytrial(indSort,:);
        speedinorder = speedbytrial(indSort,:);
        %test if fb only
        fbsepinorder = sepinorder(:,5:end);
        fbspeedinorder = speedinorder(:,5:end);
        nTRs2 = 11; %change back to 11 and sep... afterwards
        sepbystim(:,(iblock-1)*nTRs + 1: iblock*nTRs ) = sepinorder;
        speedbystim(:,(iblock-1)*nTRs + 1: iblock*nTRs ) = speedinorder;
        fbsepbystim(:,(iblock-1)*nTRs2 + 1: iblock*nTRs2 ) = fbsepinorder;
        fbspeedbystim(:,(iblock-1)*nTRs2 + 1: iblock*nTRs2 ) = fbspeedinorder;
        sepmixed(:,(iblock-1)*nTRs + 1: iblock*nTRs ) = sepbytrial;
        speedmixed(:,(iblock-1)*nTRs + 1: iblock*nTRs ) = speedbytrial;
%         x = 1:length(speedVector);
%         subplot(2,2,iblock)
%         [hAx,hLine1, hLine2] = plotyy(x,speedVector,x,categsep);
%         xlabel('Time')
%         ylabel(hAx(1), 'Dot Speed', 'Color', 'k')
%         ylabel(hAx(2), 'Category Evidence', 'Color', 'k')
%         ylim(hAx(1),[-0.5 3])
%         ylim(hAx(2), [-1.5 1])
%         set(hLine1, 'LineStyle', '--', 'Color', 'k', 'LineWidth', 3)
%         set(hLine2, 'LineStyle', '-', 'Color', 'r', 'LineWidth', 3)
%         linkaxes([hAx(1) hAx(2)], 'x');
%         
%         set(findall(gcf,'-property','FontSize'),'FontSize',16)
%         set(findall(gcf,'-property','FontColor'),'FontColor','k')
%         set(hAx(2), 'FontSize', 12)
%         set(hAx(1), 'YColor', 'k', 'FontSize', 16, 'YTick', [0:4], 'YTickLabel', {'0', '1', '2', '3', '4'})
%         set(hAx(2), 'YColor', 'r', 'FontSize', 16, 'YTick', [-1:.5:1], 'YTickLabel', {'-1', '0.5', '0', '0.5', '1'});
%         hold on;
%         
%         for rep = 1:nstim
%             line([rep*15 rep*15], [-1 5]);
%         end
        
        rep = 1:10;
        %speedVector(15*(rep-1)+1:15*(rep-1)+1+3) = []; %index the separate speeds so that either build or take out
        
        allspeeds = [allspeeds speedVector];
        allsep = [allsep sepvec];
        fbsep = [fbsep fbsepvec];
        
    end
    
    newspeedbystim = reshape(speedbystim,1,numel(speedbystim));
    newsepbystim = reshape(sepbystim,1,numel(sepbystim));
    [good] = find(newsepbystim > 0.05 & newsepbystim < 0.15);
    goodSpeeds = newspeedbystim(good);
    [thisfig,maxLoc] = plotDist(goodSpeeds,1,1,-1:.5:6.5);
    line([maxLoc maxLoc], [0 1], 'color', 'k', 'LineWidth', 2);
    title(sprintf('Subject %i Distribution of Good Speeds', subjectNum))
    xlabel('Dot Speed')
    ylim([0 .8])
    xlim([-.5 7])
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    text(4.7,.75,['cm = ' num2str(maxLoc)], 'FontSize', 18);
    text(4.7,.65, sprintf('fastS = %4.1f', hardSpeed(s)), 'FontSize', 18)
    print(thisfig, sprintf('%sgoodspeedsdist.pdf', plotDir), '-dpdf')
    
    fbnewspeedbystim = reshape(fbspeedbystim,1,numel(fbspeedbystim));
    fbnewsepbystim = reshape(fbsepbystim,1,numel(fbsepbystim));
    [fbgood] = find(fbnewsepbystim > 0.05 & fbnewsepbystim < 0.15);
    fbgoodSpeeds = fbnewspeedbystim(fbgood);
    [thisfig,maxLoc,counts1] = plotDist(fbgoodSpeeds,1,1,-1:.5:6.5);
    line([maxLoc maxLoc], [0 1], 'color', 'k', 'LineWidth', 2);
    title(sprintf('Subject %i Distribution of Good Speeds, Fb Only', subjectNum))
    xlabel('Dot Speed')
    ylim([0 .8])
    xlim([-.5 7])
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    text(4.7,.75,['cm = ' num2str(maxLoc)], 'FontSize', 18);
    goodSpeedFb(s) = mean(fbgoodSpeeds);
    text(4.7,.65, sprintf('fastS = %4.1f', hardSpeed(s)), 'FontSize', 18)
    print(thisfig, sprintf('%sfb_goodspeedsdist.pdf', plotDir), '-dpdf')
    %look up how to change yaxis categories
    %do to later: rearrange all motion trials by stimulus ID and then plot on
    %subplots every block
    
    fbnewspeedbystim = reshape(fbspeedbystim,1,numel(fbspeedbystim));
    fbnewsepbystim = reshape(fbsepbystim,1,numel(fbsepbystim));
    %[fbgood] = find(fbnewsepbystim > 0.05 & fbnewsepbystim < 0.15);
    %fbgoodSpeeds = fbnewspeedbystim(fbgood);
    [thisfig,maxLoc,counts2] = plotDist(fbnewspeedbystim,1,1,-1:.5:6.5);
    line([maxLoc maxLoc], [0 1], 'color', 'k', 'LineWidth', 2);
    title(sprintf('Subject %i Distribution of All Speeds, Fb Only', subjectNum))
    xlabel('Dot Speed')
    ylim([0 .8])
    xlim([-.5 7])
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    text(4.7,.75,['cm = ' num2str(maxLoc)], 'FontSize', 18);
    text(4.7,.65, sprintf('fastS = %4.1f', hardSpeed(s)), 'FontSize', 18)
    print(thisfig, sprintf('%sfb_allspeedsdist.pdf', plotDir), '-dpdf')
    %look up how to change yaxis categories
    %do to later: rearrange all motion trials by stimulus ID and then plot on
    %subplots every block
    
    counts_div = counts1./counts2;
    bins = -1:.5:6.5;
    bins_interp = linspace(bins(1),bins(end),500);
    counts_interp = interp1(bins,counts_div,bins_interp, 'spline');
    
    %#METHOD 2: DIVIDE BY AREA
    fighandle = figure;
        bar(bins,counts_div/nansum(counts_div));
        hold on
    %plot(xi,fks*length(inData), 'r')
    xlabel('Dot Speed')
    ylim([0 .8])
    xlim([-.5 7])
    plot(bins_interp, counts_interp/nansum(counts_div), 'color', [84 255 199]/255, 'LineWidth', 3);
    title(sprintf('Subject %i Distribution of Good/All, Fb Only', subjectNum))
    ylabel('Frequency')
    xlabel('Dot Speed')
    %ylim([0 0.3])
    [z i] = max(counts_div);
    maxLoc = bins(i);
    line([maxLoc maxLoc], [0 1], 'color', 'k', 'LineWidth', 2);
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    text(4.7,.75,['cm = ' num2str(maxLoc)], 'FontSize', 18);
    text(4.7,.65, sprintf('fastS = %4.1f', hardSpeed(s)), 'FontSize', 18)
   print(fighandle, sprintf('%sfb_allspeedsratiodist.pdf', plotDir), '-dpdf')

    
    
    
    [thisfig,maxLoc] = plotDist(allsep,1,1,[-.5:.1:.5]);
    ylim([0 .4])
    xlim([-.7 .7])
    title(sprintf('Subject %i Evidence Distribution', subjectNum))
    xlabel('Target-Lure Evidence')
    line([0.1 0.1], [0 1], 'color', 'r', 'LineWidth', 2, 'LineStyle', '--');
    line([maxLoc maxLoc], [0 1], 'color', 'k', 'LineWidth', 2);
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    text(-.68,.38,['cm = ' num2str(maxLoc)], 'FontSize', 18);
    text(-.68,.33, sprintf('fastS = %4.1f', hardSpeed(s)), 'FontSize', 18)
    print(thisfig, sprintf('%sevidencedist.pdf', plotDir), '-dpdf')
    
    xvals = [-.5:.1:.5];
    [thisfig,maxLoc,nCounts] = plotDist(fbsep,1,1,xvals);
    ylim([0 .4])
    xlim([-.7 .7])
    title(sprintf('Subject %i Evidence Distribution, Fb Only', subjectNum))
    xlabel('Target-Lure Evidence')
    line([0.1 0.1], [0 1], 'color', 'r', 'LineWidth', 2, 'LineStyle', '--');
    line([maxLoc maxLoc], [0 1], 'color', 'k', 'LineWidth', 2);
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    text(-.68,.38,['cm = ' num2str(maxLoc)], 'FontSize', 18);
    text(-.68,.33, sprintf('fastS = %4.1f', hardSpeed(s)), 'FontSize', 18)
    print(thisfig, sprintf('%sfb_evidencedist.pdf', plotDir), '-dpdf')
    idealInd = find(xvals >0.05 & xvals <0.15);
    ratioIdeal(s) = nCounts(idealInd);
    allcm(s) = maxLoc;
%     figure;
%     scatter(allspeeds,allsep);
%     %lsline;
%     p = polyfit(allspeeds,allsep,1);
%     yfit = polyval(p,allspeeds);
%     xlim([0 nTRs])
%     [rho,pval] = corrcoef(allspeeds,allsep);
%     hold on;
%     plot(allspeeds,yfit, '--k', 'LineWidth', 3);
%     text(10,.85,['corr = ' num2str(pval(1,2))]);
%     text(10,.75, ['p = ' num2str(p(1))])
%     text(10,.65, ['slope = ' num2str(p(1))])
%     title(['Category Separation vs. Dot Speed, Subject ' num2str(subjectNum) ' All Trials'])
%     set(findall(gcf,'-property','FontSize'),'FontSize',16)
if s < 8 %average over 3 TR's
    vec2avg = [0.1*ones(10,2) sepbystim];
    vec2mix = [0.1*ones(10,2) sepmixed];
    for i = 1:size(sepbystim,2)
        smoothedsep(:,i) = mean(vec2avg(:,i:i+2),2);
        smoothedmixedsep(:,i) = mean(vec2mix(:,i:i+2),2);
    end
else %average over 2 TR's
    vec2avg = [0.1*ones(10,1) sepbystim];
    vec2mix = [0.1*ones(10,1) sepmixed];
    for i = 1:size(sepbystim,2)
        smoothedsep(:,i) = mean(vec2avg(:,i:i+1),2);
        smoothedmixedsep(:,i) = mean(vec2mix(:,i:i+1),2);
    end
end
    if max(max(smoothedsep < -0.6)) || max(max(smoothedsep)) > 0.8
        sprintf('BAD STIMULI for subject %i', subjectNum)
    else
        sprintf('OKAY for subject %i', subjectNum)
    end  
%     
    figure;
    for rep = 1:(length(allsep)/15)-1
            line([rep*nTRs+.5 rep*nTRs + .5], [-1 1], 'color', 'c', 'LineWidth', 2);
    end
    hold on
    plot(allsep,'LineStyle', '-', 'Color', colors(1,:), 'LineWidth', 2, 'Marker', 'o', 'MarkerSize', 6)
    xlabel('TR Number (2s)')
    ylabel('Category Evidence')
    ylim( [-.7 .7])
    xlim([1 450])
    title(sprintf('Subject: %i All Evidence' ,subjectNum));
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    % now make plots for each stimuli
    
    %% look at average boundary differences, by stimulus and by stim
    s1 = [1*nTRs 1*nTRs + 1];
    s2 = [2*nTRs 2*nTRs + 1];
    d1(s,1) = mean([mean(abs(diff(sepbystim(:,s1),1,2))) mean(abs(diff(sepbystim(:,s2),1,2)))]);
    d1(s,2) = mean([mean(abs(diff(sepmixed(:,s1),1,2))) mean(abs(diff(sepmixed(:,s2),1,2)))]);
    n = 1:nblock;
    blockvec = (n-1)*15 + 1;
    b2 = blockvec + 14;
    innerdiff(s) = mean([mean(abs(diff(sepbystim(:,blockvec(1):b2(1)),1,2))) mean(abs(diff(sepbystim(:,blockvec(2):b2(2)),1,2))) mean(abs(diff(sepbystim(:,blockvec(3):b2(3)),1,2)))]);
    
    
    %%
    if plotstim
    for stim = 1:nstim
        thisfig = figure(stim*50);
        clf;
        x = 1:nTRs*nblock;
        [hAx,hLine1, hLine2] = plotyy(x,sepbystim(stim,:),x,speedbystim(stim,:));
        xlabel('TR Number (2s)')
        ylabel(hAx(2), 'Dot Speed', 'Color', 'k')
        ylabel(hAx(1), 'Category Evidence', 'Color', 'k')
        ylim(hAx(2),[-0.5 10])
        ylim(hAx(1), [-1 1])
        xlim([0.5 45.5])
        set(hLine2, 'LineStyle', '-', 'Color', colors(2,:), 'LineWidth', 5)
        set(hLine1, 'LineStyle', '-', 'Color', colors(1,:), 'LineWidth', 3, 'Marker', '.', 'MarkerSize', 25)
        %set(hLine1, 'LineStyle', '-', 'Color', colors(1,:), 'LineWidth', 4, 'Marker', 'o', 'MarkerSize', 7)
        linkaxes([hAx(1) hAx(2)], 'x');
        title(sprintf('Subject: %i Stimulus ID: %i',subjectNum,stim));
        set(findall(gcf,'-property','FontSize'),'FontSize',20)
        set(findall(gcf,'-property','FontColor'),'FontColor','k')
        set(hAx(1), 'FontSize', 12)
        set(hAx(2), 'YColor', colors(2,:), 'FontSize', 16, 'YTick', [0:10]); %'YTickLabel', {'0', '1', '2', '3', '4', '5})
        set(hAx(1), 'YColor', colors(1,:), 'FontSize', 16, 'YTick', [-1:.5:1], 'YTickLabel', {'-1', '-0.5', '0', '0.5', '1'});
        hold on;
        plot(x,smoothedsep(stim,:), 'LineStyle', '-', 'Color', colors(3,:), 'LineWidth', 4, 'Marker', 'o', 'MarkerSize', 3)
        legend('Ev', 'Smoothed Ev', 'Dot Speed')
        for rep = 1:2
            line([rep*nTRs+.5 rep*nTRs + .5], [-10 15], 'color', 'k', 'LineWidth', 2);
        end
        line([0 46], [0.1 0.1], 'color', [140 136 141]/255, 'LineWidth', 2.5,'LineStyle', '--');
%         savefig(sprintf('%sstim%i.fig', plotDir,stim));
         print(thisfig, sprintf('%sstim%i.pdf', plotDir,stim), '-dpdf')
    end
    end
    if plotmixedstim
     for stim = 1:nstim
        thisfig = figure(stim*71);
        clf;
        x = 1:nTRs*nblock;
        [hAx,hLine1, hLine2] = plotyy(x,sepmixed(stim,:),x,speedmixed(stim,:));
        xlabel('TR Number (2s)')
        ylabel(hAx(2), 'Dot Speed', 'Color', 'k')
        ylabel(hAx(1), 'Category Evidence', 'Color', 'k')
        ylim(hAx(2),[-0.5 10])
        ylim(hAx(1), [-1 1])
        xlim([0.5 45.5])
        set(hLine2, 'LineStyle', '-', 'Color', colors(2,:), 'LineWidth', 5)
        set(hLine1, 'LineStyle', '-', 'Color', colors(1,:), 'LineWidth', 4, 'Marker', 'o', 'MarkerSize', 7)
        %set(hLine1, 'LineStyle', '-', 'Color', colors(1,:), 'LineWidth', 4, 'Marker', 'o', 'MarkerSize', 7)
        linkaxes([hAx(1) hAx(2)], 'x');
        title(sprintf('MIXED Subject: %i Stimulus ID: %i',subjectNum,stim));
        set(findall(gcf,'-property','FontSize'),'FontSize',20)
        set(findall(gcf,'-property','FontColor'),'FontColor','k')
        set(hAx(1), 'FontSize', 12)
        set(hAx(2), 'YColor', colors(2,:), 'FontSize', 16, 'YTick', [0:10]); %'YTickLabel', {'0', '1', '2', '3', '4', '5})
        set(hAx(1), 'YColor', colors(1,:), 'FontSize', 16, 'YTick', [-1:.5:1], 'YTickLabel', {'-1', '-0.5', '0', '0.5', '1'});
        hold on;
        plot(x,smoothedmixedsep(stim,:), 'LineStyle', '-', 'Color', colors(3,:), 'LineWidth', 4, 'Marker', 'o', 'MarkerSize', 7)
        legend('Ev', 'Smoothed Ev', 'Dot Speed')
        for rep = 1:2
            line([rep*nTRs+.5 rep*nTRs + .5], [-10 15], 'color', 'k', 'LineWidth', 2);
        end
        line([0 46], [0.1 0.1], 'color', [140 136 141]/255, 'LineWidth', 2.5,'LineStyle', '--');
%         savefig(sprintf('%sstim%i.fig', plotDir,stim));
         print(thisfig, sprintf('%sMIXEDstim%i.pdf', plotDir,stim), '-dpdf')
    end
    end    
%     [nelements, xval ] = hist(sepbystim', [-.3:.05:.3]);
%     freq = nelements/45;
%     figure;
%     bar(freq*100);
%     set(gca, 'XTickLabel', num2str(xval))
%     xlabel('Target-Lure Evidence')
%     ylabel('Frequency (%)')
%     ylim([0 30])
%     legend('s1', 's2', 's3', 's4', 's5', 's6', 's7', 's8', 's9', 's10')
%     title(sprintf('Subject %i Classifier Evidence Distribution',subjectNum));
%     set(findall(gcf,'-property','FontSize'),'FontSize',17)
%     savefig(sprintf('%sdist.fig', plotDir));
%     fileSpeed = dir(fullfile(behavioral_dir, ['mot_realtime01_' num2str(subjectNum) '_' num2str(SESSION)  '*.mat']));
%         plotDir = ['/Data1/code/' projectName '/' 'Plots' '/' num2str(subjectNum) '/'];
%         if ~exist(plotDir, 'dir')
%             mkdir(plotDir);
%         end
% 
%     recallFile = dir(fullfile(behavioral_dir, ['EK19_SUB' '*mat']));
%     r1 = load([behavioral_dir '/' recallFile(end).name]);
%     z = table2cell(r1.datastruct.trials(:,16));
%     z(cellfun(@(x) any(isnan(x)),z)) = {'00'};
% 
%     resp1 = cell2mat(z);
%     resp1 = resp1(:,1);
%     
%     stimOrder = table2array(r1.datastruct.trials(:,8));
%     RTorder = stimOrder(stimOrder<11);
%     RTonly = resp1(stimOrder<11);
%     [~,sortedID] = sort(RTorder);
%     r1Sort = RTonly(sortedID);
%     
%      %now all recall changes
%     [~,allsort] = sort(stimOrder);
%     R1recall = resp1(allsort);
%     
%     recallFile = dir(fullfile(behavioral_dir, ['EK23_SUB' '*mat']));
%     r2 = load([behavioral_dir '/' recallFile(end).name]);
%     z = table2cell(r2.datastruct.trials(:,16));
%     z(cellfun(@(x) any(isnan(x)),z)) = {'00'}; %for nan's!
%     resp2 = cell2mat(z);
%     resp2 = resp2(:,1);
%     
%     stimOrder = table2array(r2.datastruct.trials(:,8));
%     RTorder = stimOrder(stimOrder<11);
%     RTonly = resp2(stimOrder<11);
%     [~,sortedID] = sort(RTorder);
%     r2Sort = RTonly(sortedID);
%     
%      %now all recall changes
%     [~,allsort] = sort(stimOrder);
%     R2recall = resp2(allsort);
%     
%     recalldiff = R2recall - R1recall;
%    rtdiff(s) = mean(recalldiff(1:10)); 
%    omitdiff(s) = mean(recalldiff(11:end));
%     
%     medsep1 = median(sepbystim(:,1:15),2);
%     medsep2 = median(sepbystim(:,31:end),2);
%     s = 100;
%     figure;
%     subplot(1,2,1)
%     scatter(str2num(r1Sort),medsep1, s,'fill','MarkerEdgeColor','b',...
%               'MarkerFaceColor','c',...
%               'LineWidth',2.5);
%     xlabel('Pre MOT Subj Rating')
%     xlim([0 5])
%     ylim([-.15 .15])
%     ylabel('Median Evidence')
%     title(sprintf('Subject %i Evidence vs. Pre Rating',subjectNum));
% 
%     subplot(1,2,2)
%     scatter(medsep2,str2num(r2Sort), s,'fill','MarkerEdgeColor','b',...
%               'MarkerFaceColor','c',...
%               'LineWidth',2.5);
%     ylabel('Post MOT Subj Rating')
%     xlabel('Median Evidence')
%     ylim([0 5])
%     xlim([-.15 .15])
%     title(sprintf('Subject %i Post Rating vs. Evidence',subjectNum));
%     set(findall(gcf,'-property','FontSize'),'FontSize',20)
%     savefig(sprintf('%srating_separated.fig', plotDir));
%     
%    

end

% thisfig = figure;
% barwitherr(std(d1,[],1)/sqrt(nsub-1),mean(d1))
% set(gca,'XTickLabel' , ['Stim ';'Mixed']);
% xlabel('Category')
% ylabel('Average Differences')
% title('Absolute Value Boundary Differences')
% set(findall(gcf,'-property','FontSize'),'FontSize',20)
% ylim([0 0.4])
% print(thisfig, sprintf('%sbystimvsorder.pdf', plotDir), '-dpdf')
% 
% boundarystim = d1(:,1);
% avges = [mean(boundarystim) mean(innerdiff)];
% errors = [std(boundarystim) std(innerdiff)]/sqrt(nsub-1);
% thisfig = figure;
% barwitherr(errors,avges)
% set(gca,'XTickLabel' , ['Boundary';'In Trial']);
% xlabel('Category')
% ylabel('Average Differences')
% title('Absolute Value Differences')
% set(findall(gcf,'-property','FontSize'),'FontSize',20)
% ylim([0 0.4])
% print(thisfig, sprintf('%sboundaryvsinner.pdf', plotDir), '-dpdf')

%% now compare ratio ideal
firstgroup = ratioIdeal(iRT);
secondgroup = ratioIdeal(iYC);
avgratio = [mean(firstgroup) mean(secondgroup)];
eavgratio = [std(firstgroup)/sqrt(length(firstgroup)-1) std(secondgroup)/sqrt(length(secondgroup)-1)];
thisfig = figure;
barwitherr(eavgratio,avgratio)
set(gca,'XTickLabel' , ['RT';'YC']);
xlabel('Subject Group')
ylabel('Good Evidence Ratio')
title('Ratio of Good Evidence by Subject Group')
set(findall(gcf,'-property','FontSize'),'FontSize',20)
ylim([0 0.3])

%% now compare cm of feedback-adapt for RT and YC
% nold = 4;
firstgroup = allcm(iRT);
secondgroup = allcm(iYC);
avgratio = [mean(firstgroup) mean(secondgroup)];
eavgratio = [std(firstgroup)/sqrt(length(firstgroup)-1) std(secondgroup)/sqrt(length(secondgroup)-1)];
thisfig = figure;
barwitherr(eavgratio,avgratio)
set(gca,'XTickLabel' , ['RT';'YC']);
xlabel('Subject Group')
ylabel('CM of Evidence')
title('CM of Evidence by Subject Group')
set(findall(gcf,'-property','FontSize'),'FontSize',20)
ylim([-.2 0.2])
%print(thisfig, sprintf('%scmbygroup.pdf', allplotDir), '-dpdf')

%% now look at if max dot speeds determine anything
% looking at the mean center of mass of evidence
%speed2 = hardSpeed(end-nnew+1:end);
figure;
plot(hardSpeed(iRT),allcm(iRT), 'k.', hardSpeed(iYC),allcm(iYC), 'r.');
xlabel('Staircased Speed')
ylabel('CM Evidence')

% mean dot speed used in feedback
thisfig = figure;
%plot(speed2,goodSpeed2, '.')
s = 100;
scatter(hardSpeed(iRT),goodSpeedFb(iRT), s,'fill','MarkerEdgeColor','b',...
               'MarkerFaceColor','c',...
               'LineWidth',3.5);
p = polyfit(hardSpeed(iRT),goodSpeedFb(iRT),1);
yfit = polyval(p,hardSpeed(iRT));
hold on;
plot(hardSpeed(iRT),yfit, '--k', 'LineWidth', 3)
scatter(hardSpeed(iYC),goodSpeedFb(iYC), s,'fill','MarkerEdgeColor','k',...
               'MarkerFaceColor','r',...
               'LineWidth',3.5);
xlabel('Staircased Speed')
ylabel('Mean of Good Speed during FB')
title('Good Speed vs. Staircased Speed')
set(findall(gcf,'-property','FontSize'),'FontSize',20)
%print(thisfig, sprintf('%sgoodfbspeedvsstaircased.pdf', allplotDir), '-dpdf')
