#!/usr/bin/env python3
"""
Create proper logo PNG files for Safe Mother Malawi
This script generates valid PNG files to replace the corrupted ones
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_logo(size, background_color, text_color, filename):
    """Create a Safe Mother Malawi logo"""
    # Create image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw background circle
    margin = size // 10
    circle_bbox = [margin, margin, size - margin, size - margin]
    draw.ellipse(circle_bbox, fill=background_color, outline=text_color, width=3)
    
    # Draw heart shape in center
    heart_size = size // 4
    heart_center = (size // 2, size // 2 - size // 8)
    
    # Simple heart using two circles and a triangle
    heart_color = text_color
    
    # Left circle of heart
    left_circle = [
        heart_center[0] - heart_size//2 - heart_size//4,
        heart_center[1] - heart_size//4,
        heart_center[0] - heart_size//4,
        heart_center[1] + heart_size//4
    ]
    draw.ellipse(left_circle, fill=heart_color)
    
    # Right circle of heart
    right_circle = [
        heart_center[0] + heart_size//4,
        heart_center[1] - heart_size//4,
        heart_center[0] + heart_size//2 + heart_size//4,
        heart_center[1] + heart_size//4
    ]
    draw.ellipse(right_circle, fill=heart_color)
    
    # Bottom triangle of heart
    triangle_points = [
        (heart_center[0], heart_center[1] + heart_size//2),
        (heart_center[0] - heart_size//2, heart_center[1]),
        (heart_center[0] + heart_size//2, heart_center[1])
    ]
    draw.polygon(triangle_points, fill=heart_color)
    
    # Add text
    try:
        # Try to use a nice font, fallback to default if not available
        font_size = size // 8
        font = ImageFont.truetype("arial.ttf", font_size)
    except:
        font = ImageFont.load_default()
    
    # Draw "Safe Mother" text
    text_y = size - size // 4
    
    # Calculate text position for centering
    text = "Safe Mother"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_x = (size - text_width) // 2
    
    draw.text((text_x, text_y), text, fill=text_color, font=font)
    
    # Save the image
    img.save(filename, 'PNG')
    print(f"Created {filename} ({size}x{size})")

def main():
    """Create the logo files"""
    # Ensure we're in the right directory
    logo_dir = "assets/logo"
    if not os.path.exists(logo_dir):
        os.makedirs(logo_dir)
    
    # Create LOGO5.png (for dark backgrounds - white/light colors)
    create_logo(
        size=512,
        background_color=(255, 255, 255, 200),  # Semi-transparent white
        text_color=(233, 30, 140, 255),         # Pink color
        filename=os.path.join(logo_dir, "LOGO5.png")
    )
    
    # Create LOGO6.png (for light backgrounds - dark colors)
    create_logo(
        size=512,
        background_color=(233, 30, 140, 50),    # Light pink background
        text_color=(233, 30, 140, 255),         # Dark pink text
        filename=os.path.join(logo_dir, "LOGO6.png")
    )
    
    # Create logo 4.png (general purpose)
    create_logo(
        size=512,
        background_color=(252, 228, 236, 255),  # Light pink background
        text_color=(233, 30, 140, 255),         # Pink text
        filename=os.path.join(logo_dir, "logo 4.png")
    )
    
    print("All logo files created successfully!")
    print("Files created:")
    print("- LOGO5.png (for dark backgrounds)")
    print("- LOGO6.png (for light backgrounds)")  
    print("- logo 4.png (general purpose)")

if __name__ == "__main__":
    main()