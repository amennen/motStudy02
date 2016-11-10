%calculate subjective details during MOT
%eh a lot of noise here--next: check whether the 
%cd /Volumes/norman/amennen/behav_test_anne/Participant' Data'/1
%number of participants here

%look at the recognition memory at the end and listen to wav files! (use
%recogdata.m to look at the recognition memory)
clear all;
projectName = 'motStudy02';
base_path = [fileparts(which('mot_realtime01.m')) filesep];

% don't put in 22 until have subject
svec = [8 12 14 15 16 18 20 22 26 27 28 29 30 31 32];
RT = [8 12 14 15 18 22 31];
YC = [16 20 26 27 28 30 32];
RT_m = [8 12 14 15 18 22 31];
YC_m = [16 28 20 26 27 30 32];
iRT = find(ismember(svec,RT));
iYC = find(ismember(svec,YC));

NSUB = length(svec);
recallSession = [19 23];
nstim = 10;
allplotDir = ['/Data1/code/' projectName '/' 'Plots' '/' ];
onlyRem = 0;
easy_rem = {};
hard_rem = {};

iRT_m = find(ismember(svec,RT_m));
for i = 1:length(YC_m)
    iYC_m(i) = find(svec==YC_m(i));
end
for i = 1:length(svec)
    n_rem(i) = length(findRememberedStim(svec(i)));
    remembered{i} = findRememberedStim(svec(i));
end
for i = 1:length(iYC_m)
    overlapping{i} = intersect(remembered{iRT_m(i)},remembered{iYC_m(i)});
end

for s = 1:NSUB
    behavioral_dir = [base_path 'BehavioralData/' num2str(svec(s)) '/'];
    for i = 1:length(recallSession)
        r = dir(fullfile(behavioral_dir, ['EK' num2str(recallSession(i)) '_' 'SUB'  '*.mat'])); 
        r = load(fullfile(behavioral_dir,r(end).name)); 
        trials = table2cell(r.datastruct.trials);
        stimID = cell2mat(trials(:,8));
%         
%         if find(RT_m == svec(s)) %then it's in the RT group
%             matched = find(RT_m == svec(s));
%         elseif find(YC_m == svec(s)) % then in YC group
%             matched = find(YC_m == svec(s));
%         end
%         goodStim = overlapping{matched};
%         goodTrials = find(ismember(stimID,goodStim));
        cond = cell2mat(trials(:,9));
        rating = cell2mat(trials(:,12));
        easy = find(cond==2);
        hard = find(cond==1);
        rating_easy = rating(easy);
        rating_hard = rating(hard);
        %stimID = stimID(goodTrials,:);
        [~, horder] = sort(stimID(find(cond==1)));
        [~, eorder] = sort(stimID(find(cond==2)));
        easy_ordered(i,:) = rating_easy(eorder);
        hard_ordered(i,:) = rating_hard(horder);
        %hAvg(s,i) = nanmean(rating(hard));
        %eAvg(s,i) = nanmean(rating(easy));
        
%         if i==1 && onlyRem % if the first recall sessnion, only take the remembered ones
%            easy_rem{s} = find(easy_ordered(s,:,i)>1);
%            hard_rem{s} = find(hard_ordered(s,:,i) >1); 
%         elseif ~onlyRem
%             easy_rem{s} = 1:nstim;
%             hard_rem{s} = 1:nstim;
%         end
     
    end
    
    diff_easy(s) = nanmean(easy_ordered(2,:) - easy_ordered(1,:));
    diff_hard(s) = nanmean(hard_ordered(2,:) - hard_ordered(1,:));
    clear easy_ordered hard_ordered
    %[allRem] = findRememberedStim(svec(s));
    r = dir(fullfile(behavioral_dir, ['_' 'RECOG'  '*.mat']));
    r = load(fullfile(behavioral_dir,r(end).name));
    trials = table2cell(r.datastruct.trials);
    stimID = cell2mat(trials(:,8));
    %goodTrials = find(ismember(stimID,goodStim));
    cond = cell2mat(trials(:,9));
    acc = cell2mat(trials(:,11));
    rt = cell2mat(trials(:,13));
    easy = find(cond==2);
    hard = find(cond==1);
    easy_score(s) = nanmean(acc(easy));
    hard_score(s) = nanmean(acc(hard));
    easy_rt(s) = nanmedian(rt(easy));
    hard_rt(s) = nanmedian(rt(hard));
    
end

% diff_easy = easy_ordered(:,easy_rem{s},2) - easy_ordered(:,easy_rem{s},1);
% diff_hard = hard_ordered(:,hard_rem{s},2) - hard_ordered(:,hard_rem{s},1);
e_ALL = nanmean(diff_easy);
h_ALL = nanmean(diff_hard);

ee_ALL = nanstd(diff_easy)/sqrt(NSUB-1);
eh_ALL = nanstd(diff_hard)/sqrt(NSUB-1);

eALLD = [eh_ALL; ee_ALL];
ALLD = [h_ALL; e_ALL];
h = figure;
barwitherr(eALLD,ALLD)
set(gca,'XTickLabel' , ['RT  '; 'Omit']);
title('Average Post - Pre Difference')
xlabel('Stim Type')
ylabel('Level of Detail Difference')
%ylim([1 5.5])
fig=gcf;
set(findall(fig,'-property','FontSize'),'FontSize',20)
%legend('Pre MOT', 'Post MOT')
%print(h, sprintf('%sYCONLY_ratings.pdf', allplotDir), '-dpdf')




%% level of detail differences across groups
firstgroup = [diff_hard(iRT); diff_easy(iRT)];
secondgroup = [diff_hard(iYC); diff_easy(iYC)];
avgratio = [nanmean(firstgroup,2) nanmean(secondgroup,2)];
eavgratio = [nanstd(firstgroup,[],2)/sqrt(length(firstgroup)-1) nanstd(secondgroup,[],2)/sqrt(length(secondgroup)-1)];
thisfig = figure;
barwitherr(eavgratio,avgratio)
set(gca,'XTickLabel' , ['MOT ';'OMIT']);
legend('Realtime', 'Yoked')
xlabel('Stimulus Type')
ylabel('Level of Detail Difference')
title('Average Post - Pre Detail Difference')
set(findall(gcf,'-property','FontSize'),'FontSize',20)
ylim([-.4 .8])
print(thisfig, sprintf('%salldetailRatings.pdf', allplotDir), '-dpdf')



cats = {'RT-MOT', 'YC-MOT', 'RT-OMIT', 'YC-OMIT'};
pl = {diff_hard(iRT), diff_hard(iYC), diff_easy(iRT), diff_easy(iYC)};
%clear mp;
%[~,mp] = ttest2(distDec2(iRT),distDec2(iYC));
%ps = [mp];
yl='Change in Imagery Detail'; %y-axis label
h = figure;plotSpread(pl,'xNames',cats,'showMM',2,'yLabel',yl); %this plots the beeswarm
h=gcf;set(h,'PaperOrientation','landscape'); %these two lines grabs some attributes important for plotting significance
%xt = get(gca, 'XTick');yt = get(gca, 'YTick');
%hold on;plotSig([1 2],yt,ps,0);hold off; %keep hold on and do plotSig.
%pn=[picd num2str(vers) '-' num2str(scramm) 'ChangeInPrecision'];%print(pn,'-depsc'); %print fig
%ylim([-1.25 1.25])
set(findall(gcf,'-property','FontSize'),'FontSize',16)
title('Post - Pre MOT Change in Detail');
print(h, sprintf('%sbeesdetails.pdf', allplotDir), '-dpdf')




%% recognition accuracy
firstgroup = [hard_score(iRT); easy_score(iRT)];
secondgroup = [hard_score(iYC); easy_score(iYC)];
avgratio = [nanmean(firstgroup,2) nanmean(secondgroup,2)];
eavgratio = [nanstd(firstgroup,[],2)/sqrt(length(firstgroup)-1) nanstd(secondgroup,[],2)/sqrt(length(secondgroup)-1)];
thisfig = figure;
barwitherr(eavgratio,avgratio)
set(gca,'XTickLabel' , ['MOT ';'OMIT']);
legend('Realtime', 'Yoked')
xlabel('Stimulus Type')
ylabel('Recognition Rate')
title('Recognition Accuracy')
set(findall(gcf,'-property','FontSize'),'FontSize',20)
ylim([0 1])
%print(thisfig, sprintf('%sallrecogAcc.pdf', allplotDir), '-dpdf')
%% recognition RT
firstgroup = [hard_rt(iRT); easy_rt(iRT)];
secondgroup = [hard_rt(iYC); easy_rt(iYC)];
avgratio = [nanmedian(firstgroup,2) nanmedian(secondgroup,2)];
eavgratio = [nanstd(firstgroup,[],2)/sqrt(length(firstgroup)-1) nanstd(secondgroup,[],2)/sqrt(length(secondgroup)-1)];
thisfig = figure;
barwitherr(eavgratio,avgratio)
set(gca,'XTickLabel' , ['MOT ';'OMIT']);
legend('Realtime', 'Yoked')
xlabel('Stimulus Type')
ylabel('RT (s)')
title('Recognition RT')
set(findall(gcf,'-property','FontSize'),'FontSize',20)
ylim([0 1])
%print(thisfig, sprintf('%sallrecogRT.pdf', allplotDir), '-dpdf')