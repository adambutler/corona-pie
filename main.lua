display.setStatusBar( display.HiddenStatusBar )

local barRadius = 150
local barWidth  = 5
local barRotation = 90;
local bars = {}
local timerSegment = 360;

local time = {};

for i=1,360 do
	bars[i] = display.newLine(display.contentWidth/2, display.contentHeight/2, 
		(display.contentWidth/2)-barRadius,display.contentHeight/2 )
	bars[i]:setColor(0, 255, 0)
	bars[i].width = barWidth
	bars[i].rotation = barRotation;
	barRotation = barRotation + 1
end

local myTimer;

function setTime(ms,callback, onTick)

	local timerx = {};
	timerx.count = ms;
	timerx.pausedDuration = 0;
	timerx.running = false;
	timerx.paused = false;
	timerx.callback = callback;

	if(onTick)then
		timerx.onTick = onTick;
	end

	timerx.complete = function()
		timerx.stop();
		timerx.callback();
	end

	timerx.stop = function()
		timerx.running = false;
		Runtime:removeEventListener( "enterFrame", timerx.tick );
	end
	
	timerx.pause = function()
		timerx.paused = true;
		timerx.stoppedTime = system.getTimer();
		Runtime:removeEventListener( "enterFrame", timerx.tick );
	end

	timerx.resume = function()
		timerx.paused = false;
		timerx.pausedDuration = timerx.pausedDuration + (system.getTimer() - timerx.stoppedTime);
		Runtime:addEventListener( "enterFrame", timerx.tick );
	end
	
	timerx.tick = function ()
		if((system.getTimer() - timerx.start) >= timerx.count + timerx.pausedDuration) then
			timerx.complete();
			Runtime:removeEventListener( "enterFrame", timerx.tick );
		elseif(timerx.onTick)then
			timerx.onTick(timerx);
		end
	end
	
	timerx.start = function ()
		timerx.running = true;
		timerx.paused = false;
		timerx.start = system.getTimer();
		Runtime:addEventListener( "enterFrame", timerx.tick );
	end
	
	timerx.getTime = function()
		if(timerx.paused)then
			return system.getTimer() - timerx.start - (system.getTimer()- timerx.stoppedTime);
		elseif(timerx.running == false)then
			return "Error: Cant request time when timer is not running / stopped"
		else
			return system.getTimer() - timerx.start - timerx.pausedDuration;
		end
	end

	return(timerx);     
end

function getRed(deg)
    if(deg>=180)then
        return 255;
    else
        return (deg/180)*200
    end
end

function getGreen(deg)
    return ((-deg+360)/360)*200
end

function onComplete(event)
	print('finished')
end

function onTick(event)
	local a = (((event.getTime() / event.count))*360);
	local g = getGreen(a);
	local r = getRed(a);

	for i=1, 360 do
		bars[i].isVisible = true;
		bars[i]:setColor(r, g, 30);
	end
	for i=1, a do
		bars[i].isVisible = false;
	end
end

myTimer = setTime(10000, onComplete, onTick);

function pause(event)
	myTimer.pause();
	print('paused at '..myTimer.getTime())
end

function resume(event)
	myTimer.resume();
	print('resumed at '..myTimer.getTime())
end

function getTime(event)
	print(myTimer.getTime());
end

myTimer.start();



local a = display.newRect(0,0,200,200);
a:setFillColor(255,0,0);
a:addEventListener("tap", pause);


local b = display.newRect(200,0,200,200);
b:setFillColor(0,255,0);
b:addEventListener("tap", resume);

local c = display.newRect(400,0,200,200);
c:setFillColor(0,0,255);
c:addEventListener("tap", getTime);