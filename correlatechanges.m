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
        
        inst = 9;
        for jstart = 1:inst
            allvec = jstart:2:jstart+6;
            s1 = allvec(1);
            s2 = allvec(3);
            c1 = allvec(2);
            c2 = allvec(4);
            dspeed = diff(speedinorder(:,[s1 s2]));
            dsep = diff(sepinorder(:,[c1 c2]));
        end
        %right now doing in three dimensions to separate by subject but can
        %also do version where not separated by subject and make into two
        %dimensions
        allspeedchanges(:,(iblock-1)*inst + 1: iblock*inst,s) = dspeed;
        allsepchanges(:,(iblock-1)*inst + 1: iblock*inst,s) = dsep;
        scatter(allspeedchanges,allsepchanges)
        
    end
    %look up how to change yaxis categories
    %do to later: rearrange all motion trials by stimulus ID and then plot on
    %subplots every block
    
    
    
    
    
end
