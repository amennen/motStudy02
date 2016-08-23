% here: going to quantify how long it takes to drop down classifier
% evidence
% can compare between the two versions and with realtime and non realtime
% versions

% need: speed (from behavioral file)
% category separation (can also pull from behavioral file)
close all;
clear all;
projectName = 'motStudy02';
allspeeds = [];
allsep = [];
nstim = 10;
nTRs = 15;
sepTRs = 17;
nblock = 3;

%if both zero, then look at all subjects for differences
updated =0; %for only looking at the results recorded after making differences (minimum dot speed, increase starting speed, average over 2)
oldonly = 0;

nnew = 4;
nold = 4;
svec = [3:5 7:11];
if updated
    svec = svec(end-nnew +1:end);
elseif oldonly
    svec = svec(1:nold);
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
        %blockNum = SESSION - 20 + 1;
        
        %behavioral_dir = ['/Data1/code/' projectName '/' 'code' '/BehavioralData/' num2str(subjectNum) '/'];
        behavioral_dir = [fileparts(which('mot_realtime01.m')) '/BehavioralData/' num2str(subjectNum) '/'];
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
        allMotionTRs = [allMotionTRs; allMotionTRs(end,:)+1; allMotionTRs(end,:) + 2]; %add in the next 2 TR's for HDF
        TRvector = reshape(allMotionTRs,1,numel(allMotionTRs));
        run = dir([runHeader 'motpatternsdata_' num2str(SESSION) '*']);
        run = load(fullfile(runHeader,run(end).name));
        categsep = run.patterns.categsep(TRvector - 10); %minus 10 because we take out those 10
        sepbytrial = reshape(categsep,17,10);
        sepbytrial = sepbytrial'; %results by trial number, TR number
        speedbytrial = reshape(speedVector,nTRs,nstim);
        speedbytrial = speedbytrial';
        [~,indSort] = sort(d.stim.id);
        sepinorder = sepbytrial(indSort,:);
        speedinorder = speedbytrial(indSort,:);
        sepbystim(:,(iblock-1)*sepTRs + 1: iblock*sepTRs ) = sepinorder;
        speedbystim(:,(iblock-1)*nTRs + 1: iblock*nTRs ) = speedinorder;

    end
    
    if s < 8 %average over 3 TR's
        vec2avg = [0.1*ones(10,2) sepbystim];
        for i = 1:size(sepbystim,2)
            smoothedsep(:,i) = mean(vec2avg(:,i:i+2),2);
        end
    else %average over 2 TR's
        vec2avg = [0.1*ones(10,1) sepbystim];
        for i = 1:size(sepbystim,2)
            smoothedsep(:,i) = mean(vec2avg(:,i:i+1),2);
        end
    end
 
    for i = 1:nstim
        %thisSep = smoothedsep(i,:); %can choose to look at smoothed
        %version or raw separation
        thisSep = sepbystim(i,:);
        highPts = find(thisSep>0.1);
        dist = nan(1,length(highPts));
        for h = 1:length(highPts)
            newvals = thisSep(highPts(h)+1:end);
            nextdown = find(newvals<0);
            if ~isempty(nextdown)
                dist(h) = nextdown(1);
            end
        end
        distDec1(s,i) = nanmean(dist);
    end
    distDec2 = nanmean(distDec1,2);
    
end

%% now compare decrease of retrieval evidence across both groups
if (~updated && ~oldonly)
    firstgroup = distDec2(1:4);
    nnew = 4;
    secondgroup = distDec2(end-nnew+1:end);
    avgratio = [mean(firstgroup) mean(secondgroup)];
    eavgratio = [std(firstgroup)/sqrt(length(firstgroup)-1) std(secondgroup)/sqrt(length(secondgroup)-1)];
    thisfig = figure;
    barwitherr(eavgratio,avgratio)
    set(gca,'XTickLabel' , ['Old 4';'New 4']);
    xlabel('Subject Group')
    ylabel('TR''s to Decrease')
    title('Time to Decrease Evidence by Group')
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    %ylim([-.2 0.2])
    print(thisfig, sprintf('%sweakeningbygroup.pdf', allplotDir), '-dpdf')
end

