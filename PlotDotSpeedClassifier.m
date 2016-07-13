% want to plot the dot speed and category separation timecourse

% need: speed (from behavioral file)
% category separation (can also pull from behavioral file)
projectName = 'motStudy02';
subjectNum = 3;
SESSION = 22;
blockNum = SESSION - 20 + 1;

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
figure;
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
%look up how to change yaxis categories
%do to later: rearrange all motion trials by stimulus ID and then plot on
%subplots every block