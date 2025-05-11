local isInCinematicWalk = false
local walkSpeed = 1.0      -- Walking speed

-- Beach scene coordinates
local startingCoords = vector3(-1517.32, -1209.44, 1.58)  -- Player starts on Vespucci Beach
local lookAroundSpot = vector3(-1520.66, -1216.76, 1.58)  -- Spot where player stops to look around
local skyViewCoords = vector3(-1520.66, -1216.76, 25.0)   -- Sky/moon view coordinates
local smokingSpot = vector3(-1493.62, -1289.36, 2.35)    -- Spot where player will smoke (formerly vehicle coords)

-- Register the command to start the cinematic walk
RegisterCommand('cinewalk', function(source, args, rawCommand)
    -- Check if already in cinematic walk
    if isInCinematicWalk then
        return
    end
    
    -- Start the beach scene
    StartBeachScene()
end, false)

-- Function to display animated welcome text with modern design
function ShowWelcomeText()
    -- Create a new thread for the text animation
    Citizen.CreateThread(function()
        -- Create a custom modern design instead of using the default scaleform
        
        -- Load background texture for blur effect
        local bgTextureDict = "pause_menu_pages_char_mom_dad"
        RequestStreamedTextureDict(bgTextureDict, true)
        while not HasStreamedTextureDictLoaded(bgTextureDict) do
            Citizen.Wait(0)
        end
        
        -- Additional texture for better background
        local bgtxd = "shared"
        RequestStreamedTextureDict(bgtxd, true)
        while not HasStreamedTextureDictLoaded(bgtxd) do
            Citizen.Wait(0)
        end
        
        -- Display the welcome message with elegant animations
        local startTime = GetGameTimer()
        local displayTime = Config.welcomeText.displayTime
        local animationPhase = 1
        -- 1: Initial fade in
        -- 2: Main display
        -- 3: Text transition
        -- 4: Fade out
        
        local frankfurt = Config.welcomeText.title
        local code = Config.welcomeText.code
        local subtitleText = Config.welcomeText.subtitle
        
        -- Track the animation progress
        local phaseStartTime = startTime
        local phase1Duration = Config.welcomeText.fadeInTime
        local phase2Duration = Config.welcomeText.mainDisplayTime
        local phase3Duration = Config.welcomeText.transitionTime
        local phase4Duration = Config.welcomeText.fadeOutTime
        
        while GetGameTimer() - startTime < displayTime do
            local currentTime = GetGameTimer()
            local timeSinceStart = currentTime - startTime
            
            -- Determine current animation phase
            if animationPhase == 1 and timeSinceStart >= phase1Duration then
                animationPhase = 2
                phaseStartTime = currentTime
            elseif animationPhase == 2 and timeSinceStart >= phase1Duration + phase2Duration then
                animationPhase = 3
                phaseStartTime = currentTime
            elseif animationPhase == 3 and timeSinceStart >= phase1Duration + phase2Duration + phase3Duration then
                animationPhase = 4
                phaseStartTime = currentTime
            end
            
            -- Calculate alpha/progress based on current phase
            local alpha = 255
            local progress = (currentTime - phaseStartTime) / 
                (animationPhase == 1 and phase1Duration or 
                 animationPhase == 2 and phase2Duration or 
                 animationPhase == 3 and phase3Duration or phase4Duration)
            
            if animationPhase == 1 then
                -- Fade in phase
                alpha = 255 * progress
            elseif animationPhase == 4 then
                -- Fade out phase
                alpha = 255 * (1 - progress)
            end
            
            -- Completely transparent background - only showing the text
            -- Define accent color for minimal UI elements
            local accentColor = {227, 66, 52, alpha} -- Red accent
            
            -- No background elements, no lines, only text will be visible
            
            -- Draw Frankfurt text with clean, minimalist style
            SetTextFont(1)
            SetTextScale(1.8, 1.8)
            SetTextColour(255, 255, 255, alpha)
            SetTextDropshadow(5, 0, 0, 0, alpha * 0.5)
            SetTextEdge(2, 0, 0, 0, alpha * 0.2)
            SetTextDropShadow()
            SetTextOutline()
            SetTextCentre(true)
            
            -- Animate the text for more visual appeal
            local textY = 0.3 - 0.04
            local textOffsetX = 0
            
            if animationPhase == 3 then
                -- Slide text during transition
                textOffsetX = 0.3 * (1 - progress)
            end
            
            -- Add subtle floating effect to main title
            local floatOffset = math.sin(GetGameTimer() * 0.0015) * 0.003 -- Reduced floating movement
            
            -- Main title with slight animations
            if animationPhase < 3 then
                -- First display Frankfurt
                BeginTextCommandDisplayText("STRING")
                AddTextComponentSubstringPlayerName(frankfurt)
                EndTextCommandDisplayText(0.5 - textOffsetX, textY + floatOffset)
            else
                -- Then slide to Frankfurt069
                BeginTextCommandDisplayText("STRING")
                AddTextComponentSubstringPlayerName(frankfurt)
                EndTextCommandDisplayText(0.5 - 0.05, textY + floatOffset)
                
                -- Add the code with different color
                SetTextFont(1)
                SetTextScale(1.8, 1.8)
                SetTextColour(255, 215, 0, alpha) -- Gold color for the number
                BeginTextCommandDisplayText("STRING")
                AddTextComponentSubstringPlayerName(code)
                EndTextCommandDisplayText(0.5 + 0.14, textY + floatOffset)
            end
            
            -- Subtitle text - improved with better font and position
            SetTextFont(4)
            SetTextScale(0.5, 0.5) -- Slightly smaller subtitle
            SetTextColour(255, 255, 255, alpha)
            SetTextDropshadow(5, 0, 0, 0, alpha * 0.3) -- Reduced shadow
            SetTextEdge(1, 0, 0, 0, alpha * 0.1) -- Reduced edge
            SetTextDropShadow()
            SetTextOutline()
            SetTextCentre(true)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName(subtitleText)
            EndTextCommandDisplayText(0.5, 0.3 + 0.04) -- Adjusted position
            
            -- Draw elegant separator line
            local lineWidth = 0.2
            local pulseAmount = 0.03
            
            -- Pulse the line with a smooth sine wave
            local pulse = math.sin(GetGameTimer() * 0.002) * pulseAmount
            lineWidth = lineWidth + pulse
            
            -- Create a gradient for the separator
            for i = 0, 10 do
                local segmentWidth = lineWidth * (1 - (i/10))
                local opacity = (1 - (i/10)) * alpha * 0.8
                DrawRect(0.5, 0.3 + 0.01, segmentWidth, 0.001, 255, 215, 0, opacity) -- Gold separator
            end
            
            Citizen.Wait(0)
        end
        
        -- Clean up textures - using the correct function name
        SetStreamedTextureDictAsNoLongerNeeded(bgTextureDict)
        SetStreamedTextureDictAsNoLongerNeeded("shared")
        
        -- Wait before showing info box
        Citizen.Wait(Config.welcomeText.waitBeforeInfoBox)
        
        -- Start permanent info box with server rules
        ShowPermanentInfoBox()
    end)
end

-- Function to show a permanent info box during the cinematic with modern design
function ShowPermanentInfoBox()
    Citizen.CreateThread(function()
        -- Continue showing info box until cinematic ends
        local currentMsgIndex = 1
        local messageChangeTime = GetGameTimer() + Config.infoBox.messageChangeInterval
        local isInfoBoxActive = true
        local lastChangeTime = GetGameTimer()
        local isVisible = true
        
        -- Register for end of cinematic
        Citizen.CreateThread(function()
            while isInCinematicWalk do
                Citizen.Wait(500)
            end
            isInfoBoxActive = false -- Stop the info box when cinematic ends
        end)
        
        -- Load textures for icons
        local textureDict = "commonmenu"
        RequestStreamedTextureDict(textureDict, true)
        while not HasStreamedTextureDictLoaded(textureDict) do
            Citizen.Wait(10)
        end
        
        -- Predefine all icon types to avoid flickering
        local iconTypes = {
            ["ACHTUNG"] = "shop_NEW_Star",
            ["TIPP"] = "mp_specitem_coke",
            ["REGELN"] = "shop_lock",
            ["REALISMUS"] = "shop_garage_icon_b",
            ["COMMUNITY"] = "shop_health_icon_b",
            ["WIRTSCHAFT"] = "shop_franklin_icon_b",
            ["KRIMINALITÄT"] = "shop_michael_icon_b",
            ["JOBS"] = "shop_trevor_icon_b",
            ["MEDIZIN"] = "shop_health_icon_b",
            ["KOMMUNIKATION"] = "mp_specitem_coke"
        }
        
        -- Pre-process messages to avoid parsing during rendering
        local processedMessages = {}
        for i, msg in ipairs(Config.infoMessages) do
            local prefixColor = {255, 255, 255} -- Default white
            if string.find(msg, "~r~") then
                prefixColor = {255, 59, 59} -- Red
            elseif string.find(msg, "~g~") then
                prefixColor = {114, 204, 114} -- Green
            elseif string.find(msg, "~b~") then
                prefixColor = {93, 182, 229} -- Blue
            elseif string.find(msg, "~y~") then
                prefixColor = {255, 215, 0} -- Yellow
            elseif string.find(msg, "~p~") then
                prefixColor = {179, 112, 219} -- Purple
            elseif string.find(msg, "~o~") then
                prefixColor = {255, 133, 85} -- Orange
            elseif string.find(msg, "~c~") then
                prefixColor = {136, 136, 136} -- Grey
            end
            
            -- Clean the message (remove color codes)
            local cleanMessage = msg:gsub("~[rgybopcws]~", "")
            
            -- Split into prefix and content
            local prefix, content = string.match(cleanMessage, "([^:]+): (.+)")
            
            -- Get icon type
            local iconType = nil
            for key, value in pairs(iconTypes) do
                if string.find(msg, key) then
                    iconType = value
                    break
                end
            end
            
            processedMessages[i] = {
                prefixColor = prefixColor,
                prefix = prefix,
                content = content,
                iconType = iconType
            }
        end
        
        -- Create display buffer for smooth transitions
        local displayMessage = processedMessages[1]
        local nextMessage = nil
        local transitionProgress = 0
        
        while isInfoBoxActive do
            -- Change message when it's time
            local currentTime = GetGameTimer()
            
            -- Handle message transitions
            if currentTime > messageChangeTime then
                -- Set up next message
                lastChangeTime = currentTime
                currentMsgIndex = currentMsgIndex + 1
                if currentMsgIndex > #processedMessages then
                    currentMsgIndex = 1
                end
                
                -- Update transition data
                nextMessage = processedMessages[currentMsgIndex]
                transitionProgress = 0
                messageChangeTime = currentTime + Config.infoBox.messageChangeInterval
            end
            
            -- Calculate transition progress
            if nextMessage then
                transitionProgress = math.min(1.0, (currentTime - lastChangeTime) / Config.infoBox.transitionSpeed)
                
                -- Complete the transition
                if transitionProgress >= 1.0 then
                    displayMessage = nextMessage
                    nextMessage = nil
                    transitionProgress = 0
                end
            end
            
            -- Calculate display opacity
            local opacity = 255
            if nextMessage then
                opacity = 255 * (1 - transitionProgress)
            end
            
            -- Only draw if visible
            if isVisible then
                -- Smaller, more compact info box
                
                -- Very subtle background for readability only
                DrawRect(0.5, 0.95, 0.4, 0.07, 0, 0, 0, 100) 
                
                -- Small accent line on the left
                DrawRect(0.5 - 0.2, 0.95, 0.002, 0.07, 
                    displayMessage.prefixColor[1], 
                    displayMessage.prefixColor[2], 
                    displayMessage.prefixColor[3], 
                    opacity)
                
                -- Small icon
                if displayMessage.iconType then
                    local iconScale = 0.02
                    DrawSprite(textureDict, displayMessage.iconType, 0.33, 0.95, iconScale, iconScale*1.5, 0.0, 255, 255, 255, opacity)
                end
                
                -- Text - prefix with matching color (larger font)
                SetTextFont(4)
                SetTextScale(Config.infoBox.titleFontSize, Config.infoBox.titleFontSize)
                SetTextColour(displayMessage.prefixColor[1], displayMessage.prefixColor[2], displayMessage.prefixColor[3], opacity)
                SetTextDropshadow(0, 0, 0, 0, opacity)
                SetTextEdge(1, 0, 0, 0, 150)
                SetTextDropShadow()
                SetTextOutline()
                SetTextRightJustify(false)
                SetTextEntry("STRING")
                AddTextComponentString(displayMessage.prefix)
                DrawText(0.35, 0.936)
                
                -- Text - content in white with larger font
                SetTextFont(4)
                SetTextScale(Config.infoBox.fontSize, Config.infoBox.fontSize)
                SetTextColour(255, 255, 255, opacity)
                SetTextDropshadow(0, 0, 0, 0, opacity)
                SetTextEdge(1, 0, 0, 0, 150)
                SetTextDropShadow()
                SetTextOutline()
                SetTextWrap(0.35, 0.7) -- Narrower text wrap for smaller box
                SetTextEntry("STRING")
                AddTextComponentString(displayMessage.content)
                DrawText(0.35, 0.955)
            end
            
            Citizen.Wait(0)
        end
        
        -- Release texture - fix the function name
        SetStreamedTextureDictAsNoLongerNeeded(textureDict)
    end)
end

-- Function to start the beach scene
function StartBeachScene()
    local playerPed = PlayerPedId()
    
    -- Ensure any existing sequence is properly terminated
    isInCinematicWalk = false
    Citizen.Wait(100)
    
    -- Teleport player to starting position on the beach
    SetEntityCoords(playerPed, startingCoords.x, startingCoords.y, startingCoords.z, true, false, false, false)
    
    -- Wait briefly for the teleport to complete
    Citizen.Wait(500)
    
    -- Set player heading to face the ocean (south)
    SetEntityHeading(playerPed, 180.0)
    
    -- Set flag to prevent multiple cinema walks
    isInCinematicWalk = true
    
    -- Create cinematic camera
    local cam = CreateCinematicCamera()
    
    -- Disable player controls - cannot be canceled
    DisablePlayerControls(true)
    
    -- Disable minimap if configured
    if Config.options.disableMinimap then
        DisplayRadar(false)
    end
    
    -- Start the sequence
    Citizen.CreateThread(function()
        -- Phase 1: Walking on beach and looking around
        local phase = 1
        local lookingAround = false
        local skyView = false
        local startTime = GetGameTimer()
        local phaseTime = 0
        local subPhase = 1
        local welcomeTextShown = false
        local phaseTimeout = 0
        local sequenceStarted = false
        local smokingStarted = false
        
        -- Set walking animation
        RequestAnimSet("move_m@casual@d")
        while not HasAnimSetLoaded("move_m@casual@d") do
            Wait(100)
        end
        SetPedMovementClipset(playerPed, "move_m@casual@d", 1.0)
        
        -- Notification
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName("Beach cinematic experience started.")
        EndTextCommandThefeedPostTicker(true, true)
        
        -- Walk to looking point
        TaskGoStraightToCoord(playerPed, lookAroundSpot.x, lookAroundSpot.y, lookAroundSpot.z, walkSpeed, -1, 180.0, 0.1)
        sequenceStarted = true
        phaseTimeout = GetGameTimer() + 30000 -- 30 seconds timeout for this phase (silent timeout)
        
        while isInCinematicWalk do
            local playerCoords = GetEntityCoords(playerPed)
            local currentTime = GetGameTimer()
            
            -- Show welcome text after 8-9 seconds of walking
            if not welcomeTextShown and currentTime - startTime > 8500 then
                ShowWelcomeText()
                welcomeTextShown = true
            end
            
            -- Handle timeout for phases - prevent getting stuck (silently)
            if currentTime > phaseTimeout then
                -- Handle phase timeouts without messages
                if phase == 1 then
                    -- Force move to next phase if looking around times out
                    ClearPedTasks(playerPed)
                    lookingAround = false
                    skyView = false
                    phase = 2
                    phaseTime = currentTime
                    
                    -- Set heading toward smoking spot
                    local heading = GetHeadingFromCoords(playerCoords.x, playerCoords.y, smokingSpot.x, smokingSpot.y)
                    SetEntityHeading(playerPed, heading)
                    
                    -- Walk to smoking spot
                    TaskGoStraightToCoord(playerPed, smokingSpot.x, smokingSpot.y, smokingSpot.z, walkSpeed, -1, heading, 0.1)
                    phaseTimeout = currentTime + 60000 -- 60 seconds timeout for phase 2
                elseif phase == 2 then
                    -- Force end if smoking scene times out
                    phase = 3
                    phaseTime = currentTime
                    phaseTimeout = currentTime + 10000 -- 10 seconds for fade out
                end
            end
            
            -- Phase 1: Beach walk and look around
            if phase == 1 then
                local distanceToLookSpot = #(lookAroundSpot - playerCoords)
                
                -- Update normal camera following player
                if not lookingAround and not skyView then
                    UpdateCinematicCamera(cam, playerPed)
                end
                
                -- When player reaches the look spot
                if distanceToLookSpot < 0.5 and not lookingAround then
                    -- Clear walking task
                    ClearPedTasks(playerPed)
                    
                    -- Play "looking around" animation
                    lookingAround = true
                    phaseTime = currentTime
                    
                    -- Play animation of looking around
                    RequestAnimDict("amb@world_human_tourist_map@male@base")
                    while not HasAnimDictLoaded("amb@world_human_tourist_map@male@base") do
                        Wait(100)
                    end
                    
                    TaskPlayAnim(playerPed, "amb@world_human_tourist_map@male@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
                    
                    -- Start camera rotation around player
                    Citizen.CreateThread(function()
                        local camRotationTime = 0
                        local totalRotationTime = 8000 -- 8 seconds
                        
                        while lookingAround and not skyView do
                            local progress = (GetGameTimer() - phaseTime) / totalRotationTime
                            
                            if progress <= 1.0 then
                                -- Rotate camera around player
                                local angle = progress * 360.0
                                local radius = 3.0
                                local camHeight = 1.5
                                
                                local offsetX = radius * math.cos(math.rad(angle))
                                local offsetY = radius * math.sin(math.rad(angle))
                                
                                local camPos = vector3(
                                    playerCoords.x + offsetX,
                                    playerCoords.y + offsetY,
                                    playerCoords.z + camHeight
                                )
                                
                                SetCamCoord(cam, camPos.x, camPos.y, camPos.z)
                                PointCamAtEntity(cam, playerPed, 0.0, 0.0, 0.0, true)
                                
                                Wait(0)
                            else
                                -- Transition to sky view
                                skyView = true
                                lookingAround = false
                                phaseTime = GetGameTimer()
                                break
                            end
                        end
                    end)
                end
                
                -- Sky view phase
                if skyView and currentTime - phaseTime < 5000 then -- 5 seconds of sky view
                    -- Transition camera to sky
                    local progress = math.min(1.0, (currentTime - phaseTime) / 2000) -- 2 seconds transition
                    
                    -- Calculate position between player and sky
                    local camPos = vector3(
                        playerCoords.x,
                        playerCoords.y - 3.0, -- slightly behind player
                        playerCoords.z + (skyViewCoords.z - playerCoords.z) * progress
                    )
                    
                    -- Set camera position pointing up at the sky
                    SetCamCoord(cam, camPos.x, camPos.y, camPos.z)
                    
                    -- Gradually change rotation to look up
                    local pitch = -45.0 * progress -- Look upward
                    SetCamRot(cam, pitch, 0.0, 180.0, 2)
                elseif skyView and currentTime - phaseTime >= 5000 then
                    -- End sky view, transition to walking to smoking spot
                    skyView = false
                    ClearPedTasks(playerPed)
                    phase = 2
                    phaseTime = currentTime
                    
                    -- Set heading toward smoking spot
                    local heading = GetHeadingFromCoords(playerCoords.x, playerCoords.y, smokingSpot.x, smokingSpot.y)
                    SetEntityHeading(playerPed, heading)
                    
                    -- Walk to smoking spot
                    TaskGoStraightToCoord(playerPed, smokingSpot.x, smokingSpot.y, smokingSpot.z, walkSpeed, -1, heading, 0.1)
                end
            
            -- Phase 2: Walk to smoking spot and smoke
            elseif phase == 2 then
                local distanceToSmokingSpot = #(smokingSpot - playerCoords)
                
                -- Return to normal camera following
                UpdateCinematicCamera(cam, playerPed)
                
                -- When close to smoking spot, start smoking animation
                if distanceToSmokingSpot < 0.5 and not smokingStarted then
                    -- Clear walking task
                    ClearPedTasks(playerPed)
                    ResetPedMovementClipset(playerPed, 0.0)
                    
                    -- Random heading (look out to sea)
                    SetEntityHeading(playerPed, 180.0)
                    
                    -- Start smoking animation
                    smokingStarted = true
                    phaseTime = currentTime
                    
                    -- Request smoking animation
                    RequestAnimDict("amb@world_human_smoking@male@male_a@base")
                    while not HasAnimDictLoaded("amb@world_human_smoking@male@male_a@base") do
                        Wait(100)
                    end
                    
                    -- Create cigarette prop
                    local propName = 'prop_cs_ciggy_01'
                    RequestModel(GetHashKey(propName))
                    while not HasModelLoaded(GetHashKey(propName)) do
                        Wait(100)
                    end
                    
                    local x, y, z = table.unpack(GetEntityCoords(playerPed))
                    local prop = CreateObject(GetHashKey(propName), x, y, z + 0.2, true, true, true)
                    local boneIndex = GetPedBoneIndex(playerPed, 64097)
                    
                    AttachEntityToEntity(prop, playerPed, boneIndex, 0.015, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                    TaskPlayAnim(playerPed, "amb@world_human_smoking@male@male_a@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
                    
                    -- Wait for smoking duration (6 seconds total - 3 seconds to watch, 3 seconds buffer before end)
                    Citizen.SetTimeout(6000, function()
                        -- End smoking and move to final phase
                        ClearPedTasks(playerPed)
                        DeleteObject(prop)
                        phase = 3
                        phaseTime = GetGameTimer()
                    end)
                end
            
            -- Phase 3: End sequence with fade out
            elseif phase == 3 then
                local fadeTime = 3000 -- 3 second fade
                local progress = math.min(1.0, (currentTime - phaseTime) / fadeTime)
                
                -- Fade out screen
                if progress < 1.0 then
                    DoScreenFadeOut(fadeTime)
                else
                    -- End the sequence
                    EndBeachScene(cam)
                    break
                end
            end
            
            -- Check if player has died
            if sequenceStarted and IsEntityDead(playerPed) then
                -- Silent end if player dies
                EndBeachScene(cam)
                break
            end
            
            Citizen.Wait(0)
        end
    end)
end

-- Function to get heading between two sets of coordinates
function GetHeadingFromCoords(x1, y1, x2, y2)
    return math.deg(math.atan2(y2 - y1, x2 - x1)) - 90.0
end

-- Function to create and set up cinematic camera
function CreateCinematicCamera()
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    RenderScriptCams(true, true, 1000, true, true)
    
    return cam
end

-- Function to update camera position and rotation during cinematic walk
function UpdateCinematicCamera(cam, playerPed)
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)
    
    -- Get vehicle status
    local inVehicle = IsPedInAnyVehicle(playerPed, false)
    local vehicle = nil
    local vehicleSpeed = 0.0
    
    if inVehicle then
        vehicle = GetVehiclePedIsIn(playerPed, false)
        vehicleSpeed = GetEntitySpeed(vehicle)
    end
    
    -- Adjust camera distance based on whether in vehicle and vehicle speed
    local distanceMultiplier = 0.6
    local heightMultiplier = 0.8
    
    if inVehicle then
        distanceMultiplier = 2.5 + (vehicleSpeed * 0.2)
        heightMultiplier = 1.0 + (vehicleSpeed * 0.05)
    end
    
    -- Position camera behind player or vehicle
    local camOffset = vector3(
        math.sin(math.rad(playerHeading)) * (-3.0 * distanceMultiplier),
        math.cos(math.rad(playerHeading)) * (-3.0 * distanceMultiplier),
        heightMultiplier
    )
    
    -- Set camera position
    local camPos = playerCoords + camOffset
    SetCamCoord(cam, camPos.x, camPos.y, camPos.z)
    
    -- Point camera at entity
    if inVehicle then
        PointCamAtEntity(cam, vehicle, 0.0, 0.0, 0.0, true)
    else
        PointCamAtEntity(cam, playerPed, 0.0, 0.0, 0.0, true)
    end
    
    -- Apply smooth transitions for camera movement
    SetCamRot(cam, GetGameplayCamRot(2), 2)
end

-- Function to end the beach scene - Updated to remove vehicle references
function EndBeachScene(cam)
    local playerPed = PlayerPedId()
    
    -- Ensure screen is faded out
    DoScreenFadeOut(0)
    
    -- Teleport player back to a safe location (e.g., the beach)
    SetEntityCoords(playerPed, startingCoords.x, startingCoords.y, startingCoords.z, true, false, false, false)
    
    -- Clear tasks and reset movement
    ClearPedTasks(playerPed)
    ResetPedMovementClipset(playerPed, 0.0)
    
    -- Destroy camera
    RenderScriptCams(false, true, 1000, true, true)
    DestroyCam(cam, true)
    
    -- Re-enable controls
    DisablePlayerControls(false)
    
    -- Re-enable minimap if it was disabled
    if Config.options.disableMinimap then
        DisplayRadar(true)
    end
    
    -- Reset flag
    isInCinematicWalk = false
    
    -- Fade screen back in
    Wait(500)
    DoScreenFadeIn(1000)
    
    -- Final notification
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName("Beach cinematic experience has ended. Willkommen in Frankfurt069!")
    EndTextCommandThefeedPostTicker(true, true)
end

-- Function to disable/enable player controls
function DisablePlayerControls(disable)
    if disable then
        for i = 0, 360 do
            DisableControlAction(0, i, true)
        end
        SetPlayerControl(PlayerId(), false, 0)
    else
        SetPlayerControl(PlayerId(), true, 0)
    end
end
