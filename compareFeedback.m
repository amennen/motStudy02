% compare feedback

%close all;
clear all;
projectName = 'motStudy02';
allspeeds = [];
allsep = [];
nstim = 10;
nTRs = 15;
sepTRs = 17;
FBTRs = 11;
nblock = 3;

svec = [8 12 14 15 16 18 20:21 26 27 28 29];
RT = [8 12 14 15 18 21];
YC = [16 20 26 27 28 29];
RT_m = [8 12 14 15 18 21];
YC_m = [16 28 20 26 27 29];
iRT = find(ismember(svec,RT));
iYC = find(ismember(svec,YC));
iRT_m = find(ismember(svec,RT_m));
for i = 1:length(YC_m)
    iYC_m(i) = find(svec==YC_m(i));
end

nsub = length(svec);
sepbystim = zeros(nstim,nTRs*3);
speedbystim = zeros(nstim,nTRs*3);
allplotDir = ['/Data1/code/' projectName '/' 'Plots' '/' ];

for s = 1:nsub
    timecourse_high = [];
    timecourse_low = [];
    
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
        nTotalTR = 120; %120 fb TR's per block
        allSmoothedFb((iblock-1)*nTotalTR + 1: iblock*nTotalTR ,s)  =  d.rtData.smoothRTDecodingFunction(~isnan(d.rtData.smoothRTDecodingFunction));
        
       
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
        
        %look get avg time when above .1
        highPts = find(allsep > 0.1);
        avgRange = 5; %number of TR's
        keepHigh =  highPts(highPts < length(allsep) - avgRange);
        for j = 1:length(keepHigh)
            timecourse_high(end+1,:) = allsep(keepHigh(j):keepHigh(j)+5);
        end
        lowPts = find(allsep < -.1);
        keepLow = lowPts(lowPts <length(allsep) - avgRange);
        for j = 1:length(keepLow)
            timecourse_low(end+1,:) = allsep(keepLow(j):keepLow(j)+5);
        end
    end
    avg_high(s,:) = mean(timecourse_high);
    avg_low(s,:) = mean(timecourse_low);
end

%% now separate plots into RT and YC groups
ds_RT = ds(:,iRT);
allds_RT = reshape(ds_RT,1,numel(ds_RT));
ev_RT = ev(:,iRT);
allev_RT = reshape(ev_RT,1,numel(ev_RT));

ds_YC = ds(:,iYC);
allds_YC = reshape(ds_YC,1,numel(ds_YC));
ev_YC = ev(:,iYC);
allev_YC = reshape(ev_YC,1,numel(ev_YC));


figure;
scatter(allds_RT,allev_RT,'fill','MarkerEdgeColor','b',...
        'MarkerFaceColor','c',...
        'LineWidth',2.5);
[rho,pval] = corrcoef([allds_RT' allev_RT']);
hold on;
scatter(allds_YC,allev_YC,'fill','MarkerEdgeColor','k',...
        'MarkerFaceColor','r',...
        'LineWidth',2.5);
    
[rho,pval] = corrcoef([allds_YC' allev_YC']);
%% look for differences in signal stability: find peaks and take difference
optimal = 0.1;
for s = 1:nsub
   z = ev(:,s);
   p = ds(:,s);
   thisSpeed = speed(:,s);
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

%% prove that more over and undershooting is because of feedback (relate previous dot speed to evidence max or min)

% between one peak and the next min-- ask what the change in speed was
% between those points?
firstgroup = [dsDecbySub(iRT); dsIncbySub(iRT)];
secondgroup = [dsDecbySub(iYC); dsIncbySub(iYC)];
avgratio = [nanmean(firstgroup,2) nanmean(secondgroup,2)];
eavgratio = [nanstd(firstgroup,[],2)/sqrt(length(firstgroup)-1) nanstd(secondgroup,[],2)/sqrt(length(secondgroup)-1)];
thisfig = figure;
barwitherr(eavgratio,avgratio)
set(gca,'XTickLabel' , ['EvDec';'EvInc']);
legend('Realtime', 'Yoked')
xlabel('Average ds Leading to Min/Max')
ylabel('Avg Change of Dot Speed')
title('Speed Changes Preceeding Min/Max')
set(findall(gcf,'-property','FontSize'),'FontSize',20)
%ylim([-.4 .8])
%print(h, sprintf('%sallrecogRT.pdf', allplotDir), '-dpdf')

%% now look at correlations between smoothed evidence in feedback
clear rho
clear pval
for imatch = 1:length(iRT_m)
    RTsub = iRT_m(imatch);
    YCsub = iYC_m(imatch);
    [rho(imatch) pval(imatch)] = corr(allSmoothedFb(:,RTsub),allSmoothedFb(:,YCsub));
    
    %[rhoLag(imatch) pvalLag(imatch)] = corr(lagSmoothedFb(:,RTsub),lagSmoothedFb(:,YCsub));
    RTB = reshape(allSmoothedFb(:,RTsub),120,3);
    RTB_1 = reshape(RTB(:,1),12,10);
    RTB_2 = reshape(RTB(:,2),12,10);
    RTB_3 = reshape(RTB(:,3),12,10);
    
    YCB = reshape(allSmoothedFb(:,YCsub),120,3);
    YCB_1 = reshape(YCB(:,1),12,10);
    YCB_2 = reshape(YCB(:,2),12,10);
    YCB_3 = reshape(YCB(:,3),12,10);
        for shift = 0:5
            RTnew1 = RTB_1(1:end-shift,:);
            YCnew1 = YCB_1(1:end-shift,:);
            RTnew2 = RTB_2(1:end-shift,:);
            YCnew2 = YCB_2(1:end-shift,:);
            RTnew3 = RTB_3(1:end-shift,:);
            YCnew3 = YCB_3(1:end-shift,:);
            newRT = [reshape(RTnew1,1,numel(RTnew1)) reshape(RTnew2,1,numel(RTnew2)) reshape(RTnew3,1,numel(RTnew3))];
            newYC = [reshape(YCnew1,1,numel(RTnew1)) reshape(YCnew2,1,numel(RTnew2)) reshape(YCnew3,1,numel(RTnew3))];
            [rhoLag(imatch,shift+1) pvalLag(imatch,shift+1)] = corr(newRT',newYC');
        end
end

h1 = figure;
%alldiffmeans = [RTavg;OMITavg];
%alldiffstd = [std(PrePostRT)/sqrt(size(PrePostRT,1)-1);std(PrePostOMIT)/sqrt(size(PrePostRT,1)-1)];
allrho = nanmean(rhoLag);
erho = nanstd(rhoLag,[],1)/sqrt(length(iRT_m)-1);
mseb(1:length(allrho),allrho, erho);
title(sprintf('RT and YC Feedback Correlation by Shift'))
set(gca, 'XTick', [1:length(allrho)])
%set(gca,'XTickLabel',['-2'; '-1'; ' 0'; ' 1'; ' 2'; ' 3'; ' 4'; ' 5'; '6'; '7'; '8'; '9'; ']);
ylabel('Correlation')
xlabel('YC TR Shift')
set(findall(gcf,'-property','FontSize'),'FontSize',16)
%line([3 3], [-1 1], 'Color', 'k', 'LineWidth', 3);
%line([6 6], [-1 1], 'Color', 'k', 'LineWidth', 3);

%xlim([1 nTRsperTrial])
%xlim([1 8])
%ylim([-.25 .25])
print(h1, sprintf('%scorrelationRTYC.pdf', allplotDir), '-dpdf') 

cats = {'1','2', '3', '4', '5'};
pl = {rhoLag(:,1), rhoLag(:,2), rhoLag(:,3), rhoLag(:,4),rhoLag(:,5) };
%clear mp;
%[~,mp(1)] = ttest2(dsDecbySub(iRT)',dsDecbySub(iYC)');[~,mp(2)] = ttest2(dsIncbySub(iRT)',dsIncbySub(iYC)');
%ps = [mp];
yl='RT YC Correlation'; %y-axis label
h = figure;plotSpread(pl,'xNames',cats,'showMM',2,'yLabel',yl); %this plots the beeswarm
h=gcf;set(h,'PaperOrientation','landscape'); %these two lines grabs some attributes important for plotting significance
xt = get(gca, 'XTick');yt = get(gca, 'YTick');
%hold on;plotSig([1 3],yt,ps,0);hold off; %keep hold on and do plotSig.
%pn=[picd num2str(vers) '-' num2str(scramm) 'ChangeInPrecision'];%print(pn,'-depsc'); %print fig
%ylim([-1.25 1.25])
set(findall(gcf,'-property','FontSize'),'FontSize',16)
title('Correlation between RT and YC');
xlabel('YC Lag Behind RT')
print(h, sprintf('%sbeescorrelationRTYC.pdf', allplotDir), '-dpdf') 
%% prove that more over and undershooting is because of feedback (relate previous dot speed to evidence max or min)

% between one peak and the next min-- ask what the change in speed was
% between those points?
timeHigh = [ mean(avg_high(iRT,:)); mean(avg_high(iYC,:))];
eHigh = [nanstd(avg_high(iRT,:),[],1)/sqrt(length(iRT)-1) ;nanstd(avg_high(iYC,:),[],1)/sqrt(length(iYC)-1)];
h = figure;
mseb(1:avgRange+1,timeHigh, eHigh);
title(sprintf('High Timecourse'))
set(gca, 'XTick', [1:avgRange+1])
%set(gca,'XTickLabel',['-2'; '-1'; ' 0'; ' 1'; ' 2'; ' 3'; ' 4'; ' 5'; '6'; '7'; '8'; '9'; ']);
ylabel('Retrieval - Control Evidence')
xlabel('Time Points')
set(findall(gcf,'-property','FontSize'),'FontSize',16)
legend('Real-time', 'Yoked')
print(h, sprintf('%sHighTimecourse.pdf', allplotDir), '-dpdf') 

%% do the same for low points
timelow = [ mean(avg_low(iRT,:)); mean(avg_low(iYC,:))];
elow = [nanstd(avg_low(iRT,:),[],1)/sqrt(length(iRT)-1) ;nanstd(avg_low(iYC,:),[],1)/sqrt(length(iYC)-1)];
h = figure;
mseb(1:avgRange+1,timelow, elow);
title(sprintf('Low Timecourse'))
set(gca, 'XTick', [1:avgRange+1])
%set(gca,'XTickLabel',['-2'; '-1'; ' 0'; ' 1'; ' 2'; ' 3'; ' 4'; ' 5'; '6'; '7'; '8'; '9'; ']);
ylabel('Retrieval - Control Evidence')
xlabel('Time Points')
set(findall(gcf,'-property','FontSize'),'FontSize',16)
legend('Real-time', 'Yoked')
print(h, sprintf('%sLowTimecourse.pdf', allplotDir), '-dpdf') 
