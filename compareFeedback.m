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

svec = [8 12:16 18 20:22 24 26 27 28 29];
RT = [8 12:15 18 21 22];
YC = [16 20 24 26 27 28 29];
iRT = find(ismember(svec,RT));
iYC = find(ismember(svec,YC));

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