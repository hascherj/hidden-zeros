function [] = askMe(window,keys,textcol,screenCap)
[ScreenX, ScreenY] = WindowSize(window);
cx = ScreenX/2;
cy = ScreenY/2;
%Text
    line1 = 'That is incorrect. Please ask the experimenter for help.';
    DrawFormattedText(window, line1, 'center', 'center', textcol, [], [], [], 2, [], []);
%Show on screen
    Screen('Flip',window);
%Take a picture
                if screenCap
                        capSizeX=ScreenX; capSizeY=ScreenY;
                        image=Screen('GetImage', window, [cx-capSizeX/2 cy-capSizeY/2 cx+capSizeX/2 cy+capSizeY/2]);
                        imgname=strcat('/Users/hascherj/Dropbox/Mac/Documents/Steph Projects/HiddenZero/ExpPics/askMe.png');
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
            elseif keyCode(keys(5))
                proceed = 1;
            end
        end
    end %while proceed
    WaitSecs(0.5);
end