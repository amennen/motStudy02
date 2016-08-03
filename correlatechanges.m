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
sepTRs = 17;
nblock = 3;
svec = [3:5 7];
nsub = length(svec);
sepbystim = zeros(nstim,nTRs*3);
speedbystim = zeros(nstim,nTRs*3);
num2avg = 3; %including starting point

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
        x = 1:length(speedVector);
        
        inst = 11;
        for jstart = 1:inst
            allvec = jstart:2:jstart+6;
            s1 = allvec(1);
            s2 = allvec(3);
            c1 = allvec(2);
            c2 = allvec(4);
            dspeed(:,jstart) = diff(speedinorder(:,[s1 s2]),1,2);
            dsep(:,jstart) = diff(sepinorder(:,[c1 c2]),1,2);
        end
        %right now doing in three dimensions to separate by subject but can
        %also do version where not separated by subject and make into two
        %dimensions
        allspeedchanges(:,(iblock-1)*inst + 1: iblock*inst,s) = dspeed;
        allsepchanges(:,(iblock-1)*inst + 1: iblock*inst,s) = dsep;
        
        
        maxsep = 17-(num2avg -1);
        inst = maxsep - 6;
        takeAverage = 1;
        if takeAverage
            for jstart = 1:inst
                allvec = jstart:2:jstart+6;
                s1 = allvec(1):allvec(1)+num2avg-1;
                s2 = allvec(3):allvec(3)+num2avg-1;
                c1 = allvec(2):allvec(2)+num2avg-1;
                c2 = allvec(4):allvec(4)+num2avg-1;
                avgdSpeed(:,jstart) = diff([mean(speedinorder(:,s1),2) mean(speedinorder(:,s2),2)],1,2);
                avgdSep(:,jstart) = diff([mean(sepinorder(:,c1),2) mean(sepinorder(:,c2),2)],1,2);
            end
        end
        allavgspeed(:,(iblock-1)*inst + 1: iblock*inst,s) = avgdSpeed;
        allavgsep(:,(iblock-1)*inst + 1: iblock*inst,s) = avgdSep;
        
    end
    newspeeds = reshape(allspeedchanges(:,:,s),1,numel(allspeedchanges(:,:,s)));
    newseps = reshape(allsepchanges(:,:,s),1,numel(allsepchanges(:,:,s)));
    izero = find(newspeeds==0);
   % newspeeds(izero) = [];
   % newseps(izero) = [];
    
    h = figure;
    x = newspeeds;
    y = newseps;
    scatter(newspeeds,newseps,'fill','MarkerEdgeColor','b',...
        'MarkerFaceColor','c',...
        'LineWidth',2.5);
    xlabel('Speed Change')
    ylabel('Classification Change')
    [rho,pval] = corrcoef([newspeeds' newseps']);
    text(2,.85,['corr = ' num2str(rho(1,2))]);
    text(2,.65, ['p = ' num2str(pval(1,2))])
    
    p = polyfit(x,y,1);
    yfit = polyval(p,x)
    hold on;
    plot(x,yfit, '--k', 'LineWidth', 3);
    text(2,.45, ['slope = ' num2str(p(1))])
    
    ylim([-1 1])
    xlim([-6 6 ])
    title(sprintf('Subject %i Post Rating vs. Evidence',subjectNum));
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    print(h, sprintf('%scorrelations.pdf', plotDir), '-dpdf')
    
    %look up how to change yaxis categories
    %do to later: rearrange all motion trials by stimulus ID and then plot on
    %subplots every block
    
    
    newavgspeeds = reshape(allavgspeed(:,:,s),1,numel(allavgspeed(:,:,s)));
    newavgseps = reshape(allavgsep(:,:,s),1,numel(allavgsep(:,:,s)));
    izero = find(newavgspeeds==0);
    %newavgspeeds(izero) = [];
    %newavgseps(izero) = [];
    h = figure;
    x = newavgspeeds;
    y = newavgseps;
    scatter(x,y,'fill','MarkerEdgeColor','b',...
        'MarkerFaceColor','c',...
        'LineWidth',2.5);
    xlabel('Speed Change')
    ylabel('Classification Change')
    [rho,pval] = corrcoef([x' y']);
    text(2,.85,['corr = ' num2str(rho(1,2))]);
    text(2,.65, ['p = ' num2str(pval(1,2))]);
    
    p = polyfit(x,y,1);
    yfit = polyval(p,x);
    hold on;
    plot(x,yfit, '--k', 'LineWidth', 3);
    text(2,.45, ['slope = ' num2str(p(1))]);
    
    ylim([-1 1])
    xlim([-6 6 ])
    title(sprintf('AVG Subject %i Post Rating vs. Evidence',subjectNum));
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
   print(h, sprintf('%sAVG%i_correlations.pdf', plotDir,num2avg), '-dpdf')
end
