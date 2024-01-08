function [] = UpArrow(sx,sy,fx,fy,window,col)
Screen('DrawLine',window,col,sx,sy,fx,fy+15,8);
Screen('FillPoly',window,col,[fx fy;fx-15 fy+15; fx+15 fy+15]);
end