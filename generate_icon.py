#!/usr/bin/env python3
"""
Generate a simple app icon using the primary app color
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_app_icon():
    # App primary color (navy blue)
    primary_color = (0, 49, 120)  # #003178
    
    # Create a 1024x1024 image (high resolution for scaling)
    size = 1024
    image = Image.new('RGB', (size, size), primary_color)
    draw = ImageDraw.Draw(image)
    
    # Add a subtle gradient effect by drawing concentric circles
    center = size // 2
    max_radius = size // 2
    
    # Create a subtle radial gradient
    for i in range(max_radius, 0, -2):
        # Gradually lighten the color towards the center
        lightness = int(20 * (1 - i / max_radius))
        color = (
            min(255, primary_color[0] + lightness),
            min(255, primary_color[1] + lightness), 
            min(255, primary_color[2] + lightness)
        )
        draw.ellipse([center - i, center - i, center + i, center + i], fill=color)
    
    # Add a white "SM" text in the center (Safe Mother)
    try:
        # Try to use a system font
        font_size = size // 4
        font = ImageFont.truetype("arial.ttf", font_size)
    except:
        # Fallback to default font
        font = ImageFont.load_default()
    
    # Draw "SM" text
    text = "SM"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    text_x = (size - text_width) // 2
    text_y = (size - text_height) // 2
    
    # Add text shadow for better visibility
    shadow_offset = 4
    draw.text((text_x + shadow_offset, text_y + shadow_offset), text, 
              fill=(0, 0, 0, 128), font=font)
    
    # Draw main text in white
    draw.text((text_x, text_y), text, fill=(255, 255, 255), font=font)
    
    # Save the icon
    output_path = "assets/icon/app_icon.png"
    image.save(output_path, "PNG", quality=100)
    print(f"✅ App icon created: {output_path}")
    print(f"   Size: {size}x{size}")
    print(f"   Color: #{primary_color[0]:02x}{primary_color[1]:02x}{primary_color[2]:02x}")
    
    return output_path

if __name__ == "__main__":
    create_app_icon()