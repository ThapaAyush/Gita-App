Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Users\Ayush Thapa\.gemini\antigravity\brain\63bf444f-d943-47d2-a531-5f7e31344cac\.user_uploaded\media_1794030687936_3e843042.jpg"
$src = [System.Drawing.Image]::FromFile($srcPath)
Write-Host "Source Dimensions: $($src.Width) x $($src.Height)"

# Create a clean high-res master bitmap with transparency (512x512)
$masterSize = 512
$master = New-Object System.Drawing.Bitmap($masterSize, $masterSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($master)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.Clear([System.Drawing.Color]::Transparent)

# Find circle boundary - in the image, the circle is centered and occupies ~74% of the image
# Let's inspect the crop. Let's draw the source image scaled, or clip to the circle.
# Let's see: in media_1794030687936_3e843042.jpg, the circle diameter is approximately 740px in a 1024x1024 image.
# If we crop to the circle boundary, the logo will fill the entire icon nicely!
$g.DrawImage($src, 0, 0, $masterSize, $masterSize)
$g.Dispose()

$testOut = "D:\Bhagavad gita as it is\assets\images\test_logo.png"
$master.Save($testOut, [System.Drawing.Imaging.ImageFormat]::Png)
$master.Dispose()
$src.Dispose()
Write-Host "Saved test_logo.png"

