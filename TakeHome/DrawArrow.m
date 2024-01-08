function [] = UpArrow(sx,sy,fx,fy)
Screen('DrawLine',onScreen,bluecol,sx,sy,fx-10,fy-10);
Screen('FillPoly',onScreen,bluecol,[fx fy;])