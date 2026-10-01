import os
import math
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

REPO_DIR = r"d:\MyProgrammingProjects\DotnetProjects\ProjectHub.Api"
SC_DIR = os.path.join(REPO_DIR, "docs", "assets", "screenshots")
OUT_DIR = os.path.join(REPO_DIR, "docs", "assets")
MOCKUPS_DIR = os.path.join(SC_DIR, "mockups")

# Canvas dimensions: 2560 x 1440 (16:9, Retina sharpness)
W, H = 2560, 1440

def find_coeffs(dst, src):
    matrix = []
    for p1, p2 in zip(dst, src):
        matrix.append([p1[0], p1[1], 1, 0, 0, 0, -p2[0]*p1[0], -p2[0]*p1[1]])
        matrix.append([0, 0, 0, p1[0], p1[1], 1, -p2[1]*p1[0], -p2[1]*p1[1]])
    A = np.matrix(matrix, dtype=float)
    B = np.array(src).reshape(8)
    res = np.dot(np.linalg.inv(A.T * A) * A.T, B)
    return np.array(res).reshape(8)

def create_background():
    """Creates a dark, futuristic studio background with ambient glow and perspective grid."""
    base = np.zeros((H, W, 4), dtype=np.uint8)
    for y in range(H):
        t = y / H
        r = int(10 * (1 - t) + 4 * t)
        g = int(14 * (1 - t) + 7 * t)
        b = int(26 * (1 - t) + 16 * t)
        base[y, :, 0] = r
        base[y, :, 1] = g
        base[y, :, 2] = b
        base[y, :, 3] = 255
    bg = Image.fromarray(base, mode="RGBA")
    
    # Top-Left Violet Bloom: (129, 140, 248)
    bloom_violet = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw_v = ImageDraw.Draw(bloom_violet)
    for r in range(850, 0, -25):
        alpha = int(48 * (1 - r / 850)**2)
        draw_v.ellipse([-150 - r, -150 - r, 380 + r, 380 + r], fill=(129, 140, 248, alpha))
    bloom_violet = bloom_violet.filter(ImageFilter.GaussianBlur(70))
    bg = Image.alpha_composite(bg, bloom_violet)
    
    # Bottom-Right Cyan Bloom: (56, 189, 248)
    bloom_cyan = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw_c = ImageDraw.Draw(bloom_cyan)
    for r in range(950, 0, -30):
        alpha = int(48 * (1 - r / 950)**2)
        draw_c.ellipse([W + 120 - r, H + 120 - r, W + 120 + r, H + 120 + r], fill=(56, 189, 248, alpha))
    bloom_cyan = bloom_cyan.filter(ImageFilter.GaussianBlur(80))
    bg = Image.alpha_composite(bg, bloom_cyan)

    # Center Hero Ambient Glow (Indigo / Violet)
    center_glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw_cg = ImageDraw.Draw(center_glow)
    for r in range(640, 0, -25):
        alpha = int(45 * (1 - r / 640)**1.5)
        draw_cg.ellipse([W//2 - r, 740 - int(r*0.62), W//2 + r, 740 + int(r*0.62)], fill=(99, 102, 241, alpha))
    center_glow = center_glow.filter(ImageFilter.GaussianBlur(65))
    bg = Image.alpha_composite(bg, center_glow)

    # Cyberpunk Perspective Floor Grid (Bottom half)
    grid_img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw_grid = ImageDraw.Draw(grid_img)
    horizon_y = 650
    for i in range(1, 19):
        y = horizon_y + int(math.pow(i / 18.0, 2.2) * (H - horizon_y + 120))
        if y < H:
            t = (y - horizon_y) / (H - horizon_y)
            alpha = int(26 * t)
            draw_grid.line([(0, y), (W, y)], fill=(99, 140, 248, alpha), width=1)
    
    center_x = W // 2
    for x in range(-W, W * 2, 70):
        alpha = 18
        draw_grid.line([(center_x + (x - center_x) * 0.05, horizon_y), (x, H)], fill=(56, 189, 248, alpha), width=1)
    bg = Image.alpha_composite(bg, grid_img)

    # Subtle Dot Matrix Background (Upper area)
    dots_img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw_dots = ImageDraw.Draw(dots_img)
    for gx in range(40, W, 45):
        for gy in range(40, horizon_y + 80, 45):
            dist_center = math.hypot(gx - W/2, gy - 360)
            if dist_center < 700:
                alpha = int(16 * (1 - dist_center / 700))
            else:
                alpha = 5
            draw_dots.ellipse([gx - 1.5, gy - 1.5, gx + 1.5, gy + 1.5], fill=(148, 163, 184, alpha))
    bg = Image.alpha_composite(bg, dots_img)

    return bg

def create_pixel_phone_mockup(screenshot_path, target_h=780, accent_glow=None):
    """
    Renders the screenshot inside an authentic Google Pixel phone frame:
    - Centered circular punch-hole selfie camera
    - Slim, uniform Pixel bezels with smooth curved corners
    - Clean dark obsidian matte frame
    """
    sc = Image.open(screenshot_path).convert("RGBA")
    sc_w, sc_h = sc.size
    aspect = sc_w / sc_h
    
    screen_h = target_h
    screen_w = int(screen_h * aspect)
    
    # Modern Google Pixel has slim, balanced bezels
    bezel_lr = max(8, int(screen_w * 0.028))
    bezel_tb = max(9, int(screen_h * 0.014))
    
    phone_w = screen_w + bezel_lr * 2
    phone_h = screen_h + bezel_tb * 2
    phone_radius = int(phone_w * 0.105)
    screen_radius = int(phone_radius * 0.84)
    
    # 1. Resize screenshot with Lanczos resampling for maximum sharpness
    resized_sc = sc.resize((screen_w, screen_h), Image.Resampling.LANCZOS)
    
    # Screen mask with rounded corners
    screen_mask = Image.new("L", (screen_w, screen_h), 0)
    draw_smask = ImageDraw.Draw(screen_mask)
    draw_smask.rounded_rectangle([0, 0, screen_w, screen_h], radius=screen_radius, fill=255)
    
    # 2. Google Pixel Centered Circular Camera Punch Hole
    cam_r = max(5, int(screen_w * 0.020))
    cam_x = screen_w // 2
    cam_y = max(8, int(screen_h * 0.027))
    
    draw_camera = ImageDraw.Draw(resized_sc)
    # Subtle dark outer camera ring
    draw_camera.ellipse([cam_x - cam_r - 1, cam_y - cam_r - 1, cam_x + cam_r + 1, cam_y + cam_r + 1], 
                        fill=(16, 20, 28, 255))
    # Deep camera aperture circle
    draw_camera.ellipse([cam_x - cam_r, cam_y - cam_r, cam_x + cam_r, cam_y + cam_r], 
                        fill=(5, 7, 12, 255))
    # Subtle optical sensor reflection highlight
    dot_r = max(1, cam_r // 3)
    draw_camera.ellipse([cam_x - dot_r, cam_y - cam_r // 2 - dot_r, cam_x + dot_r, cam_y - cam_r // 2 + dot_r], 
                        fill=(35, 55, 85, 170))
    
    # Subtle screen glass reflection overlay
    sheen = Image.new("RGBA", (screen_w, screen_h), (0, 0, 0, 0))
    draw_sheen = ImageDraw.Draw(sheen)
    draw_sheen.polygon([(0, 0), (screen_w, 0), (0, int(screen_h * 0.40))], fill=(255, 255, 255, 10))
    resized_sc = Image.alpha_composite(resized_sc, sheen)
    
    # 3. Outer Google Pixel phone chassis
    phone_canvas = Image.new("RGBA", (phone_w, phone_h), (0, 0, 0, 0))
    draw_phone = ImageDraw.Draw(phone_canvas)
    
    # Sleek dark obsidian aluminum/matte finish
    draw_phone.rounded_rectangle([0, 0, phone_w - 1, phone_h - 1], radius=phone_radius, fill=(20, 24, 34, 255))
    draw_phone.rounded_rectangle([1, 1, phone_w - 2, phone_h - 2], radius=phone_radius - 1, outline=(48, 60, 80, 230), width=1)
    
    if accent_glow:
        draw_phone.rounded_rectangle([0, 0, phone_w - 1, phone_h - 1], radius=phone_radius, outline=(*accent_glow, 160), width=2)
    
    phone_canvas.paste(resized_sc, (bezel_lr, bezel_tb), mask=screen_mask)
    
    # Soft drop shadow
    pad = 110
    total_w = phone_w + pad * 2
    total_h = phone_h + pad * 2
    phone_with_shadow = Image.new("RGBA", (total_w, total_h), (0, 0, 0, 0))
    
    shadow_img = Image.new("RGBA", (total_w, total_h), (0, 0, 0, 0))
    draw_shadow = ImageDraw.Draw(shadow_img)
    draw_shadow.rounded_rectangle([pad + 4, pad + 18, pad + phone_w - 4, pad + phone_h + 30], 
                                  radius=phone_radius, fill=(0, 0, 0, 185))
    shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(38))
    
    if accent_glow:
        glow_layer = Image.new("RGBA", (total_w, total_h), (0, 0, 0, 0))
        draw_gl = ImageDraw.Draw(glow_layer)
        draw_gl.ellipse([pad - 25, pad + phone_h - 35, pad + phone_w + 25, pad + phone_h + 75], fill=(*accent_glow, 85))
        glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(42))
        phone_with_shadow = Image.alpha_composite(phone_with_shadow, glow_layer)
        
    phone_with_shadow = Image.alpha_composite(phone_with_shadow, shadow_img)
    phone_with_shadow.paste(phone_canvas, (pad, pad), mask=phone_canvas)
    
    return phone_with_shadow, phone_w, phone_h, pad, phone_canvas

def transform_phone(img, pad, pw, ph, tilt_mode, strength=0.08):
    if tilt_mode == "center":
        return img
    
    w, h = img.size
    cx0, cy0 = pad, pad
    cx1, cy1 = pad + pw, pad + ph
    
    dy = int(ph * strength)
    dx = int(pw * (strength * 0.6))
    
    if "left" in tilt_mode:
        dst = [
            (cx0, cy0 - dy//2),
            (cx1 - dx, cy0 + dy//2),
            (cx1 - dx, cy1 - dy//2),
            (cx0, cy1 + dy//2)
        ]
    else:
        dst = [
            (cx0 + dx, cy0 + dy//2),
            (cx1, cy0 - dy//2),
            (cx1, cy1 + dy//2),
            (cx0 + dx, cy1 - dy//2)
        ]
        
    src = [(cx0, cy0), (cx1, cy0), (cx1, cy1), (cx0, cy1)]
    coeffs = find_coeffs(dst, src)
    return img.transform((w, h), Image.Transform.PERSPECTIVE, coeffs, Image.Resampling.BICUBIC)

def build_banner():
    os.makedirs(OUT_DIR, exist_ok=True)
    os.makedirs(MOCKUPS_DIR, exist_ok=True)
    
    bg = create_background()
    transparent_canvas = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    
    # 7 Pure Dark Google Pixel Mockups
    # Drawing order: outer first, inner second, hero center last (on top)
    screens_config = [
        # (filename, target_h, tilt_mode, strength, center_x, center_y, accent_glow, mockup_name)
        ("05_modal_switch_workspace.png", 660, "left_outer",  0.110,  390,  755, (129, 140, 248), "01_switch_workspace"),
        ("09_modal_create_task.png",      660, "right_outer", 0.110, 2170,  755, (168, 85, 247),  "07_create_task"),
        ("02_presence_and_stream.png",    710, "left_mid",    0.075,  680,  740, (16, 185, 129),  "02_activity_stream"),
        ("08_modal_task_details.png",     710, "right_mid",   0.075, 1880,  740, (236, 72, 153),  "06_task_details"),
        ("01_dashboard_overview.png",     760, "left_inner",  0.045,  970,  730, (99, 102, 241),  "03_dashboard"),
        ("06_projects_list.png",          760, "right_inner", 0.045, 1590,  730, (59, 130, 246),  "05_projects_list"),
        ("07_kanban_board.png",           820, "center",      0.000, 1280,  720, (56, 189, 248),  "04_kanban_hero"),
    ]
    
    for fname, target_h, tilt_mode, strength, cx, cy, accent_glow, m_name in screens_config:
        fpath = os.path.join(SC_DIR, fname)
        if not os.path.exists(fpath):
            print(f"Warning: File not found: {fpath}")
            continue
            
        mockup_with_shadow, pw, ph, pad, standalone_phone = create_pixel_phone_mockup(
            fpath, target_h=target_h, accent_glow=accent_glow
        )
        
        # Save individual standalone mockup for Canva flexible use
        standalone_phone.save(os.path.join(MOCKUPS_DIR, f"{m_name}_mockup.png"), "PNG")
        
        # Transform for 3D perspective
        transformed = transform_phone(mockup_with_shadow, pad, pw, ph, tilt_mode, strength=strength)
        
        tw, th = transformed.size
        px = cx - tw // 2
        py = cy - th // 2
        
        # Paste onto dark background banner
        bg.paste(transformed, (px, py), mask=transformed)
        # Paste onto transparent banner
        transparent_canvas.paste(transformed, (px, py), mask=transformed)
        
        print(f"Placed Google Pixel frame: {fname} [{tilt_mode}] at ({cx}, {cy})")

    # Save output images - NO text, NO titles, NO badges (pure screens for Canva editing)
    banner_png = os.path.join(OUT_DIR, "projecthub_banner.png")
    banner_transparent_png = os.path.join(OUT_DIR, "projecthub_banner_transparent.png")
    banner_jpg = os.path.join(OUT_DIR, "projecthub_banner.jpg")
    
    bg.save(banner_png, "PNG", optimize=True)
    transparent_canvas.save(banner_transparent_png, "PNG", optimize=True)
    
    rgb_banner = bg.convert("RGB")
    rgb_banner.save(banner_jpg, "JPEG", quality=95)
    
    print("\nSuccessfully generated:")
    print(f"1. Main Dark Banner: {banner_png}")
    print(f"2. Transparent Banner: {banner_transparent_png}")
    print(f"3. High-Quality JPEG: {banner_jpg}")
    print(f"4. Individual Mockups saved to: {MOCKUPS_DIR}")

if __name__ == "__main__":
    build_banner()
