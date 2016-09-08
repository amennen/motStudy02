%calculate subjective details during MOT
%eh a lot of noise here--next: check whether the 
%cd /Volumes/norman/amennen/behav_test_anne/Participant' Data'/1
%number of participants here

%look at the recognition memory at the end and listen to wav files! (use
%recogdata.m to look at the recognition memory)
projectName = 'motStudy02';
svec = 8:14;
NSUB = length(svec);
recallSession = [19 23];
nstim = 10;
allplotDir = ['/Data1/code/' projectName '/' 'Plots' '/' ];

for s = 1:NSUB
    behavioral_dir = ['/Data1/code/' projectName '/' 'code' '/BehavioralData/' num2str(svec(s)) '/'];
    for i = 1:length(recallSession)
        r = dir(fullfile(behavioral_dir, ['EK' num2str(recallSession(i)) '_' 'SUB'  '*.mat'])); 
        r = load(fullfile(behavioral_dir,r(end).name)); 
        trials = table2cell(r.datastruct.trials);
        stimID = cell2mat(trials(:,8));
        cond = cell2mat(trials(:,9));
        rating = cell2mat(trials(:,12));
        easy = find(cond==2);
        hard = find(cond==1);
        rating_easy = rating(easy);
        rating_hard = rating(hard);
        [~, horder] = sort(stimID(find(cond==1)));
        [~, eorder] = sort(stimID(find(cond==2)));
        easy_ordered(s,1:nstim,i) = rating_easy(eorder);
        hard_ordered(s,1:nstim,i) = rating_hard(horder);
        %hAvg(s,i) = nanmean(rating(hard));
        %eAvg(s,i) = nanmean(rating(easy));
    end
end

diff_easy = easy_ordered(:,:,2) - easy_ordered(:,:,1);
diff_hard = hard_ordered(:,:,2) - hard_ordered(:,:,1);
e_ALL = nanmean(nanmean(diff_easy,2));
h_ALL = nanmean(nanmean(diff_hard,2));

ee_ALL = nanstd(nanmean(diff_easy,2))/sqrt(NSUB-1);
eh_ALL = nanstd(nanmean(diff_hard,2))/sqrt(NSUB-1);

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
print(h, sprintf('%sratingsRt.pdf', allplotDir), '-dpdf')




%%

