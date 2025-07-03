local dragonCam = nil
local isDragonCamActive = false

local dragonPeds = { -- Ped list that can use this camera
 -- [`prpwyvern`] = true
}

-- Configurable values
local distanceFromPed = 7.0
local verticalOffset = 2.5
local fov = 60.0
local mouseSensitivity = 400.0 -- increase or decrease for mouse camera turn speed

local camPitch = 0.0
local camHeading = 0.0

RegisterCommand("dragoncamera", function()
    local ped = PlayerPedId()
    local pedModel = GetEntityModel(ped)

    if not dragonPeds[pedModel] then
        print("Not using a supported dragon ped.")
        return
    end

    if isDragonCamActive then
        -- Turn off
        ClearFocus()
        RenderScriptCams(false, false, 0, true, true)
    
        if dragonCam then
            DestroyCam(dragonCam, false)
            dragonCam = nil
        end
    
        isDragonCamActive = false
        print("Dragon camera disabled.")
        return
    end

    local coords = GetEntityCoords(ped)
    local camX = coords.x
    local camY = coords.y - distanceFromPed
    local camZ = coords.z + verticalOffset

    dragonCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(dragonCam, camX, camY, camZ)
    PointCamAtEntity(dragonCam, ped, 0.0, 0.0, 0.0, true)
    SetCamFov(dragonCam, fov)
    RenderScriptCams(true, false, 0, true, true)
    isDragonCamActive = true

    CreateThread(function()
        while isDragonCamActive do
            local ped = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)
            local relX = GetDisabledControlNormal(0, 1) -- left/right
            local relY = GetDisabledControlNormal(0, 2) -- up/down
    
camHeading = camHeading - relX * mouseSensitivity * 0.01
camPitch   = camPitch + relY * mouseSensitivity * 0.01

            camPitch = math.max(-30.0, math.min(30.0, camPitch))
    
            local headingRad = math.rad(camHeading)
            local pitchRad = math.rad(camPitch)
    
            local offsetX = math.sin(headingRad) * math.cos(pitchRad) * distanceFromPed
            local offsetY = -math.cos(headingRad) * math.cos(pitchRad) * distanceFromPed
            local offsetZ = math.sin(pitchRad) * distanceFromPed
    
            local camX = pedCoords.x + offsetX
            local camY = pedCoords.y + offsetY
            local camZ = pedCoords.z + verticalOffset + offsetZ
    
            SetCamCoord(dragonCam, camX, camY, camZ)
            PointCamAtEntity(dragonCam, ped, 0.0, 0.0, 0.0, true)
    
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
    
            Wait(0)
        end
    end)
    
end, false)
