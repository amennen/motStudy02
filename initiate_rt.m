function [mainWindow windowSize colors device trigger workingDir logName matlabSaveFile ivx fmri slack] = initiate_rt(subject,session,sessionStrings,short_string,long_string,speed,colors)

    %% declarations
    AssertOpenGL
    DEFAULT_MONITOR_SIZE = [1024 768];
    DEBUG_MONITOR_SIZE = [700 500];
    MAINFONT = 'Arial';
    MAINFONTSIZE = 30;
    KEYBOARD_TRIGGER = 'Return';
    SCAN_TRIGGER = '='; % skyra PST
    ivx = [];
    subjectDir = [];
    fmri = 0;
    %% colors
    colors.WHITE = [255 255 255];
    colors.BLACK = [0 0 0];
    colors.GREY = (colors.BLACK + colors.WHITE)./2;
    colors.GREEN = [0 255 0];
    colors.RED = [255 0 0];
    colors.BLUE = [0 0 255];

     % default keypress handling
    device = -1;
    trigger = KEYBOARD_TRIGGER; % keyboard
    %% helpful input reminder for incorrect syntax
    if subject <= 0 || session <= 0 || session > length(sessionStrings)
        disp(' '); disp('********SESSION MAP********')
        for i=1:length(sessionStrings)
            disp([num2str(i) ': ' sessionStrings{i}]);
        end
        disp('***************************'); disp(' '); 
        disp('use valid session and syntax: my_experiment(subject_number,session,[debug_SPEED/optional])')
        mainWindow=[]; windowSize=[]; device=[]; trigger=[]; workingDir=[]; subjectDir=[]; logName=[]; matlabSaveFile=[];
        return
    end

    %% disable input / catch errors
    dbstop if error
    ListenChar(2); % disables keyboard input to Matlab command window
    

    %% find working dir (figure out which computer we're using)
    try %work computer
        ls('/Volumes/Macintosh HD/Users/amennen/Documents/Norman/MOT/motStudy02/');
        workingDir = '/Volumes/Macintosh HD/Users/amennen/Documents/Norman/MOT/motStudy02/';
        windowSize.degrees = [35 30];
        [keyboardIndices, productNames, allInfos] = GetKeyboardIndices;
        device = keyboardIndices(find(strcmp(productNames, '')));
        addpath(genpath('/Users/amennen/mychanges_sptb/'));
    catch
        try % my laptop
            ls('/Users/amennen/mot_study')
            workingDir = '/Users/amennen/motStudy02/';
            windowSize.degrees = [35 30];
        catch
            try  %computer testing room
                ls('/Users/normanlab/mot_study/')
                workingDir = '/Users/normanlab/motStudy02/';
                windowSize.degrees = [35 30];
                addpath(genpath('/Users/normanlab/mychanges_sptb/'));
                catch
                    try %Skyra
                        ls('/Data1/code/motStudy02/')
                        workingDir = '/Data1/code/motStudy02/code/';
                        fmri  = 1;
                        % special scanner keypress input
%                         if debug_mode
%                             device = -1;
%                         else
%                             device = PniKbGetDeviceNamed('Xkeys');
%                             %                         device = PniKbStartEverything;
%                         end
                       % addpath(genpath('../SPTBanne'))
                        trigger = SCAN_TRIGGER;
                        [keyboardIndices, productNames, allInfos] = GetKeyboardIndices;
                        z = strfind(productNames, 'Xkeys');
                        %z = strfind(productNames, 'Dell Dell');
                        deviceIND = find(~cellfun(@isempty,z));
                        device = keyboardIndices(deviceIND);
%                         % initialize eyetracker
%                         if ~any(strfind(path,'iViewXToolbox')); addpath(genpath('../iViewXToolbox')); end
%                         try load('ivx.mat')
%                         catch
%                             pnet('closeall'); %Force all current pnet connections/sockets (in the present matlab session) to close
%                             ivx = iViewXInitDefaults; %creates the necessary ivx data structure
%                             ivx.host = '192.168.1.24'; %eye tracker IP
%                             ivx.port = 4444; %eye tracker port
%                             ivx.localport = 4445; %port on stim PC
%                             [result, ivx]=iViewX('openconnection', ivx);
%                             [result ivx] = iViewX('loadbitmap', ivx, 'NTB_5cal-10left-5up_1280x720_black.jpg');
%                             if result < 0
%                                 warning('Could not establish connection to eye tracker');
%                             end
%                         end
                        windowSize.degrees = [51 30];
                    catch
                        error('Can''t find working directory');
                    end
               % end
            end
        end
    end
    %cd(workingDir);
%     if exist('ivx','var') && ~isempty(ivx)
%         ivx.nCalPoints = 5;
%         ivx.absCalPos = [640 360; 370 215; 910 215; 370 495; 910 495];
%     end
        %% initiate graphics
    sca            
    pause on
    Screen('Preference', 'SkipSyncTests', 2); % 0 for screentest
    if speed > 0
        debug_mode = 1;
        screenNumber = 0;
        windowSize.pixels = DEBUG_MONITOR_SIZE;
    else
%         HideCursor;
        debug_mode = 0;
        Screen('Preference', 'SkipSyncTests', 2);
        screens = Screen('Screens');
        screenNumber = max(screens);
        resolution = Screen('Resolution',screenNumber);
        if fmri
            windowSize.pixels = [resolution.width/2 resolution.height];
        else
            windowSize.pixels = [resolution.width resolution.height];
        end
    end
    [mainWindow, null] = Screen('OpenWindow',screenNumber,colors.BGCOLOR,[0 0 windowSize.pixels]);
    ifi = Screen('GetFlipInterval', mainWindow);
    slack  = ifi/2;
    if windowSize.pixels(2) > windowSize.pixels(1)
        SIZE_AXIS = 1;
    else SIZE_AXIS = 2;
    end
    MAINFONTSIZE = round(30 * (windowSize.pixels(SIZE_AXIS) / DEFAULT_MONITOR_SIZE(SIZE_AXIS))); % scales font by window size

    Screen('TextFont',mainWindow,MAINFONT);
    Screen('TextSize',mainWindow,MAINFONTSIZE);
    Screen('Flip',mainWindow);
    
   
    windowSize.degrees_per_pixel = windowSize.degrees ./ windowSize.pixels;

    %% add needed code libraries
    %if ~any(strfind(path,'trigger')); addpath([workingDir 'trigger']); end

    %% initiate file handling
    % directory
%     addpath(workingDir)
%     if ~exist('data')
%         mkdir data
%     end
%     cd([workingDir '/data'])
%     if ~exist(int2str(subject))
%         mkdir(int2str(subject));
%     end
%     cd(int2str(subject))
%     subjectDir = pwd;
    
    % log file
    logName = ['subj' int2str(subject) '.txt'];


    % matlab save file
    matlabSaveFile = ['mot_realtime01_' num2str(subject) '_' num2str(session) '_' datestr(now,'ddmmmyy_HHMM') '.mat'];

return