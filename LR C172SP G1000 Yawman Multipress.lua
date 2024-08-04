--[[
 LR C172 mapping for the Yawman Arrow By Ryan Mikulovsky, CC0 1.0.
 
 Inspired by Yawman's mapping for the MSFS PMDG 777.
 Thanks for Thomas Nield for suggesting looking into Lua for better controller support in XP12. Button numbers and variable names came from Thomas.
 
 See Thomas' video and access example Lua scripts at https://www.youtube.com/watch?v=x8SMg33RRQ4
 
 Repository at https://github.com/rpmik/Lua-Yawman-Control-LR-C172
]]
-- use local to prevent other unknown Lua scripts from overwriting variables (or vice versa)
local STICK_X = 0 
local STICK_Y = 1
local POLE_RIGHT = 2 
local POLE_LEFT = 3
local RUDDER = 4
local SLIDER_LEFT = 5
local SLIDER_RIGHT = 6 
local POV_UP = 0
local POV_RIGHT = 2
local POV_DOWN = 4
local POV_LEFT = 6
local THUMBSTICK_CLK = 8
local SIXPACK_1 = 9
local SIXPACK_2 = 10
local SIXPACK_3 = 11
local SIXPACK_4 = 12
local SIXPACK_5 = 13
local SIXPACK_6 = 14
local POV_CENTER = 15
local RIGHT_BUMPER = 16
local DPAD_CENTER = 17
local LEFT_BUMPER = 18
local WHEEL_DOWN = 19
local WHEEL_UP = 20
local DPAD_UP = 21
local DPAD_LEFT = 22
local DPAD_DOWN = 23
local DPAD_RIGHT = 24

-- Logic states to keep button assignments sane
local STILL_PRESSED = false -- track presses for everything
local MULTI_SIXPACK_PRESSED = false -- track presses for only the six pack where there's multiple six pack buttons involved
local DPAD_PRESSED = false
local BUMPERS_PRESSED = false

local CHASE_VIEW = false

local FRAME_COUNT = 0.0
local GoFasterFrameRate = 0.0
local PauseIncrementFrameCount = 0.0
local FrameRate = 0.0
local CurFrame = 0.0

-- Clean up the code with this
local NoCommand = "sim/none/none"

function multipressLRC172SP_buttons() 
    -- if aircraft is an Embraer E-175 then procede
    if PLANE_ICAO == "C172" then 
        FRAME_COUNT = FRAME_COUNT + 1.0  
		-- Base Config buttons that should almost always get reassigned except during a press
        if not STILL_PRESSED and not DPAD_PRESSED then -- avoid overwriting assignments during other activity
			set_button_assignment(DPAD_UP,NoCommand)
			set_button_assignment(DPAD_DOWN,NoCommand)
			set_button_assignment(DPAD_LEFT,"sim/general/zoom_out_fast")
			set_button_assignment(DPAD_RIGHT,"sim/general/zoom_in_fast")
			set_button_assignment(DPAD_CENTER,NoCommand)
			set_button_assignment(WHEEL_UP, NoCommand)
			set_button_assignment(WHEEL_DOWN, NoCommand)
			set_button_assignment(LEFT_BUMPER, NoCommand) -- multifunction
			set_button_assignment(RIGHT_BUMPER, NoCommand) -- multifunction
			set_button_assignment(SIXPACK_1,NoCommand)
			set_button_assignment(SIXPACK_2,"sim/flight_controls/brakes_regular")
			set_button_assignment(SIXPACK_3,NoCommand)		
			set_button_assignment(SIXPACK_4,NoCommand)
			set_button_assignment(SIXPACK_5,NoCommand)
			set_button_assignment(SIXPACK_6,NoCommand)			
			set_button_assignment(POV_UP,"sim/flight_controls/pitch_trim_up")
			set_button_assignment(POV_DOWN,"sim/flight_controls/pitch_trim_down")
			set_button_assignment(POV_LEFT,"sim/view/glance_left")
			set_button_assignment(POV_RIGHT,"sim/view/glance_right")
			set_button_assignment(POV_CENTER,"sim/view/default_view")
			--set_button_assignment(THUMBSTICK_CLK,"sim/flight_controls/brakes_toggle_regular")

        end 
        
        -- Get button status
    
        right_bumper_pressed = button(RIGHT_BUMPER)
        left_bumper_pressed = button(LEFT_BUMPER)
        
        sp1_pressed = button(SIXPACK_1)
        sp2_pressed = button(SIXPACK_2)
        sp3_pressed = button(SIXPACK_3)
		sp4_pressed = button(SIXPACK_4)
		sp5_pressed = button(SIXPACK_5)
		sp6_pressed = button(SIXPACK_6)
		
		pov_up_pressed = button(POV_UP)
		pov_down_pressed = button(POV_DOWN)
		
		dpad_up_pressed = button(DPAD_UP)
		dpad_center_pressed = button(DPAD_CENTER)
		dpad_down_pressed = button(DPAD_DOWN)
		dpad_left_pressed = button(DPAD_LEFT)
		dpad_right_pressed = button(DPAD_RIGHT)
		
		wheel_up_pressed = button(WHEEL_UP)
		wheel_down_pressed = button(WHEEL_DOWN)
		
-- Start expanded control logic

		if dpad_center_pressed and not CHASE_VIEW and not STILL_PRESSED then
			command_once("sim/view/chase")
			CHASE_VIEW = true
			STILL_PRESSED = true
		end
	
		if dpad_center_pressed and CHASE_VIEW and not STILL_PRESSED then
			command_once("sim/view/default_view")
			CHASE_VIEW = false
			STILL_PRESSED = true
		end

-- Auto pilot engage A 
		
		if right_bumper_pressed and not dpad_up_pressed and not STILL_PRESSED then
			command_once("sim/GPS/g1000n1_ap")
			STILL_PRESSED = true
		
		end
		
-- autopilot control
	
		if sp1_pressed then

				
			if not STILL_PRESSED then -- Do not constantly set the button assignment every frame
				--set_button_assignment(RIGHT_BUMPER,"sim/autopilot/autothrottle_n1epr_toggle")
				set_button_assignment(DPAD_RIGHT,NoCommand)
			end
			
			if dpad_up_pressed then
				meterC172SPInteraction(DPAD_PRESSED,"sim/autopilot/airspeed_up", "sim/autopilot/airspeed_up", 1.0, 2.0) -- at around two seconds, use larger increment
				DPAD_PRESSED = true
			elseif dpad_down_pressed then
				meterC172SPInteraction(DPAD_PRESSED,"sim/autopilot/airspeed_down", "sim/autopilot/airspeed_down",1.0,2.0)
				DPAD_PRESSED = true
			end
			

		-- Pause Simulation
			if sp2_pressed and sp3_pressed and not MULTI_SIXPACK_PRESSED then
				command_once("sim/operation/pause_toggle")
				MULTI_SIXPACK_PRESSED = true
			end
			
			STILL_PRESSED = true
		end
		
		if sp2_pressed then
			if not STILL_PRESSED then -- Do not constantly set the button assignment every frame
				set_button_assignment(RIGHT_BUMPER,"sim/GPS/g1000n1_fd")
				set_button_assignment(DPAD_RIGHT,"sim/GPS/g1000n1_nav")
				set_button_assignment(DPAD_LEFT,"sim/autopilot/NAV") -- built-in XP12 command
				set_button_assignment(DPAD_DOWN,"sim/GPS/g1000n1_apr")
				set_button_assignment(DPAD_UP,"sim/GPS/g1000n1_vnv")

			end
					
			-- Flash Light
			if sp5_pressed and not MULTI_SIXPACK_PRESSED then
				command_once("sim/view/flashlight_red")
				MULTI_SIXPACK_PRESSED = true
			end
			
			STILL_PRESSED = true
		end

		if sp3_pressed then

			if not STILL_PRESSED then
				set_button_assignment(RIGHT_BUMPER,"sim/GPS/g1000n1_vnv")
				set_button_assignment(SIXPACK_6,"sim/lights/landing_lights_toggle")
				set_button_assignment(DPAD_LEFT,"sim/autopilot/level_change")
				set_button_assignment(DPAD_RIGHT,"sim/GPS/g1000n1_alt")
			end
			
			if dpad_up_pressed then
				meterC172SPInteraction(DPAD_PRESSED,"sim/autopilot/altitude_up", "sim/autopilot/altitude_up", 1.0, 2.0) -- at around two seconds, use larger increment
				DPAD_PRESSED = true
			elseif dpad_down_pressed then
				meterC172SPInteraction(DPAD_PRESSED,"sim/autopilot/altitude_down", "sim/autopilot/altitude_down", 1.0, 2.0)
				DPAD_PRESSED = true
			end
			
			STILL_PRESSED = true
			
		end
		
		if sp5_pressed then
			if not STILL_PRESSED then
				set_button_assignment(RIGHT_BUMPER,"sim/autopilot/heading")
			end
			
			if dpad_up_pressed then
				meterC172SPInteraction(DPAD_PRESSED,"sim/autopilot/heading_up", "sim/autopilot/heading_up", 1.0, 3.0) -- at around two seconds, use larger increment
				DPAD_PRESSED = true
			elseif dpad_down_pressed then
				meterC172SPInteraction(DPAD_PRESSED,"sim/autopilot/heading_down", "sim/autopilot/heading_down", 1.0, 3.0)
				DPAD_PRESSED = true
			end
			STILL_PRESSED = true
		end
		
		if sp6_pressed then
			set_button_assignment(DPAD_LEFT,"sim/instruments/barometer_down")
			set_button_assignment(DPAD_RIGHT,"sim/instruments/barometer_up")
			set_button_assignment(DPAD_CENTER,"sim/instruments/barometer_std")

			--set_button_assignment(RIGHT_BUMPER,"sim/autopilot/vertical_speed_pre_sel")
			set_button_assignment(DPAD_CENTER,"sim/GPS/g1000n1_vs")

			
			if dpad_up_pressed then
				meterC172SPInteraction(DPAD_PRESSED,"sim/autopilot/vertical_speed_up", "sim/autopilot/vertical_speed_up", 1.0, 3.0) -- at around two seconds, use larger increment
				DPAD_PRESSED = true
			elseif dpad_down_pressed then
				meterC172SPInteraction(DPAD_PRESSED,"sim/autopilot/vertical_speed_down", "sim/autopilot/vertical_speed_down", 1.0, 3.0)
				DPAD_PRESSED = true
			end
			
			STILL_PRESSED = true

		end

-- parking brake			
		if left_bumper_pressed then
			set_button_assignment(SIXPACK_2,NoCommand)
			set_button_assignment(SIXPACK_1,NoCommand)

			if wheel_up_pressed or wheel_down_pressed then
				meterC172SPInteraction(BUMPERS_PRESSED, "sim/flight_controls/brakes_toggle_max", "sim/flight_controls/brakes_toggle_max", 2.0, 20) -- at around two seconds, use larger increment
				BUMPERS_PRESSED = true
			end
			
--[[
			if not STILL_PRESSED then
				set_button_assignment(WHEEL_UP,"sim/flight_controls/brakes_toggle_max")
				set_button_assignment(WHEEL_DOWN,"sim/flight_controls/brakes_toggle_max")
			end
]]
				-- Cockpit camera height not implemented as it deals with the rudder axes.....
			if sp1_pressed and not MULTI_SIXPACK_PRESSED then
				if dpad_up_pressed then
					-- EFB but this doesn't quite work. C172.
					--set_pilots_head(-0.60079902410507,1.5304770469666,-11.694169998169,306.1875,-17.333335876465)
				else
					-- All instruments
					set_pilots_head(-0.24383999407291,0.36880800127983,0.18287999927998,0.93750029802322,-18.001930236816)
				end
				MULTI_SIXPACK_PRESSED = true
			elseif sp2_pressed and not MULTI_SIXPACK_PRESSED then
				-- Pilot's display
				set_pilots_head(-0.18544515967369,0.22489054501057,-0.23299551010132,358.3125,-3.6666672229767)
				MULTI_SIXPACK_PRESSED = true
			elseif sp3_pressed and not MULTI_SIXPACK_PRESSED then
				-- Co-pilot's display
				set_pilots_head(0.075676143169403,0.22489054501057,-0.24068839848042,358.3125,-3.6666672229767)
				MULTI_SIXPACK_PRESSED = true
			elseif sp4_pressed and not MULTI_SIXPACK_PRESSED then
				-- back, left rear
				set_pilots_head(-0.24383999407291,0.36880800127983,0.18287999927998,227.8125,-14.000004768372)
				MULTI_SIXPACK_PRESSED = true
			elseif sp5_pressed and not MULTI_SIXPACK_PRESSED then
				-- right corner
				set_pilots_head(-0.24383999407291,0.36880800127983,0.18287999927998,39,-1.1666687726974)

				MULTI_SIXPACK_PRESSED = true
			elseif sp6_pressed and not MULTI_SIXPACK_PRESSED then
				-- right rear
				set_pilots_head(-0.24383999407291,0.36880800127983,0.18287999927998,133.46115112305,-8.862753868103)
				MULTI_SIXPACK_PRESSED = true
			end
			
			STILL_PRESSED = true
		end
				

-- DPAD_up mode
		if dpad_up_pressed then
			if not STILL_PRESSED then
				--set_button_assignment(RIGHT_BUMPER,"laminar/C172/autopilot/capt_toga_press") -- there's only a toggle (Will investigate later)
				--set_button_assignment(WHEEL_UP,"sim/flight_controls/flaps_down")
				--set_button_assignment(WHEEL_DOWN,"sim/flight_controls/flaps_up")
				set_button_assignment(POV_LEFT,"sim/view/glance_left")
				set_button_assignment(POV_RIGHT,"sim/view/glance_right")
				set_button_assignment(POV_UP,"sim/view/straight_up")
				set_button_assignment(POV_DOWN,"sim/view/straight_down")
		
				set_button_assignment(DPAD_LEFT,NoCommand)
				set_button_assignment(DPAD_RIGHT,NoCommand)
			end
			
			if wheel_up_pressed then
				meterC172SPInteraction(DPAD_PRESSED, "sim/flight_controls/flaps_down", "sim/flight_controls/flaps_down", 1.2, 10) -- at around two seconds, use larger increment
				DPAD_PRESSED = true
			elseif wheel_down_pressed then
				meterC172SPInteraction(DPAD_PRESSED, "sim/flight_controls/flaps_up", "sim/flight_controls/flaps_up", 1.2, 10) -- at around two seconds, use larger increment
				DPAD_PRESSED = true
			end
			
			if dpad_left_pressed then
				-- Pilot's seat C172
				--headX, headY, headZ, heading, pitch = get_pilots_head()
				--print(headX .. "," .. headY .. "," .. headZ .. "," .. heading .. "," .. pitch)
				set_pilots_head(-0.24384000897408,0.36880797147751,0.18287998437881,0,0)

			elseif dpad_right_pressed then
				-- Copilot's seat C172
				set_pilots_head(0.28304398059845,0.36880797147751,0.18287998437881,0,0)

			end
			STILL_PRESSED = true

		end
		
-- DPAD_down mode
		if dpad_down_pressed then
			if not STILL_PRESSED then
				--set_button_assignment(RIGHT_BUMPER,"laminar/C172/autopilot/disconnect_toggle")
			end
			
			STILL_PRESSED = true
		end

		if wheel_up_pressed and not DPAD_PRESSED then
			for z = 0,2,1 do -- make the wheel turn a bit faster per press
				command_once("sim/flight_controls/pitch_trim_up")
			end
		end
		
		if wheel_down_pressed and not DPAD_PRESSED then
			for z = 0,2,1 do
				command_once("sim/flight_controls/pitch_trim_down")
			end
		end			
			
			
-- All buttons need to be released to end STILL_PRESSED phase
		if not sp1_pressed and not sp2_pressed and not sp3_pressed and not sp4_pressed and not sp5_pressed and not sp6_pressed and not right_bumper_pressed and not left_bumper_pressed and not dpad_center_pressed and not dpad_down_pressed and not dpad_left_pressed and not dpad_right_pressed then
			STILL_PRESSED = false
		end

		if not sp1_pressed and not sp2_pressed and not sp3_pressed and not sp4_pressed and not sp5_pressed and not sp6_pressed then
			MULTI_SIXPACK_PRESSED = false
		end 
		
		if not dpad_up_pressed and not dpad_left_pressed and not dpad_right_pressed and not dpad_down_pressed then
			DPAD_PRESSED = false
		end
		
		if not left_bumper_pressed and not right_bumper_pressed then
			BUMPERS_PRESSED = false
		end
		
    end 
end

-- If aircraft's interactive Command increment is not continuous or continuous and too fast, use framerate to meter incrementing
function meterC172SPInteraction(boolButtonPressed, strCommandName1, strCommandName2, floatSeconds, floatIntervalSpeed)
		-- floatIntervalSpeed -- generally, higher is slower. 
		
		-- Set metering based on current frame rate
		DataRef("FrameRatePeriod","sim/operation/misc/frame_rate_period","writable")
		CurFrame = FRAME_COUNT
		
		if not boolButtonPressed then
			FrameRate = 1/FrameRatePeriod
			-- Roughly calculate how many frames to wait before incrementing based on floatSeconds
			GoFasterFrameRate = (floatSeconds * FrameRate) + CurFrame -- start five seconds of slow increments
		end

		if CurFrame < GoFasterFrameRate then
			if not boolButtonPressed then
				command_once(strCommandName1)
				-- calculate frame to wait until continuing
				-- if floatSeconds is 2 then we'll wait around 1 second before continuing so as to allow a single standalone increment
				PauseIncrementFrameCount = ((floatSeconds/2) * FrameRate) + CurFrame
			else
				-- wait a beat with PauseIncrementFrameCount then continue
				if (CurFrame > PauseIncrementFrameCount) and (CurFrame % floatIntervalSpeed) == 0 then
					command_once(strCommandName1)
				end
			end
		elseif CurFrame >= GoFasterFrameRate and boolButtonPressed then
			-- If current frame is divisible by five then issue a command -- helps to delay the command in a regular interval
			if (CurFrame % floatIntervalSpeed) == 0 then
				command_once(strCommandName2)
			end
		end			
end


-- Don't mess with other configurations
if PLANE_ICAO == "C172" then 
	clear_all_button_assignments()

--[[
set_axis_assignment(STICK_X, "roll", "normal" )
set_axis_assignment(STICK_Y, "pitch", "normal" )
set_axis_assignment(POLE_RIGHT, "reverse", "reverse")
set_axis_assignment(POLE_RIGHT, "speedbrakes", "reverse")
set_axis_assignment(RUDDER, "yaw", "normal" )
]]

	do_every_frame("multipressLRC172SP_buttons()")
end
