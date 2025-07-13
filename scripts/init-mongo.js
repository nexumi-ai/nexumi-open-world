// MongoDB Initialization Script for Nexumi Game
// This script runs when the MongoDB container starts for the first time

print("🎮 Initializing Nexumi Game Database...");

// Switch to the game database
db = db.getSiblingDB('nexumi_game');

// Create collections with validation schemas
print("📁 Creating collections...");

// Players collection with validation
db.createCollection("players", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["player_id", "username", "created_at"],
      properties: {
        player_id: { 
          bsonType: "string",
          description: "must be a string and is required" 
        },
        username: { 
          bsonType: "string",
          minLength: 3,
          maxLength: 20,
          description: "must be a string 3-20 characters and is required" 
        },
        level: { 
          bsonType: "int", 
          minimum: 1,
          maximum: 100,
          description: "must be an integer between 1-100" 
        },
        experience: { 
          bsonType: "int", 
          minimum: 0,
          description: "must be a non-negative integer" 
        },
        health: {
          bsonType: "int",
          minimum: 0,
          description: "must be a non-negative integer"
        },
        currency: {
          bsonType: "int",
          minimum: 0,
          description: "must be a non-negative integer"
        }
      }
    }
  }
});

// Worlds collection
db.createCollection("worlds");

// Marketplace collection
db.createCollection("marketplace", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["listing_id", "seller_id", "item_id", "price", "status"],
      properties: {
        price: {
          bsonType: "int",
          minimum: 1,
          description: "must be a positive integer"
        },
        status: {
          bsonType: "string",
          enum: ["active", "sold", "cancelled", "expired"],
          description: "must be a valid status"
        }
      }
    }
  }
});

// Guilds collection
db.createCollection("guilds");

// Analytics collection
db.createCollection("analytics");

print("✅ Collections created successfully!");

// Create indexes for better performance
print("🔍 Creating indexes...");

// Player indexes
db.players.createIndex({ "player_id": 1 }, { unique: true });
db.players.createIndex({ "username": 1 }, { unique: true });
db.players.createIndex({ "email": 1 }, { unique: true, sparse: true });
db.players.createIndex({ "last_login": -1 });
db.players.createIndex({ "level": -1 });
db.players.createIndex({ "guild_id": 1 });

// Marketplace indexes
db.marketplace.createIndex({ "status": 1 });
db.marketplace.createIndex({ "category": 1 });
db.marketplace.createIndex({ "seller_id": 1 });
db.marketplace.createIndex({ "created_at": -1 });
db.marketplace.createIndex({ "price": 1 });

// World indexes
db.worlds.createIndex({ "world_id": 1 }, { unique: true });

// Guild indexes
db.guilds.createIndex({ "guild_id": 1 }, { unique: true });
db.guilds.createIndex({ "name": 1 }, { unique: true });
db.guilds.createIndex({ "leader_id": 1 });

// Analytics indexes
db.analytics.createIndex({ "timestamp": -1 });
db.analytics.createIndex({ "event_name": 1 });
db.analytics.createIndex({ "session_id": 1 });

print("✅ Indexes created successfully!");

// Create application user
print("👤 Creating application user...");

db.createUser({
  user: "nexumi_app",
  pwd: "nexumi_app_password_2024",
  roles: [
    { role: "readWrite", db: "nexumi_game" }
  ]
});

// Create read-only user for analytics
db.createUser({
  user: "nexumi_readonly",
  pwd: "readonly_password_2024",
  roles: [
    { role: "read", db: "nexumi_game" }
  ]
});

print("✅ Users created successfully!");

// Insert test data
print("🧪 Creating test data...");

// Create test player
var testPlayerId = "player_" + new Date().getTime();
db.players.insertOne({
  player_id: testPlayerId,
  username: "TestPlayer",
  email: "test@nexumi.com",
  level: 5,
  experience: 1250,
  health: 100,
  max_health: 100,
  position: {
    x: 0,
    y: 0,
    world_id: "main_world"
  },
  inventory: [
    {
      item_id: "wooden_sword",
      quantity: 1,
      durability: 95
    },
    {
      item_id: "health_potion",
      quantity: 3
    },
    {
      item_id: "wood",
      quantity: 50
    }
  ],
  equipped_items: {
    weapon: "wooden_sword",
    armor: null,
    accessory: null
  },
  skills: {
    mining: 3,
    crafting: 4,
    combat: 5,
    farming: 2
  },
  achievements: ["first_login", "first_craft"],
  currency: 500,
  guild_id: null,
  friends: [],
  settings: {
    music_volume: 0.8,
    sfx_volume: 0.9,
    auto_save: true
  },
  created_at: new Date(),
  last_login: new Date()
});

// Create test world
db.worlds.insertOne({
  world_id: "main_world",
  name: "Nexumi Main World",
  description: "The primary world for Nexumi players",
  seed: 12345,
  difficulty: "normal",
  settings: {
    pvp_enabled: false,
    building_enabled: true,
    respawn_on_death: true
  },
  chunks: {},
  global_structures: {
    spawn_point: { x: 0, y: 0 },
    main_town: { x: 100, y: 100 }
  },
  created_at: new Date(),
  updated_at: new Date()
});

// Create test marketplace listings
var testListingId1 = "listing_" + new Date().getTime() + "_1";
var testListingId2 = "listing_" + new Date().getTime() + "_2";

db.marketplace.insertMany([
  {
    listing_id: testListingId1,
    seller_id: testPlayerId,
    item_id: "iron_sword",
    quantity: 1,
    price: 150,
    category: "weapons",
    description: "A well-crafted iron sword, perfect for combat",
    condition: "excellent",
    status: "active",
    created_at: new Date(),
    expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 days from now
  },
  {
    listing_id: testListingId2,
    seller_id: testPlayerId,
    item_id: "health_potion",
    quantity: 10,
    price: 5,
    category: "consumables",
    description: "Restores 50 HP instantly",
    condition: "new",
    status: "active",
    created_at: new Date(),
    expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
  }
]);

// Create test guild
var testGuildId = "guild_" + new Date().getTime();
db.guilds.insertOne({
  guild_id: testGuildId,
  name: "Dragon Slayers",
  description: "Elite guild for experienced adventurers",
  tag: "DRAG",
  leader_id: testPlayerId,
  members: [
    {
      player_id: testPlayerId,
      username: "TestPlayer",
      role: "leader",
      joined_at: new Date(),
      contribution_points: 100
    }
  ],
  level: 1,
  experience: 0,
  treasury: 1000,
  max_members: 50,
  requirements: {
    min_level: 5,
    application_required: true
  },
  perks: {
    exp_bonus: 0.05,
    resource_bonus: 0.03
  },
  created_at: new Date(),
  updated_at: new Date()
});

// Create sample analytics events
db.analytics.insertMany([
  {
    event_id: "event_" + new Date().getTime() + "_1",
    event_name: "player_login",
    event_data: {
      player_id: testPlayerId,
      login_method: "username",
      session_duration_previous: 1800
    },
    timestamp: new Date(),
    session_id: "session_" + new Date().getTime()
  },
  {
    event_id: "event_" + new Date().getTime() + "_2",
    event_name: "item_crafted",
    event_data: {
      player_id: testPlayerId,
      item_id: "wooden_sword",
      ingredients_used: ["wood", "iron_ingot"],
      crafting_time: 5.2
    },
    timestamp: new Date(),
    session_id: "session_" + new Date().getTime()
  }
]);

print("✅ Test data created successfully!");

// Display summary
print("\n🎉 Nexumi Database Initialization Complete!");
print("📊 Summary:");
print("   📁 Collections: " + db.getCollectionNames().length);
print("   👥 Players: " + db.players.countDocuments());
print("   🌍 Worlds: " + db.worlds.countDocuments());
print("   🛒 Marketplace: " + db.marketplace.countDocuments());
print("   🛡️ Guilds: " + db.guilds.countDocuments());
print("   📈 Analytics: " + db.analytics.countDocuments());

print("\n🔗 Connection Info:");
print("   Database: nexumi_game");
print("   App User: nexumi_app");
print("   Web UI: http://localhost:8081");
print("   MongoDB: mongodb://localhost:27017");

print("\n🚀 Your Nexumi database is ready for epic adventures!"); 