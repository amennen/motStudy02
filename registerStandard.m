projectName = 'motStudy02';

plotDir = ['/Data1/code/' projectName '/' 'Plots' '/' ]; %should be all

svec = [8 12 14 15 16 18 20 22 26 27 28 30 31 32];

datevec = {'8-10-16', '8-27-16', '9-7-16', '9-14-16','9-16-16', '9-23-16','10-4-16',  '10-6-16','10-18-16', '10-22-16', '10-26-16' ,  '11-4-16', '11-4-16', '11-8-16'};
runvec = ones(1,length(svec));
runvec(find(svec==22)) = 2; %subject 22 was run 2
runvec(find(svec==30)) = 2;
NSUB = length(svec);

if IsLinux
    biac_dir = '/Data1/packages/BIAC_Matlab_R2014a/';
    bxhpath='/opt/BXH/1.11.1/bin/';
    fslpath='/opt/fsl/5.0.8/bin/';
end

%s=1;
for s = 1:NSUB
    subjectNum = svec(s);
    
    runNum = runvec(s);
    scanDate = datevec{s};
    
    %date = '7-12-16';
    
    shiftTR = 2;
    
    setenv('FSLOUTPUTTYPE','NIFTI_GZ');
    save_dir = ['/Data1/code/' projectName '/data/' num2str(subjectNum) '/']; %this is where she sets the save directory!
    process_dir = ['/Data1/code/' projectName '/data/' num2str(subjectNum) '/' 'reg' '/'];
    roi_dir = ['/Data1/code/' projectName '/data/'];
    code_dir = ['/Data1/code/' projectName '/' 'code' '/']; %change to wherever code is stored
    locPatterns_dir = fullfile(save_dir, 'Localizer/');
    behavioral_dir = ['/Data1/code/' projectName '/' 'code' '/BehavioralData/' num2str(subjectNum) '/'];
    addpath(genpath(code_dir));
    subjectName = [datestr(scanDate,5) datestr(scanDate,7) datestr(scanDate,11) num2str(runNum) '_' projectName];
    dicom_dir = ['/Data1/subjects/' datestr(scanDate,10) datestr(scanDate,5) datestr(scanDate,7) '.' subjectName '.' subjectName '/'];
    locScanNum = 11;
    loc_scanstr = num2str(exFuncScanNum, '%2.2i');
    loc_genstr = sprintf('%s001_0000%s_0*',dicom_dir,loc_scanstr);
    loc_fn = 'loc_old_orientation';
    loc_reorient_fn = 'loc_new_orientation';
    final_locfn = 'localizer_standard';
    cd(process_dir)
    %convert mprage dicom files to a bxh wrapper
    unix(sprintf('%sdicom2bxh %s %s.bxh',bxhpath,loc_genstr,loc_fn));
    
    %reorient bxh wrapper
    unix(sprintf('%sbxhreorient --orientation=LAS %s.bxh %s.bxh',bxhpath,loc_fn,loc_reorient_fn));
    
    
    %convert the reoriented bxh wrapper to a nifti file
    unix(sprintf('%sbxh2analyze --overwrite --analyzetypes --niigz --niftihdr -s %s.bxh %s',bxhpath,loc_reorient_fn,loc_reorient_fn))
    
    %unix(sprintf('%sbet %s.nii.gz %s_brain.nii.gz -R',fslpath,loc_reorient_fn,loc_reorient_fn));

    unix(sprintf('%sapplywarp --ref=$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz --in=%s.nii.gz --warp=highres2standard_warp --premat=example_func2highres.mat --out=%s.nii.gz',fslpath,loc_reorient_fn,final_locfn))
    %unix(sprintf('%sbet %s.nii.gz %s_brain -R',fslpath,final_locfn,final_locfn));
    fprintf('done with subject %s!\n', subjectName);
end
