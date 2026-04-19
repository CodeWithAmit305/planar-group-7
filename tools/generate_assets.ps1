$ErrorActionPreference = 'Stop'

function Write-Svg {
    param(
        [string]$Path,
        [string]$Content
    )
    $dir = Split-Path -Parent $Path
    if ($dir) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    Set-Content -Path $Path -Value $Content -Encoding UTF8
}

function New-WavTone {
    param(
        [string]$Path,
        [double]$Duration = 1.0,
        [int]$SampleRate = 44100,
        [scriptblock]$Generator
    )

    $dir = Split-Path -Parent $Path
    if ($dir) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }

    $samples = [int]($Duration * $SampleRate)
    $channels = 1
    $bitsPerSample = 16
    $blockAlign = $channels * ($bitsPerSample / 8)
    $byteRate = $SampleRate * $blockAlign
    $dataSize = $samples * $blockAlign

    $fs = [System.IO.File]::Open($Path, [System.IO.FileMode]::Create)
    $bw = New-Object System.IO.BinaryWriter($fs)

    $bw.Write([System.Text.Encoding]::ASCII.GetBytes('RIFF'))
    $bw.Write([int](36 + $dataSize))
    $bw.Write([System.Text.Encoding]::ASCII.GetBytes('WAVE'))
    $bw.Write([System.Text.Encoding]::ASCII.GetBytes('fmt '))
    $bw.Write([int]16)
    $bw.Write([int16]1)
    $bw.Write([int16]$channels)
    $bw.Write([int]$SampleRate)
    $bw.Write([int]$byteRate)
    $bw.Write([int16]$blockAlign)
    $bw.Write([int16]$bitsPerSample)
    $bw.Write([System.Text.Encoding]::ASCII.GetBytes('data'))
    $bw.Write([int]$dataSize)

    for ($i = 0; $i -lt $samples; $i++) {
        $t = $i / [double]$SampleRate
        $v = & $Generator $t $Duration
        if ($v -gt 1.0) { $v = 1.0 }
        if ($v -lt -1.0) { $v = -1.0 }
        $sample = [int16]($v * 32767)
        $bw.Write($sample)
    }

    $bw.Flush()
    $bw.Dispose()
    $fs.Dispose()
}

$bgLab = @"
<svg xmlns='http://www.w3.org/2000/svg' width='1920' height='1080' viewBox='0 0 1920 1080'>
  <defs>
    <linearGradient id='g1' x1='0' y1='0' x2='0' y2='1'>
      <stop offset='0%' stop-color='#071019'/>
      <stop offset='50%' stop-color='#0d1a25'/>
      <stop offset='100%' stop-color='#02060a'/>
    </linearGradient>
    <linearGradient id='g2' x1='0' y1='0' x2='1' y2='0'>
      <stop offset='0%' stop-color='#1df2d0' stop-opacity='0.0'/>
      <stop offset='50%' stop-color='#1df2d0' stop-opacity='0.25'/>
      <stop offset='100%' stop-color='#1df2d0' stop-opacity='0.0'/>
    </linearGradient>
    <linearGradient id='g3' x1='0' y1='0' x2='1' y2='1'>
      <stop offset='0%' stop-color='#7cf8ff' stop-opacity='0.18'/>
      <stop offset='100%' stop-color='#ffb24b' stop-opacity='0.02'/>
    </linearGradient>
  </defs>
  <rect width='1920' height='1080' fill='url(#g1)'/>
  <rect x='0' y='120' width='1920' height='4' fill='url(#g2)'/>
  <rect x='0' y='540' width='1920' height='4' fill='url(#g2)'/>
  <rect x='0' y='930' width='1920' height='4' fill='url(#g2)'/>
  <g opacity='0.8'>
    <rect x='120' y='150' width='280' height='500' rx='18' fill='#09131b' stroke='#1df2d0' stroke-opacity='0.18' stroke-width='2'/>
    <rect x='470' y='110' width='360' height='590' rx='20' fill='#09131b' stroke='#7cf8ff' stroke-opacity='0.22' stroke-width='2'/>
    <rect x='910' y='180' width='290' height='470' rx='18' fill='#081018' stroke='#1df2d0' stroke-opacity='0.16' stroke-width='2'/>
    <rect x='1290' y='100' width='520' height='620' rx='22' fill='#08131b' stroke='#7cf8ff' stroke-opacity='0.16' stroke-width='2'/>
  </g>
  <g opacity='0.55'>
    <rect x='180' y='210' width='160' height='20' rx='10' fill='#7cf8ff'/>
    <rect x='530' y='180' width='210' height='18' rx='9' fill='#1df2d0'/>
    <rect x='1400' y='170' width='220' height='18' rx='9' fill='#7cf8ff'/>
    <rect x='1450' y='220' width='160' height='12' rx='6' fill='#1df2d0'/>
  </g>
  <rect width='1920' height='1080' fill='url(#g3)'/>
  <g opacity='0.13' stroke='#7cf8ff' stroke-width='1'>
    <path d='M0 760 H1920'/>
    <path d='M0 790 H1920'/>
    <path d='M0 820 H1920'/>
    <path d='M200 0 V1080'/>
    <path d='M960 0 V1080'/>
    <path d='M1710 0 V1080'/>
  </g>
</svg>
"@

$titleBg = @"
<svg xmlns='http://www.w3.org/2000/svg' width='1920' height='1080' viewBox='0 0 1920 1080'>
  <defs>
    <linearGradient id='sky' x1='0' y1='0' x2='0' y2='1'>
      <stop offset='0%' stop-color='#071017'/>
      <stop offset='55%' stop-color='#0f1b25'/>
      <stop offset='100%' stop-color='#020407'/>
    </linearGradient>
    <radialGradient id='moon' cx='50%' cy='40%' r='40%'>
      <stop offset='0%' stop-color='#9bf5ff' stop-opacity='0.9'/>
      <stop offset='100%' stop-color='#9bf5ff' stop-opacity='0'/>
    </radialGradient>
    <linearGradient id='forest' x1='0' y1='0' x2='0' y2='1'>
      <stop offset='0%' stop-color='#08140f'/>
      <stop offset='100%' stop-color='#020705'/>
    </linearGradient>
  </defs>
  <rect width='1920' height='1080' fill='url(#sky)'/>
  <ellipse cx='1520' cy='180' rx='260' ry='160' fill='url(#moon)'/>
  <rect x='0' y='770' width='1920' height='310' fill='url(#forest)'/>
  <g fill='#040907'>
    <path d='M40 1080 L120 650 L210 1080 Z'/>
    <path d='M180 1080 L260 620 L350 1080 Z'/>
    <path d='M360 1080 L450 610 L540 1080 Z'/>
    <path d='M580 1080 L660 660 L760 1080 Z'/>
    <path d='M1260 1080 L1360 600 L1460 1080 Z'/>
    <path d='M1440 1080 L1540 670 L1650 1080 Z'/>
    <path d='M1610 1080 L1705 640 L1810 1080 Z'/>
  </g>
  <g opacity='0.9'>
    <rect x='890' y='510' width='360' height='210' rx='18' fill='#081218' stroke='#7cf8ff' stroke-opacity='0.22' stroke-width='3'/>
    <rect x='930' y='470' width='280' height='70' rx='14' fill='#102431' stroke='#1df2d0' stroke-opacity='0.24' stroke-width='2'/>
    <rect x='1015' y='390' width='110' height='110' rx='12' fill='#0b2029' stroke='#b4fdff' stroke-opacity='0.3' stroke-width='3'/>
    <rect x='1010' y='405' width='120' height='12' rx='6' fill='#1df2d0' fill-opacity='0.55'/>
  </g>
  <g opacity='0.12' stroke='#7cf8ff' stroke-width='1'>
    <path d='M0 150 H1920'/>
    <path d='M0 320 H1920'/>
    <path d='M0 610 H1920'/>
  </g>
</svg>
"@

$platform = @"
<svg xmlns='http://www.w3.org/2000/svg' width='256' height='64' viewBox='0 0 256 64'>
  <defs>
    <linearGradient id='p1' x1='0' y1='0' x2='0' y2='1'>
      <stop offset='0%' stop-color='#162633'/>
      <stop offset='100%' stop-color='#0a1218'/>
    </linearGradient>
  </defs>
  <rect x='1' y='1' width='254' height='62' rx='12' fill='url(#p1)' stroke='#80fcff' stroke-opacity='0.22' stroke-width='2'/>
  <rect x='18' y='16' width='84' height='8' rx='4' fill='#80fcff' fill-opacity='0.35'/>
  <rect x='116' y='16' width='122' height='8' rx='4' fill='#1df2d0' fill-opacity='0.18'/>
  <rect x='18' y='38' width='220' height='6' rx='3' fill='#ffffff' fill-opacity='0.08'/>
</svg>
"@

$portal = @"
<svg xmlns='http://www.w3.org/2000/svg' width='220' height='260' viewBox='0 0 220 260'>
  <defs>
    <radialGradient id='core' cx='50%' cy='50%' r='50%'>
      <stop offset='0%' stop-color='#d7ffff' stop-opacity='1'/>
      <stop offset='45%' stop-color='#7cf8ff' stop-opacity='0.95'/>
      <stop offset='100%' stop-color='#13e4d5' stop-opacity='0.05'/>
    </radialGradient>
    <linearGradient id='ring' x1='0' y1='0' x2='1' y2='1'>
      <stop offset='0%' stop-color='#9afcff'/>
      <stop offset='100%' stop-color='#1df2d0'/>
    </linearGradient>
  </defs>
  <ellipse cx='110' cy='120' rx='58' ry='78' fill='url(#core)'/>
  <ellipse cx='110' cy='120' rx='78' ry='102' fill='none' stroke='url(#ring)' stroke-width='12' stroke-opacity='0.85'/>
  <ellipse cx='110' cy='120' rx='95' ry='118' fill='none' stroke='#d7ffff' stroke-opacity='0.14' stroke-width='2'/>
  <rect x='50' y='208' width='120' height='22' rx='11' fill='#0f2027' stroke='#7cf8ff' stroke-opacity='0.28' stroke-width='2'/>
  <rect x='72' y='228' width='76' height='16' rx='8' fill='#081218'/>
</svg>
"@

$door = @"
<svg xmlns='http://www.w3.org/2000/svg' width='180' height='280' viewBox='0 0 180 280'>
  <defs>
    <linearGradient id='d1' x1='0' y1='0' x2='0' y2='1'>
      <stop offset='0%' stop-color='#162636'/>
      <stop offset='100%' stop-color='#081018'/>
    </linearGradient>
  </defs>
  <rect x='20' y='8' width='140' height='264' rx='24' fill='#0b1219' stroke='#7cf8ff' stroke-opacity='0.2' stroke-width='4'/>
  <rect x='34' y='24' width='112' height='228' rx='18' fill='url(#d1)' stroke='#1df2d0' stroke-opacity='0.22' stroke-width='2'/>
  <rect x='56' y='44' width='68' height='110' rx='12' fill='#7cf8ff' fill-opacity='0.12'/>
  <rect x='56' y='182' width='68' height='18' rx='9' fill='#1df2d0' fill-opacity='0.4'/>
  <circle cx='128' cy='138' r='7' fill='#d9ffff' fill-opacity='0.8'/>
</svg>
"@

$console = @"
<svg xmlns='http://www.w3.org/2000/svg' width='190' height='220' viewBox='0 0 190 220'>
  <defs>
    <linearGradient id='c1' x1='0' y1='0' x2='0' y2='1'>
      <stop offset='0%' stop-color='#152532'/>
      <stop offset='100%' stop-color='#081118'/>
    </linearGradient>
  </defs>
  <path d='M66 12 H124 L146 70 V202 H44 V70 Z' fill='url(#c1)' stroke='#7cf8ff' stroke-opacity='0.22' stroke-width='3'/>
  <rect x='54' y='42' width='82' height='54' rx='12' fill='#0c2028' stroke='#1df2d0' stroke-opacity='0.34' stroke-width='2'/>
  <rect x='64' y='56' width='62' height='10' rx='5' fill='#7cf8ff' fill-opacity='0.55'/>
  <rect x='60' y='110' width='70' height='12' rx='6' fill='#ffffff' fill-opacity='0.08'/>
  <rect x='60' y='136' width='70' height='12' rx='6' fill='#ffffff' fill-opacity='0.08'/>
  <rect x='60' y='162' width='70' height='12' rx='6' fill='#ffffff' fill-opacity='0.08'/>
</svg>
"@

$orb = @"
<svg xmlns='http://www.w3.org/2000/svg' width='180' height='180' viewBox='0 0 180 180'>
  <defs>
    <radialGradient id='o1' cx='35%' cy='30%' r='65%'>
      <stop offset='0%' stop-color='#9bf5ff'/>
      <stop offset='35%' stop-color='#4fd7ff'/>
      <stop offset='100%' stop-color='#1a2d3b'/>
    </radialGradient>
  </defs>
  <circle cx='90' cy='90' r='72' fill='url(#o1)' stroke='#d7ffff' stroke-opacity='0.25' stroke-width='4'/>
  <path d='M42 94 C60 74 108 68 136 96' fill='none' stroke='#ffffff' stroke-opacity='0.18' stroke-width='7' stroke-linecap='round'/>
  <circle cx='62' cy='54' r='14' fill='#ffffff' fill-opacity='0.18'/>
</svg>
"@

$terminal = @"
<svg xmlns='http://www.w3.org/2000/svg' width='150' height='210' viewBox='0 0 150 210'>
  <defs>
    <linearGradient id='t1' x1='0' y1='0' x2='0' y2='1'>
      <stop offset='0%' stop-color='#183242'/>
      <stop offset='100%' stop-color='#081018'/>
    </linearGradient>
  </defs>
  <path d='M56 12 H94 L120 54 V198 H30 V54 Z' fill='url(#t1)' stroke='#7cf8ff' stroke-opacity='0.22' stroke-width='3'/>
  <rect x='42' y='44' width='66' height='88' rx='10' fill='#7cf8ff' fill-opacity='0.12' stroke='#1df2d0' stroke-opacity='0.22' stroke-width='2'/>
  <rect x='52' y='62' width='46' height='8' rx='4' fill='#a8ffff' fill-opacity='0.7'/>
  <rect x='52' y='80' width='36' height='6' rx='3' fill='#ffffff' fill-opacity='0.18'/>
  <rect x='52' y='95' width='40' height='6' rx='3' fill='#ffffff' fill-opacity='0.14'/>
</svg>
"@

$glow = @"
<svg xmlns='http://www.w3.org/2000/svg' width='256' height='256' viewBox='0 0 256 256'>
  <defs>
    <radialGradient id='g' cx='50%' cy='50%' r='50%'>
      <stop offset='0%' stop-color='#d7ffff' stop-opacity='1'/>
      <stop offset='40%' stop-color='#7cf8ff' stop-opacity='0.55'/>
      <stop offset='100%' stop-color='#1df2d0' stop-opacity='0'/>
    </radialGradient>
  </defs>
  <circle cx='128' cy='128' r='120' fill='url(#g)'/>
</svg>
"@

$playerIdle = @"
<svg xmlns='http://www.w3.org/2000/svg' width='160' height='220' viewBox='0 0 160 220'>
  <ellipse cx='82' cy='42' rx='20' ry='23' fill='#f0d0bf'/>
  <path d='M64 37 C70 12 108 10 111 42 C102 30 85 26 64 37 Z' fill='#13222e'/>
  <rect x='58' y='62' width='48' height='56' rx='18' fill='#e6f1ff'/>
  <path d='M46 78 L80 60 L114 78 L104 140 H56 Z' fill='#23435a'/>
  <rect x='69' y='72' width='22' height='46' rx='8' fill='#18cfd0'/>
  <rect x='42' y='80' width='16' height='56' rx='8' fill='#23435a'/>
  <rect x='104' y='80' width='16' height='56' rx='8' fill='#23435a'/>
  <rect x='58' y='136' width='18' height='50' rx='9' fill='#1e2d3a'/>
  <rect x='88' y='136' width='18' height='50' rx='9' fill='#1e2d3a'/>
  <rect x='52' y='182' width='28' height='16' rx='6' fill='#11181f'/>
  <rect x='84' y='182' width='28' height='16' rx='6' fill='#11181f'/>
  <path d='M104 84 L126 98 L114 120 L94 108 Z' fill='#ffb24b' fill-opacity='0.72'/>
</svg>
"@

$playerRun1 = @"
<svg xmlns='http://www.w3.org/2000/svg' width='160' height='220' viewBox='0 0 160 220'>
  <ellipse cx='82' cy='42' rx='20' ry='23' fill='#f0d0bf'/>
  <path d='M64 37 C70 12 108 10 111 42 C102 30 85 26 64 37 Z' fill='#13222e'/>
  <rect x='58' y='62' width='48' height='56' rx='18' fill='#e6f1ff'/>
  <path d='M46 78 L80 60 L114 78 L104 140 H56 Z' fill='#23435a'/>
  <rect x='69' y='72' width='22' height='46' rx='8' fill='#18cfd0'/>
  <rect x='38' y='84' width='16' height='50' rx='8' transform='rotate(-18 46 109)' fill='#23435a'/>
  <rect x='108' y='82' width='16' height='56' rx='8' transform='rotate(16 116 110)' fill='#23435a'/>
  <rect x='54' y='138' width='18' height='54' rx='9' transform='rotate(18 63 165)' fill='#1e2d3a'/>
  <rect x='90' y='136' width='18' height='48' rx='9' transform='rotate(-20 99 160)' fill='#1e2d3a'/>
  <rect x='46' y='182' width='28' height='16' rx='6' fill='#11181f'/>
  <rect x='92' y='176' width='28' height='16' rx='6' fill='#11181f'/>
  <path d='M104 84 L126 98 L114 120 L94 108 Z' fill='#ffb24b' fill-opacity='0.72'/>
</svg>
"@

$playerRun2 = @"
<svg xmlns='http://www.w3.org/2000/svg' width='160' height='220' viewBox='0 0 160 220'>
  <ellipse cx='82' cy='42' rx='20' ry='23' fill='#f0d0bf'/>
  <path d='M64 37 C70 12 108 10 111 42 C102 30 85 26 64 37 Z' fill='#13222e'/>
  <rect x='58' y='62' width='48' height='56' rx='18' fill='#e6f1ff'/>
  <path d='M46 78 L80 60 L114 78 L104 140 H56 Z' fill='#23435a'/>
  <rect x='69' y='72' width='22' height='46' rx='8' fill='#18cfd0'/>
  <rect x='42' y='82' width='16' height='56' rx='8' transform='rotate(18 50 110)' fill='#23435a'/>
  <rect x='104' y='84' width='16' height='50' rx='8' transform='rotate(-18 112 109)' fill='#23435a'/>
  <rect x='56' y='136' width='18' height='48' rx='9' transform='rotate(-20 65 160)' fill='#1e2d3a'/>
  <rect x='90' y='138' width='18' height='54' rx='9' transform='rotate(18 99 165)' fill='#1e2d3a'/>
  <rect x='50' y='176' width='28' height='16' rx='6' fill='#11181f'/>
  <rect x='88' y='182' width='28' height='16' rx='6' fill='#11181f'/>
  <path d='M104 84 L126 98 L114 120 L94 108 Z' fill='#ffb24b' fill-opacity='0.72'/>
</svg>
"@

$playerJump = @"
<svg xmlns='http://www.w3.org/2000/svg' width='160' height='220' viewBox='0 0 160 220'>
  <ellipse cx='82' cy='42' rx='20' ry='23' fill='#f0d0bf'/>
  <path d='M64 37 C70 12 108 10 111 42 C102 30 85 26 64 37 Z' fill='#13222e'/>
  <rect x='58' y='62' width='48' height='56' rx='18' fill='#e6f1ff'/>
  <path d='M46 78 L80 60 L114 78 L104 136 H56 Z' fill='#23435a'/>
  <rect x='69' y='72' width='22' height='42' rx='8' fill='#18cfd0'/>
  <rect x='40' y='82' width='16' height='48' rx='8' transform='rotate(-34 48 106)' fill='#23435a'/>
  <rect x='108' y='82' width='16' height='48' rx='8' transform='rotate(32 116 106)' fill='#23435a'/>
  <rect x='56' y='134' width='18' height='42' rx='9' transform='rotate(42 65 155)' fill='#1e2d3a'/>
  <rect x='88' y='134' width='18' height='42' rx='9' transform='rotate(-42 97 155)' fill='#1e2d3a'/>
  <rect x='46' y='164' width='28' height='16' rx='6' fill='#11181f'/>
  <rect x='92' y='164' width='28' height='16' rx='6' fill='#11181f'/>
  <path d='M104 84 L126 98 L114 120 L94 108 Z' fill='#ffb24b' fill-opacity='0.72'/>
</svg>
"@

$playerLand = @"
<svg xmlns='http://www.w3.org/2000/svg' width='160' height='220' viewBox='0 0 160 220'>
  <ellipse cx='82' cy='48' rx='20' ry='23' fill='#f0d0bf'/>
  <path d='M64 43 C70 18 108 16 111 48 C102 36 85 32 64 43 Z' fill='#13222e'/>
  <rect x='58' y='68' width='48' height='50' rx='18' fill='#e6f1ff'/>
  <path d='M46 84 L80 66 L114 84 L104 140 H56 Z' fill='#23435a'/>
  <rect x='69' y='78' width='22' height='40' rx='8' fill='#18cfd0'/>
  <rect x='44' y='86' width='16' height='50' rx='8' fill='#23435a'/>
  <rect x='100' y='86' width='16' height='50' rx='8' fill='#23435a'/>
  <rect x='54' y='136' width='22' height='42' rx='10' fill='#1e2d3a'/>
  <rect x='84' y='136' width='22' height='42' rx='10' fill='#1e2d3a'/>
  <rect x='48' y='174' width='32' height='18' rx='6' fill='#11181f'/>
  <rect x='82' y='174' width='32' height='18' rx='6' fill='#11181f'/>
  <path d='M104 88 L126 102 L114 122 L94 110 Z' fill='#ffb24b' fill-opacity='0.72'/>
</svg>
"@

Write-Svg 'assets/sprites/backgrounds/lab_backdrop.svg' $bgLab
Write-Svg 'assets/sprites/backgrounds/title_backdrop.svg' $titleBg
Write-Svg 'assets/sprites/world/platform_panel.svg' $platform
Write-Svg 'assets/sprites/world/portal_anchor.svg' $portal
Write-Svg 'assets/sprites/world/door_lab.svg' $door
Write-Svg 'assets/sprites/world/console_lab.svg' $console
Write-Svg 'assets/sprites/world/orb_blocker.svg' $orb
Write-Svg 'assets/sprites/world/clue_terminal.svg' $terminal
Write-Svg 'assets/sprites/fx/glow.svg' $glow
Write-Svg 'assets/sprites/player/player_idle.svg' $playerIdle
Write-Svg 'assets/sprites/player/player_run_1.svg' $playerRun1
Write-Svg 'assets/sprites/player/player_run_2.svg' $playerRun2
Write-Svg 'assets/sprites/player/player_jump.svg' $playerJump
Write-Svg 'assets/sprites/player/player_land.svg' $playerLand

New-WavTone -Path 'assets/audio/jump.wav' -Duration 0.18 -Generator {
    param($t, $d)
    $env = [Math]::Exp(-18 * $t)
    return ([Math]::Sin(2 * [Math]::PI * (430 - 220 * $t) * $t) * 0.45 * $env)
}

New-WavTone -Path 'assets/audio/interact.wav' -Duration 0.22 -Generator {
    param($t, $d)
    $env = [Math]::Exp(-14 * $t)
    return (([Math]::Sin(2 * [Math]::PI * 660 * $t) + [Math]::Sin(2 * [Math]::PI * 990 * $t) * 0.45) * 0.28 * $env)
}

New-WavTone -Path 'assets/audio/switch.wav' -Duration 0.85 -Generator {
    param($t, $d)
    $env = [Math]::Sin([Math]::PI * ($t / $d))
    $a = [Math]::Sin(2 * [Math]::PI * (150 + 210 * $t) * $t)
    $b = [Math]::Sin(2 * [Math]::PI * (410 - 90 * $t) * $t)
    return ($a * 0.22 + $b * 0.13) * $env
}

New-WavTone -Path 'assets/audio/success.wav' -Duration 1.0 -Generator {
    param($t, $d)
    $env = [Math]::Exp(-2.2 * $t)
    $n1 = [Math]::Sin(2 * [Math]::PI * 523.25 * $t)
    $n2 = [Math]::Sin(2 * [Math]::PI * 659.25 * $t)
    $n3 = [Math]::Sin(2 * [Math]::PI * 783.99 * $t)
    return ($n1 * 0.18 + $n2 * 0.18 + $n3 * 0.18) * $env
}

New-WavTone -Path 'assets/audio/fail.wav' -Duration 1.1 -Generator {
    param($t, $d)
    $env = [Math]::Exp(-2.8 * $t)
    $s = [Math]::Sin(2 * [Math]::PI * (220 - 60 * $t) * $t)
    $w = [Math]::Sin(2 * [Math]::PI * 52 * $t) * 0.35
    return ($s * 0.25 + $w * 0.14) * $env
}

New-WavTone -Path 'assets/audio/ambient_hum.wav' -Duration 12.0 -Generator {
    param($t, $d)
    $mod = 0.68 + 0.22 * [Math]::Sin(2 * [Math]::PI * 0.12 * $t)
    $hum = [Math]::Sin(2 * [Math]::PI * 55 * $t) * 0.18
    $air = [Math]::Sin(2 * [Math]::PI * 110 * $t) * 0.05
    $tone = [Math]::Sin(2 * [Math]::PI * 165 * $t) * 0.03
    return ($hum + $air + $tone) * $mod
}

New-WavTone -Path 'assets/audio/lab_theme.wav' -Duration 24.0 -Generator {
    param($t, $d)
    $pulse = 0.62 + 0.26 * [Math]::Sin(2 * [Math]::PI * 0.25 * $t)
    $pad = [Math]::Sin(2 * [Math]::PI * 110 * $t) * 0.10
    $fifth = [Math]::Sin(2 * [Math]::PI * 164.81 * $t) * 0.08
    $octave = [Math]::Sin(2 * [Math]::PI * 220 * $t) * 0.05
    $spark = [Math]::Sin(2 * [Math]::PI * 330 * $t + [Math]::Sin(2 * [Math]::PI * 0.18 * $t)) * 0.03
    return ($pad + $fifth + $octave + $spark) * $pulse
}
