% want to plot the dot speed and category separation timecourse

% need: speed (from behavioral file)
% category separation (can also pull from behavioral file)
projectName = 'motStudy02';
subjectNum = 3;
allspeeds = [];
allsep = [];
figure;
for iblock = 1:3
    blockNum = iblock;
    SESSION = 19 + blockNum;
    %blockNum = SESSION - 20 + 1;
    
    behavioral_dir = ['/Data1/code/' projectName '/' 'code' '/BehavioralData/' num2str(subjectNum) '/'];
    save_dir = ['/Data1/code/' projectName '/data/' num2str(subjectNum) '/']; %this is where she sets the save directory!
    runHeader = fullfile(save_dir,[ 'motRun' num2str(blockNum) '/']);
    fileSpeed = dir(fullfile(behavioral_dir, ['mot_realtime01_' num2str(subjectNum) '_' num2str(SESSION)  '*.mat']));
    matlabOpenFile = [behavioral_dir '/' fileSpeed(end).name];
    d = load(matlabOpenFile);
    allSpeed = d.stim.motionSpeed; %matrix of TR's
    speedVector = reshape(allSpeed,1,numel(allSpeed));
    allMotionTRs = convertTR(d.timing.trig.wait,d.timing.plannedOnsets.motion,d.config.TR); %row,col = mTR,trialnumber
    TRvector = reshape(allMotionTRs,1,numel(allMotionTRs));
    run = dir([runHeader 'motpatternsdata_' num2str(SESSION) '*']);
    run = load(fullfile(runHeader,run(end).name));
    categsep = run.patterns.categsep(TRvector - 10 + 2); %minus 10 because we take out those 10
    
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
    
    for rep = 1:10
        line([rep*15 rep*15], [-1 5]);
    end
    
    rep = 1:10;
    speedVector(15*(rep-1)+1:15*(rep-1)+1+3) = []; %index the separate speeds so that either build or take out

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
xlim([0 15])
[rho,pval] = corrcoef(allspeeds,allsep);
hold on;
plot(allspeeds,yfit, '--k', 'LineWidth', 3);
text(10,.85,['corr = ' num2str(pval(1,2))]);
text(10,.75, ['p = ' num2str(p(1))])
text(10,.65, ['slope = ' num2str(p(1))])
title(['Category Separation vs. Dot Speed, Subject ' num2str(subjectNum) ' All Trials'])
set(findall(gcf,'-property','FontSize'),'FontSize',16)