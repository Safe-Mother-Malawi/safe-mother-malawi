# Safe Mother Malawi Logo Generator
# This script creates proper PNG logo files to replace the corrupted ones

Add-Type -AssemblyName System.Drawing

function Create-Logo {
    param(
        [string]$FilePath,
        [bool]$IsDarkBackground,
        [int]$Size = 512
    )
    
    # Create bitmap and graphics
    $bitmap = New-Object System.Drawing.Bitmap($Size, $Size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    
    # Colors
    if ($IsDarkBackground) {
        $bgColor = [System.Drawing.Color]::FromArgb(200, 255, 255, 255)  # Semi-transparent white
        $textColor = [System.Drawing.Color]::FromArgb(255, 233, 30, 140)  # Pink
        $heartColor = [System.Drawing.Color]::FromArgb(255, 233, 30, 140) # Pink
    } else {
        $bgColor = [System.Drawing.Color]::FromArgb(50, 233, 30, 140)     # Light pink
        $textColor = [System.Drawing.Color]::FromArgb(255, 233, 30, 140)  # Pink
        $heartColor = [System.Drawing.Color]::FromArgb(255, 233, 30, 140) # Pink
    }
    
    # Calculate dimensions
    $centerX = $Size / 2
    $centerY = $Size / 2
    $radius = $Size * 0.4
    
    # Draw background circle
    $bgBrush = New-Object System.Drawing.SolidBrush($bgColor)
    $textPen = New-Object System.Drawing.Pen($textColor, 6)
    
    $circleRect = New-Object System.Drawing.Rectangle(
        ($centerX - $radius), 
        ($centerY - $radius), 
        ($radius * 2), 
        ($radius * 2)
    )
    
    $graphics.FillEllipse($bgBrush, $circleRect)
    $graphics.DrawEllipse($textPen, $circleRect)
    
    # Draw heart shape (simplified as circle for PowerShell limitations)
    $heartBrush = New-Object System.Drawing.SolidBrush($heartColor)
    $heartSize = $Size * 0.15
    $heartRect = New-Object System.Drawing.Rectangle(
        ($centerX - $heartSize/2),
        ($centerY - $heartSize/2 - $Size * 0.05),
        $heartSize,
        $heartSize
    )
    $graphics.FillEllipse($heartBrush, $heartRect)
    
    # Draw mother figure (simplified)
    $figureColor = if ($IsDarkBackground) { 
        [System.Drawing.Color]::FromArgb(180, 255, 255, 255) 
    } else { 
        [System.Drawing.Color]::FromArgb(180, 233, 30, 140) 
    }
    $figureBrush = New-Object System.Drawing.SolidBrush($figureColor)
    
    # Mother head
    $motherHeadRect = New-Object System.Drawing.Rectangle(
        ($centerX - $Size * 0.15),
        ($centerY + $Size * 0.05),
        ($Size * 0.08),
        ($Size * 0.08)
    )
    $graphics.FillEllipse($figureBrush, $motherHeadRect)
    
    # Baby head
    $babyHeadRect = New-Object System.Drawing.Rectangle(
        ($centerX + $Size * 0.08),
        ($centerY + $Size * 0.08),
        ($Size * 0.06),
        ($Size * 0.06)
    )
    $graphics.FillEllipse($figureBrush, $babyHeadRect)
    
    # Draw text
    $font = New-Object System.Drawing.Font("Arial", ($Size * 0.08), [System.Drawing.FontStyle]::Bold)
    $textBrush = New-Object System.Drawing.SolidBrush($textColor)
    $textFormat = New-Object System.Drawing.StringFormat
    $textFormat.Alignment = [System.Drawing.StringAlignment]::Center
    $textFormat.LineAlignment = [System.Drawing.StringAlignment]::Center
    
    $textRect = New-Object System.Drawing.Rectangle(0, ($centerY + $radius * 0.5), $Size, ($Size * 0.15))
    $graphics.DrawString("Safe Mother", $font, $textBrush, $textRect, $textFormat)
    
    # Draw subtitle
    $subtitleFont = New-Object System.Drawing.Font("Arial", ($Size * 0.04), [System.Drawing.FontStyle]::Regular)
    $subtitleColor = if ($IsDarkBackground) {
        [System.Drawing.Color]::FromArgb(200, 255, 255, 255)
    } else {
        [System.Drawing.Color]::FromArgb(200, 233, 30, 140)
    }
    $subtitleBrush = New-Object System.Drawing.SolidBrush($subtitleColor)
    $subtitleRect = New-Object System.Drawing.Rectangle(0, ($centerY + $radius * 0.7), $Size, ($Size * 0.1))
    $graphics.DrawString("Malawi", $subtitleFont, $subtitleBrush, $subtitleRect, $textFormat)
    
    # Save the image
    $bitmap.Save($FilePath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Cleanup
    $graphics.Dispose()
    $bitmap.Dispose()
    $bgBrush.Dispose()
    $textPen.Dispose()
    $heartBrush.Dispose()
    $figureBrush.Dispose()
    $font.Dispose()
    $textBrush.Dispose()
    $subtitleFont.Dispose()
    $subtitleBrush.Dispose()
    
    Write-Host "Created: $FilePath" -ForegroundColor Green
}

# Main execution
Write-Host "Safe Mother Malawi Logo Generator" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Ensure assets/logo directory exists
$logoDir = "assets/logo"
if (!(Test-Path $logoDir)) {
    New-Item -ItemType Directory -Path $logoDir -Force
    Write-Host "Created directory: $logoDir" -ForegroundColor Yellow
}

# Create the logo files
try {
    Write-Host "`nGenerating logo files..." -ForegroundColor Yellow
    
    # LOGO5.png - For dark backgrounds
    Create-Logo -FilePath "$logoDir/LOGO5.png" -IsDarkBackground $true
    
    # LOGO6.png - For light backgrounds  
    Create-Logo -FilePath "$logoDir/LOGO6.png" -IsDarkBackground $false
    
    # logo 4.png - General purpose
    Create-Logo -FilePath "$logoDir/logo 4.png" -IsDarkBackground $false
    
    Write-Host "`nAll logo files created successfully!" -ForegroundColor Green
    Write-Host "Files created in $logoDir/:" -ForegroundColor White
    Write-Host "  - LOGO5.png (for dark backgrounds)" -ForegroundColor White
    Write-Host "  - LOGO6.png (for light backgrounds)" -ForegroundColor White
    Write-Host "  - logo 4.png (general purpose)" -ForegroundColor White
    
    # Verify files were created
    Write-Host "`nVerifying files..." -ForegroundColor Yellow
    Get-ChildItem "$logoDir/*.png" | ForEach-Object {
        $size = [math]::Round($_.Length / 1KB, 2)
        Write-Host "  ✓ $($_.Name) - ${size} KB" -ForegroundColor Green
    }
    
} catch {
    Write-Host "Error creating logo files: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`nLogo restoration complete! 🎉" -ForegroundColor Green