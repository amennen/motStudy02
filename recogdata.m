%recognition task
recog = 24; %associates task
projectName = 'motStudy02';
allplotDir = ['/Data1/code/' projectName '/' 'Plots' '/' ];

svec = 8:14;
NSUB = length(svec);

for s = 1:NSUB
    behavioral_dir = ['/Data1/code/' projectName '/' 'code' '/BehavioralData/' num2str(svec(s)) '/'];
        r = dir(fullfile(behavioral_dir, ['_' 'RECOG'  '*.mat'])); 
        r = load(fullfile(behavioral_dir,r(end).name)); 
        trials = table2cell(r.datastruct.trials);
        stimID = cell2mat(trials(:,8));
        cond = cell2mat(trials(:,9));
        acc = cell2mat(trials(:,11));
        rt = cell2mat(trials(:,13));
        easy = find(cond==2);
        hard = find(cond==1);
        easy_score(s) = mean(acc(easy));
        hard_score(s) = mean(acc(hard));
        easy_rt(s) = nanmean(rt(easy));
        hard_rt(s) = nanmean(rt(hard));
end
eALLD = [std(hard_score)/sqrt(NSUB-1);std(easy_score)/sqrt(NSUB-1)];
ALLD = [mean(hard_score); mean(easy_score)];
h = figure;
barwitherr(eALLD,ALLD)
set(gca,'XTickLabel' , ['RT  '; 'Omit']);
title('Recognition Accuracy')
xlabel('Stim Type')
ylabel('Recognition Rate (%)')
%ylim([1 5.5])
fig=gcf;
set(findall(fig,'-property','FontSize'),'FontSize',20)
print(h, sprintf('%srecogacc.pdf', allplotDir), '-dpdf')

eALLD = [nanstd(hard_rt)/sqrt(NSUB-1);nanstd(easy_rt)/sqrt(NSUB-1)];
ALLD = [nanmean(hard_rt); nanmean(easy_rt)];
h = figure;
barwitherr(eALLD,ALLD)
set(gca,'XTickLabel' , ['RT  '; 'Omit']);
title('Recognition RT')
xlabel('Stim Type')
ylabel('RT (s)')
%ylim([1 5.5])
fig=gcf;
set(findall(fig,'-property','FontSize'),'FontSize',20)
print(h, sprintf('%srecogrt.pdf', allplotDir), '-dpdf')
