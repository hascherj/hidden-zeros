function [correct, times] = CompQ(window,yText,texture,keys,textcol,ntimes,startCorrect,screenCap)
[ScreenX, ScreenY] = WindowSize(window);
cx = ScreenX/2;
cy = ScreenY/2;
%Did they just answer incorrectly
    if ~startCorrect
        line1 = 'That is incorrect. Press the spacebar to try again.';
        DrawFormattedText(window, line1, 'center', 'center', textcol, [], [], [], 2, [], []);
        Screen('Flip',window);
        %Take a picture
                if screenCap && ntimes
                        capSizeX=ScreenX; capSizeY=ScreenY;
                        image=Screen('GetImage', window, [cx-capSizeX/2 cy-capSizeY/2 cx+capSizeX/2 cy+capSizeY/2]);
                        imgname=strcat('C:/Users/bbaird/Documents/HiddenZero/AdminFiles/Screenshots/incorrect.png');
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
                    if keyCode(keys(6))
                        ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
                    elseif keyCode(keys(7))
                        proceed = 1;
                    end
                end
            end %while proceed
            WaitSecs(0.5);
    end
%Paste Texture
    Screen('DrawTexture',window,texture);
    Screen('TextSize', window, 23)
%Text
    line1 = 'Consider the following example. Which of the following is TRUE?';
    line2 = '\nPress the corresponding key to choose an option.';
    line3 = '\nA: If I choose this option, I will get $10 every day this week.';
    line4 = '\nB: If I choose this option, I will get $10 today.';
    line5 = '\nC: If I choose this option, I will get $10 tomorrow.';
    line6 = '\nD: If I choose this option, I will get $10 next week.';
    DrawFormattedText(window, [line1 line2], 'center', yText, textcol, [], [], [], 2, [], []);
    DrawFormattedText(window, [line3 line4 line5 line6], 3*ScreenX/8, 1.5*yText, textcol, [], [], [], 2, [], []);
    Screen('TextSize', window, 30)
%Show on screen
    Screen('Flip',window);
    %Take a picture
                if screenCap && ~ntimes
                        capSizeX=ScreenX; capSizeY=ScreenY;
                        image=Screen('GetImage', window, [cx-capSizeX/2 cy-capSizeY/2 cx+capSizeX/2 cy+capSizeY/2]);
                        imgname=strcat('C:/Users/bbaird/Documents/HiddenZero/AdminFiles/Screenshots/compQ.png');
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
            if keyCode(keys(6))
                ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
            elseif keyCode(keys(2))
                proceed = 1;
                correct = 1;
                times = ntimes + 1;
            elseif keyCode(keys(1)) || keyCode(keys(3)) || keyCode(keys(4))
                proceed = 1;
                correct = 0;
                times = ntimes + 1;
            end
        end
    end %while proceed
    WaitSecs(0.5);
end