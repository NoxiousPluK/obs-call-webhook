--[[
    OBS Plugin that calls configurable webhooks on recording start and stop events.

    ©️ 2026, NoxiousPluK
    MIT License
    https://github.com/NoxiousPluK/obs-call-webhook
]]

local obs = obslua
local ffi = require("ffi")

ffi.cdef [[
    typedef void* HANDLE;
    typedef int    BOOL;
    typedef struct {
        unsigned long  cb;
        char          *lpReserved, *lpDesktop, *lpTitle;
        unsigned long  dwX, dwY, dwXSize, dwYSize;
        unsigned long  dwXCountChars, dwYCountChars, dwFillAttribute, dwFlags;
        unsigned short wShowWindow, cbReserved2;
        unsigned char *lpReserved2;
        HANDLE         hStdInput, hStdOutput, hStdError;
    } STARTUPINFOA;
    typedef struct {
        HANDLE hProcess, hThread;
        unsigned long dwProcessId, dwThreadId;
    } PROCESS_INFORMATION;
    BOOL CreateProcessA(
        const char *lpApplicationName, char *lpCommandLine,
        void *lpProcessAttributes, void *lpThreadAttributes,
        BOOL bInheritHandles, unsigned long dwCreationFlags,
        void *lpEnvironment, const char *lpCurrentDirectory,
        STARTUPINFOA *lpStartupInfo, PROCESS_INFORMATION *lpProcessInformation
    );
    BOOL CloseHandle(HANDLE hObject);
]]

local CREATE_NO_WINDOW = 0x08000000

local function spawn(cmd)
    local si = ffi.new("STARTUPINFOA")
    si.cb = ffi.sizeof("STARTUPINFOA")
    local pi = ffi.new("PROCESS_INFORMATION")
    local buf = ffi.new("char[?]", #cmd + 1, cmd)
    local ok = ffi.C.CreateProcessA(nil, buf, nil, nil, false, CREATE_NO_WINDOW, nil, nil, si, pi)
    if ok ~= 0 then
        ffi.C.CloseHandle(pi.hProcess)
        ffi.C.CloseHandle(pi.hThread)
    end
end

local start_webhook = ""
local stop_webhook  = ""

----------------------------------------------------------------------------
-- OBS event callback
----------------------------------------------------------------------------
function on_event(event)
    if event == obs.OBS_FRONTEND_EVENT_RECORDING_STARTED then
        call_webhook(start_webhook)
    elseif event == obs.OBS_FRONTEND_EVENT_RECORDING_STOPPED then
        call_webhook(stop_webhook)
    elseif event == obs.OBS_FRONTEND_EVENT_RECORDING_PAUSED then
        call_webhook(stop_webhook)
    elseif event == obs.OBS_FRONTEND_EVENT_RECORDING_UNPAUSED then
        call_webhook(start_webhook)
    end
end

----------------------------------------------------------------------------
-- Webhook helper
----------------------------------------------------------------------------
function call_webhook(url)
    if url and url ~= "" then
        spawn('curl -s -o NUL -X POST "' .. url .. '"')
    end
end

----------------------------------------------------------------------------
-- OBS script API
----------------------------------------------------------------------------
function script_description()
    return "Calls configurable webhooks on recording start and stop events."
end

function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_text(props, "start_webhook", "Recording started URL", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "stop_webhook", "Recording stopped URL", obs.OBS_TEXT_DEFAULT)
    return props
end

function script_defaults(settings)
    obs.obs_data_set_default_string(settings, "start_webhook", "")
    obs.obs_data_set_default_string(settings, "stop_webhook", "")
end

function script_update(settings)
    start_webhook = obs.obs_data_get_string(settings, "start_webhook")
    stop_webhook  = obs.obs_data_get_string(settings, "stop_webhook")
end

function script_load(settings)
    obs.obs_frontend_add_event_callback(on_event)
end

function script_unload()
end
