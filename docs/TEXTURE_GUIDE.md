# Nexumi Texture and Asset Guide

This guide explains how to obtain and set up textures for your Nexumi MMORPG project.

## 🎨 **Current Texture System**

The game uses a `TextureManager` that automatically loads textures and creates placeholder sprites. Currently, colored placeholders are used, but you can replace them with actual pixel art.

## 📥 **Where to Get Textures**

### **1. Free Godot Demo Assets**

**Best Source**: Godot's official demo projects contain high-quality pixel art assets.

#### Download Links:
- **Main Repository**: https://github.com/godotengine/godot-demo-projects
- **Pixel Platformer**: https://github.com/godotengine/godot-demo-projects/tree/master/2d/pixel_platformer
- **Isometric Game**: https://github.com/godotengine/godot-demo-projects/tree/master/2d/isometric_game

#### How to Download:
```bash
# Clone the entire repository
git clone https://github.com/godotengine/godot-demo-projects.git

# Or download specific demo as ZIP from GitHub
```

### **2. Free Pixel Art Resources**

#### **OpenGameArt.org**
- Website: https://opengameart.org/
- Filter by: "Pixel Art" + "CC0" or "CC-BY"
- Great for tiles, characters, items

#### **Itch.io Free Assets**
- Website: https://itch.io/game-assets/free
- Search: "pixel art", "16x16", "32x32"
- Many free tilesets and character sprites

#### **Kenney Assets**
- Website: https://www.kenney.nl/assets
- All assets are CC0 (public domain)
- Excellent pixel art game assets

### **3. Paid Premium Assets**

#### **Humble Bundle**
- Regular game asset bundles
- High-quality pixel art collections

#### **Unity Asset Store**
- Many assets work in any engine
- Look for "2D" and "Pixel Art" categories

## 🗂️ **Asset Organization**

Place downloaded assets in the following folder structure:

```
assets/
├── sprites/
│   ├── world/          # Terrain blocks
│   │   ├── grass.png
│   │   ├── dirt.png
│   │   ├── stone.png
│   │   ├── sand.png
│   │   ├── water.png
│   │   └── ...
│   ├── items/          # Tools, weapons, consumables
│   │   ├── wooden_sword.png
│   │   ├── iron_sword.png
│   │   ├── wooden_axe.png
│   │   └── ...
│   ├── player/         # Character animations
│   │   ├── player_idle.png
│   │   ├── player_walk.png
│   │   └── player_spriteframes.tres
│   ├── ui/             # Interface elements
│   │   ├── button.png
│   │   ├── panel.png
│   │   └── ...
│   └── effects/        # Particles, magic effects
├── audio/
│   ├── sfx/           # Sound effects
│   └── music/         # Background music
└── materials/         # Additional textures
```

## ⚙️ **Texture Setup in Godot**

### **1. Import Settings**

For pixel-perfect graphics, set these import settings:

1. Select your texture in FileSystem
2. Go to Import tab
3. Set these options:
   - **Filter**: OFF (unchecked)
   - **Mipmaps**: OFF (unchecked)
   - **Texture → Min-Mag Filter**: Linear

### **2. Project Settings**

Go to Project → Project Settings → Rendering:

- **Textures → Filtering**: OFF
- **Snap 2D transforms to pixel**: ON
- **Snap 2D vertices to pixel**: ON

### **3. Camera Setup**

In your Camera2D node:
- Set **Zoom** to even numbers (2, 4, 6)
- Enable **Pixel Snap** in Camera2D settings

## 🎯 **Recommended Texture Sizes**

### **World Tiles**
- Standard: 32x32 pixels
- High-res: 64x64 pixels

### **Characters**
- Player: 24x32 pixels (width x height)
- NPCs: 16x16 to 32x32 pixels

### **Items**
- Icons: 16x16 or 32x32 pixels
- Tools/Weapons: 32x32 pixels

### **UI Elements**
- Buttons: 32x16 pixels
- Panels: 9-slice compatible
- Icons: 16x16 pixels

## 🔧 **Quick Setup Commands**

### **Download Godot Demos**
```bash
# Navigate to your project
cd /path/to/Nexumi

# Create assets directory
mkdir -p assets/sprites/{world,items,player,ui,effects}

# Download demos
git clone https://github.com/godotengine/godot-demo-projects.git temp_demos

# Copy relevant assets
cp temp_demos/2d/pixel_platformer/art/* assets/sprites/
cp temp_demos/2d/isometric_game/art/* assets/sprites/

# Clean up
rm -rf temp_demos
```

### **PowerShell (Windows)**
```powershell
# Navigate to project
cd C:\Users\rexbl\Documents\Nexumi

# Create directories
New-Item -ItemType Directory -Path assets\sprites\world, assets\sprites\items, assets\sprites\player, assets\sprites\ui -Force

# Download using git
git clone https://github.com/godotengine/godot-demo-projects.git temp_demos

# Copy assets (adjust paths as needed)
Copy-Item temp_demos\2d\pixel_platformer\art\* assets\sprites\ -Recurse

# Clean up
Remove-Item temp_demos -Recurse -Force
```

## 🎨 **Creating Custom Textures**

### **Recommended Tools**

#### **Free**
- **Aseprite** (open source version)
- **GIMP** with pixel art plugins
- **Piskel** (web-based)

#### **Paid**
- **Aseprite** (best for pixel art)
- **Photoshop** with pixel art workflow
- **GraphicsGale**

### **Basic Pixel Art Guidelines**

1. **Limited Color Palette**: Use 4-16 colors per sprite
2. **Consistent Light Source**: Keep lighting direction consistent
3. **Readable Silhouettes**: Sprites should be recognizable in silhouette
4. **Consistent Scale**: All sprites should use same pixel-to-unit ratio

## 🔄 **Updating Textures in Game**

The `TextureManager` automatically detects new textures. To add new assets:

1. Place files in appropriate `assets/sprites/` subfolder
2. Name files to match item IDs in `ItemDatabase.gd`
3. Restart the game or call `TextureManager.reload_textures()`

### **File Naming Convention**
```
world blocks: grass.png, dirt.png, stone.png
items: wooden_sword.png, iron_pickaxe.png
characters: player_spriteframes.tres
```

## 🐛 **Troubleshooting**

### **Blurry Textures**
- Check Import settings: Filter should be OFF
- Verify Camera zoom is even number
- Enable pixel snap settings

### **Missing Textures**
- Check file names match database IDs
- Verify files are in correct folders
- Check Godot import errors tab

### **Wrong Sizes**
- Resize textures to recommended dimensions
- Use nearest-neighbor scaling to maintain pixel art style

## 📋 **Asset Checklist**

### **Essential Assets Needed**
- [ ] Player character (8 directions: idle + walk)
- [ ] World blocks (grass, dirt, stone, sand, water)
- [ ] Basic tools (axe, pickaxe, sword)
- [ ] UI elements (buttons, panels, health bar)
- [ ] Trees and vegetation
- [ ] Resource nodes (ore, coal)

### **Optional but Recommended**
- [ ] Particle effects
- [ ] Sound effects
- [ ] Background music
- [ ] Additional character animations
- [ ] Building materials
- [ ] Furniture sprites

## 🌟 **Next Steps**

1. **Download demo assets** from Godot repository
2. **Set up folder structure** as shown above
3. **Configure import settings** for pixel-perfect rendering
4. **Test in game** to verify textures load correctly
5. **Gradually replace** placeholder textures with custom art

---

**Need Help?** 
- Check the Godot documentation on 2D pixel art
- Join the Godot Discord for asset recommendations
- Browse OpenGameArt.org for inspiration

Your game will look amazing with proper pixel art assets! 🎮✨ 