%cd /Volumes/norman/amennen/behav_test_anne/Participant' Data'/1
%number of participants here
cd /Volumes/norman/amennen/behav_test_anne/Participant' Data'/
base_path = [fileparts(which('behav_test_anne.m')) filesep];
PICFOLDER = [base_path 'stimuli/FIGRIM/ALLSCENES/'];
num_subjects = 1:21;
exclude_subj = [2 14];
subvec = setdiff(num_subjects,exclude_subj);
N_mTurk = 9;
trialcolumns = [2:25];
subvec = setdiff(num_subjects,exclude_subj);
counter = 1;
c2 = 1;
c8 = 1;
skip = 0;
n8 = 0;
for s = 1:length(subvec)
    cd(num2str(subvec(s)))
    setup = load(['behav_subj_' num2str(subvec(s)) '_stimAssignment.mat']);
    r1F = dir('EK19*mat');
    r1 = load(r1F.name);
    trials = table2cell(r1.datastruct.trials);
    stimID = cell2mat(trials(:,9));
    cond = cell2mat(trials(:,10));
    sorted = sort(setup.pics);
    resp = xlsread(['S' num2str(subvec(s)) 'R1.xlsx']);
    resp = resp(:,trialcolumns);
    trialcolumns= [2:25]; %this maps onto trials 1-24
    r2F = dir('EK23*mat');
    r2 = load(r2F.name);
    trials2 = table2cell(r2.datastruct.trials);
    stim2 = cell2mat(trials2(:,9));
    cond2 = cell2mat(trials2(:,10));
    resp2 = xlsread(['S' num2str(subvec(s)) 'R2.xlsx']);
    resp2 = resp2(:,trialcolumns);
    if skip
    skipPics = findrepeats(setup.pics);
    [c TC1] = setdiff(stimID,skipPics, 'stable');
    [c TC2] = setdiff(stim2,skipPics, 'stable');
    else
        TC1 = trialcolumns;
        TC2 = trialcolumns;
    end
    
    for i=1:length(TC1)
        if skip
            col = TC1(i);
        else
            col = i;
        end
        allresp = resp(:,col);
        
        rightchoiceIndex = stimID(col);
        rightfile = setup.pics{rightchoiceIndex};
        rightchoice = find(strcmp(sorted,rightfile));
        
        
        [N,ed,c] = histcounts(allresp,'BinMethod','integers');
        Z = sort(N,'descend');
        if Z(1)~= 9
        P = find(N == Z(2));
        SECRESP = ceil(ed(P));
        end
        if mode(allresp) == rightchoice
            COR = 1;
        elseif SECRESP == rightchoice
            COR =2;
        else
            COR = 0;
        end
    
        if Z(1) == 9 
            M(counter,:) = [Z 0 COR];
            if ~COR
                mode(allresp);
            end
        else
            M(counter,:) = [Z(1:2) COR]; %save first and second mode
        end
        
        if mode(allresp) == rightchoice
            acc1(1,rightchoiceIndex) = 1;
        else
            acc1(1,rightchoiceIndex) = 0;
        end
        acc1(2,rightchoiceIndex) = cond(col);
        [mode1(c8) agree1(c8)] = mode(allresp);
        modeisright1(c8) = rightchoice == mode1(c8);
        nright = length(find(allresp==rightchoice));
        rightcounter(counter)= nright;
       %to find setuppics index of sorted file = find(strcmp(sorted{19},setup.pics))
%         if nright == 8
%             n8 = n8 + 1;
%             %fprintf('the correct picture is %s \n', rightfile);
%             i_wrong = find(allresp~=rightchoice);
%             wrongpic = allresp(i_wrong);
%             if wrongpic == 30
%                 fprintf('CHOOSE NONE\n');
%             else
%                 wrongfile = sorted{wrongpic};
%             %fprintf('but the one chosen incorrectly was %s \n', wrongpic);
%             figure
%             
%             %title(['subject ' num2str(subvec(s)) '; trial ' num2str(TC1(i))]);
%             subplot(1,2,1)
%             imshow(strcat(PICFOLDER, rightfile));
%             title('Correct Choice')
%             subplot(1,2,2)
%             imshow(strcat(PICFOLDER, wrongfile));
%             title('Wrong Choice')
%             text(0.5, 1,['ONE subject ' num2str(subvec(s)) '; trial ' num2str(TC1(i))],'HorizontalAlignment',...
%                 'center','VerticalAlignment', 'top')
%             axis square
%             
%             end
%         end
        counter = counter + 1;
        c8 = c8+1;
    end
    
   
    %TC2 = [50:61, 75:86];
    
    for i=1:length(TC1)
        if skip
            col = TC2(i);
        else
            col = i;
        end
        allresp = resp2(:,col);
        
        rightchoiceIndex = stim2(col);
        rightfile = setup.pics{rightchoiceIndex};
        rightchoice = find(strcmp(sorted,rightfile));
        
       [N,ed,c] = histcounts(allresp,'BinMethod','integers');
        Z = sort(N,'descend');
        if Z(1)~= 9
        P = find(N == Z(2));
        SECRESP = ceil(ed(P));
        end
        if mode(allresp) == rightchoice
            COR = 1;
        elseif SECRESP == rightchoice
            COR =2;
        else
            COR = 0;
        end
    
        if Z(1) == 9 
            M(counter,:) = [Z 0 COR];
            if ~COR
                mode(allresp);
            end
        else
            M(counter,:) = [Z(1:2) COR]; %save first and second mode
        end
        
        if mode(allresp) == rightchoice
            acc2(1,rightchoiceIndex) = 1;
        else
            acc2(1,rightchoiceIndex) = 0;
        end
        [mode2(c2) agree2(c2)] = mode(allresp);
        modeisright2(c2) = rightchoice == mode2(c2);
        acc2(2,rightchoiceIndex) = cond2(col);
        nright = length(find(allresp==rightchoice));
        rightcounter(counter)= nright;
%         if nright == 8
%             n8 = n8 + 1;
%             %fprintf('the correct picture is %s \n',rightfile);
%             i_wrong = find(allresp~=rightchoice);
%             wrongpic = allresp(i_wrong);
%             if wrongpic == 30
%                 fprintf('CHOSE NONE\n')
%             else
%                 wrongfile = sorted{wrongpic};
%             %fprintf('but the one chosen incorrectly was %s \n', wrongpic);
%             figure
%             title(['subject ' num2str(subvec(s)) '; trial ' num2str(TC1(i))]);
%             subplot(1,2,1)
%             imshow(strcat(PICFOLDER, rightfile));
%             title('Correct Choice')
%             subplot(1,2,2)
%             imshow(strcat(PICFOLDER, wrongfile));
%             title('Wrong Choice')
%             text(0.5, 1,['TWO subject ' num2str(subvec(s)) '; trial ' num2str(TC2(i))],'HorizontalAlignment',...
%                 'center','VerticalAlignment', 'top')
%             axis square
%              
%             end
%         end
        c2 = c2 +1;
        counter = counter + 1;
    end
    
    %now only take those columns that were nonrepeated
    acc1 = acc1(:,find(acc1(2,:)~=0));
    acc2 = acc2(:,find(acc2(2,:)~=0));
    
    %omit 3 easy 2 hard 1
    %accuracydiff = acc(1,:) - acc2(1,:); %1-2
    omit = find(acc2(2,:)==3);
    easy = find(acc2(2,:)==2);
    hard = find(acc2(2,:)==1);
    
    hAvg = [mean(acc1(1,hard)) mean(acc2(1,hard))];
    eAvg = [mean(acc1(1,easy)) mean(acc2(1,easy))];
    oAvg = [mean(acc1(1,omit)) mean(acc2(1,omit))];
    ALLDATA(s,:) = [hAvg eAvg oAvg];
    
%     EhAvg = [std(acc1(1,hard)) std(acc2(1,hard))]/sqrt(N_mTurk-1);
%     EeAvg = [std(acc1(1,easy)) std(acc2(1,easy))]/sqrt(N_mTurk-1);
%     EoAvg = [std(acc1(1,omit)) std(acc2(1,omit))]/sqrt(N_mTurk-1);
%     EALLDATA(s,:) = [EhAvg EeAvg EoAvg];
    clear acc1
    clear acc2
    
    cd ..
end
% %maybe make 1 plot?R1 and R2
% agree1_vec = reshape(agree1, numel(agree1),1);
% wrong1 = find(~modeisright1);
 bincenters = 1:9;
% figure;
% hist(agree1_vec,bincenters);
% hold on;
% hist(agree1_vec(wrong1), bincenters);
% h = findobj(gca,'Type','patch');
% h(1).FaceColor = [1 0 0];
% title('Histogram of Agreement for Recall 1')
% xlabel('N Agree in Mode (out of 9 Raters)')
% ylabel('Frequency')
% fig=gcf;
% set(findall(fig,'-property','FontSize'),'FontSize',12)
% legend('All trials', 'Incorrect mode');
% 
% 
% agree2_vec = reshape(agree2, numel(agree2),1);
% wrong2 = find(~modeisright2);
% figure;
% hist(agree2_vec,bincenters);
% hold on;
% hist(agree2_vec(wrong2), bincenters);
% h = findobj(gca,'Type','patch');
% h(1).FaceColor = [1 0 0];
% title('Histogram of Agreement for Recall 2')
% xlabel('N Agree in Mode (out of 9 Raters)')
% ylabel('Frequency')
% set(findall(fig,'-property','FontSize'),'FontSize',12)
% legend('All trials', 'Incorrect mode');
% fig=gcf;
% set(findall(fig,'-property','FontSize'),'FontSize',12)

figure;
[f,x] = hist(rightcounter, bincenters);
figure;
%bar([x;x],[f/sum(f); f2/sum(f2)]);
plot(x, f/sum(f)*100, '.k-', x, f2/sum(f2)*100, '.r--', 'MarkerSize', 10)
title('Distribution of Number of Right Choices')
xlabel('N Right (out of 9 Raters)')
ylabel('% Frequency')
fig=gcf;
set(findall(fig,'-property','FontSize'),'FontSize',12)
legend('All Trials', 'No Repeated Cagegories ONLY')
%ylim([0 450]);
%%
figure;
TWOCOR = find(M(:,3)==2);
ONECOR = find(M(:,3)==1);
NEITHER = find(M(:,3)==0);
MT = M(:,1:2);
figure;
hist3(MT(ONECOR,:),[7 5])
xlabel('N Agree in Mode')
ylabel('Second best N agree')
zlabel('Counts')
title('Mode is Correct')

figure
hist3(MT(TWOCOR,:), [3 3])
xlabel('N Agree in Mode')
ylabel('Second best N agree')
zlabel('Counts')
title('Second-best choice is Correct')

figure
hist3(MT(NEITHER,:))
xlabel('N Agree in Mode')
ylabel('Second best N agree')
zlabel('Counts')
title('Both Wrong')



plot(M(:,1),M(:,2), 'o')
xlabel('N raters who agree (out of 9)')
ylabel('Second highest agreement')
title('Rater Agreement')
fig=gcf;
set(findall(fig,'-property','FontSize'),'FontSize',12)
%%
figure;
% plot(HAVG, 'r.', 'MarkerSize',15);
% hold on
% plot(EAVG, 'b.', 'MarkerSize',15);
% plot(OAVG, 'k.', 'MarkerSize',15);
barwitherr(EALLDATA*100,ALLDATA*100)
ylim([30 105])

%average across subjects
figure;
allsubavg = mean(ALLDATA,1);
allsubavg = reshape(allsubavg,2,3);
Eallsubavg = std(ALLDATA,1)/sqrt(length(subvec) - 1);
Eallsubavg = reshape(Eallsubavg,2,3);
barwitherr(Eallsubavg'*100,allsubavg'*100)
ylim([70 105])
set(gca,'XTickLabel' , ['Hard'; 'Easy'; 'Omit']);
title('Average Recall Matching Rate')
xlabel('MOT Category')
ylabel('Average Recall mTurk Matching Rate (%)')
legend('Pre-mot', 'Post-mot')
fig=gcf;
set(findall(fig,'-property','FontSize'),'FontSize',12)

%%analyze by speed setting
%clean this up later by finding excluding value and calculating what the
%subject number would be
HS1 = 1:9; %subjects 1-10 is really 1-9 number subjects
HS2 = 10:12;
HS4 = 13:14;
HS3 = 15:19; %should be 17-19 but minus 2 so it's 15-17
H1 = mean(ALLDATA(HS1,1:2),1);
H2 = mean(ALLDATA(HS2,1:2),1);
H3 = mean(ALLDATA(HS3,1:2),1);
H4 = mean(ALLDATA(HS4,1:2),1);

ALLHS = [H1; H2; H3 ; H4];

EH1 = std(ALLDATA(HS1,1:2),1)/sqrt(length(HS1) - 1);
EH2 = std(ALLDATA(HS2,1:2),1)/sqrt(length(HS2) - 1);
EH3 = std(ALLDATA(HS3,1:2),1)/sqrt(length(HS3) - 1);
EH4 = std(ALLDATA(HS4,1:2),1)/sqrt(length(HS4) - 1);
EALLHS = [EH1; EH2; EH3 ; EH4];

figure;
barwitherr(EALLHS*100,ALLHS*100)
ylim([30 105])
set(gca,'XTickLabel' , ['HS=17'; 'HS=20'; 'HS=25';'HS=32']);
title('Average Recall Matching Rate, Hard Pairs ONLY')
xlabel('Hard MOT Speed')
ylabel('Average Recall Rate (%)')
legend('Pre-mot', 'Post-mot')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%now do the same thing by comparing easy conditions
E1 = mean(ALLDATA(HS1,3:4),1);
E2 = mean(ALLDATA(HS2,3:4),1);
E3 = mean(ALLDATA(HS3,3:4),1);
E4 = mean(ALLDATA(HS4,3:4),1);

ALLES = [E1; E2; E3 ; E4];

EE1 = std(ALLDATA(HS1,3:4),1)/sqrt(length(HS1) - 1);
EE2 = std(ALLDATA(HS2,3:4),1)/sqrt(length(HS2) - 1);
EE3 = std(ALLDATA(HS3,1:2),1)/sqrt(length(HS3) - 1);
EE4 = std(ALLDATA(HS4,3:4),1)/sqrt(length(HS4) - 1);
EALLES = [EE1; EE2; EE3 ; EE4];

figure;
barwitherr(EALLES*100,ALLES*100)
ylim([30 105])
set(gca,'XTickLabel' , ['HS=17'; 'HS=20'; 'HS=25';'HS=32']);
title('Average Recall Matching Rate, Easy Pairs ONLY')
xlabel('Hard MOT Speed')
ylabel('Average Recall Rate (%)')
legend('Pre-mot', 'Post-mot')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%now do the same thing by comparing omit conditions
O1 = mean(ALLDATA(HS1,5:6),1);
O2 = mean(ALLDATA(HS2,5:6),1);
O3 = mean(ALLDATA(HS3,5:6),1);
O4 = mean(ALLDATA(HS4,5:6),1);

ALLOS = [O1; O2; O3 ; O4];

EO1 = std(ALLDATA(HS1,5:6),1)/sqrt(length(HS1) - 1);
EO2 = std(ALLDATA(HS2,5:6),1)/sqrt(length(HS2) - 1);
EO3 = std(ALLDATA(HS3,1:2),1)/sqrt(length(HS3) - 1);
EO4 = std(ALLDATA(HS4,5:6),1)/sqrt(length(HS4) - 1);
EALLOS = [EO1; EO2; EO3 ; EO4];

figure;
barwitherr(EALLOS*100,ALLOS*100)
ylim([30 105])
set(gca,'XTickLabel' , ['HS=17'; 'HS=20'; 'HS=25';'HS=32']);
title('Average Recall Matching Rate, Omit Pairs ONLY')
xlabel('Hard MOT Speed')
ylabel('Average Recall Rate (%)')
legend('Pre-mot', 'Post-mot')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%now do the same thing by high and low hard speed tracking accuracy
low = mean(ALLDATA(lowacc,1:2),1);
high = mean(ALLDATA(highacc,1:2),1);

ALLacc = [low; high];

Elow = std(ALLDATA(lowacc,1:2),1)/sqrt(length(lowacc) - 1);
Ehigh = std(ALLDATA(highacc,1:2),1)/sqrt(length(highacc) - 1);
EALLacc = [Elow; Ehigh];

figure;
barwitherr(EALLacc*100,ALLacc*100)
ylim([30 105])
set(gca,'XTickLabel' , ['poor acc'; 'high acc']);
title('Average Recall Matching Rate by Dot Trackign Accuracy, Hard Pairs ONLY')
xlabel('Hard Dot Tracking Accuracy Group')
ylabel('Average Recall Rate (%)')
legend('Pre-mot', 'Post-mot')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%now do the same thing by high and low hard speed tracking accuracy
lowE = mean(ALLDATA(lowacc,3:4),1);
highE = mean(ALLDATA(highacc,3:4),1);

ALLaccE = [lowE; highE];

ElowE = std(ALLDATA(lowacc,3:4),1)/sqrt(length(lowacc) - 1);
EhighE = std(ALLDATA(highacc,3:4),1)/sqrt(length(highacc) - 1);
EALLaccE = [ElowE; EhighE];

figure;
barwitherr(EALLaccE*100,ALLaccE*100)
ylim([30 105])
set(gca,'XTickLabel' , ['poor acc'; 'high acc']);
title('Average Recall Matching Rate by Dot Trackign Accuracy, Easy Pairs ONLY')
xlabel('Hard Dot Tracking Accuracy Group')
ylabel('Average Recall Rate (%)')
legend('Pre-mot', 'Post-mot')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%now do the same thing by high and low hard speed tracking accuracy
lowO = mean(ALLDATA(lowacc,5:6),1);
highO = mean(ALLDATA(highacc,5:6),1);

ALLaccO = [lowO; highO];

ElowO = std(ALLDATA(lowacc,5:6),1)/sqrt(length(lowacc) - 1);
EhighO = std(ALLDATA(highacc,5:6),1)/sqrt(length(highacc) - 1);
EALLaccO = [ElowO; EhighO];

figure;
barwitherr(EALLaccO*100,ALLaccO*100)
ylim([30 105])
set(gca,'XTickLabel' , ['poor acc'; 'high acc']);
title('Average Recall Matching Rate by Dot Trackign Accuracy, Omit Pairs ONLY')
xlabel('Hard Dot Tracking Accuracy Group')
ylabel('Average Recall Rate (%)')
legend('Pre-mot', 'Post-mot')


