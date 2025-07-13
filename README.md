# Nexumi - The MMORPG Openworld Game

A cross-platform pixel-art MMORPG built with Godot 4.4 featuring crafting, building, survival, and multiplayer elements.

## 🎮 Game Features

### Core Systems
- **Building System**: Construct houses, blocks, weapons, crafts, and furniture
- **Boss Fights**: Epic encounters with challenging enemies
- **Inventory System**: Comprehensive item management with stacking and categories
- **Creative Mode**: Build and design custom maps
- **Survival Elements**: Resource management and environmental challenges
- **Multiplayer**: Local network and hotspot connectivity

### World & Content
- **Procedural World Generation**: Auto-generated chunks with biomes
- **Biome Diversity**: Grasslands, forests, deserts, mountains, oceans, and more
- **Resource Gathering**: Trees, rocks, water, and craftable materials
- **Trading & Economy**: Shops, auction house, and currency system
- **NPCs & Towns**: Blacksmiths, merchants, and settlements
- **Pets & Mounts**: Companionship and transportation
- **Farming System**: Grow crops and raise animals

## 🏗️ Project Structure

```
Nexumi/
├── assets/
│   ├── sprites/          # Game sprites organized by type
│   ├── audio/           # Sound effects and music
│   └── materials/       # Textures and materials
├── scenes/
│   ├── main/           # Main game scene
│   ├── player/         # Player character scenes
│   ├── world/          # World and environment scenes
│   ├── ui/             # User interface scenes
│   └── menus/          # Menu scenes
├── scripts/
│   ├── core/           # Core game systems
│   ├── player/         # Player controller and related scripts
│   ├── world/          # World generation and chunk management
│   ├── inventory/      # Inventory and item systems
│   ├── crafting/       # Crafting and recipe systems
│   ├── building/       # Construction and building systems
│   ├── combat/         # Combat and weapon systems
│   ├── multiplayer/    # Networking and multiplayer
│   ├── economy/        # Trading and currency systems
│   └── ui/             # UI controllers and managers
└── resources/
    ├── data/           # Game data files
    └── configs/        # Configuration files
```

## 🚀 Getting Started

### Prerequisites
- Godot 4.4 or later
- Basic understanding of GDScript
- Git for version control

### Setup
1. Clone the repository
2. Open the project in Godot
3. The game will automatically load the main scene
4. Press F5 to run the game

### Controls
- **WASD/Arrow Keys**: Move player
- **E**: Interact with objects
- **I**: Open inventory
- **Left Click**: Attack
- **Right Click**: Use tool
- **ESC**: Pause/Unpause

## 📋 Development Roadmap

### ✅ Completed
- [x] Basic project structure
- [x] Core game architecture
- [x] Player movement and controls
- [x] World generation foundation
- [x] Inventory system
- [x] Crafting system framework
- [x] Item database

### 🔄 In Progress
- [ ] Player controller refinement
- [ ] World chunk rendering
- [ ] Basic combat system

### 📝 Planned Features
- [ ] Building system implementation
- [ ] Survival mechanics (hunger, thirst, health)
- [ ] Multiplayer networking
- [ ] Economy and trading
- [ ] NPCs and towns
- [ ] Pets and mounts
- [ ] Farming system
- [ ] Creative mode
- [ ] Boss fights
- [ ] Audio system
- [ ] Save/Load system

## 🛠️ Architecture Overview

### Core Systems

#### GameManager
Central singleton that manages game state, coordinates all systems, and handles scene transitions.

#### WorldGenerator
Handles procedural world generation with chunk-based loading, biome generation, and resource placement.

#### InventoryManager
Manages item storage, stacking, and equipment with a flexible slot-based system.

#### CraftingManager
Handles recipe management, crafting queues, and item creation with station requirements.

#### ItemDatabase
Centralized item definitions with properties for weapons, tools, blocks, and consumables.

### Key Classes

- **Player**: Main player character with movement, interaction, and combat
- **Item**: Base item class with type-specific properties
- **WorldChunk**: Represents a chunk of the world with blocks and entities
- **CraftingRecipe**: Defines crafting recipes with ingredients and requirements

## 🎯 Development Guidelines

### Code Organization
- Use descriptive class names and follow Godot naming conventions
- Implement proper signal patterns for communication between systems
- Keep scripts focused on single responsibilities
- Use autoload singletons for global systems

### Performance Considerations
- Implement efficient chunk loading/unloading
- Use object pooling for frequently created/destroyed objects
- Optimize rendering with proper layer management
- Implement LOD (Level of Detail) for distant objects

### Multiplayer Design
- Design systems with networking in mind
- Use authoritative server architecture
- Implement proper state synchronization
- Handle connection drops gracefully

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Implement your changes
4. Test thoroughly
5. Submit a pull request

### Code Style
- Follow GDScript style guide
- Use meaningful variable names
- Add comments for complex logic
- Document public functions

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Built with Godot Engine
- Inspired by classic sandbox and survival games
- Community contributions and feedback

---

**Note**: This is an ambitious project that requires significant development time. The current implementation provides a solid foundation with core systems in place. Continue development by implementing the planned features step by step, testing thoroughly, and iterating based on gameplay feedback. 