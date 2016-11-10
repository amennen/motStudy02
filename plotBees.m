% plotBees: plot distrubition for beeswarm functions
% compare feedback

%close all;
%clear all;
projectName = 'motStudy02';
allspeeds = [];
allsep = [];
nstim = 10;
nTRs = 15;
sepTRs = 17;
FBTRs = 11;
nblock = 3;
svec = [8 12 14 15 16 18 20 22 26 27 28 30 31 32];

RT = [8 12 14 15 18  22 31];
YC = [16 20 26 27 28 30 32];
iRT = find(ismember(svec,RT));
iYC = find(ismember(svec,YC));

RT_m = [8 12 14 15 18  22 31];
YC_m = [16 28 20 26 27  30 32];
iRT_m = find(ismember(svec,RT_m));
% for i = 1:length(YC_m)
%     iYC_m(i) = find(svec==YC_m(i));
% end
% for i = 1:length(svec)
%     n_rem(i) = length(findRememberedStim(svec(i)));
%     remembered{i} = findRememberedStim(svec(i));
% end
% for i = 1:length(iYC_m)
%     overlapping{i} = intersect(remembered{iRT_m(i)},remembered{iYC_m(i)});
% end
nsub = length(svec);
sepbystim = zeros(nstim,nTRs*3);
speedbystim = zeros(nstim,nTRs*3);
allplotDir = ['/Data1/code/' projectName '/' 'Plots' '/' ];
allds_RT = [];
allev_RT = [];
allspeed_RT = [];
allds_YC = [];
allev_YC = [];
allspeed_YC = [];
goodTrials =0;
for s = 1:nsub
    subjectNum = svec(s);

    remStim = findRememberedStim(subjectNum);
    subject_ds = [];
    subject_ev = [];
    subject_speed = [];
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
        
        %goodTrials = find(ismember(d.stim.id,remStim));
        
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
        if goodTrials
            sepbytrial = sepbytrial(:,goodTrials);
        end
        allsepchange = diff(sepbytrial,1,1);
        FBsepchange = reshape(allsepchange(4:end,:),1,numel(allsepchange(4:end,:)));
        allsep = reshape(sepbytrial(5:end,:),1,numel(sepbytrial(5:end,:)));
        if goodTrials
            allSpeed = allSpeed(:,goodTrials);
        end
        allspeedchanges = diff(allSpeed,1,1);
            
        FBspeed = reshape(allSpeed(5:end,:),1,numel(allSpeed(5:end,:)));
        FBspeedchange = reshape(allspeedchanges(4:end,:),1,numel(allspeedchanges(4:end,:)));
        FBTRs = length(FBspeedchange);
        if ismember(subjectNum,RT)
            allds_RT = [allds_RT FBspeedchange];
            allev_RT = [allev_RT allsep];
            allspeed_RT = [allspeed_RT FBspeed];
        else
            allds_YC = [allds_YC FBspeedchange];
            allev_YC = [allev_YC allsep];
            allspeed_YC = [allspeed_YC FBspeed];
        end
        subject_ds = [subject_ds FBspeedchange];
        subject_ev = [subject_ev allsep];
        subject_speed = [subject_speed FBspeed];
        
        %ds((iblock-1)*FBTRs + 1: iblock*FBTRs ,s) = FBspeedchange;
        %ev((iblock-1)*FBTRs + 1: iblock*FBTRs ,s) = allsep;
        %speed((iblock-1)*FBTRs + 1: iblock*FBTRs ,s) = FBspeed;
    end
    bySubj_ds{s} = subject_ds;
    bySubj_ev{s} = subject_ev;
    bySubj_speed{s} = subject_speed;
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
thisfig = figure;plotSpread(pl,'xNames',cats,'showMM',2,'yLabel',yl); %this plots the beeswarm
h=gcf;set(h,'PaperOrientation','landscape'); %these two lines grabs some attributes important for plotting significance
xt = get(gca, 'XTick');yt = get(gca, 'YTick');
hold on;plotSig(xt,yt,ps,0);hold off; %keep hold on and do plotSig.
%pn=[picd num2str(vers) '-' num2str(scramm) 'ChangeInPrecision'];%print(pn,'-depsc'); %print fig
ylim([-1.25 1.25])
title('Distribution of Evidence During MOT')
set(findall(gcf,'-property','FontSize'),'FontSize',20)
line([0 46], [0.15 0.15], 'color', [140 136 141]/255, 'LineWidth', 1.5,'LineStyle', '--');
line([0 46], [0.1 0.1], 'color', [0 0 0 ]/255, 'LineWidth', 2.5,'LineStyle', '--');
line([0 46], [0.05 0.05], 'color', [140 136 141]/255, 'LineWidth', 1.5,'LineStyle', '--');
print(thisfig, sprintf('%sbeesbygroup.pdf', allplotDir), '-dpdf')



%violin plots
thisfig = figure;
distributionPlot(pl, 'showMM', 2, 'xNames', cats, 'ylabel', yl, 'colormap', copper)
xlim([.5 2.5])
ylim([-1.25 1.25])
title('Distribution of Evidence During MOT')
xlabel('Subject Group')
set(findall(gcf,'-property','FontSize'),'FontSize',20)
print(thisfig, sprintf('%sviolinsbygroup.pdf', allplotDir), '-dpdf')

%% do separately for each subject

cats = {'R1', 'Y1', 'R2', 'Y2', 'R3', 'Y3', 'R4', 'Y4', 'R5', 'Y5', 'R6', 'Y6'};
pl = {bySubj_ev{iRT_m(1)}', bySubj_ev{iYC_m(1)}', bySubj_ev{iRT_m(2)}', bySubj_ev{iYC_m(2)}', bySubj_ev{iRT_m(3)}', bySubj_ev{iYC_m(3)}', bySubj_ev{iRT_m(4)}', bySubj_ev{iYC_m(4)}',bySubj_ev{iRT_m(5)}', bySubj_ev{iYC_m(5)}', bySubj_ev{iRT_m(6)}', bySubj_ev{iYC_m(6)}'};
for j = 1:length(iRT_m) %do for each pair
    [~,mp(j)] = ttest2(bySubj_ev{iRT_m(j)}',bySubj_ev{iYC_m(j)}');
end
ps = [mp];
yl='Retrieval Evidence During MOT'; %y-axis label
thisfig = figure;plotSpread(pl,'xNames',cats,'showMM',2,'yLabel',yl); %this plots the beeswarm
h=gcf;set(h,'PaperOrientation','landscape'); %these two lines grabs some attributes important for plotting significance
xt = get(gca, 'XTick');yt = get(gca, 'YTick');
hold on;plotSig(1:2:length(iRT_m)*2,yt,ps,0);hold off; %keep hold on and do plotSig.
%pn=[picd num2str(vers) '-' num2str(scramm) 'ChangeInPrecision'];%print(pn,'-depsc'); %print fig
ylim([-1.25 1.25])
set(findall(gcf,'-property','FontSize'),'FontSize',16)
title('Classifier Evidence During MOT by Subject')
%plot bands
line([0 46], [0.15 0.15], 'color', [140 136 141]/255, 'LineWidth', 1.5,'LineStyle', '--');
line([0 46], [0.1 0.1], 'color', [0 0 0 ]/255, 'LineWidth', 2.5,'LineStyle', '--');
line([0 46], [0.05 0.05], 'color', [140 136 141]/255, 'LineWidth', 1.5,'LineStyle', '--');
print(thisfig, sprintf('%sbeesbysubj.pdf', allplotDir), '-dpdf')

%% now look at data

optimal = 0.1;
for s = 1:nsub
   z = bySubj_ev{s}';
   p = bySubj_ds{s}';
   thisSpeed = bySubj_speed{s}';
   [pks,locs] = findpeaks(z);
   overshoot = sum(abs(pks- optimal));
   [lows,minloc] = findpeaks(-1*z);
   undershoot = sum(abs(optimal-lows));
   offshoot(s) = overshoot + undershoot;
   %assume peak is first
   allLoc = sort([locs' minloc']);
   avgdec = [];
   avginc = [];
   for q = 1:length(allLoc)-1
       thisLoc = allLoc(q);
       nextLoc = allLoc(q+1);
       if ismember(thisLoc,locs) && ismember(nextLoc,minloc) %we're decreasing
            %decRange = [allLoc(q):allLoc(q+1)];
            %avgdec = [avgdec mean(p(decRange))];
            
            decRange = [allLoc(q) allLoc(q+1)];
            avgdec = [avgdec diff(thisSpeed(decRange))];
       elseif ismember(thisLoc,minloc) && ismember(nextLoc,locs)
            %incRange = [allLoc(q):allLoc(q+1)];
            %avginc = [avginc mean(p(incRange))];
            
            incRange = [allLoc(q) allLoc(q+1)];
            avginc = [avginc diff(thisSpeed(incRange))];
       end
   end
   dsDecbySub(s) = mean(avgdec);
   dsIncbySub(s) = mean(avginc);
end

% do this as a beeswarm
firstgroup = offshoot(iRT);
secondgroup = offshoot(iYC);
avgratio = [mean(firstgroup) mean(secondgroup)];
eavgratio = [std(firstgroup)/sqrt(length(firstgroup)-1) std(secondgroup)/sqrt(length(secondgroup)-1)];
thisfig = figure;
barwitherr(eavgratio,avgratio)
set(gca,'XTickLabel' , ['RT';'YC']);
xlabel('Subject Group')
ylabel('OffShoot')
title('Offshoots')
set(findall(gcf,'-property','FontSize'),'FontSize',20)
%print(thisfig, sprintf('%sMEANEVIDENCE.pdf', allplotDir), '-dpdf')
%% try to say it's because of feedback
cats = {'EvDec:RT','EvDec:YC', 'EvInc:RT', 'EvInc:YC'};
pl = {dsDecbySub(iRT)', dsDecbySub(iYC)', dsIncbySub(iRT)', dsIncbySub(iYC)'}
clear mp;
[~,mp(1)] = ttest2(dsDecbySub(iRT)',dsDecbySub(iYC)');[~,mp(2)] = ttest2(dsIncbySub(iRT)',dsIncbySub(iYC)');
ps = [mp];
yl='\Delta Speed Before Evidence Changes'; %y-axis label
h = figure;plotSpread(pl,'xNames',cats,'showMM',2,'yLabel',yl); %this plots the beeswarm
h=gcf;set(h,'PaperOrientation','landscape'); %these two lines grabs some attributes important for plotting significance
xt = get(gca, 'XTick');yt = get(gca, 'YTick');
hold on;plotSig([1 3],yt,ps,0);hold off; %keep hold on and do plotSig.
%pn=[picd num2str(vers) '-' num2str(scramm) 'ChangeInPrecision'];%print(pn,'-depsc'); %print fig
%ylim([-1.25 1.25])
set(findall(gcf,'-property','FontSize'),'FontSize',16)
title('Speed Changes Preceeding Min/Max Evidence');
print(h, sprintf('%sdsbeforemax.pdf', allplotDir), '-dpdf')