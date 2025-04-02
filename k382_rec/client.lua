local isRecording = false
local isUIOpen = false
local isMouseEnabled = false

-- Función para abrir la UI
local function OpenUI()
    if not isUIOpen then
        isUIOpen = true
        SendNUIMessage({ action = "open" })
        -- Aseguramos que el mouse esté desactivado al abrir
        isMouseEnabled = false
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(true)
    end
end

-- Función para cerrar la UI
local function CloseUI()
    if isUIOpen then
        if isRecording then
            StopRecordingAndSaveClip()
            isRecording = false
        end
        isUIOpen = false
        isMouseEnabled = false
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        SendNUIMessage({ action = "close" })
    end
end

-- Funciones para el control del mouse
local function EnableMouse()
    if isUIOpen and not isMouseEnabled then
        isMouseEnabled = true
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(false)
    end
end

local function DisableMouse()
    if isUIOpen and isMouseEnabled then
        isMouseEnabled = false
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(true)
    end
end

-- Comando para abrir la UI
RegisterCommand("cine", function()
    OpenUI()
end, false)

-- Comando para cerrar la UI
RegisterCommand("cineoff", function()
    CloseUI()
end, false)

-- Callbacks NUI
RegisterNUICallback("startRec", function(data, cb)
    if not isRecording and isUIOpen then
        StartRecording(1)
        isRecording = true
        DisableMouse() -- Desactivar el mouse después de presionar el botón
    end
    cb('ok')
end)

RegisterNUICallback("stopRec", function(data, cb)
    if isRecording and isUIOpen then
        StopRecordingAndSaveClip()
        isRecording = false
        DisableMouse() -- Desactivar el mouse después de presionar el botón
    end
    cb('ok')
end)

RegisterNUICallback("closeUI", function(data, cb)
    CloseUI()
    DisableMouse() -- Desactivar el mouse después de presionar el botón
    cb('ok')
end)

-- Control de tecla INSERT para el mouse
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isUIOpen then
            -- INSERT para activar el mouse
            if IsControlJustPressed(0, 121) then -- 121 es INSERT
                EnableMouse()
            end
        end
    end
end)

-- Asegurarse de que la UI esté cerrada cuando el recurso se detenga
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    CloseUI()
end)
