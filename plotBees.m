% plotBees: plot distrubition for beeswarm functions
% compare feedback

close all;
clear all;
projectName = 'motStudy02';
allspeeds = [];
allsep = [];
nstim = 10;
nTRs = 15;
sepTRs = 17;
FBTRs = 11;
nblock = 3;
RT_m = [8 12 13 14 15 18 21];
YC_m = [16 28 24 20 26 27 29];
svec = [8 12:16 18 20:22 24 26 27 28 29];
RT = [8 12:15 18 21 22];
YC = [16 20 24 26 27 28 29];
iRT = find(ismember(svec,RT));
iYC = find(ismember(svec,YC));
iRT_m = find(ismember(svec,RT_m))
for i = 1:length(YC_m)
    iYC_m(i) = find(svec==YC_m(i))
end
nsub = length(svec);
sepbystim = zeros(nstim,nTRs*3);
speedbystim = zeros(nstim,nTRs*3);
allplotDir = ['/Data1/code/' projectName '/' 'Plots' '/' ];

for s = 1:nsub
    subjectNum = svec(s);
    for iblock = 1:nblock
        blockNum = iblock;
        SESSION = 19 + blockNum;
        
        behavioral_dir = [fileparts(which('mot_realtime01.m')) '/BehavioralData/' num2str(subjectNum) '/'];
        save_dir = ['/Data1/code/' projectName '/data/' num2str(subjectNum) '/']; %this is where she sets the save directory!
        runHeader = fullfile(save_dir,[ 'motRun' num2str(blockNum) '/']);
        fileSpeed = dir(fullfile(behavioral_dir, ['mot_realtime01_' num2str(subjectNum) '_' num2str(SESSION)  '*.mat']));
        names = {fileSpeed.name};
        dates = [fileSpeed.datenum];
        [~,newest] = max(dates);
        plotDir = ['/Data1/code/' projectName '/' 'Plots' '/' num2str(subjectNum) '/'];
        if ~exist(plotDir, 'dir')
            mkdir(plotDir);
        end
        matlabOpenFile = [behavioral_dir '/' names{newest}];
        d = load(matlabOpenFile);
        allSpeed = d.stim.motionSpeed; %matrix of TR's
        speedVector = reshape(allSpeed,1,numel(allSpeed));
        allMotionTRs = convertTR(d.timing.trig.wait,d.timing.plannedOnsets.motion,d.config.TR); %row,col = mTR,trialnumber
        allMotionTRs = allMotionTRs + 2;%[allMotionTRs; allMotionTRs(end,:)+1; allMotionTRs(end,:) + 2]; %add in the next 2 TR's for HDF
        onlyFbTRs = allMotionTRs(4:end,:);
        FBTR2 = allMotionTRs(5:end,end);
        TRvector = reshape(allMotionTRs,1,numel(allMotionTRs));
        FBTRVector = reshape(onlyFbTRs,1,numel(onlyFbTRs));
        FBTRVector2 = reshape(FBTR2,1,numel(FBTR2));
        run = dir([runHeader 'motpatternsdata_' num2str(SESSION) '*']);
        names = {run.name};
        dates = [run.datenum];
        [~,newest] = max(dates);
        run = load(fullfile(runHeader,run(end).name));
        categsep = run.patterns.categsep(TRvector - 10); %minus 10 because we take out those 10
        sepbytrial = reshape(categsep,nTRs,10);
        allsepchange = diff(sepbytrial,1,1);
        FBsepchange = reshape(allsepchange(4:end,:),1,numel(allsepchange(4:end,:)));
        allsep = reshape(sepbytrial(5:end,:),1,numel(sepbytrial(5:end,:)));
        allspeedchanges = diff(d.stim.motionSpeed,1,1);
        FBspeed = reshape(allSpeed(5:end,:),1,numel(allSpeed(5:end,:)));
        FBspeedchange = reshape(allspeedchanges(4:end,:),1,numel(allspeedchanges(4:end,:)));
        FBTRs = length(FBspeedchange);
        ds((iblock-1)*FBTRs + 1: iblock*FBTRs ,s) = FBspeedchange;
        ev((iblock-1)*FBTRs + 1: iblock*FBTRs ,s) = allsep;
        speed((iblock-1)*FBTRs + 1: iblock*FBTRs ,s) = FBspeed;
    end
    
end
%% separate groups
ds_RT = ds(:,iRT);
allds_RT = reshape(ds_RT,1,numel(ds_RT));
ev_RT = ev(:,iRT);
allev_RT = reshape(ev_RT,1,numel(ev_RT));
speed_RT = speed(:,iRT);
allspeed_RT = reshape(speed_RT,1,numel(speed_RT));

ds_YC = ds(:,iYC);
allds_YC = reshape(ds_YC,1,numel(ds_YC));
ev_YC = ev(:,iYC);
allev_YC = reshape(ev_YC,1,numel(ev_YC));
speed_YC = speed(:,iYC);
allspeed_YC = reshape(speed_YC,1,numel(speed_YC));

%% plot

cats={'RT' 'YC'}; %category labels
[~,mHUCp]=ttest2(allev_RT,allev_YC);
pl={allev_RT', allev_YC'}; %these are all the elements (rows) in each condition (columns)
ps=[mHUCp]; %so here I'm plotting 
yl='Retrieval Evidence During MOT'; %y-axis label
figure;plotSpread(pl,'xNames',cats,'showMM',2,'yLabel',yl); %this plots the beeswarm
h=gcf;set(h,'PaperOrientation','landscape'); %these two lines grabs some attributes important for plotting significance
xt = get(gca, 'XTick');yt = get(gca, 'YTick');
hold on;plotSig(xt,yt,ps,0);hold off; %keep hold on and do plotSig.
%pn=[picd num2str(vers) '-' num2str(scramm) 'ChangeInPrecision'];%print(pn,'-depsc'); %print fig
ylim([-1.25 1.25])
set(findall(gcf,'-property','FontSize'),'FontSize',20)
line([0 46], [0.15 0.15], 'color', [140 136 141]/255, 'LineWidth', 1.5,'LineStyle', '--');
line([0 46], [0.1 0.1], 'color', [0 0 0 ]/255, 'LineWidth', 2.5,'LineStyle', '--');
line([0 46], [0.05 0.05], 'color', [140 136 141]/255, 'LineWidth', 1.5,'LineStyle', '--');

%% do separately for each subject

cats = {'RT1', 'YC1', 'RT2', 'YC2', 'RT3', 'YC3', 'RT4', 'YC4', 'RT5', 'YC5', 'RT6', 'YC6', 'RT7', 'YC7'};
pl = {ev(:,iRT_m(1)), ev(:,iYC_m(1)), ev(:,iRT_m(2)), ev(:,iYC(2)), ev(:,iRT_m(3)), ev(:,iYC_m(3)), ev(:,iRT_m(4)), ev(:,iYC_m(4)), ev(:,iRT_m(5)), ev(:,iYC_m(5)), ev(:,iRT_m(6)), ev(:,iYC_m(6)), ev(:,iRT_m(7)), ev(:,iYC_m(7))};
for j = 1:length(iRT_m) %do for each pair
    [~,mp(j)] = ttest2(ev(:,iRT_m(j)),ev(:,iYC_m(j)));
end
ps = [mp];
yl='Retrieval Evidence During MOT'; %y-axis label
figure;plotSpread(pl,'xNames',cats,'showMM',2,'yLabel',yl); %this plots the beeswarm
h=gcf;set(h,'PaperOrientation','landscape'); %these two lines grabs some attributes important for plotting significance
xt = get(gca, 'XTick');yt = get(gca, 'YTick');
hold on;plotSig(xt,yt,ps,0);hold off; %keep hold on and do plotSig.
%pn=[picd num2str(vers) '-' num2str(scramm) 'ChangeInPrecision'];%print(pn,'-depsc'); %print fig
ylim([-1.25 1.25])
set(findall(gcf,'-property','FontSize'),'FontSize',20)
%plot bands
line([0 46], [0.15 0.15], 'color', [140 136 141]/255, 'LineWidth', 1.5,'LineStyle', '--');
line([0 46], [0.1 0.1], 'color', [0 0 0 ]/255, 'LineWidth', 2.5,'LineStyle', '--');
line([0 46], [0.05 0.05], 'color', [140 136 141]/255, 'LineWidth', 1.5,'LineStyle', '--');
