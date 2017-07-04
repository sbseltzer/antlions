
if !SERVER then return end

/*------------------------------------
	CreateGameTimer
	ID - Unique Identifier.
	fLength - Time limit to count up or down to.
	funcTranslate - Function that takes the current time as an argument and outputs a string.
	funcOnStart - Called on start.
	funcOnEnd - Called on end.
	funcCheck - Called every second.
	bUp - Cound up rather than down.
	bSync - Automatically synchronize with client.
	
	CreateGameTimer( 1, 30, string.ToMinutesSeconds, function(timer) print("start!") end, function(timer) print("end!") end, function(timer) print("check!") end, false, true )
------------------------------------*/
local GAME_TIMERS = {}
function CreateGameTimer( ID, fLength, funcTranslate, funcOnStart, funcOnEnd, funcCheck, bUp, bSync )
	
	local t = {}
	t.ID = ID
	t.fLength = fLength
	t.funcTranslate = funcTranslate
	t.funcOnStart = funcOnStart
	t.funcOnEnd = funcOnEnd
	t.funcCheck = funcCheck
	t.bUp = bUp
	t.bSync = bSync
	if bUp then
		t.CurrentTime = 0
	else
		t.CurrentTime = fLength
	end
	
	t.Check = function( self )
		if self.bUp == true then
			if self.fLength != 0 and self.CurrentTime == self.fLength then
				self:funcOnEnd()
				return
			end
			self.CurrentTime = self.CurrentTime + 1
		elseif !self.bUp then
			if self.CurrentTime == 0 then
				self:funcOnEnd()
				return
			end
			self.CurrentTime = self.CurrentTime - 1
		end
		self:funcCheck()
		if !self.bSync then return end
		umsg.Start( "SendGameTimerInfo" )
			umsg.String( self.ID )
			umsg.String( self.funcTranslate( self.CurrentTime ) )
		umsg.End()
	end
	
	timer.Create( "GAMETIMERS_"..t.ID, 1, fLength, t.Check, t)
	timer.Stop( "GAMETIMERS_"..t.ID )
	
	local bFirst = true
	
	t.Start = function( self )
		if bFirst then
			self:funcOnStart()
			bFirst = false
		end
		timer.Start( "GAMETIMERS_"..self.ID )
	end
	
	t.Stop = function( self )
		timer.Stop( "GAMETIMERS_"..self.ID )
		if t.bUp then
			t.CurrentTime = 0
		else
			t.CurrentTime = fLength
		end
	end
	
	t.Pause = function( self )
		timer.Pause( "GAMETIMERS_"..self.ID )
	end
	
	t.UnPause = function( self )
		timer.UnPause( "GAMETIMERS_"..self.ID )
	end
	
	GAME_TIMERS[ID] = t
	
	return GAME_TIMERS[ID]
	
end
function CheckTimers()
	
	
	
end