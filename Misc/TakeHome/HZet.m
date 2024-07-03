try
    rng(sum(100*clock)); %change the seed for each participant
    %%

    %%% Eyetracking is turned off
    %%% 
    %%% Counterbalanced for LL-position
    %%% Break every 50 trials


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%          Experiment Parameters            %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % 4 Conditions - no zero (0), future zero (1), current zero (2), all zero (3)
    % Task 2 is coded as condition 4 (task equal to cond 0)

    %Set condition (need to turn off the later one to use this)
    %    whichCond = 4;

    %Number of trials (max nTrial = 485 currently)
    nTrials = 5;

    %Taking pictures?
    screenCap = 0;

    %Show instructions?
    doInstruc = 1;

    %Do comprehension questions?
    doCompQ = 1;

    %Do the first task (det. by whichCond)?
    doTask1 = 1;

    %Do the second task?
    doTask2 = 1;

    %Do eyetracking?
    doEye = 0;

    % Do sliders?
    doSliders = 1;

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%               Setup Stuff                 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%% Prompt %%%
    prompt = {'Enter subject number:'};
    defaults = {'999'};
    answer = inputdlg(prompt, 'Experimental setup information', 1, defaults);
    [subjectNumber] = deal(answer{:});

    %%% Counterbalancing %%%
    counterBalance = mod(str2double(subjectNumber),16);
    % Which zeros condition (0 = none, 1 = SS_0, 2 = LL_0, 3 =
    % Both)
    whichCond = mod(counterBalance,4);

    %For behavioral pilot - no zeros
    %whichCond = 3;
    
    
    % Which block do they see LL in? (0 = L, 1 = C, 2 = R, 3 = random)
    LL_Position = mod(counterBalance,4);
    if LL_Position == 3
        LL_rand = true;
    end

    %%% File Set-Up %%%
    rootDir = cd;
    expName='HZ';
    baseName=[subjectNumber expName];

    fileName = [baseName '_choiceData' '.csv']; %Basic rating data
    choiceDataFile = fopen(fileName, 'a'); %'a' allows data to be added to file

    fprintf(choiceDataFile, '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n','SN','Trial','LL','SS','DD','Condition','SS_Right','LL_Position','Chose1SS','RT1','Chose2SS','LeftRT1','LeftRT2','LeftRT3','RightRT1','RightRT2','RightRT3','doEye');

    %%% Eyetracking Files and Arrays %%%
    if doEye
        fileName = ['dat_tmg' baseName '.xls'];
        timeFile = fopen(fileName, 'a');
        fprintf(timeFile, '%s\t%s\n', 'Time', 'ETCount');
        edfFile = [baseName '.edf'];

        fileName = ['dat_1fix' baseName '.xls']; % Fixations 1
        fix1File = fopen(fileName, 'a');
        fprintf(fix1File, '%s\t%s\t%s\t%s\t%s\n', 'Trial', 'ROI', 'Start Time', 'End Time', 'SubjectNumber');

        fileName = ['dat_2fix' baseName '.xls']; % Fixations 2
        fix2File = fopen(fileName, 'a');
        fprintf(fix2File, '%s\t%s\t%s\t%s\t%s\n', 'Trial', 'ROI', 'Start Time', 'End Time', 'SubjectNumber');
    end %if doEye
    ETCount = 1;
    fix_time = 1;


    mx = [];
    my = [];
    ma = [];
    matETttrial = [];
    matETtblock = [];



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
    HideCursor;
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

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%             Choice Design                 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %One alternative on the screen - this is for the instructions only

    %%% Create the base boxes %%%

    %Basic Parameters - Boxes are defined (L T R B)
    A = (1/6)*ScreenX; %left side of screen to left edge of first box
    F = (1/6)*ScreenX; %x-dist btn top left and bottom right boxes
    E = (1/4)*ScreenY; %y-dist btn top left and bottom right boxes
    B = cx-(1/2)*F-A; %width of each set of boxes
    m = (1/3)*B; %width/height of each indiv box
    G = cy-(1/2)*E-(1/3)*B; %top of screen to top of first box
    C = (1/4)*G;
    A2 = cx+(1/2)*F;
    G2 = ScreenY-G;
    r = 10; %dot radius
    %Top left boxes
    Box1 = [A G A+m G+m];
    Box2 = [A+m G A+2*m G+m];
    Box3 = [A+2*m G A+B G+m];
    Screen('FrameRect', onScreen, whitecol, Box1,2);
    Screen('FrameRect', onScreen, whitecol, Box2,2);
    Screen('FrameRect', onScreen, whitecol, Box3,2);
    %Bottom right boxes
    Box4 = [A2 G2-m A2+m G2];
    Box5 = [A2+m G2-m A2+2*m G2];
    Box6 = [A2+2*m G2-m A2+B G2];
    Screen('FrameRect', onScreen, whitecol, Box4,2);
    Screen('FrameRect', onScreen, whitecol, Box5,2);
    Screen('FrameRect', onScreen, whitecol, Box6,2);

    %Draw the three dots
    dot1 = [cx-r cy-r cx+r cy+r];
    dot2 = [cx-(1/4)*F-r cy-(1/4)*E-r cx-(1/4)*F+r cy-(1/4)*E+r];
    dot3 = [cx+(1/4)*F-r cy+(1/4)*E-r cx+(1/4)*F+r cy+(1/4)*E+r];

    Screen('FillOval', onScreen, whitecol,dot1);
    Screen('FillOval', onScreen, whitecol,dot2);
    Screen('FillOval', onScreen, whitecol,dot3);

    %Add the text (only for the top for now)
    lineDay = 'Day\n';
    line2 = '1';
    line3 = '2';
    line4 = '3';
    textBox1 = [A+(1/3)*m G-C-(1/3)*m A+(2/3)*m G-C];
    textBox2 = [A+(4/3)*m G-C-(1/3)*m A+(5/3)*m G-C];
    textBox3 = [A+(7/3)*m G-C-(1/3)*m A+(8/3)*m G-C];
    DrawFormattedText(onScreen, [lineDay line2], 'center', 'center', whitecol, [], [], [], 2, [], textBox1);
    DrawFormattedText(onScreen, [lineDay line3], 'center', 'center', whitecol, [], [], [], 2, [], textBox2);
    DrawFormattedText(onScreen, [lineDay line4], 'center', 'center', whitecol, [], [], [], 2, [], textBox3);

    %Capture the screen here and convert to a figure
    blank1Choice = Screen('GetImage', onScreen, [], 'backBuffer');
    blank1Choice = Screen('MakeTexture', onScreen, blank1Choice); % Make this a texture, it's easier to draw

    %Clear the drawings
    Screen('FillRect', onScreen, 0);

    %Empty boxes for arrows and ovals(for instructions)
    arrow1 = [A+(1/2)*m G-C A+(1/2)*m G-5];
    arrow2 = [A+(3/2)*m G-C A+(3/2)*m G-5];
    arrow3 = [A+(5/2)*m G-C A+(5/2)*m G-5];
    arrow4 = [A2+(1/2)*m G2+C A2+(1/2)*m G2+5];
    arrow5 = [A2+(3/2)*m G2+C A2+(3/2)*m G2+5];
    arrow6 = [A2+(5/2)*m G2+C A2+(5/2)*m G2+5];
    oval1 = [A+(1/6)*m G-C-(15/24)*m A+(5/6)*m G-C+(1/24)*m];
    oval2 = [A2+(7/6)*m G2+C+(1/24)*m A2+(11/6)*m G2+C+(17/24)*m];
    oval3 = [A2 G2+C-(1/10)*m A2+B G2+C+(9/10)*m];

    %Empty boxes for choice info
    SS_1 = Box1;
    LL_1 = Box4;
    DD1_1 = [A2 G2+C+(1/3)*m A2+m G2+C+(2/3)*m];
    DD2_1 = [A2+m G2+C+(1/3)*m A2+2*m G2+C+(2/3)*m];
    DD3_1 = [A2+2*m G2+C+(1/3)*m A2+B G2+C+(2/3)*m];



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Now create blank choice b/n 2 alternatives
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Parameters
    altBoxW = cx;
    ccx = (1/2)*altBoxW;
    altBoxH = ScreenY;
    ccy = (1/2)*altBoxH;
    A = (1/6)*altBoxW; %left side of screen to left edge of first box
    F = (1/6)*altBoxW; %x-dist btn top left and bottom right boxes
    E = (1/4)*altBoxH; %y-dist btn top left and bottom right boxes
    B = ccx-(1/2)*F-A; %width of each set of boxes
    m = (1/3)*B; %width/height of each indiv box
    G = ccy-(1/2)*E-(1/3)*B; %top of screen to top of first box
    C = (1/6)*G;
    A2 = ccx+(1/2)*F;
    G2 = altBoxH-G;
    r = 5; %dot radius

    %Start with the left alternative
    %Top left boxes
    BoxL1 = [A G A+m G+m];
    BoxL2 = [A+m G A+2*m G+m];
    BoxL3 = [A+2*m G A+B G+m];
    Screen('FrameRect', onScreen, whitecol, BoxL1,2);
    Screen('FrameRect', onScreen, whitecol, BoxL2,2);
    Screen('FrameRect', onScreen, whitecol, BoxL3,2);
    %Bottom right boxes
    BoxL4 = [A2 G2-m A2+m G2];
    BoxL5 = [A2+m G2-m A2+2*m G2];
    BoxL6 = [A2+2*m G2-m A2+B G2];
    Screen('FrameRect', onScreen, whitecol, BoxL4,2);
    Screen('FrameRect', onScreen, whitecol, BoxL5,2);
    Screen('FrameRect', onScreen, whitecol, BoxL6,2);

    %Draw the three dots
    dotL1 = [ccx-r ccy-r ccx+r ccy+r];
    dotL2 = [ccx-(1/4)*F-r ccy-(1/4)*E-r ccx-(1/4)*F+r ccy-(1/4)*E+r];
    dotL3 = [ccx+(1/4)*F-r ccy+(1/4)*E-r ccx+(1/4)*F+r ccy+(1/4)*E+r];

    Screen('FillOval', onScreen, whitecol,dotL1);
    Screen('FillOval', onScreen, whitecol,dotL2);
    Screen('FillOval', onScreen, whitecol,dotL3);

    %Add the text (only for the top for now)
    lineDay = 'Day\n';
    line2 = '1';
    line3 = '2';
    line4 = '3';
    textBoxL1 = [A+(1/3)*m G-C-(1/3)*m A+(2/3)*m G-C];
    textBoxL2 = [A+(4/3)*m G-C-(1/3)*m A+(5/3)*m G-C];
    textBoxL3 = [A+(7/3)*m G-C-(1/3)*m A+(8/3)*m G-C];
    DrawFormattedText(onScreen, [lineDay line2], 'center', 'center', whitecol, [], [], [], 2, [], textBoxL1);
    DrawFormattedText(onScreen, [lineDay line3], 'center', 'center', whitecol, [], [], [], 2, [], textBoxL2);
    DrawFormattedText(onScreen, [lineDay line4], 'center', 'center', whitecol, [], [], [], 2, [], textBoxL3);

    %Now the right alternative (just add cx to each horiz dist)
    %Top left boxes
    BoxR1 = [cx+A G cx+A+m G+m];
    BoxR2 = [cx+A+m G cx+A+2*m G+m];
    BoxR3 = [cx+A+2*m G cx+A+B G+m];
    Screen('FrameRect', onScreen, whitecol, BoxR1,2);
    Screen('FrameRect', onScreen, whitecol, BoxR2,2);
    Screen('FrameRect', onScreen, whitecol, BoxR3,2);
    %Bottom right boxes
    BoxR4 = [cx+A2 G2-m cx+A2+m G2];
    BoxR5 = [cx+A2+m G2-m cx+A2+2*m G2];
    BoxR6 = [cx+A2+2*m G2-m cx+A2+B G2];
    Screen('FrameRect', onScreen, whitecol, BoxR4,2);
    Screen('FrameRect', onScreen, whitecol, BoxR5,2);
    Screen('FrameRect', onScreen, whitecol, BoxR6,2);

    %Draw the three dots
    dotR1 = [cx+ccx-r ccy-r cx+ccx+r ccy+r];
    dotR2 = [cx+ccx-(1/4)*F-r ccy-(1/4)*E-r cx+ccx-(1/4)*F+r ccy-(1/4)*E+r];
    dotR3 = [cx+ccx+(1/4)*F-r ccy+(1/4)*E-r cx+ccx+(1/4)*F+r ccy+(1/4)*E+r];

    Screen('FillOval', onScreen, whitecol,dotR1);
    Screen('FillOval', onScreen, whitecol,dotR2);
    Screen('FillOval', onScreen, whitecol,dotR3);

    %Add the text (only for the top for now)
    textBoxR1 = [cx+A+(1/3)*m G-C-(1/3)*m cx+A+(2/3)*m G-C];
    textBoxR2 = [cx+A+(4/3)*m G-C-(1/3)*m cx+A+(5/3)*m G-C];
    textBoxR3 = [cx+A+(7/3)*m G-C-(1/3)*m cx+A+(8/3)*m G-C];
    DrawFormattedText(onScreen, [lineDay line2], 'center', 'center', whitecol, [], [], [], 2, [], textBoxR1);
    DrawFormattedText(onScreen, [lineDay line3], 'center', 'center', whitecol, [], [], [], 2, [], textBoxR2);
    DrawFormattedText(onScreen, [lineDay line4], 'center', 'center', whitecol, [], [], [], 2, [], textBoxR3);

    %Add dashed vertical line down the middle
    Screen('LineStipple', onScreen, 1, 5, [0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1]);
    Screen('DrawLine', onScreen, whitecol, cx, 0, cx, ScreenY, 3);
    Screen('LineStipple', onScreen, 0);

    %Capture the screen here and convert to a figure
    blankChoice = Screen('GetImage', onScreen, [], 'backBuffer');
    blankChoice = Screen('MakeTexture', onScreen, blankChoice); % Make this a texture, it's easier to draw

    %Take a picture of the choice design
    if screenCap
        Screen('Flip', onScreen);
        capSizeX=ScreenX; capSizeY=ScreenY;
        image=Screen('GetImage', onScreen, [cx-capSizeX/2 cy-capSizeY/2 cx+capSizeX/2 cy+capSizeY/2]);
        imgname=strcat('/Users/hascherj/Dropbox/Mac/Documents/Steph Projects/HiddenZero/ExpPics/binary_choice_ex_3.png');
        imwrite(image, imgname, 'png');
        %Wait for button press
        while KbCheck
        end
        FlushEvents('keyDown');
        proceed = 0;
        while proceed == 0
            [keyIsDown, secs, keyCode] = KbCheck(-1);
            if keyIsDown
                if keyCode(escKey)
                    ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
                elseif keyCode(RAkey)
                    proceed = 1;
                end
            end
        end %while KbCheck
    else
        Screen('FillRect', onScreen, 0); %clear the drawings if pic isn't taken
    end

    %Extra boxes for choice tasks
    %SS and LL for each side
    SS_L = BoxL1;
    SS_R = BoxR1;
    if LL_Position == 0
        LL_L = BoxL4;
        LL_R = BoxR4;
    elseif LL_Position == 1 || LL_rand
        LL_L = BoxL5;
        LL_R = BoxR5;
    elseif LL_Position == 2
        LL_L = BoxL6;
        LL_R = BoxR6;
    end

    %DD text boxes for each side (these go in the bottom)
    DD_L1 = [altBoxW-A-(8/3)*m G2+C+(1/3)*m altBoxW-A-(7/3)*m G2+C+(2/3)*m];
    DD_L2 = [altBoxW-A-(5/3)*m G2+C+(1/3)*m altBoxW-A-(4/3)*m G2+C+(2/3)*m];
    DD_L3 = [altBoxW-A-(2/3)*m G2+C+(1/3)*m altBoxW-A-(1/3)*m G2+C+(2/3)*m];
    DD_R1 = [ScreenX-A-(8/3)*m G2+C+(1/3)*m ScreenX-A-(7/3)*m G2+C+(2/3)*m];
    DD_R2 = [ScreenX-A-(5/3)*m G2+C+(1/3)*m ScreenX-A-(4/3)*m G2+C+(2/3)*m];
    DD_R3 = [ScreenX-A-(2/3)*m G2+C+(1/3)*m ScreenX-A-(1/3)*m G2+C+(2/3)*m];

    %Choice Boxes (to highlight selected alternative)
    leftAltBox = [(4/5)*A G-C-(5/4)*m altBoxW-(4/5)*A G2+C+(5/4)*m];
    rightAltBox = [altBoxW+(4/5)*A G-C-(5/4)*m ScreenX-(4/5)*A G2+C+(5/4)*m];

    %Number boxes for ROI's
    Box(1,:) = textBoxL1;
    Box(2,:) = textBoxL2;
    Box(3,:) = textBoxL3;
    Box(4,:) = BoxL1;
    Box(5,:) = BoxL2;
    Box(6,:) = BoxL3;
    Box(7,:) = BoxL4;
    Box(8,:) = BoxL5;
    Box(9,:) = BoxL6;
    Box(10,:) = DD_L1;
    Box(11,:) = DD_L2;
    Box(12,:) = DD_L3;
    Box(13,:) = textBoxR1;
    Box(14,:) = textBoxR2;
    Box(15,:) = textBoxR3;
    Box(16,:) = BoxR1;
    Box(17,:) = BoxR2;
    Box(18,:) = BoxR3;
    Box(19,:) = BoxR4;
    Box(20,:) = BoxR5;
    Box(21,:) = BoxR6;
    Box(22,:) = DD_R1;
    Box(23,:) = DD_R2;
    Box(24,:) = DD_R3;


    %Load in trials
    %SS = Shorter Sooner, LL = Larger Later, DD = Days Delay
    %Trials - predetermined by Steph et al. - (SS,LL,DD)
    allTrials = csvread('HZtrials_v3.csv', 1, 0); %may want to include the matrix explicitly before real experiment
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%              Instructions                 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if doInstruc

        %Screen 1
        line1 = 'In this study, you will make some choices between amounts of money available\n';
        line2 = 'at different times. For each question, choose the option you prefer.\n';
        line3 = 'Although these choices are hypothetical, please answer as if they are real.\n';
        line4 = '\n\nPress the spacebar to continue.';

        DrawFormattedText(onScreen, [line1 line2 line3 line4], 'center', 'center', whitecol, [], [], [], 2, [], []);
        Screen('Flip', onScreen);

        %Take a picture
        if screenCap
            capSizeX=ScreenX; capSizeY=ScreenY;
            image=Screen('GetImage', onScreen, [cx-capSizeX/2 cy-capSizeY/2 cx+capSizeX/2 cy+capSizeY/2]);
            imgname=strcat('/Users/hascherj/Dropbox/Mac/Documents/Steph Projects/HiddenZero/ExpPics/instruc1.png');
            imwrite(image, imgname, 'png');
        end

        %Wait for button press
        while KbCheck
        end

        FlushEvents('keyDown');
        proceed = 0;
        while proceed == 0
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

        %Screen 2
        Screen('DrawTexture',onScreen,blank1Choice);
        DrawFormattedText(onScreen, [lineDay '21'], 'center', 'center', whitecol, [], [], [], 2, [], DD1_1);
        DrawFormattedText(onScreen, [lineDay '22'], 'center', 'center', whitecol, [], [], [], 2, [], DD2_1);
        DrawFormattedText(onScreen, [lineDay '23'], 'center', 'center', whitecol, [], [], [], 2, [], DD3_1);
        blankScreen2 = Screen('GetImage', onScreen, [], 'backBuffer');
        blankScreen2 = Screen('MakeTexture', onScreen, blankScreen2);
        Screen('FillRect', onScreen, 0);
        Screen('DrawTexture',onScreen,blankScreen2,[],[fifthX (3/10)*ScreenY 4*fifthX (9/10)*ScreenY]);

        line1 = 'In this study, there will be two options to choose from.\n';
        line2 = 'Each of the options will look like this:';
        line3 = '\n\nPress the spacebar to continue.';

        DrawFormattedText(onScreen, [line1 line2 line3], 'center', decY, whitecol, [], [], [], 2, [], []);


        Screen('Flip',onScreen);

        %Take a picture
        if screenCap
            capSizeX=ScreenX; capSizeY=ScreenY;
            image=Screen('GetImage', onScreen, [cx-capSizeX/2 cy-capSizeY/2 cx+capSizeX/2 cy+capSizeY/2]);
            imgname=strcat('/Users/hascherj/Dropbox/Mac/Documents/Steph Projects/HiddenZero/ExpPics/instruc2.png');
            imwrite(image, imgname, 'png');
        end

        %Wait for button press
        while KbCheck
        end

        FlushEvents('keyDown');
        proceed = 0;
        while proceed == 0
            [keyIsDown, secs, keyCode] = KbCheck(-1);
            if keyIsDown
                if keyCode(escKey)
                    ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
                elseif keyCode(RAkey)
                    proceed = 1;
                end
            end
        end %while proceed
        WaitSecs(0.5);

        %Screen 3
        Screen('DrawTexture',onScreen,blank1Choice);
        DrawFormattedText(onScreen, [lineDay '21'], 'center', 'center', whitecol, [], [], [], 2, [], DD1_1);
        DrawFormattedText(onScreen, [lineDay '22'], 'center', 'center', whitecol, [], [], [], 2, [], DD2_1);
        DrawFormattedText(onScreen, [lineDay '23'], 'center', 'center', whitecol, [], [], [], 2, [], DD3_1);
        %Add arrows
        DownArrow(arrow1(1),arrow1(2),arrow1(3),arrow1(4),onScreen,bluecol);
        DownArrow(arrow2(1),arrow2(2),arrow2(3),arrow2(4),onScreen,bluecol);
        DownArrow(arrow3(1),arrow3(2),arrow3(3),arrow3(4),onScreen,bluecol);
        UpArrow(arrow4(1),arrow4(2),arrow4(3),arrow4(4),onScreen,bluecol);
        UpArrow(arrow5(1),arrow5(2),arrow5(3),arrow5(4),onScreen,bluecol);
        UpArrow(arrow6(1),arrow6(2),arrow6(3),arrow6(4),onScreen,bluecol);
        blankScreen3 = Screen('GetImage', onScreen, [], 'backBuffer');
        blankScreen3 = Screen('MakeTexture', onScreen, blankScreen3);
        Screen('FillRect', onScreen, 0);
        Screen('DrawTexture',onScreen,blankScreen3,[],[fifthX (3/10)*ScreenY 4*fifthX (9/10)*ScreenY]);

        line1 = 'Each box corresponds to a day (Day 1 = today, Day 2 = tomorrow, etc.). Each of these\n';
        line2 = 'boxes may have some amount of money listed (e.g., $20.00). If an amount of money is listed\n';
        line3 = 'in a box, that is the amount of money you would receive on that day. If there is nothing\n';
        line4 = 'in a box, then you wouldn`t receive anything on that day.';
        line5 = '\n \nPress the spacebar to continue.';

        Screen('TextSize', onScreen, 22)
        DrawFormattedText(onScreen, [line1 line2 line3 line4 line5], 'center', decY, whitecol, [], [], [], 2, [], []);
        Screen('TextSize', onScreen, 30)

        Screen('Flip',onScreen);

        %Take a picture
        if screenCap
            capSizeX=ScreenX; capSizeY=ScreenY;
            image=Screen('GetImage', onScreen, [cx-capSizeX/2 cy-capSizeY/2 cx+capSizeX/2 cy+capSizeY/2]);
            imgname=strcat('/Users/hascherj/Dropbox/Mac/Documents/Steph Projects/HiddenZero/ExpPics/instruc3.png');
            imwrite(image, imgname, 'png');
        end

        %Wait for button press
        while KbCheck
        end

        FlushEvents('keyDown');
        proceed = 0;
        while proceed == 0
            [keyIsDown, secs, keyCode] = KbCheck(-1);
            if keyIsDown
                if keyCode(escKey)
                    ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
                elseif keyCode(RAkey)
                    proceed = 1;
                end
            end
        end %while proceed
        WaitSecs(0.5);
        %Screen 4
        Screen('DrawTexture',onScreen,blank1Choice);
        DrawFormattedText(onScreen, [lineDay '21'], 'center', 'center', whitecol, [], [], [], 2, [], DD1_1);
        DrawFormattedText(onScreen, [lineDay '22'], 'center', 'center', whitecol, [], [], [], 2, [], DD2_1);
        DrawFormattedText(onScreen, [lineDay '23'], 'center', 'center', whitecol, [], [], [], 2, [], DD3_1);
        DownArrow(arrow1(1),arrow1(2),arrow1(3),arrow1(4),onScreen,bluecol);
        Screen('FrameOval',onScreen,bluecol,SS_1,7);
        Screen('FrameOval',onScreen,bluecol,oval1,7);
        Screen('TextStyle', onScreen, 1);
        DrawFormattedText(onScreen, '$X', 'center', 'center', whitecol, [], [], [], 2, [], SS_1);
        Screen('TextStyle', onScreen, 0);
        blankScreen4 = Screen('GetImage', onScreen, [], 'backBuffer');
        blankScreen4 = Screen('MakeTexture', onScreen, blankScreen4);
        Screen('FillRect', onScreen, 0);
        Screen('DrawTexture',onScreen,blankScreen4,[],[fifthX (3/10)*ScreenY 4*fifthX (9/10)*ScreenY]);

        line1 = 'So, for example, if a dollar amount was listed in the first box, then that`s how much\n';
        line2 = 'money this option would give you today (Day 1). In the example below, you would get $X today.';
        line3 = '\n\nPress the spacebar to continue.';

        DrawFormattedText(onScreen, [line1 line2 line3], 'center', decY, whitecol, [], [], [], 2, [], []);


        Screen('Flip',onScreen);

        %Take a picture
        if screenCap
            capSizeX=ScreenX; capSizeY=ScreenY;
            image=Screen('GetImage', onScreen, [cx-capSizeX/2 cy-capSizeY/2 cx+capSizeX/2 cy+capSizeY/2]);
            imgname=strcat('/Users/hascherj/Dropbox/Mac/Documents/Steph Projects/HiddenZero/ExpPics/instruc4.png');
            imwrite(image, imgname, 'png');
        end

        %Wait for button press
        while KbCheck
        end

        FlushEvents('keyDown');
        proceed = 0;
        while proceed == 0
            [keyIsDown, secs, keyCode] = KbCheck(-1);
            if keyIsDown
                if keyCode(escKey)
                    ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
                elseif keyCode(RAkey)
                    proceed = 1;
                end
            end
        end %while proceed
        WaitSecs(0.5);

        %Screen 5 - depends on LL_Location
        Screen('DrawTexture',onScreen,blank1Choice);
        DrawFormattedText(onScreen, [lineDay '21'], 'center', 'center', whitecol, [], [], [], 2, [], DD1_1);
        DrawFormattedText(onScreen, [lineDay '22'], 'center', 'center', whitecol, [], [], [], 2, [], DD2_1);
        DrawFormattedText(onScreen, [lineDay '23'], 'center', 'center', whitecol, [], [], [], 2, [], DD3_1);
        if LL_Position == 0
            exDay = '21';
            UpArrow(arrow4(1),arrow4(2),arrow4(3),arrow4(4),onScreen,bluecol);
            Screen('FrameOval',onScreen,bluecol,oval1,7);
            Screen('FrameOval',onScreen,bluecol,Box4,7);
            Screen('TextStyle', onScreen, 1);
            DrawFormattedText(onScreen, '$Y', 'center', 'center', whitecol, [], [], [], 2, [], Box4);
            Screen('TextStyle', onScreen, 0);
        elseif LL_Position == 1 || LL_rand
            exDay = '22';
            UpArrow(arrow5(1),arrow5(2),arrow5(3),arrow5(4),onScreen,bluecol);
            Screen('FrameOval',onScreen,bluecol,oval2,7);
            Screen('FrameOval',onScreen,bluecol,Box5,7);
            Screen('TextStyle', onScreen, 1);
            DrawFormattedText(onScreen, '$Y', 'center', 'center', whitecol, [], [], [], 2, [], Box5);
            Screen('TextStyle', onScreen, 0);
        elseif LL_Position == 2
            exDay = '23';
            UpArrow(arrow6(1),arrow6(2),arrow6(3),arrow6(4),onScreen,bluecol);
            Screen('FrameOval',onScreen,bluecol,oval3,7);
            Screen('FrameOval',onScreen,bluecol,Box6,7);
            Screen('TextStyle', onScreen, 1);
            DrawFormattedText(onScreen, '$Y', 'center', 'center', whitecol, [], [], [], 2, [], Box6);
            Screen('TextStyle', onScreen, 0);
        end
        blankScreen5 = Screen('GetImage', onScreen, [], 'backBuffer');
        blankScreen5 = Screen('MakeTexture', onScreen, blankScreen5);
        Screen('FillRect', onScreen, 0);
        Screen('DrawTexture',onScreen,blankScreen5,[],[fifthX (3/10)*ScreenY 4*fifthX (9/10)*ScreenY]);

        line1 = strcat('In this example, you would get $Y on Day ',exDay,':');
        line2 = '\n\nPress the spacebar to continue.';

        DrawFormattedText(onScreen, [line1 line2], 'center', decY, whitecol, [], [], [], 2, [], []);


        Screen('Flip',onScreen);

        %Take a picture
        if screenCap
            capSizeX=ScreenX; capSizeY=ScreenY;
            image=Screen('GetImage', onScreen, [cx-capSizeX/2 cy-capSizeY/2 cx+capSizeX/2 cy+capSizeY/2]);
            imgname=strcat('/Users/hascherj/Dropbox/Mac/Documents/Steph Projects/HiddenZero/ExpPics/instruc5.png');
            imwrite(image, imgname, 'png');
        end

        %Wait for button press
        while KbCheck
        end

        FlushEvents('keyDown');
        proceed = 0;
        while proceed == 0
            [keyIsDown, secs, keyCode] = KbCheck(-1);
            if keyIsDown
                if keyCode(escKey)
                    ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
                elseif keyCode(RAkey)
                    proceed = 1;
                end
            end
        end %while proceed
        WaitSecs(0.5);

        %Screen 6
        Screen('DrawTexture',onScreen,blank1Choice);
        DrawFormattedText(onScreen, [lineDay '21'], 'center', 'center', whitecol, [], [], [], 2, [], DD1_1);
        DrawFormattedText(onScreen, [lineDay '22'], 'center', 'center', whitecol, [], [], [], 2, [], DD2_1);
        DrawFormattedText(onScreen, [lineDay '23'], 'center', 'center', whitecol, [], [], [], 2, [], DD3_1);
        Screen('FrameOval',onScreen,bluecol,oval3,10);
        blankScreen6 = Screen('GetImage', onScreen, [], 'backBuffer');
        blankScreen6 = Screen('MakeTexture', onScreen, blankScreen6);
        Screen('FillRect', onScreen, 0);
        Screen('DrawTexture',onScreen,blankScreen6,[],[fifthX (3/10)*ScreenY 4*fifthX (9/10)*ScreenY]);

        line1 = 'The later days will change from decision to decision. So, instead of Days 21-23,\n';
        line2 = 'it might be Days 8-10, Days 46-48, or any other three-day combination.';
        line3 = '\n\nPress the spacebar to continue.';

        DrawFormattedText(onScreen, [line1 line2 line3], 'center', decY, whitecol, [], [], [], 2, [], []);


        Screen('Flip',onScreen);

        %Take a picture
        if screenCap
            capSizeX=ScreenX; capSizeY=ScreenY;
            image=Screen('GetImage', onScreen, [cx-capSizeX/2 cy-capSizeY/2 cx+capSizeX/2 cy+capSizeY/2]);
            imgname=strcat('/Users/hascherj/Dropbox/Mac/Documents/Steph Projects/HiddenZero/ExpPics/instruc6.png');
            imwrite(image, imgname, 'png');
        end

        %Wait for button press
        while KbCheck
        end

        FlushEvents('keyDown');
        proceed = 0;
        while proceed == 0
            [keyIsDown, secs, keyCode] = KbCheck(-1);
            if keyIsDown
                if keyCode(escKey)
                    ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
                elseif keyCode(RAkey)
                    proceed = 1;
                end
            end
        end %while proceed
        WaitSecs(0.5);

         %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%           Comprehension Check             %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if doCompQ
        Screen('DrawTexture',onScreen,blank1Choice);
        DrawFormattedText(onScreen, [lineDay '8'], 'center', 'center', whitecol, [], [], [], 2, [], DD1_1);
        DrawFormattedText(onScreen, [lineDay '9'], 'center', 'center', whitecol, [], [], [], 2, [], DD2_1);
        DrawFormattedText(onScreen, [lineDay '10'], 'center', 'center', whitecol, [], [], [], 2, [], DD3_1);
        Screen('TextStyle', onScreen, 1);
        DrawFormattedText(onScreen, '$10', 'center', 'center', whitecol, [], [], [], 2, [], SS_1);
        Screen('TextStyle', onScreen, 0);
        %add in comp q details here
        compScreenBig = Screen('GetImage', onScreen, [], 'backBuffer');
        compScreenBig = Screen('MakeTexture', onScreen, compScreenBig);
        Screen('FillRect', onScreen, 0);
        Screen('DrawTexture',onScreen,compScreenBig,[],[fifthX (3/10)*ScreenY 4*fifthX (9/10)*ScreenY]);
        compScreenSmall = Screen('GetImage', onScreen, [], 'backBuffer');
        compScreenSmall = Screen('MakeTexture', onScreen, compScreenSmall);
        compKeys = [Akey,Bkey,Ckey,Dkey,Pkey,escKey,RAkey];
        [correct,times] = CompQ(onScreen,decY,compScreenSmall,compKeys,whitecol,0,1,screenCap);
        while ~correct && (times < 2)
            [correct,times] = CompQ(onScreen,decY,compScreenSmall,compKeys,whitecol,times,0,screenCap);
        end
        if correct
            %Text
            line1 = 'That is correct.';
            line2 = '\n\nPress the spacebar to begin the experiment.';
            DrawFormattedText(onScreen, [line1 line2], 'center', 'center', whitecol, [], [], [], 2, [], []);
            %Show on screen
            Screen('Flip',onScreen);
            %Take a picture
            if screenCap
                capSizeX=ScreenX; capSizeY=ScreenY;
                image=Screen('GetImage', onScreen, [cx-capSizeX/2 cy-capSizeY/2 cx+capSizeX/2 cy+capSizeY/2]);
                imgname=strcat('/Users/hascherj/Dropbox/Mac/Documents/Steph Projects/HiddenZero/ExpPics/correct.png');
                imwrite(image, imgname, 'png');
            end
            %Wait for button press
            while KbCheck
            end

            FlushEvents('keyDown');
            proceed = 0;
            while proceed == 0
                [keyIsDown, secs, keyCode] = KbCheck(-1);
                if keyIsDown
                    if keyCode(escKey)
                        ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
                    elseif keyCode(RAkey)
                        proceed = 1;
                    end
                end
            end %while proceed
            WaitSecs(0.5);
        end
        if ~correct && (times > 1)
            askMe(onScreen,compKeys,whitecol,screenCap)
            times = 3;
        end
    end


        %Screen 7
        line1 = 'Now you are ready to begin! You will be making decisions between two options, one on\n';
        line2 = 'each side of the screen. For each decision, choose the option you prefer: to choose the\n';
        line3 = 'option on the left, press the "F" key. To choose the option on the right, press the "J" key.\n';
        line35 = '\nOnce you have selected an option, you will have the opportunity to confirm (or change) your choice. \nTo confirm your choice, press the same button you just pressed (F for left and J for right) three times. \nTo change your choice, press the other button (F for left and J for right) three times.';
        line4 = '\n\nPlease take these decisions seriously. \nAt the end of the study, the computer will randomly draw a number between 1 and 100. If the number is 1 through 10, \nwe will randomly select one of your decisions and you will receive the option that you chose,\n in the form of a Visa gift card.';
        line5 = '\n\nPress the spacebar to begin.';

        DrawFormattedText(onScreen, [line1 line2 line3 line35 line4 line5], 'center', 'center', whitecol, [], [], [], 2, [], []);

        Screen('Flip',onScreen);

        %Take a picture
        if screenCap
            capSizeX=ScreenX; capSizeY=ScreenY;
            image=Screen('GetImage', onScreen, [cx-capSizeX/2 cy-capSizeY/2 cx+capSizeX/2 cy+capSizeY/2]);
            imgname=strcat('/Users/hascherj/Dropbox/Mac/Documents/Steph Projects/HiddenZero/ExpPics/instruc7.png');
            imwrite(image, imgname, 'png');
        end

        %Wait for button press
        while KbCheck
        end

        FlushEvents('keyDown');
        proceed = 0;
        while proceed == 0
            [keyIsDown, secs, keyCode] = KbCheck(-1);
            if keyIsDown
                if keyCode(escKey)
                    ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
                elseif keyCode(RAkey)
                    proceed = 1;
                end
            end
        end %while proceed
        WaitSecs(0.5);
    end %doInstruc
   
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%            EyeTracking Setup              %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if doEye % if the eyetracker is connected
        tmp = EyelinkInit(0);

        % Provide Eyelink with details about the graphics environment
        % and perform some initializations. The information is returned
        % in a structure that also contains useful defaults
        % and control codes (e.g. tracker state bit and Eyelink key values).
        el = EyelinkInitDefaults(onScreen);

        % Initialization of the connection with the Eyelink Gazetracker.
        % exit program if this fails.
        if ~EyelinkInit(0) % Initializes Eyelink and Ethernet system. Returns: 0 if OK, -1 if error
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

        el.backgroundcolour = 0;
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
        if eye_used == el.BINOCULAR; % if both eyes are tracked
            eye_used = el.LEFT_EYE; % use left eye
        end
    end % if do eyeTracking
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%                 Task 1                    %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if doTask1
        %Task 1 trials (this only matters when nTrials < length(allTrials))
        trialMat1 = allTrials(randperm(size(allTrials,1)),:); %shuffle rows
        trialMat1= trialMat1(1:nTrials,:); %only include nTrials


        %Do Task 1
        for i = 1:nTrials
            % Assign LL_Position if LL_rand
            if LL_rand
                LL_Position = randi([0 2]);
            end

            % Take a break every 50 trials %
                if mod(i,50) == 0 && i ~= nTrials
                    Screen('FillRect', onScreen, [0]);
                        
                        line1 = 'If desired, you may take a short break now. \n\n If you have any questions, ask the experimenter at this time.';
                        line2 = '\n\n When you are ready to continue with the task, \n please press the space bar.';
                        
                        
                        % Draw all the text in one go
                        Screen('TextSize',onScreen,scaleSize);
                        DrawFormattedText(onScreen, [line1 line2],'center', ScreenY * 0.25, whitecolor, [], [], [], 1.5);
                        
                        Screen('Flip',onScreen);
                        
                        FlushEvents('keyDown');
                        proceed=0;
                        while proceed==0
                            [keyIsDown, secs, keyCode] = KbCheck(-1);
                            if keyIsDown
                                if keyCode(RAkey)
                                    proceed=1;
                                elseif keyCode(escKey)
                                    ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
                                end
                            end
                        end
                end
            if doEye
                Eyelink('StartRecording');
                WaitSecs(0.1);
                Eyelink('Message', 'SYNCTIME_0');
                Eyelink('Message', '!V TRIAL_VAR VALID_TRIAL %d', 1);

                % Fixation screen
                Screen('FillRect', onScreen, [0 0 0]);
                Screen(onScreen,'TextSize',crossSize);
                [newX, newY] = Screen(onScreen,'DrawText',fixation,round(cx-width/2),round(cy), [255 255 255], 0, 1);
                Screen(onScreen,'TextSize',30);
                [vbl,fix_onset] = Screen('Flip', onScreen);

                % Make sure they fixate
                eye_used = Eyelink('eyeavailable');
                fixated = 0;

                while GetSecs - fix_onset <= fix_time

                    if Eyelink('NewFloatSampleAvailable') > 0
                        % get the sample in the form of an event structure
                        evt = Eyelink('NewestFloatSample');

                        eyeX = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                        eyeY = evt.gy(eye_used+1);
                        a = evt.pa(eye_used+1);
                        eyetime = GetSecs();
                        % do we have valid data and is the pupil visible?

                        if eyeX ~= el.MISSING_DATA && eyeY ~= el.MISSING_DATA && a > 0
                            distFromFix = sqrt((eyeX - 0.5*ScreenX)^2 + (eyeY - 0.5*ScreenY)^2);
                        else
                            distFromFix = 99999; % if no eye is present,do not advance trial
                        end

                        if distFromFix > fixThresh
                            fix_onset = GetSecs; % Do not advance the trial
                        end

                        [~,~,keyCode] = KbCheck;

                        if keyCode(sixkey)

                            Eyelink('Message', '!V TRIAL_VAR VALID_TRIAL %d', 0);
                            Eyelink('StopRecording');

                            EyelinkDoTrackerSetup(el);

                            Eyelink('StartRecording');
                            Eyelink('Message', '!V TRIAL_VAR VALID_TRIAL %d', 1);

                            fixated = 0;

                            %elseif keyCode(escKey)
                            % ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')

                        end

                    end

                    Screen('FillRect', onScreen, 0);
                    Screen(onScreen,'TextSize',crossSize);
                    [newX, newY] = Screen(onScreen,'DrawText',fixation,round(cx-width/2),round(cy), [255 255 255], 0, 1);
                    Screen(onScreen,'TextSize',30);
                    vbl  = Screen('Flip', onScreen, vbl + (waitframes - 0.5) * ifi);

                end % while ~fixated

                Eyelink('Message', 'SYNCTIME_1'); % Sync time
                WaitSecs(0.001);
                Eyelink('Message', 'Choice Screen Start Trial %d', i);
            else %if ~doEye
                % Fixation screen
                Screen('FillRect', onScreen, [0 0 0]);
                Screen(onScreen,'TextSize',crossSize);
                [newX, newY] = Screen(onScreen,'DrawText',fixation,round(cx-width/2),round(cy), [255 255 255], 0, 1);
                Screen(onScreen,'TextSize',30);
                [vbl,fix_onset] = Screen('Flip', onScreen);
                WaitSecs(fix_time);
            end %if doEye
            %Create Trial
            %Pull trial values
            SS = trialMat1(i,1);
            LL = trialMat1(i,2);
            DD = trialMat1(i,3);
            if LL_Position == 0
                %Need 2 days after
                DD_1 = DD;
                DD_2 = DD + 1;
                DD_3 = DD + 2;
            elseif LL_Position == 1
                %Need day before and after
                DD_1 = DD - 1;
                DD_2 = DD;
                DD_3 = DD + 1;
            elseif LL_Position == 2
                %Need 2 days before
                DD_1 = DD - 2;
                DD_2 = DD - 1;
                DD_3 = DD;
            end
            %Make text versions
            SS_t = num2str(SS);
            LL_t = num2str(LL);
            DD1 = num2str(DD_1);
            DD2 = num2str(DD_2);
            DD3 = num2str(DD_3);
            %Draw base texture
            Screen('DrawTexture',onScreen,blankChoice);
            %Randomize which side is SS/LL
            SS_Right = floor(2*rand()); %0 = SS on left
            %Add in trial values
            %SS and LL
            if SS_Right
                DrawFormattedText(onScreen,['$' SS_t],'center', 'center', whitecol, [], [], [], 2, [], SS_R);
                DrawFormattedText(onScreen,['$' LL_t],'center', 'center', whitecol, [], [], [], 2, [], LL_L);
            else
                DrawFormattedText(onScreen,['$' SS_t],'center', 'center', whitecol, [], [], [], 2, [], SS_L);
                DrawFormattedText(onScreen,['$' LL_t],'center', 'center', whitecol, [], [], [], 2, [], LL_R);
            end
            %Days
            DrawFormattedText(onScreen,[lineDay DD1],'center', 'center', whitecol, [], [], [], 2, [], DD_L1);
            DrawFormattedText(onScreen,[lineDay DD1],'center', 'center', whitecol, [], [], [], 2, [], DD_R1);
            DrawFormattedText(onScreen,[lineDay DD2],'center', 'center', whitecol, [], [], [], 2, [], DD_L2);
            DrawFormattedText(onScreen,[lineDay DD2],'center', 'center', whitecol, [], [], [], 2, [], DD_R2);
            DrawFormattedText(onScreen,[lineDay DD3],'center', 'center', whitecol, [], [], [], 2, [], DD_L3);
            DrawFormattedText(onScreen,[lineDay DD3],'center', 'center', whitecol, [], [], [], 2, [], DD_R3);
            %Add in zeroes by condition and side
            if SS_Right
                if whichCond == 1 || whichCond == 3
                    DrawFormattedText(onScreen,'$0','center', 'center', whitecol, [], [], [], 2, [], LL_R);
                end
                if whichCond == 2 || whichCond == 3
                    DrawFormattedText(onScreen,'$0','center', 'center', whitecol, [], [], [], 2, [], SS_L);
                end
            else
                if whichCond == 1 || whichCond == 3
                    DrawFormattedText(onScreen,'$0','center', 'center', whitecol, [], [], [], 2, [], LL_L);
                end
                if whichCond == 2 || whichCond == 3
                    DrawFormattedText(onScreen,'$0','center', 'center', whitecol, [], [], [], 2, [], SS_R);
                end
            end
            %Capture Textures
            trialChoice = Screen('GetImage', onScreen, [], 'backBuffer');
            trialChoice = Screen('MakeTexture', onScreen, trialChoice); % Make this a texture, it's easier to draw

            %Display on screen
            [vbl, choiceOnset, FlipTimestamp, Missed, Beampos] = Screen('Flip', onScreen, 0, 1);
            %Take Screenshot
            if screenCap && i == 1
                capSizeX=ScreenX; capSizeY=ScreenY;
                image=Screen('GetImage', onScreen, [cx-capSizeX/2 cy-capSizeY/2 cx+capSizeX/2 cy+capSizeY/2]);
                imgname=strcat('/Users/hascherj/Dropbox/Mac/Documents/Steph Projects/HiddenZero/ExpPics/binary_choice_ex_cond_', num2str(whichCond), '.png');
                imwrite(image, imgname, 'png');
            end
            %Collect response
            RT = 0; %default
            while KbCheck %make them lift their finger from last trial
            end
            FlushEvents('keyDown');
            pastROI = 0;
            %Choose0 = 0;
            Choose1 = 0;
            Choose2 = 0;
            numLeft = 0;
            numRight = 0;
            while Choose1 == 0
                if doEye
                    % Check recording status, stop display if error
                    err = Eyelink('CheckRecording');

                    if(err~=0)
                        error('checkrecording problem, status: %d',err)
                    end

                    % check for presence of a new sample update
                    status = Eyelink('NewFloatSampleAvailable');
                    % satus = -1 (none or error) ; 0 (old) ; 1 (new)

                    if status ~= 1
                        fprintf('no sample available, status: %d\n',status)
                    end
                    % Track their eyes!
                    if Eyelink( 'NewFloatSampleAvailable') > 0 % get the sample in the form of an event structure
                        evt = Eyelink( 'NewestFloatSample');
                        if eye_used ~= -1 % do we know which eye to use yet? % if so, get current gaze position from sample
                            curx = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                            cury = evt.gy(eye_used+1); % do we have valid data and is the pupil visible?
                            if curx~=el.MISSING_DATA && cury~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                                %Insert ROI's here
                                ROI = 0;
                                for k = 1:24
                                    thisBox = Box(k,:);
                                    if curx>=thisBox(1) && curx<=thisBox(3) && cury>=thisBox(2) && cury<=thisBox(4)
                                        ROI = k;
                                    end
                                end
                                if ROI == pastROI
                                    pastROI = ROI;
                                elseif ROI ~= pastROI
                                    if ROI ~= 0
                                        fprintf(fix1File, '%s\t%s\t%s\t%s\t%s\n', num2str(i), num2str(ROI), num2str(GetSecs-choiceOnset), '0',num2str(subjectNumber));
                                    else
                                        fprintf(fix1File, '%s\t%s\t%s\t%s\t%s\n', num2str(i), num2str(ROI), '0', num2str(GetSecs-choiceOnset),num2str(subjectNumber));
                                    end % if ROI != 0
                                    pastROI = ROI;
                                else
                                    %counter = counter + 1;
                                end % if curx
                            else % if we don't, first find eye that's being tracked
                                eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
                                if eye_used == el.BINOCULAR % if both eyes are tracked
                                    eye_used = el.LEFT_EYE; % use left eye
                                end % if eye_used
                            end % if curx
                        end % if eye_used
                    end % if new eye sample
                end %if doEye
                %while Choose1 == 0
                % Get keyboard response
                [keyIsDown, secs, keyCode] = KbCheck(-1);
                if keyIsDown && (keyCode(escKey) || keyCode(Lkey) || keyCode(Rkey))
                    if doEye
                        Eyelink('Message', 'SYNCTIME_2');
                        WaitSecs(0.001);
                        Eyelink('Message', 'Part 1 Choice Made Trial %d', j);
                    end
                    if keyCode(escKey)
                        if doEye
                            Eyelink('StopRecording');
                            Eyelink('CloseFile');
                            Eyelink('ReceiveFile',edfFile);
                            Eyelink('ShutDown');
                        end
                        ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
                    elseif keyCode(Lkey)
                        time1 = GetSecs;
                        RT1 = time1 - choiceOnset;
                        RTmat(i,1) = i;
                        RTmat(i,2) = RT1;
                        Choices1(i,1) = i;
                        Chose1Left = 1;
                        choiceBox = leftAltBox;
                        if SS_Right
                            chose1SS = 0;
                            Choices1(i,2) = LL;
                            Choices1(i,3) = DD;
                        else
                            chose1SS = 1;
                            Choices1(i,2) = SS;
                            Choices1(i,3) = 0;
                        end

                    elseif keyCode(Rkey)
                        time1 = GetSecs;
                        RT1 = time1 - choiceOnset;
                        RTmat(i,1) = i;
                        RTmat(i,2) = RT1;
                        Choices1(i,1) = i;
                        Chose1Left = 0;
                        choiceBox = rightAltBox;
                        if SS_Right
                            chose1SS = 1;
                            Choices1(i,2) = SS;
                            Choices1(i,3) = 0;
                        else
                            chose1SS = 0;
                            Choices1(i,2) = LL;
                            Choices1(i,3) = DD;
                        end
                    end
                    Choose1 = 1;
                    wait = 1;
                end % if key is down
            end % while Choose1
            %Get Confirmation
            RTmat = -ones(nTrials,8);
            while ~Choose2
                Screen('DrawTexture',onScreen,trialChoice);
                Screen('FrameRect', onScreen, redcol, choiceBox, 5);
                Screen('FillRect',onScreen,0,[cx-(cx/5) ScreenY*.85 cx + (cx/5) ScreenY*.95])
                DrawFormattedText(onScreen,'CONFIRM CHOICE','center',(.9*ScreenY),whitecol);
                Screen('Flip',onScreen);
                %Take Screenshot
                if screenCap && i == 1
                    capSizeX=ScreenX; capSizeY=ScreenY;
                    image=Screen('GetImage', onScreen, [cx-capSizeX/2 cy-capSizeY/2 cx+capSizeX/2 cy+capSizeY/2]);
                    imgname=strcat('/Users/hascherj/Dropbox/Mac/Documents/Steph Projects/HiddenZero/ExpPics/confirmEx.png');
                    imwrite(image, imgname, 'png');
                end
                [keyIsDown, secs, keyCode] = KbCheck(-1);
                if wait
                    while keyIsDown
                        [keyIsDown, secs, keyCode] = KbCheck(-1);
                    end
                    wait = 0;
                end
                if doEye
                    % Check recording status, stop display if error
                    err = Eyelink('CheckRecording');

                    if(err~=0)
                        error('checkrecording problem, status: %d',err)
                    end

                    % check for presence of a new sample update
                    status = Eyelink('NewFloatSampleAvailable');
                    % satus = -1 (none or error) ; 0 (old) ; 1 (new)

                    if status ~= 1
                        fprintf('no sample available, status: %d\n',status)
                    end
                    % Track their eyes!
                    if Eyelink( 'NewFloatSampleAvailable') > 0 % get the sample in the form of an event structure
                        evt = Eyelink( 'NewestFloatSample');
                        if eye_used ~= -1 % do we know which eye to use yet? % if so, get current gaze position from sample
                            curx = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                            cury = evt.gy(eye_used+1); % do we have valid data and is the pupil visible?
                            if curx~=el.MISSING_DATA && cury~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                                %Insert ROI's here
                                ROI = 0;
                                for k = 1:24
                                    thisBox = Box(k,:);
                                    if curx>thisBox(1) && curx<=thisBox(3) && cury>thisBox(2) && cury<=thisBox(4)
                                        ROI = k;
                                    end
                                end
                                if ROI == pastROI
                                    pastROI = ROI;
                                elseif ROI ~= pastROI
                                    if ROI ~= 0
                                        fprintf(fix1File, '%s\t%s\t%s\t%s\t%s\n', num2str(i), num2str(ROI), num2str(GetSecs-choiceOnset), '0',num2str(subjectNumber));
                                    else
                                        fprintf(fix1File, '%s\t%s\t%s\t%s\t%s\n', num2str(i), num2str(ROI), '0', num2str(GetSecs-choiceOnset),num2str(subjectNumber));
                                    end % if ROI != 0
                                    pastROI = ROI;
                                else
                                    %counter = counter + 1;
                                end % if curx
                            else % if we don't, first find eye that's being tracked
                                eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
                                if eye_used == el.BINOCULAR % if both eyes are tracked
                                    eye_used = el.LEFT_EYE; % use left eye
                                end % if eye_used
                            end % if curx
                        end % if eye_used
                    end % if new eye sample
                end %if doEye
                if keyIsDown && (keyCode(escKey) || keyCode(Lkey) || keyCode(Rkey))
                    if doEye
                        Eyelink('Message', 'SYNCTIME_3');
                        WaitSecs(0.001);
                        Eyelink('Message', 'Session II Choice2 Made Trial %d', j, 'Repeat', Choose2);
                    end
                    if keyCode(escKey)
                        if doEye
                            Eyelink('StopRecording');
                            Eyelink('CloseFile');
                            Eyelink('ReceiveFile',edfFile);
                            Eyelink('ShutDown');
                        end
                        ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
                    elseif keyCode(Lkey)
                        numLeft = numLeft + 1;
                        RT2 = GetSecs - time1;
                        RTmat(i,2+numLeft) = RT2;
                        Chose2Left = 1;
                        if SS_Right
                            chose2SS = 0;
                            Choices1(i,4) = LL;
                            Choices1(i,5) = DD;
                        else
                            chose2SS = 1;
                            Choices1(i,4) = SS;
                            Choices1(i,5) = 0;
                        end
                    elseif keyCode(Rkey)
                        numRight = numRight + 1;
                        RT2 = GetSecs - time1;
                        RTmat(i,5+numRight) = RT2;
                        Chose2Left = 0;
                        if SS_Right
                            chose2SS = 1;
                            Choices1(i,4) = SS;
                            Choices1(i,5) = 0;
                        else
                            chose2SS = 0;
                            Choices1(i,4) = LL;
                            Choices1(i,5) = DD;
                        end
                    end
                    if numLeft > 2 || numRight > 2
                        %'SN','Trial','LL','SS','DD','Condition','SS_Right','LL_Position','chose1SS','RT1','chose2SS','LeftRT1','LRT2','LRT3','RRT1','RRT2','RRT3','doEye'
                        fprintf(choiceDataFile,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n',num2str(subjectNumber),num2str(i),num2str(LL),num2str(SS),num2str(DD),num2str(whichCond),num2str(SS_Right),num2str(LL_Position),num2str(chose1SS),num2str(RT1),num2str(chose2SS),num2str(RTmat(i,3)),num2str(RTmat(i,4)),num2str(RTmat(i,5)),num2str(RTmat(i,6)),num2str(RTmat(i,7)),num2str(RTmat(i,8)),num2str(doEye));
                    Choose2 = 1;
                    end
                    while KbCheck
                    end
                end % if keyisDown
            end % while choose2
            % end %while Choose0
            if doEye
                Eyelink('StopRecording');
            end
        end %for i = 1:nTrials
    end %do Task1

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%                 Task 2                    %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if doTask2
        whichCond = 4;
        %Transition screen
        if doTask1 && ~doEye % no eyetracking
            line1 = 'You have completed half of the choices. Feel free to take a short break.\n';
            line2 = 'Once you are ready to move on, let the experimenter know.';
            DrawFormattedText(onScreen, [line1 line2], 'center', 'center', whitecol, [], [], [], 2, [], []);
            Screen('Flip',onScreen);
            %Wait for button press
            while KbCheck
            end

            FlushEvents('keyDown');
            proceed = 0;
            while proceed == 0
                [keyIsDown, secs, keyCode] = KbCheck(-1);
                if keyIsDown
                    if keyCode(escKey)
                        ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
                    elseif keyCode(RAkey)
                        proceed = 1;
                    end
                end
            end %while proceed
            WaitSecs(0.5);
        elseif doTask1 && doEye % yes eyetracking - need to recalibrate
            line1 = 'You have completed half of the choices. Feel free to take a short break. Before you\n';
            line2 = 'begin the second half, we will recalibrate the eye tracker. Once you are ready to move\n';
            line3 = 'on, let the experimenter know.';
            DrawFormattedText(onScreen, [line1 line2 line3], 'center', 'center', whitecol, [], [], [], 2, [], []);
            Screen('Flip',onScreen);
            WaitSecs(0.5);
            while KbCheck
            end

            FlushEvents('keyDown');
            proceed = 0;
            while proceed == 0
                [keyIsDown, secs, keyCode] = KbCheck(-1);
                if keyIsDown
                    if keyCode(escKey)
                        ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
                    elseif keyCode(sixkey)
                        proceed = 1;
                    end
                end
            end %while proceed


            %%% RECALIBRATE
            Eyelink('Message', '!V TRIAL_VAR VALID_TRIAL %d', 0);
            Eyelink('StopRecording');

            EyelinkDoTrackerSetup(el);

            Eyelink('StartRecording');
            Eyelink('Message', '!V TRIAL_VAR VALID_TRIAL %d', 1);

            fixated = 0;

                    
        end %Transition screen
        %Now everyone does no-zeroes condition
        %Task 2 trials (this only matters when nTrials < length(allTrials))
        trialMat2 = allTrials(randperm(size(allTrials,1)),:); %shuffle rows
        trialMat2 = trialMat2(1:nTrials,:); %only include nTrials

        %Do Task 2
        for i = 1:nTrials
            % Assign LL_Position if LL_rand
            if LL_rand
                LL_Position = randi([0 2]);
            end
            if doEye
                Eyelink('StartRecording');
                WaitSecs(0.1);
                Eyelink('Message', 'SYNCTIME_0');
                Eyelink('Message', '!V TRIAL_VAR VALID_TRIAL %d', 1);

                % Fixation screen
                Screen('FillRect', onScreen, [0 0 0]);
                Screen(onScreen,'TextSize',crossSize);
                [newX, newY] = Screen(onScreen,'DrawText',fixation,round(cx-width/2),round(cy), [255 255 255], 0, 1);
                Screen(onScreen,'TextSize',30);
                [vbl,fix_onset] = Screen('Flip', onScreen);

                % Make sure they fixate
                eye_used = Eyelink('eyeavailable');
                fixated = 0;

                while GetSecs - fix_onset <= fix_time

                    if Eyelink('NewFloatSampleAvailable') > 0
                        % get the sample in the form of an event structure
                        evt = Eyelink('NewestFloatSample');

                        eyeX = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                        eyeY = evt.gy(eye_used+1);
                        a = evt.pa(eye_used+1);
                        eyetime = GetSecs();
                        % do we have valid data and is the pupil visible?

                        if eyeX ~= el.MISSING_DATA && eyeY ~= el.MISSING_DATA && a > 0
                            distFromFix = sqrt((eyeX - 0.5*ScreenX)^2 + (eyeY - 0.5*ScreenY)^2);
                        else
                            distFromFix = 99999; % if no eye is present,do not advance trial
                        end

                        if distFromFix > fixThresh
                            fix_onset = GetSecs; % Do not advance the trial
                        end

                        [~,~,keyCode] = KbCheck;

                        if keyCode(sixkey)

                            Eyelink('Message', '!V TRIAL_VAR VALID_TRIAL %d', 0);
                            Eyelink('StopRecording');

                            EyelinkDoTrackerSetup(el);

                            Eyelink('StartRecording');
                            Eyelink('Message', '!V TRIAL_VAR VALID_TRIAL %d', 1);

                            fixated = 0;

                            %elseif keyCode(escKey)
                            % ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')

                        end

                    end

                    Screen('FillRect', onScreen, 0);
                    Screen(onScreen,'TextSize',crossSize);
                    [newX, newY] = Screen(onScreen,'DrawText',fixation,round(cx-width/2),round(cy), [255 255 255], 0, 1);
                    Screen(onScreen,'TextSize',30);
                    vbl  = Screen('Flip', onScreen, vbl + (waitframes - 0.5) * ifi);

                end % while ~fixated

                Eyelink('Message', 'SYNCTIME_1'); % Sync time
                WaitSecs(0.001);
                Eyelink('Message', 'Choice Screen Start Part 2 Trial %d', i);
            else %if ~doEye
                % Fixation screen
                Screen('FillRect', onScreen, [0 0 0]);
                Screen(onScreen,'TextSize',crossSize);
                [newX, newY] = Screen(onScreen,'DrawText',fixation,round(cx-width/2),round(cy), [255 255 255], 0, 1);
                Screen(onScreen,'TextSize',30);
                [vbl,fix_onset] = Screen('Flip', onScreen);
                WaitSecs(fix_time);
            end %if doEye
            %Create Trial
            %Pull trial values
            SS = trialMat2(i,1);
            LL = trialMat2(i,2);
            DD = trialMat2(i,3);
            if LL_Position == 0
                %Need 2 days after
                DD_1 = DD;
                DD_2 = DD + 1;
                DD_3 = DD + 2;
            elseif LL_Position == 1
                %Need day before and after
                DD_1 = DD - 1;
                DD_2 = DD;
                DD_3 = DD + 1;
            elseif LL_Position == 2
                %Need 2 days before
                DD_1 = DD - 2;
                DD_2 = DD - 1;
                DD_3 = DD;
            end
            %Make text versions
            SS_t = num2str(SS);
            LL_t = num2str(LL);
            DD1 = num2str(DD_1);
            DD2 = num2str(DD_2);
            DD3 = num2str(DD_3);
            %Draw base texture
            Screen('DrawTexture',onScreen,blankChoice);
            %Randomize which side is SS/LL
            SS_Right = floor(2*rand()); %0 = SS on left
            %Add in trial values
            %SS and LL
            if SS_Right
                DrawFormattedText(onScreen,['$' SS_t],'center', 'center', whitecol, [], [], [], 2, [], SS_R);
                DrawFormattedText(onScreen,['$' LL_t],'center', 'center', whitecol, [], [], [], 2, [], LL_L);
            else
                DrawFormattedText(onScreen,['$' SS_t],'center', 'center', whitecol, [], [], [], 2, [], SS_L);
                DrawFormattedText(onScreen,['$' LL_t],'center', 'center', whitecol, [], [], [], 2, [], LL_R);
            end
            %Days
            DrawFormattedText(onScreen,[lineDay DD1],'center', 'center', whitecol, [], [], [], 2, [], DD_L1);
            DrawFormattedText(onScreen,[lineDay DD1],'center', 'center', whitecol, [], [], [], 2, [], DD_R1);
            DrawFormattedText(onScreen,[lineDay DD2],'center', 'center', whitecol, [], [], [], 2, [], DD_L2);
            DrawFormattedText(onScreen,[lineDay DD2],'center', 'center', whitecol, [], [], [], 2, [], DD_R2);
            DrawFormattedText(onScreen,[lineDay DD3],'center', 'center', whitecol, [], [], [], 2, [], DD_L3);
            DrawFormattedText(onScreen,[lineDay DD3],'center', 'center', whitecol, [], [], [], 2, [], DD_R3);
            %Add in zeroes by condition and side
            if SS_Right
                if whichCond == 1 || whichCond == 3
                    DrawFormattedText(onScreen,'$0','center', 'center', whitecol, [], [], [], 2, [], LL_R);
                end
                if whichCond == 2 || whichCond == 3
                    DrawFormattedText(onScreen,'$0','center', 'center', whitecol, [], [], [], 2, [], SS_L);
                end
            else
                if whichCond == 1 || whichCond == 3
                    DrawFormattedText(onScreen,'$0','center', 'center', whitecol, [], [], [], 2, [], LL_L);
                end
                if whichCond == 2 || whichCond == 3
                    DrawFormattedText(onScreen,'$0','center', 'center', whitecol, [], [], [], 2, [], SS_R);
                end
            end
            %Capture Textures
            trialChoice = Screen('GetImage', onScreen, [], 'backBuffer');
            trialChoice = Screen('MakeTexture', onScreen, trialChoice); % Make this a texture, it's easier to draw

            %Display on screen
            [vbl, choiceOnset, FlipTimestamp, Missed, Beampos] = Screen('Flip', onScreen, 0, 1);
            %Take Screenshot
            if screenCap && i == 1
                capSizeX=ScreenX; capSizeY=ScreenY;
                image=Screen('GetImage', onScreen, [cx-capSizeX/2 cy-capSizeY/2 cx+capSizeX/2 cy+capSizeY/2]);
                imgname=strcat('/Users/hascherj/Dropbox/Mac/Documents/Steph Projects/HiddenZero/ExpPics/binary_choice_ex_cond_', num2str(whichCond), '.png');
                imwrite(image, imgname, 'png');
            end
            %Collect response
            RT = 0; %default
            while KbCheck %make them lift their finger from last trial
            end
            FlushEvents('keyDown');
            pastROI = 0;
            Choose1 = 0;
            Choose2 = 0;
            numLeft = 0;
            numRight = 0;
            while Choose1 == 0
                if doEye
                    % Check recording status, stop display if error
                    err = Eyelink('CheckRecording');

                    if(err~=0)
                        error('checkrecording problem, status: %d',err)
                    end

                    % check for presence of a new sample update
                    status = Eyelink('NewFloatSampleAvailable');
                    % satus = -1 (none or error) ; 0 (old) ; 1 (new)

                    if status ~= 1
                        fprintf('no sample available, status: %d\n',status)
                    end
                    % Track their eyes!
                    if Eyelink( 'NewFloatSampleAvailable') > 0 % get the sample in the form of an event structure
                        evt = Eyelink( 'NewestFloatSample');
                        if eye_used ~= -1 % do we know which eye to use yet? % if so, get current gaze position from sample
                            curx = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                            cury = evt.gy(eye_used+1); % do we have valid data and is the pupil visible?
                            if curx~=el.MISSING_DATA && cury~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                                %Insert ROI's here
                                ROI = 0;
                                for k = 1:24
                                    thisBox = Box(k,:);
                                    if curx>=thisBox(1) && curx<=thisBox(3) && cury>=thisBox(2) && cury<=thisBox(4)
                                        ROI = k;
                                    end
                                end
                                if ROI == pastROI
                                    pastROI = ROI;
                                elseif ROI ~= pastROI
                                    if ROI ~= 0
                                        fprintf(fix2File, '%s\t%s\t%s\t%s\t%s\n', num2str(i), num2str(ROI), num2str(GetSecs-choiceOnset), '0',num2str(subjectNumber));
                                    else
                                        fprintf(fix2File, '%s\t%s\t%s\t%s\t%s\n', num2str(i), num2str(ROI), '0', num2str(GetSecs-choiceOnset),num2str(subjectNumber));
                                    end % if ROI != 0
                                    pastROI = ROI;
                                else
                                    %counter = counter + 1;
                                end % if curx
                            else % if we don't, first find eye that's being tracked
                                eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
                                if eye_used == el.BINOCULAR % if both eyes are tracked
                                    eye_used = el.LEFT_EYE; % use left eye
                                end % if eye_used
                            end % if curx
                        end % if eye_used
                    end % if new eye sample
                end %if doEye
                %while Choose1 == 0
                % Get keyboard response
                [keyIsDown, secs, keyCode] = KbCheck(-1);
                if keyIsDown && (keyCode(escKey) || keyCode(Lkey) || keyCode(Rkey))
                    if doEye
                        Eyelink('Message', 'SYNCTIME_2');
                        WaitSecs(0.001);
                        Eyelink('Message', 'Part 2 Choice Made Trial %d', j);
                    end
                    if keyCode(escKey)
                        if doEye
                            Eyelink('StopRecording');
                            Eyelink('CloseFile');
                            Eyelink('ReceiveFile',edfFile);
                            Eyelink('ShutDown');
                        end
                        ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
                    elseif keyCode(Lkey)
                        time1 = GetSecs;
                        RT1 = time1 - choiceOnset;
                        Choices2(i,1) = i;
                        Chose1Left = 1;
                        choiceBox = leftAltBox;
                        if SS_Right
                            chose1SS = 0;
                            Choices2(i,2) = LL;
                            Choices2(i,3) = DD;
                        else
                            chose1SS = 1;
                            Choices2(i,2) = SS;
                            Choices2(i,3) = 0;
                        end

                    elseif keyCode(Rkey)
                        time1 = GetSecs;
                        RT1 = time1 - choiceOnset;
                        Choices2(i,1) = i;
                        Chose1Left = 0;
                        choiceBox = rightAltBox;
                        if SS_Right
                            chose1SS = 1;
                            Choices2(i,2) = SS;
                            Choices2(i,3) = 0;
                        else
                            chose1SS = 0;
                            Choices2(i,2) = LL;
                            Choices2(i,3) = DD;
                        end
                    end
                    Choose1 = 1;
                    wait = 1;
                end % if key is down
            end % while Choose1
            %Get Confirmation
            RTmat2 = -ones(nTrials,8);
            while ~Choose2
                Screen('DrawTexture',onScreen,trialChoice);
                Screen('FrameRect', onScreen, redcol, choiceBox, 5);
                Screen('FillRect',onScreen,0,[cx-(cx/5) ScreenY*.85 cx + (cx/5) ScreenY*.95])
                DrawFormattedText(onScreen,'CONFIRM CHOICE','center',(.9*ScreenY),whitecol);
                Screen('Flip',onScreen);
                %Take Screenshot
                if screenCap && i == 1
                    capSizeX=ScreenX; capSizeY=ScreenY;
                    image=Screen('GetImage', onScreen, [cx-capSizeX/2 cy-capSizeY/2 cx+capSizeX/2 cy+capSizeY/2]);
                    imgname=strcat('/Users/hascherj/Dropbox/Mac/Documents/Steph Projects/HiddenZero/ExpPics/confirmEx.png');
                    imwrite(image, imgname, 'png');
                end
                [keyIsDown, secs, keyCode] = KbCheck(-1);
                if wait
                    while keyIsDown
                        [keyIsDown, secs, keyCode] = KbCheck(-1);
                    end
                    wait = 0;
                end
                if doEye
                    % Check recording status, stop display if error
                    err = Eyelink('CheckRecording');

                    if(err~=0)
                        error('checkrecording problem, status: %d',err)
                    end

                    % check for presence of a new sample update
                    status = Eyelink('NewFloatSampleAvailable');
                    % satus = -1 (none or error) ; 0 (old) ; 1 (new)

                    if status ~= 1
                        fprintf('no sample available, status: %d\n',status)
                    end
                    % Track their eyes!
                    if Eyelink( 'NewFloatSampleAvailable') > 0 % get the sample in the form of an event structure
                        evt = Eyelink( 'NewestFloatSample');
                        if eye_used ~= -1 % do we know which eye to use yet? % if so, get current gaze position from sample
                            curx = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                            cury = evt.gy(eye_used+1); % do we have valid data and is the pupil visible?
                            if curx~=el.MISSING_DATA && cury~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                                %Insert ROI's here
                                ROI = 0;
                                for k = 1:24
                                    thisBox = Box(k,:);
                                    if curx>thisBox(1) && curx<=thisBox(3) && cury>thisBox(2) && cury<=thisBox(4)
                                        ROI = k;
                                    end
                                end
                                if ROI == pastROI
                                    pastROI = ROI;
                                elseif ROI ~= pastROI
                                    if ROI ~= 0
                                        fprintf(fix2File, '%s\t%s\t%s\t%s\t%s\n', num2str(i), num2str(ROI), num2str(GetSecs-choiceOnset), '0',num2str(subjectNumber));
                                    else
                                        fprintf(fix2File, '%s\t%s\t%s\t%s\t%s\n', num2str(i), num2str(ROI), '0', num2str(GetSecs-choiceOnset),num2str(subjectNumber));
                                    end % if ROI != 0
                                    pastROI = ROI;
                                else
                                    %counter = counter + 1;
                                end % if curx
                            else % if we don't, first find eye that's being tracked
                                eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
                                if eye_used == el.BINOCULAR % if both eyes are tracked
                                    eye_used = el.LEFT_EYE; % use left eye
                                end % if eye_used
                            end % if curx
                        end % if eye_used
                    end % if new eye sample
                end %if doEye
                if keyIsDown && (keyCode(escKey) || keyCode(Lkey) || keyCode(Rkey))
                    if doEye
                        Eyelink('Message', 'SYNCTIME_3');
                        WaitSecs(0.001);
                        Eyelink('Message', 'Part 2 Choice2 Made Trial %d', j);
                    end
                    if keyCode(escKey)
                        if doEye
                            Eyelink('StopRecording');
                            Eyelink('CloseFile');
                            Eyelink('ReceiveFile',edfFile);
                            Eyelink('ShutDown');
                        end
                        ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
                    elseif keyCode(Lkey)
                        numLeft = numLeft + 1;
                        RT2 = GetSecs - time1;
                        RTmat2(i,2+numLeft) = RT2;
                        Chose2Left = 1;
                        if SS_Right
                            chose2SS = 0;
                            Choices2(i,4) = LL;
                            Choices2(i,5) = DD;
                        else
                            chose2SS = 1;
                            Choices2(i,4) = SS;
                            Choices2(i,5) = 0;
                        end
                    elseif keyCode(Rkey)
                        numRight = numRight + 1;
                        RT2 = GetSecs - time1;
                        RTmat2(i,5+numRight) = RT2;
                        Chose2Left = 0;
                        if SS_Right
                            chose2SS = 1;
                            Choices2(i,4) = SS;
                            Choices2(i,5) = 0;
                        else
                            chose2SS = 0;
                            Choices2(i,4) = LL;
                            Choices2(i,5) = DD;
                        end
                    end
                    if numLeft > 2 || numRight > 2
                        %'SN','Trial','LL','SS','DD','Condition','SS_Right','LL_Position','chose1SS','RT1','chose2SS','LeftRT1','LRT2','LRT3','RRT1','RRT2','RRT3','doEye'
                        fprintf(choiceDataFile,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n',num2str(subjectNumber),num2str(i),num2str(LL),num2str(SS),num2str(DD),num2str(whichCond),num2str(SS_Right),num2str(LL_Position),num2str(chose1SS),num2str(RT1),num2str(chose2SS),num2str(RTmat2(i,3)),num2str(RTmat2(i,4)),num2str(RTmat2(i,5)),num2str(RTmat2(i,6)),num2str(RTmat2(i,7)),num2str(RTmat2(i,8)),num2str(doEye));
                    Choose2 = 1;
                    end
                    Choose0 = 1;
                    while KbCheck
                    end
                end % if keyisDown
            end % while choose2
            % end %while Choose0
            if doEye
                Eyelink('StopRecording');
            end
        end %for i = 1:nTrials
    end %do task 2

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%             Elicit Attention              %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if doSliders

    ShowCursor;
    % Instruction screen
    line1 =  'You have completed all of the choices.\n Please feel free to move your chin from the chin rest.\n\n There are a few more questions for you to answer.\n';
    line2 = 'In each of the following questions, you will be asked about your behavior during the experiment.\n';
    line3 = 'You will be presented with a slider like the one below.\n Use your mouse to move the slider to your desired response.\n';
    line4 = 'Once the slider is where you want it to be, press the space bar.';
    line5 = '\n\n If you have any questions, please ask the experimenter at this time.';
    line6 = 'Otherwise, press the space bar to begin.';
    slider0 = [ScreenX*.25,5*ScreenY/6,ScreenX*0.75,5*ScreenY/6+10];
    slider(onScreen,slider0,cx,cy,20,whitecol,redcol,'Option 1','Option 2',-1,[line1 line2 line3 line4 line5 line6]);


    %Wait for button press
    while KbCheck
    end

    FlushEvents('keyDown');
    proceed = 0;
    sliderVal = -1;
    while proceed == 0
        [x,y,buttons] = GetMouse(onScreen);
        if any(buttons)
            sliderVal = slider(onScreen,slider0,x,y,20,whitecol,redcol,'Option 1','Option 2',sliderVal,[line1 line2 line3 line4 line5 line6]);
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
    Screen('Flip',onScreen);

    % Shapes
    slider1 = [ScreenX*.25,ScreenY/2,ScreenX*0.75,ScreenY/2+10];

    % Elicitation Screen 1
    line1 =  'On the LAST decision that you made, what percentage of the time did you\n';
    line2 = 'spend looking at each of the following aspects of the decision?\n';
    line3 = 'Please note: your answers must add up to 100.';
    slider(onScreen,slider1,cx,cy,20,whitecol,redcol,'Dollar Amounts','Timing \n(when you get the money)',-1,[line1 line2]);
    

    %Wait for button press
    while KbCheck
    end

    FlushEvents('keyDown');
    proceed = 0;
    sliderVal = -1;
    while proceed == 0
        [x,y,buttons] = GetMouse(onScreen);
        if any(buttons)
            sliderVal = slider(onScreen,slider1,x,y,20,whitecol,redcol,'Dollar Amounts','Timing \n(When you get the money)',sliderVal,[line1 line2 line3]);
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

    % Elicitation Screen 2
    line1 =  'On the LAST decision that you made, what percentage of the time did you\n';
    line2 = 'pay attention to each of the following aspects of the decision?\n';
    line3 = 'Please note: your answers must add up to 100.';
    slider(onScreen,slider1,cx,cy,20,whitecol,redcol,'Dollar Amounts\nOR Timing','Something Else',-1,[line1 line2]);
    

    %Wait for button press
    while KbCheck
    end

    FlushEvents('keyDown');
    proceed = 0;
    sliderVal = -1;
    while proceed == 0
        [x,y,buttons] = GetMouse(onScreen);
        if any(buttons)
            sliderVal = slider(onScreen,slider1,x,y,20,whitecol,redcol,'Dollar Amounts\nOR Timing','Something Else',sliderVal,[line1 line2 line3]);
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



    % Elicitation Screen 3
    line1 =  'On the LAST decision that you made, what percentage of the time did you\n';
    line2 = 'pay attention to each of the following aspects of the decision?\n';
    line3 = 'Please note: your answers must add up to 100.';
    slider(onScreen,slider1,cx,cy,20,whitecol,redcol,'Chosen Option','Non-chosen Option',-1,[line1 line2]);
    

    %Wait for button press
    while KbCheck
    end

    FlushEvents('keyDown');
    proceed = 0;
    sliderVal = -1;
    while proceed == 0
        [x,y,buttons] = GetMouse(onScreen);
        if any(buttons)
            sliderVal = slider(onScreen,slider1,x,y,20,whitecol,redcol,'Chosen Option','Non-chosen Option',sliderVal,[line1 line2 line3]);
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


    % Elicitation Screen 4
    line1 =  'Across ALL the decisions that you made, what percentage of the time did you\n';
    line2 = 'pay attention to each of the following aspects of the decision?\n';
    line3 = 'Please note: your answers must add up to 100.';
    slider(onScreen,slider1,cx,cy,20,whitecol,redcol,'Dollar Amounts','Timing',-1,[line1 line2]);
    

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


    % Elicitation Screen 5
    line1 =  'Across ALL the decisions that you made, what percentage of the time did you\n';
    line2 = 'pay attention to each of the following aspects of the decision?\n';
    line3 = 'Please note: your answers must add up to 100.';
    slider(onScreen,slider1,cx,cy,20,whitecol,redcol,'Dollar Amounts\nOR Timing','Something Else',-1,[line1 line2]);
    

    %Wait for button press
    while KbCheck
    end

    FlushEvents('keyDown');
    proceed = 0;
    sliderVal = -1;
    while proceed == 0
        [x,y,buttons] = GetMouse(onScreen);
        if any(buttons)
            sliderVal = slider(onScreen,slider1,x,y,20,whitecol,redcol,'Dollar Amounts\nOR Timing','Something Else',sliderVal,[line1 line2 line3]);
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


    % Elicitation Screen 6
    line1 =  'Across ALL the decisions that you made, what percentage of the time did you\n';
    line2 = 'pay attention to each of the following aspects of the decision?\n';
    line3 = 'Please note: your answers must add up to 100.';
    slider(onScreen,slider1,cx,cy,20,whitecol,redcol,'Chosen Option','Non-chosen Option',-1,[line1 line2]);
    

    %Wait for button press
    while KbCheck
    end

    FlushEvents('keyDown');
    proceed = 0;
    sliderVal = -1;
    while proceed == 0
        [x,y,buttons] = GetMouse(onScreen);
        if any(buttons)
            sliderVal = slider(onScreen,slider1,x,y,20,whitecol,redcol,'Chosen Option','Non-chosen Option',sliderVal,[line1 line2 line3]);
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


    % Elicitation Screen 7
    line1 =  'Across ALL the decisions that you made, how much weight did you\n';
    line2 = 'put on each of the following aspects of the decision?\n';
    line3 = 'Please note: your answers must add up to 100.';
    slider(onScreen,slider1,cx,cy,20,whitecol,redcol,'Dollar Amounts','Timing',-1,[line1 line2]);
    

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

    end %if doSliders

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%                  Done                     %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Conclusion Screen
    line1 = 'You have now completed all of the choices. Thank you so much for\n';
    line2 = 'participating. Please let the experimenter know that you are finished.';
    DrawFormattedText(onScreen, [line1 line2], 'center', 'center', whitecol, [], [], [], 2, [], []);
    Screen('Flip',onScreen);
    %Wait for button press
    while KbCheck
    end

    FlushEvents('keyDown');
    proceed = 0;
    while proceed == 0
        [keyIsDown, secs, keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(escKey)
                ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
            elseif keyCode(RAkey)
                proceed = 1;
            end
        end
    end %while proceed

    % random draw from 1-100
    paymentnum = Sample(1:100);
    % PAYMENT
    line1 = 'The computer has randomly selected a number between 1 and 100. \nThat number is: ';
    if paymentnum < 11
        line2 = '\n\n This means that one of your decisions will be randomly selected and you will receive the option that you chose.';
    else
        line2 = '\n\n This means that you were not randomly selected for a bonus.';
    end

    DrawFormattedText(onScreen, [line1 num2str(paymentnum) line2], 'center', 'center', whitecol, [], [], [], 2, [], []);
    Screen('Flip',onScreen);
    %Wait for button press
    while KbCheck
    end

    FlushEvents('keyDown');
    proceed = 0;
    while proceed == 0
        [keyIsDown, secs, keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(escKey)
                ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
            elseif keyCode(RAkey)
                proceed = 1;
            end
        end
    end %while proceed

    WaitSecs(0.5);
    %%
    %You've reached the end!
    filename = [subjectNumber expName '.mat'];
    save(filename)
    fclose('all');
    ShowCursor;
    Screen('CloseAll')
catch err  %quit out if the code encounters an error
    disp('There is an ERROR!');
    %matlabfile = ['matlab' num2str(subjectNumber) 'choice.mat'];
    %save(matlabfile);
    if doEye
        Eyelink('StopRecording');
        Eyelink('CloseFile');
        Eyelink('ReceiveFile',edfFile);
        Eyelink('ShutDown');
    end
    if IsOSX
        ListenChar(0); %restore normal keyboard use
    end %if ismac
    filename = [subjectNumber expName '.mat'];
    save(filename)
    sca
    fclose('all');
    ShowCursor;
    Screen('CloseAll')
    rethrow(err);
end