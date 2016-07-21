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
svec = [3:5 7];
nsub = length(svec);
sepbystim = zeros(nstim,nTRs*3);
speedbystim = zeros(nstim,nTRs*3);

for s = 1:nsub
    subjectNum = svec(s);
    figure;
    for iblock = 1:nblock
        blockNum = iblock;
        SESSION = 19 + blockNum;
        %blockNum = SESSION - 20 + 1;
        
        behavioral_dir = ['/Data1/code/' projectName '/' 'code' '/BehavioralData/' num2str(subjectNum) '/'];
        save_dir = ['/Data1/code/' projectName '/data/' num2str(subjectNum) '/']; %this is where she sets the save directory!
        runHeader = fullfile(save_dir,[ 'motRun' num2str(blockNum) '/']);
        fileSpeed = dir(fullfile(behavioral_dir, ['mot_realtime01_' num2str(subjectNum) '_' num2str(SESSION)  '*.mat']));
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
        run = dir([runHeader 'motpatternsdata_' num2str(SESSION) '*']);
        run = load(fullfile(runHeader,run(end).name));
        categsep = run.patterns.categsep(TRvector - 10 + 2); %minus 10 because we take out those 10
        sepbytrial = reshape(categsep,15,10);
        sepbytrial = sepbytrial'; %results by trial number, TR number
        speedbytrial = reshape(speedVector,nTRs,nstim);
        speedbytrial = speedbytrial';
        [~,indSort] = sort(d.stim.id);
        sepinorder = sepbytrial(indSort,:);
        speedinorder = speedbytrial(indSort,:);
        sepbystim(:,(iblock-1)*nTRs + 1: iblock*nTRs ) = sepinorder;
        speedbystim(:,(iblock-1)*nTRs + 1: iblock*nTRs ) = speedinorder;
        x = 1:length(speedVector);
        subplot(2,2,iblock)
        [hAx,hLine1, hLine2] = plotyy(x,speedVector,x,categsep);
        xlabel('Time')
        ylabel(hAx(1), 'Dot Speed', 'Color', 'k')
        ylabel(hAx(2), 'Category Evidence', 'Color', 'k')
        ylim(hAx(1),[-0.5 3])
        ylim(hAx(2), [-1.5 1])
        set(hLine1, 'LineStyle', '--', 'Color', 'k', 'LineWidth', 3)
        set(hLine2, 'LineStyle', '-', 'Color', 'r', 'LineWidth', 3)
        linkaxes([hAx(1) hAx(2)], 'x');
        
        set(findall(gcf,'-property','FontSize'),'FontSize',16)
        set(findall(gcf,'-property','FontColor'),'FontColor','k')
        set(hAx(2), 'FontSize', 12)
        set(hAx(1), 'YColor', 'k', 'FontSize', 16, 'YTick', [0:4], 'YTickLabel', {'0', '1', '2', '3', '4'})
        set(hAx(2), 'YColor', 'r', 'FontSize', 16, 'YTick', [-1:.5:1], 'YTickLabel', {'-1', '0.5', '0', '0.5', '1'});
        hold on;
        
        for rep = 1:nstim
            line([rep*15 rep*15], [-1 5]);
        end
        
        rep = 1:10;
        %speedVector(15*(rep-1)+1:15*(rep-1)+1+3) = []; %index the separate speeds so that either build or take out
        
        allspeeds = [allspeeds speedVector];
        allsep = [allsep categsep];
        
    end
    %look up how to change yaxis categories
    %do to later: rearrange all motion trials by stimulus ID and then plot on
    %subplots every block
    
    figure;
    scatter(allspeeds,allsep);
    %lsline;
    p = polyfit(allspeeds,allsep,1);
    yfit = polyval(p,allspeeds);
    xlim([0 nTRs])
    [rho,pval] = corrcoef(allspeeds,allsep);
    hold on;
    plot(allspeeds,yfit, '--k', 'LineWidth', 3);
    text(10,.85,['corr = ' num2str(pval(1,2))]);
    text(10,.75, ['p = ' num2str(p(1))])
    text(10,.65, ['slope = ' num2str(p(1))])
    title(['Category Separation vs. Dot Speed, Subject ' num2str(subjectNum) ' All Trials'])
    set(findall(gcf,'-property','FontSize'),'FontSize',16)
    colors = [230 33 132;73 91 252]/255;
    % now make plots for each stimuli
    for stim = 1:nstim
        figure(stim);
        clf;
        x = 1:nTRs*nblock;
        [hAx,hLine1, hLine2] = plotyy(x,sepbystim(stim,:),x,speedbystim(stim,:));
        xlabel('TR Number (2s)')
        ylabel(hAx(2), 'Dot Speed', 'Color', 'k')
        ylabel(hAx(1), 'Category Evidence', 'Color', 'k')
        ylim(hAx(2),[-0.5 7])
        ylim(hAx(1), [-1 1])
        xlim([0.5 45.5])
        set(hLine2, 'LineStyle', ':', 'Color', colors(2,:), 'LineWidth', 5)
        set(hLine1, 'LineStyle', '-', 'Color', colors(1,:), 'LineWidth', 4, 'Marker', 'o', 'MarkerSize', 7)
        linkaxes([hAx(1) hAx(2)], 'x');
        title(sprintf('Subject: %i Stimulus ID: %i',subjectNum,stim));
        set(findall(gcf,'-property','FontSize'),'FontSize',20)
        set(findall(gcf,'-property','FontColor'),'FontColor','k')
        set(hAx(1), 'FontSize', 12)
        set(hAx(2), 'YColor', colors(2,:), 'FontSize', 16, 'YTick', [0:7]); %'YTickLabel', {'0', '1', '2', '3', '4', '5})
        set(hAx(1), 'YColor', colors(1,:), 'FontSize', 16, 'YTick', [-1:.5:1], 'YTickLabel', {'-1', '-0.5', '0', '0.5', '1'});
        hold on;
        
        for rep = 1:2
            line([rep*nTRs+.5 rep*nTRs + .5], [-10 15], 'color', 'k', 'LineWidth', 2);
        end
        savefig(sprintf('%sstim%i.fig', plotDir,stim));
    end
    
    [nelements, xval ] = hist(sepbystim', [-.3:.05:.3]);
    freq = nelements/45;
    figure;
    bar(freq*100);
    set(gca, 'XTickLabel', num2str(xval))
    xlabel('Target-Lure Evidence')
    ylabel('Frequency (%)')
    ylim([0 30])
    legend('s1', 's2', 's3', 's4', 's5', 's6', 's7', 's8', 's9', 's10')
    title(sprintf('Subject %i Classifier Evidence Distribution',subjectNum));
    set(findall(gcf,'-property','FontSize'),'FontSize',17)
    savefig(sprintf('%sdist.fig', plotDir));
    fileSpeed = dir(fullfile(behavioral_dir, ['mot_realtime01_' num2str(subjectNum) '_' num2str(SESSION)  '*.mat']));
        plotDir = ['/Data1/code/' projectName '/' 'Plots' '/' num2str(subjectNum) '/'];
        if ~exist(plotDir, 'dir')
            mkdir(plotDir);
        end

    recallFile = dir(fullfile(behavioral_dir, ['EK19_SUB' '*mat']));
    r1 = load([behavioral_dir '/' recallFile(end).name]);
    z = table2cell(r1.datastruct.trials(:,16));
    z(cellfun(@(x) any(isnan(x)),z)) = {'00'};

    resp1 = cell2mat(z);
    resp1 = resp1(:,1);
    
    stimOrder = table2array(r1.datastruct.trials(:,8));
    RTorder = stimOrder(stimOrder<11);
    [~,sortedID] = sort(RTorder);
    r1Sort = resp1(sortedID);
    
    recallFile = dir(fullfile(behavioral_dir, ['EK23_SUB' '*mat']));
    r2 = load([behavioral_dir '/' recallFile(end).name]);
    z = table2cell(r2.datastruct.trials(:,16));
    z(cellfun(@(x) any(isnan(x)),z)) = {'00'}; %for nan's!
    resp2 = cell2mat(z);
    resp2 = resp2(:,1);
    
    stimOrder = table2array(r2.datastruct.trials(:,8));
    RTorder = stimOrder(stimOrder<11);
    [~,sortedID] = sort(RTorder);
    r2Sort = resp1(sortedID);
    
    medsep = median(sepbystim,2);
    s = 100;
    figure;
    subplot(1,2,1)
    scatter(str2num(r1Sort),medsep, s,'fill','MarkerEdgeColor','b',...
              'MarkerFaceColor','c',...
              'LineWidth',2.5);
    xlabel('Pre MOT Subj Rating')
    xlim([0 5])
    ylim([-.15 .15])
    ylabel('Median Evidence')
    title(sprintf('Subject %i Evidence vs. Pre Rating',subjectNum));

    subplot(1,2,2)
    scatter(medsep,str2num(r2Sort), s,'fill','MarkerEdgeColor','b',...
              'MarkerFaceColor','c',...
              'LineWidth',2.5);
    ylabel('Post MOT Subj Rating')
    xlabel('Median Evidence')
    ylim([0 5])
    xlim([-.15 .15])
    title(sprintf('Subject %i Post Rating vs. Evidence',subjectNum));
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    savefig(sprintf('%srating.fig', plotDir));

end
