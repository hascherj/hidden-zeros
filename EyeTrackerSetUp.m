%%% ------------------ %%%
%%% Eye Tracker Set-Up %%%
%%% ------------------ %%%

if doEye == 1 % if the eyetracker is connected
    
    dummymode = 0; % No need to use mouse as an eyetracker
    
    tmp = EyelinkInit(0);
    
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    el = EyelinkInitDefaults(onScreen);
    
    % Initialization of the connection with the Eyelink Gazetracker.
    % exit program if this fails.
    if ~EyelinkInit(dummy_mode) % Initializes Eyelink and Ethernet system. Returns: 0 if OK, -1 if error
        error('could not init connection to Eyelink')
    end
    
    % check the software version
    [v , vs] = Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs);
    
    status = Eyelink('openfile',edfFile);
    % open EDF file (auto recording? what's the results of this?)
    if status~=0
        fprintf('Cannot create EDF file ''%s''\n', edfFile);
        Eyelink('Shutdown');
        Screen('CloseAll');
        return;
    end
    
    % SET UP TRACKER CONFIGURATION
    % Setting the proper recording resolution, proper calibration type,
    % as well as the data file content;
    Eyelink('command', 'screen_pixel_coords = %ld %ld %ld %ld', 0, 0, ScreenX-1, ScreenY-1);
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, ScreenX-1, ScreenY-1);
    % set calibration type.
    Eyelink('command', 'calibration_type = HV9');
    
    % set EDF file contents using the file_sample_data and
    % file-event_filter commands
    % set link data thtough link_sample_data and link_event_filter
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,INPUT');
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,INPUT');
    
    Eyelink('command', 'file_sample_data  = GAZE,AREA,GAZERES,STATUS,INPUT');
    Eyelink('command', 'link_sample_data  = GAZE,AREA,GAZERES,STATUS,INPUT');
    
    % make sure we're still connected.
    if Eyelink('IsConnected')~=1
        fprintf('not connected, clean up\n');
        Eyelink('ShutDown');
        Screen('CloseAll');
        return;
    end
    
    el.backgroundcolour = bcolor;
    el.foregroundcolour = 255;  %what's the differenece btwn foregroundcolour and calibtargetcolour?
    el.calibrationtargetcolour= 255;
    el.msgfontcolour  = 255;
    
    % parameters are in frequency, volume, and duration
    % set the second value in each line to 0 to turn off the sound
    el.cal_target_beep=[600 0 0.05];
    el.drift_correction_target_beep=[600 0 0.05];
    el.calibration_failed_beep=[400 0 0.25];
    el.calibration_success_beep=[800 0 0.25];
    el.drift_correction_failed_beep=[400 0 0.25];
    el.drift_correction_success_beep=[800 0 0.25];
    % you must call this function to apply the changes from above
    EyelinkUpdateDefaults(el);
    
    %Eyelink('command','screen_pixel_coords = %1d %1d %1d %1d', 0,0,ScreenRect(3)-1, ScreenRect(4)-1); % 0, 0, SCREEN_X-1, SCREEN_Y-1
    %Eyelink('message', 'DISPLAY_COORDS = %ld %ld %1d %1d', 0,0,ScreenRect(3)-1, ScreenRect(4)-1);
    
    %Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA'); % make
    
    %edfFile='demo.edf';
    Eyelink('Openfile', edfFile);
    
    % Calibrate the eye tracker
    EyelinkDoTrackerSetup(el);
    
    WaitSecs(0.1);
    begin_record_time = GetSecs();
    Eyelink('StartRecording');
    fprintf(timeFile,  '%s\t%s\n', begin_record_time, num2str(ETCount));
    ETCount = ETCount + 1;
    
    eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
    if eye_used == el.BINOCULAR % if both eyes are tracked
        eye_used = el.LEFT_EYE; % use left eye
    end
end % if etconnected