try
    rng(sum(100*clock)); %change the seed for each participant
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%          Experiment Parameters            %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        % 4 Conditions - no zero (1), future zero (2), current zero (3), all zero (4)
        % Task 2 is coded as condition 0 (task equal to cond 1)
            
        %Set condition (can set manually for testing)
            %whichCond = floor(4*rand())+1;
            whichCond = 4;
    
        %Number of trials (max nTrial = 24 currently)
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
    
        %%% File Set-Up %%%
            rootDir = cd;
            expName='hiddenZero';
            baseName=[subjectNumber expName];

            fileName = [baseName '_choiceData' '.csv']; %Basic rating data
            choiceDataFile = fopen(fileName, 'a'); %'a' allows data to be added to file
            
            fprintf(choiceDataFile, '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n' , 'SN','Trial','LL','SS','DD','Condition','Chose1SS','RT1','Chose2SS','RT2');
    
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
            corssSize = 50; %size of fixation cross
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
                LL_L = BoxL4;
                LL_R = BoxR4;
            
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
        
        %Load in trials
        %SS = Shorter Sooner, LL = Larger Later, DD = Days Delay
        %Trials - predetermined by Steph et al. - (SS,LL,DD)
            allTrials = csvread('HZtrials.csv', 1, 1); %may want to include the matrix explicitly before real experiment
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

        %Screen 5
            Screen('DrawTexture',onScreen,blank1Choice);
            DrawFormattedText(onScreen, [lineDay '21'], 'center', 'center', whitecol, [], [], [], 2, [], DD1_1);
            DrawFormattedText(onScreen, [lineDay '22'], 'center', 'center', whitecol, [], [], [], 2, [], DD2_1);
            DrawFormattedText(onScreen, [lineDay '23'], 'center', 'center', whitecol, [], [], [], 2, [], DD3_1);
            UpArrow(arrow4(1),arrow4(2),arrow4(3),arrow4(4),onScreen,bluecol);
            Screen('FrameOval',onScreen,bluecol,oval1,7);
            Screen('FrameOval',onScreen,bluecol,LL_1,7);
            Screen('TextStyle', onScreen, 1);
            DrawFormattedText(onScreen, '$Y', 'center', 'center', whitecol, [], [], [], 2, [], LL_1);
            Screen('TextStyle', onScreen, 0);
            blankScreen5 = Screen('GetImage', onScreen, [], 'backBuffer');
            blankScreen5 = Screen('MakeTexture', onScreen, blankScreen5);
            Screen('FillRect', onScreen, 0);
            Screen('DrawTexture',onScreen,blankScreen5,[],[fifthX (3/10)*ScreenY 4*fifthX (9/10)*ScreenY]);

            line1 = 'In this example, you would get $Y on Day 21:';
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

        %Screen 7
            line1 = 'Now you are ready to begin! You will be making decisions between two options, one on\n';
            line2 = 'each side of the screen. For each decision, choose the option you prefer: to choose the\n';
            line3 = 'option on the left, press the "F" key. To choose the option on the right, press the "J" key.\n';
            line4 = 'Although these choices are hypothetical, please answer as if they are real.';
            line5 = '\n\nPress the spacebar to begin.';

            DrawFormattedText(onScreen, [line1 line2 line3 line4 line5], 'center', 'center', whitecol, [], [], [], 2, [], []);

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
    %%%           Comprehension Check             %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if doCompQ
        Screen('DrawTexture',onScreen,blank1Choice);
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
                line1 = 'That is correct. [Insert B text here].';
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
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%            EyeTracking Setup              %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if doEye
        EyeTrackerSetUp
    end
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
                %Pull trial values
                    SS = trialMat1(i,1);
                    LL = trialMat1(i,2);
                    DD = trialMat1(i,3);
                %Need day before and after
                    DD_F1 = DD + 1;
                    DD_F2 = DD + 2;
                %Make text versions
                    SS_t = num2str(SS);
                    LL_t = num2str(LL);
                    DD1 = num2str(DD);
                    DD2 = num2str(DD_F1);
                    DD3 = num2str(DD_F2);
                %Draw base texture
                    Screen('DrawTexture',onScreen,blankChoice);
                %Randomize which side is SS/LL
                    SS_Side = floor(2*rand()); %0 = SS on left
                %Add in trial values
                    %SS and LL
                        if SS_Side
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
                    if SS_Side
                        if whichCond == 2 || whichCond == 4
                            DrawFormattedText(onScreen,'$0','center', 'center', whitecol, [], [], [], 2, [], LL_R);
                        end
                        if whichCond == 3 || whichCond == 4
                            DrawFormattedText(onScreen,'$0','center', 'center', whitecol, [], [], [], 2, [], SS_L);
                        end
                    else
                        if whichCond == 2 || whichCond == 4
                            DrawFormattedText(onScreen,'$0','center', 'center', whitecol, [], [], [], 2, [], LL_L);
                        end
                        if whichCond == 3 || whichCond == 4
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
                    while KbCheck
                    end
                    FlushEvents('keyDown');
                    Choose1 = 0;
                    while Choose1 == 0
                        [keyIsDown, secs, keyCode] = KbCheck(-1);
                            if keyIsDown && (keyCode(escKey) || keyCode(Lkey) || keyCode(Rkey))
                                if keyCode(escKey)
                                    ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
                                elseif keyCode(Lkey)
                                    RT1 = GetSecs - choiceOnset;
                                    Choices1(i,1) = i;
                                    Chose1Left = 1;
                                    choiceBox = leftAltBox;
                                    if SS_Side
                                        chose1SS = 0;
                                        Choices1(i,2) = LL;
                                        Choices1(i,3) = DD;
                                    else
                                        chose1SS = 1;
                                        Choices1(i,2) = SS;
                                        Choices1(i,3) = 0;
                                    end
                                    
                                elseif keyCode(Rkey)
                                    RT1 = GetSecs - choiceOnset;
                                    Choices1(i,1) = i;
                                    Chose1Left = 0;
                                    choiceBox = rightAltBox;
                                    if SS_Side
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
                                Choose2 = 0;
                                wait = 1;
                            %Get Confirmation
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
                                    if keyIsDown && (keyCode(escKey) || keyCode(Lkey) || keyCode(Rkey))
                                        if keyCode(escKey)
                                            ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
                                        elseif keyCode(Lkey)
                                            RT2 = GetSecs - RT1;
                                            Chose2Left = 1;
                                            if SS_Side
                                                chose2SS = 0;
                                                Choices1(i,4) = LL;
                                                Choices1(i,5) = DD;
                                            else
                                                chose2SS = 1;
                                                Choices1(i,4) = SS;
                                                Choices1(i,5) = 0;
                                            end
                                        elseif keyCode(Rkey)
                                            RT2 = GetSecs - RT1;
                                            Chose2Left = 0;
                                            if SS_Side
                                                chose2SS = 1;
                                                Choices1(i,4) = SS;
                                                Choices1(i,5) = 0;
                                            else
                                                chose2SS = 0;
                                                Choices1(i,4) = LL;
                                                Choices1(i,5) = DD;
                                            end
                                        end
                                        %'SN','Trial','LL','SS','DD','Condition','chose1SS','RT1','chose2SS','RT2'
                                        fprintf(choiceDataFile,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,\n',num2str(subjectNumber),num2str(i),num2str(LL),num2str(SS),num2str(DD),num2str(whichCond),num2str(chose1SS),num2str(RT1),num2str(chose2SS),num2str(RT2));
                                        Choose2 = 1;
                                        WaitSecs(.5);
                                    end
                                end
                            end
                    end %while choosing
            end %for i = 1:nTrials
    end %do Task1

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%                 Task 2                    %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if doTask2
        %Transition screen
            if doTask1
                line1 = 'You have completed half of the choices. Feel free to take a short break. Before you\n';
                line2 = 'begin the second half, we will recalibrate the eye tracker. Once you are ready to move\n';
                line3 = 'on, let the experimenter know.';
            DrawFormattedText(onScreen, [line1 line2 line3], 'center', 'center', whitecol, [], [], [], 2, [], []);
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
            % ^^ This will need to be recoded to include ET recalibration
            end %Trans screen
        %Now everyone does no-zeroes condition
        %Task 2 trials (this only matters when nTrials < length(allTrials))
            trialMat2 = allTrials(randperm(size(allTrials,1)),:); %shuffle rows
            trialMat2 = trialMat2(1:nTrials,:); %only include nTrials
        
        %Do Task 2
            for j = 1:nTrials
                %Pull trial values
                    SS = trialMat2(j,1);
                    LL = trialMat2(j,2);
                    DD = trialMat2(j,3);
                %Need day before and after
                    DD_F1 = DD + 1;
                    DD_F2 = DD + 2;
                %Make text versions
                    SS_t = num2str(SS);
                    LL_t = num2str(LL);
                    DD1 = num2str(DD);
                    DD2 = num2str(DD_F1);
                    DD3 = num2str(DD_F2);
                %Draw base texture
                    Screen('DrawTexture',onScreen,blankChoice);
                %Randomize which side is SS/LL
                    SS_Side = floor(2*rand()); %0 = SS on left
                %Add in trial values
                    %SS and LL
                        if SS_Side
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
                %Capture Textures
                    trialChoice = Screen('GetImage', onScreen, [], 'backBuffer');
                    trialChoice = Screen('MakeTexture', onScreen, trialChoice); % Make this a texture, it's easier to draw
                %Display on screen
                    [vbl, choiceOnset, FlipTimestamp, Missed, Beampos] = Screen('Flip', onScreen, 0, 1);
                %Collect response
                    RT = 0; %default
                    while KbCheck
                    end
                    FlushEvents('keyDown');
                    Choose1 = 0;
                    while Choose1 == 0
                        [keyIsDown, secs, keyCode] = KbCheck(-1);
                            if keyIsDown && (keyCode(escKey) || keyCode(Lkey) || keyCode(Rkey))
                                if keyCode(escKey)
                                    ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
                                elseif keyCode(Lkey)
                                    RT1 = GetSecs - choiceOnset;
                                    Choices2(i,1) = i;
                                    Chose1Left = 1;
                                    choiceBox = leftAltBox;
                                    if SS_Side
                                        chose1SS = 0;
                                        Choices2(i,2) = LL;
                                        Choices2(i,3) = DD;
                                    else
                                        chose1SS = 1;
                                        Choices2(i,2) = SS;
                                        Choices2(i,3) = 0;
                                    end
                                    
                                elseif keyCode(Rkey)
                                    RT1 = GetSecs - choiceOnset;
                                    Choices2(i,1) = i;
                                    Chose1Left = 0;
                                    choiceBox = rightAltBox;
                                    if SS_Side
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
                                Choose2 = 0;
                                wait = 1;
                            %Get Confirmation
                                while ~Choose2
                                    Screen('DrawTexture',onScreen,trialChoice);
                                    Screen('FrameRect', onScreen, redcol, choiceBox, 3);
                                    Screen('FillRect',onScreen,0,[cx-(cx/5) ScreenY*.85 cx + (cx/5) ScreenY*.95])
                                    DrawFormattedText(onScreen,'CONFIRM CHOICE','center',(.9*ScreenY),whitecol);
                                    Screen('Flip',onScreen);
                                    [keyIsDown, secs, keyCode] = KbCheck(-1);
                                    if wait
                                    while keyIsDown
                                        [keyIsDown, secs, keyCode] = KbCheck(-1);
                                    end
                                    wait = 0;
                                    end
                                    if keyIsDown && (keyCode(escKey) || keyCode(Lkey) || keyCode(Rkey))
                                        if keyCode(escKey)
                                            ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
                                        elseif keyCode(Lkey)
                                            RT2 = GetSecs - RT1;
                                            Chose2Left = 1;
                                            if SS_Side
                                                chose2SS = 0;
                                                Choices2(i,4) = LL;
                                                Choices2(i,5) = DD;
                                            else
                                                chose2SS = 1;
                                                Choices2(i,4) = SS;
                                                Choices2(i,5) = 0;
                                            end
                                        elseif keyCode(Rkey)
                                            RT2 = GetSecs - RT1;
                                            Chose2Left = 0;
                                            if SS_Side
                                                chose2SS = 1;
                                                Choices2(i,4) = SS;
                                                Choices2(i,5) = 0;
                                            else
                                                chose2SS = 0;
                                                Choices2(i,4) = LL;
                                                Choices2(i,5) = DD;
                                            end
                                        end
                                        %'SN','Trial','LL','SS','DD','Condition','chose1SS','RT1','chose2SS','RT2'
                                        fprintf(choiceDataFile,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,\n',num2str(subjectNumber),num2str(i),num2str(LL),num2str(SS),num2str(DD),'0',num2str(chose1SS),num2str(RT1),num2str(chose2SS),num2str(RT2));
                                        Choose2 = 1;
                                        WaitSecs(0.5);
                                    end
                                end
                            end
                    end %while choosing
            end %for i = 1:nTrials
    end %do task 2
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%                  Done                     %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Could put in reward here if we decide to incentivize in the future
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