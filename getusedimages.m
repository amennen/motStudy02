%find any stimuli that weren't used only for training or not used at all
%(any of the other tasks or recog lures)

%if used in training it would have an id number between 21-28

%load stim assignment, pics and recogLures to get all images
projectName = 'motStudy02';
svec = 8:14;
NSUB = length(svec);
base_path = [fileparts(which('mot_realtime01.m')) filesep];

for s = 1:NSUB
    behavioral_dir = [base_path '/BehavioralData/' num2str(svec(s)) '/'];
    load([behavioral_dir 'mot_realtime01_subj_' num2str(svec(s)) '_stimAssignment.mat']);
    allPics = cat(2,pics,recogLures);
    fname = findNewestFile(behavioral_dir,fullfile(behavioral_dir, ['mot_realtime01_' num2str(svec(s)) '_' num2str(3)  '*.mat']));
    z = load(fname);
    training = z.stim.associate;
    usedBad = setdiff(allPics,training);
    %then open familiarization to get training pics
        
    %load all images
    ALLMATERIALS = -1;
    base_path = [fileparts(which('mot_realtime01.m')) filesep];
    PICLISTFILE = [base_path 'stimuli/SCREENNAMES.txt'];
    candidates = readStimulusFile_evenIO(PICLISTFILE,ALLMATERIALS);
    candidates = transpose(candidates);
    %good pool are the training pics and unused images
    unused{s} = setdiff(candidates,usedBad);
end
%see if any overlap between subjects
U12 = intersect(unused{1},unused{2});
U34 = intersect(unused{3},unused{4});
U56 = intersect(unused{5},unused{6});
UB1 = intersect(U12,U34);
UB2 = intersect(U56,unused{7});
anyunused = intersect(UB1,UB2);