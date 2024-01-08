try
    %%% Prompt %%%
    prompt = {'Enter subject number:'};
    defaults = {'999'};
    answer = inputdlg(prompt, 'Experimental setup information', 1, defaults);
    [subjectNumber] = deal(answer{:});

    %%% File Set-Up %%%
    rootDir = cd;
    expName='HZ';
    baseName=[subjectNumber expName];

    %Screen Dimensions
    screens = Screen('Screens'); %count the screen
    onScreen = max(screens); %select the screen
    [ScreenX, ScreenY] = WindowSize(onScreen);

    cx=(ScreenX/2); %Middle of screen on X-axis
    cy=(ScreenY/2); %Middle of screen on Y-axis
    thirdX = ScreenX/3;
    thirdY = ScreenY/3;
    quadX = ScreenX/4; % the middle of the left half of the screen
    quadY = ScreenY/4;
    fifthX = ScreenX/5;
    fifthY = ScreenY/5;
    eighthX = ScreenX/8;
    eighthY = ScreenY/8;
    decX = (ScreenX/10);
    decY = (ScreenY/10);

    ScreenRect = [0 0 ScreenX ScreenY]; %Rectangle = size of whole display

    fixThresh = 200; % fixation threshold width

    %%% Operating System Check%%%
    KbName('UnifyKeyNames');
    if IsOSX
        TopPriority=0;
        sysTxtOff=0; % no text adjustments needed
        ptbPipeMode=kPsychNeedFastBackingStore; % enable imaging pipeline for mac
    elseif IsWin
        TopPriority=1;
        sysTxtOff=1; % windows draws text from the upper left corned instead of lower left. To correct
        % an adjustment factor of 1*letterheight is subtracted from the y coordinate of
        % the starting point
        ptbPipeMode=[]; % don't need to enable imaging pipeline
    else
        ListenChar(0); clear screen; error('Operating system not OS X or Windows.');
    end %if ismac


    %%% Keys %%%
    Nkey=KbName('n');
    RAkey=KbName('space');
    Lkey=KbName('f');
    Rkey=KbName('j');
    Upkey=KbName('uparrow');
    Downkey=KbName('downarrow');
    escKey=KbName('w');
    sixkey=KbName('q');
    Akey=KbName('a');
    Bkey=KbName('b');
    Ckey=KbName('c');
    Dkey=KbName('d');
    Pkey=KbName('p');
    leftButton=[KbName('1!') KbName('1') KbName(',<') KbName('leftarrow')];
    rightButton=[KbName('2@') KbName('2') KbName('.>') KbName('rightarrow')];
    if IsOSX
        enterButton=[KbName('enter') KbName('return')];
    else
        enterButton=KbName('return');
    end %if ismac

    %%% Screen Visuals %%%
    fixX=cx;
    fixY=cy;
    fixRadThresh=52;
    fixRadThresh2=100;

    %%% Font %%%
    mainFont = 'Arial';
    scaleSize = 28;
    ticLength = 12;
    ticWidth = 6;
    crossSize = 50; %size of fixation cross
    ratesSize = 32;


    %%% Colors %%%
    whitecol = [255 255 255]; %white
    redcol = [157 0 0]; %[206 0 0];
    marooncol = [60 0 0];
    greencol = [0 120 0]; %[0 90 0]; %[0 119 0];
    bluecol = [0 0 255];
    yellowcol = [165 165 0]; %[157 47 0]; %[200 69 0];
    purpcol = [157 0 129]; %[238 0 100]; %[238 0 238];
    slatecol = [50 50 169];
    aquacol = [0 204 255];
    cyancol = [0 142 142];
    orangecol = [157 90 0]; %more of a gold%[220 150 0];
    lavendercol = [102 22 255]; %[238 121 159];
    pericol = [113 113 198];
    greycol = 150;


    %%%%%%%%%%%%%%%%%%%
    %%% Open Screen %%%
    %%%%%%%%%%%%%%%%%%%
    Screen('Preference', 'SkipSyncTests', 1);
    maxScreens = max(screens);
    [onScreen, screenRect] = Screen('OpenWindow', maxScreens); % Open the second window
    Screen('FillRect', onScreen, [0 0 0]); % Make the screen black
    %HideCursor;
    Screen('BlendFunction', onScreen, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('TextSize', onScreen, 30)

    % Query the frame duration and set waitframe
    ifi = Screen('GetFlipInterval', onScreen);
    waitframes = 1;

    % For fixation, setup:
    Screen(onScreen,'TextSize',crossSize);
    fixation='+';
    [normBoundsRect, offsetBoundsRect] = Screen('TextBounds', onScreen, fixation);
    width=normBoundsRect(3)-normBoundsRect(1); height=normBoundsRect(4)-normBoundsRect(2);

    Screen('TextSize', onScreen, 30)

    % Shapes
    slider1 = [ScreenX*.25,ScreenY/2,ScreenX*0.75,ScreenY/2+10];

    % Elicitation Screen 1
    line1 =  'On the LAST decision that you made, what percentage of the time did you\n';
    line2 = 'pay attention to each of the following aspects of the decision?\n';
    line3 = 'Please note: your answers must add up to 100.';
    slider(onScreen,slider1,cx,cy,20,whitecol,redcol,'Dollar Amounts','Timing',-1,[line1 line2 line3]);
    

    %Wait for button press
    while KbCheck
    end

    FlushEvents('keyDown');
    proceed = 0;
    sliderVal = -1;
    while proceed == 0
        [x,y,buttons] = GetMouse(onScreen);
        if any(buttons)
            sliderVal = slider(onScreen,slider1,x,y,20,whitecol,redcol,'Dollar Amounts','Timing',sliderVal,[line1 line2 line3]);
        end

        [keyIsDown, secs, keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(escKey)
                ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
            elseif keyCode(RAkey)
                proceed = 1;
            end
        end
    end %while proceed
    WaitSecs(.5);
    
Screen('CloseAll');
sca
catch err  %quit out if the code encounters an error
    disp('There is an ERROR!');
    %matlabfile = ['matlab' num2str(subjectNumber) 'choice.mat'];
    %save(matlabfile);
    if IsOSX
        ListenChar(0); %restore normal keyboard use
    end %if ismac
    sca
    fclose('all');
    ShowCursor;
    Screen('CloseAll')
    rethrow(err);
end