#!/usr/bin/env python3
"""
Simple script to create a woman/mother app icon for Safe Mother Malawi
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_app_icon():
    # Create a 512x512 image with a nice background color
    size = 512
    img = Image.new('RGBA', (size, size), (33, 150, 243, 255))  # Material Blue
    draw = ImageDraw.Draw(img)
    
    # Draw a simple woman/mother silhouette
    center_x, center_y = size // 2, size // 2
    
    # Head (circle)
    head_radius = 60
    head_top = center_y - 120
    draw.ellipse([
        center_x - head_radius, head_top,
        center_x + head_radius, head_top + head_radius * 2
    ], fill='white')
    
    # Body (rounded rectangle)
    body_width = 80
    body_height = 140
    body_top = head_top + head_radius * 2 - 10
    draw.rounded_rectangle([
        center_x - body_width // 2, body_top,
        center_x + body_width // 2, body_top + body_height
    ], radius=20, fill='white')
    
    # Arms
    arm_width = 25
    arm_length = 80
    # Left arm
    draw.rounded_rectangle([
        center_x - body_width // 2 - arm_width, body_top + 20,
        center_x - body_width // 2, body_top + 20 + arm_length
    ], radius=12, fill='white')
    # Right arm
    draw.rounded_rectangle([
        center_x + body_width // 2, body_top + 20,
        center_x + body_width // 2 + arm_width, body_top + 20 + arm_length
    ], radius=12, fill='white')
    
    # Baby (small circle in arms)
    baby_radius = 20
    baby_x = center_x + 15
    baby_y = body_top + 50
    draw.ellipse([
        baby_x - baby_radius, baby_y - baby_radius,
        baby_x + baby_radius, baby_y + baby_radius
    ], fill='#FFB74D')  # Light orange for baby
    
    # Heart symbol (for care/love)
    heart_size = 30
    heart_x = center_x - 40
    heart_y = body_top + 30
    
    # Simple heart shape using circles and triangle
    draw.ellipse([heart_x - 10, heart_y, heart_x + 10, heart_y + 15], fill='#E91E63')  # Pink
    draw.ellipse([heart_x + 5, heart_y, heart_x + 25, heart_y + 15], fill='#E91E63')
    draw.polygon([
        (heart_x - 8, heart_y + 12),
        (heart_x + 23, heart_y + 12),
        (heart_x + 7.5, heart_y + 25)
    ], fill='#E91E63')
    
    return img

def main():
    # Create the main app icon
    icon = create_app_icon()
    
    # Save as PNG
    assets_dir = "assets/images"
    os.makedirs(assets_dir, exist_ok=True)
    
    # Save main icon
    icon.save(f"{assets_dir}/app_icon.png", "PNG")
    
    # Create foreground version (for adaptive icon)
    # Make background transparent for adaptive icon
    foreground = Image.new('RGBA', (512, 512), (0, 0, 0, 0))
    draw = ImageDraw.Draw(foreground)
    
    # Same drawing but on transparent background
    center_x, center_y = 256, 256
    
    # Head
    head_radius = 50
    head_top = center_y - 100
    draw.ellipse([
        center_x - head_radius, head_top,
        center_x + head_radius, head_top + head_radius * 2
    ], fill='white')
    
    # Body
    body_width = 70
    body_height = 120
    body_top = head_top + head_radius * 2 - 10
    draw.rounded_rectangle([
        center_x - body_width // 2, body_top,
        center_x + body_width // 2, body_top + body_height
    ], radius=18, fill='white')
    
    # Arms
    arm_width = 22
    arm_length = 70
    draw.rounded_rectangle([
        center_x - body_width // 2 - arm_width, body_top + 18,
        center_x - body_width // 2, body_top + 18 + arm_length
    ], radius=11, fill='white')
    draw.rounded_rectangle([
        center_x + body_width // 2, body_top + 18,
        center_x + body_width // 2 + arm_width, body_top + 18 + arm_length
    ], radius=11, fill='white')
    
    # Baby
    baby_radius = 18
    baby_x = center_x + 12
    baby_y = body_top + 45
    draw.ellipse([
        baby_x - baby_radius, baby_y - baby_radius,
        baby_x + baby_radius, baby_y + baby_radius
    ], fill='#FFB74D')
    
    # Heart
    heart_x = center_x - 35
    heart_y = body_top + 25
    draw.ellipse([heart_x - 8, heart_y, heart_x + 8, heart_y + 12], fill='#E91E63')
    draw.ellipse([heart_x + 4, heart_y, heart_x + 20, heart_y + 12], fill='#E91E63')
    draw.polygon([
        (heart_x - 6, heart_y + 10),
        (heart_x + 18, heart_y + 10),
        (heart_x + 6, heart_y + 20)
    ], fill='#E91E63')
    
    foreground.save(f"{assets_dir}/app_icon_foreground.png", "PNG")
    
    print("✅ App icons created successfully!")
    print(f"   - Main icon: {assets_dir}/app_icon.png")
    print(f"   - Foreground: {assets_dir}/app_icon_foreground.png")

if __name__ == "__main__":
    main()