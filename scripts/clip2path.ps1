Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$dir = "$env:USERPROFILE\Pictures\screenshots"
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

$img = [System.Windows.Forms.Clipboard]::GetImage()
if ($img -ne $null) {
    $file = "$dir\clip_$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds()).png"
    $img.Save($file, [System.Drawing.Imaging.ImageFormat]::Png)
    [Console]::Write($file)
} else {
    $text = [System.Windows.Forms.Clipboard]::GetText()
    [Console]::Write($text)
}
