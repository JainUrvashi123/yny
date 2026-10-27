Add-Type -AssemblyName System.Drawing
$dir = "C:\Users\Web\Documents\idca_app (2)\idca_app\assets\images"
foreach ($name in @('tone-banner.jpg', 'ttwo-banner.jpg', 'tthree.jpg', 'tfour.jpg')) {
    $path = Join-Path $dir $name
    $img = [System.Drawing.Image]::FromFile($path)
    $ratio = [Math]::Round($img.Width / $img.Height, 2)
    Write-Host "$name : $($img.Width) x $($img.Height) (Ratio: $ratio)"
    $img.Dispose()
}
