# Nexumi Database Setup Guide

This guide explains how to set up and configure MongoDB for your Nexumi MMORPG project.

## 🎯 **Database Architecture Choice**

For Nexumi, we use a **hybrid approach**:

- **MongoDB**: For multiplayer data, user accounts, marketplace, analytics
- **Local SQLite/JSON**: For single-player mode and offline play
- **Automatic Fallback**: If MongoDB is unavailable, game uses local storage

### **Why MongoDB for MMORPG?**

✅ **Advantages:**
- **Flexible Schema**: Easy to add new features without migrations
- **Horizontal Scaling**: Handle thousands of players
- **Real-time Queries**: Fast lookups for player data
- **JSON-like Documents**: Perfect for game data structures
- **Built-in Replication**: High availability

✅ **Perfect for:**
- Player profiles and inventories
- World chunk data
- Marketplace transactions
- Guild systems
- Analytics and metrics

## 🗄️ **Database Collections Structure**

```javascript
// Collection: players
{
  "_id": ObjectId(),
  "player_id": "player_1234567890_123",
  "username": "PlayerName",
  "email": "player@example.com",
  "level": 25,
  "experience": 15750,
  "health": 100,
  "max_health": 120,
  "position": {
    "x": 1520.5,
    "y": 890.2,
    "world_id": "main_world"
  },
  "inventory": [
    {
      "item_id": "iron_sword",
      "quantity": 1,
      "durability": 85
    }
  ],
  "equipped_items": {
    "weapon": "iron_sword",
    "armor": "leather_armor"
  },
  "skills": {
    "mining": 15,
    "crafting": 20,
    "combat": 18
  },
  "achievements": ["first_kill", "master_crafter"],
  "currency": 2500,
  "guild_id": "guild_123",
  "friends": ["player_456", "player_789"],
  "created_at": ISODate(),
  "last_login": ISODate()
}

// Collection: worlds
{
  "_id": ObjectId(),
  "world_id": "main_world",
  "name": "Main World",
  "seed": 12345,
  "settings": {
    "difficulty": "normal",
    "pvp_enabled": true
  },
  "chunks": {
    "0_0": {
      "blocks": [[...]],
      "resources": {...},
      "structures": {...}
    }
  },
  "created_at": ISODate()
}

// Collection: marketplace
{
  "_id": ObjectId(),
  "listing_id": "listing_1234567890",
  "seller_id": "player_123",
  "item_id": "iron_sword",
  "quantity": 1,
  "price": 500,
  "category": "weapons",
  "description": "Well-crafted iron sword",
  "status": "active", // active, sold, cancelled
  "created_at": ISODate(),
  "expires_at": ISODate()
}

// Collection: guilds
{
  "_id": ObjectId(),
  "guild_id": "guild_123",
  "name": "Dragon Slayers",
  "description": "Elite guild for dragon hunting",
  "leader_id": "player_123",
  "members": [
    {
      "player_id": "player_123",
      "role": "leader",
      "joined_at": ISODate()
    }
  ],
  "level": 5,
  "treasury": 10000,
  "created_at": ISODate()
}
```

## 🚀 **MongoDB Installation**

### **Option 1: MongoDB Atlas (Cloud - Recommended)**

1. **Create Account**: Go to https://cloud.mongodb.com/
2. **Create Cluster**: Choose free tier (512MB)
3. **Configure Network**: Add your IP to whitelist
4. **Create User**: Database access with read/write permissions
5. **Get Connection String**: Copy connection URI

**Connection String Format:**
```
mongodb+srv://username:password@cluster.mongodb.net/nexumi_game?retryWrites=true&w=majority
```

### **Option 2: Local MongoDB Installation**

#### **Windows:**
```powershell
# Download MongoDB Community Server
# Install MongoDB from: https://www.mongodb.com/try/download/community

# Start MongoDB service
net start MongoDB

# Or run manually
"C:\Program Files\MongoDB\Server\7.0\bin\mongod.exe" --dbpath C:\data\db
```

#### **Linux/macOS:**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install mongodb

# macOS with Homebrew
brew tap mongodb/brew
brew install mongodb-community

# Start MongoDB
sudo systemctl start mongod
# or
brew services start mongodb/brew/mongodb-community
```

#### **Docker (Easy Setup):**
```bash
# Pull and run MongoDB
docker run -d --name nexumi-mongo \
  -p 27017:27017 \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=password123 \
  -v mongo-data:/data/db \
  mongo:latest

# Connect to database
docker exec -it nexumi-mongo mongosh
```

## ⚙️ **Database Configuration**

### **1. Update Game Settings**

Edit your `DatabaseManager.gd` settings:

```gdscript
# For MongoDB Atlas
@export var database_url: String = "mongodb+srv://username:password@cluster.mongodb.net"
@export var database_name: String = "nexumi_game"
@export var use_local_fallback: bool = false  # Set to true for development

# For Local MongoDB
@export var database_url: String = "mongodb://localhost:27017"
@export var database_name: String = "nexumi_game"
@export var use_local_fallback: bool = true
```

### **2. Create Database and Collections**

Connect to MongoDB and create initial structure:

```javascript
// Connect to MongoDB
use nexumi_game

// Create collections with validation
db.createCollection("players", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["player_id", "username"],
      properties: {
        player_id: { bsonType: "string" },
        username: { bsonType: "string" },
        level: { bsonType: "int", minimum: 1 },
        experience: { bsonType: "int", minimum: 0 }
      }
    }
  }
})

db.createCollection("worlds")
db.createCollection("marketplace")
db.createCollection("guilds")
db.createCollection("analytics")

// Create indexes for better performance
db.players.createIndex({ "player_id": 1 }, { unique: true })
db.players.createIndex({ "username": 1 }, { unique: true })
db.players.createIndex({ "last_login": -1 })

db.marketplace.createIndex({ "status": 1 })
db.marketplace.createIndex({ "category": 1 })
db.marketplace.createIndex({ "created_at": -1 })

db.worlds.createIndex({ "world_id": 1 }, { unique: true })

db.analytics.createIndex({ "timestamp": -1 })
db.analytics.createIndex({ "event_name": 1 })
```

### **3. Set Up User Permissions**

```javascript
// Create application user
db.createUser({
  user: "nexumi_app",
  pwd: "your_secure_password",
  roles: [
    { role: "readWrite", db: "nexumi_game" }
  ]
})

// Create read-only user for analytics
db.createUser({
  user: "nexumi_readonly",
  pwd: "readonly_password", 
  roles: [
    { role: "read", db: "nexumi_game" }
  ]
})
```

## 🔌 **Connecting Godot to MongoDB**

### **Method 1: REST API (Recommended)**

Create a simple REST API server to interface with MongoDB:

#### **Node.js + Express Example:**

```javascript
// server.js
const express = require('express');
const { MongoClient } = require('mongodb');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const uri = "mongodb://localhost:27017";
const client = new MongoClient(uri);

// Connect to MongoDB
client.connect();
const db = client.db('nexumi_game');

// Player endpoints
app.get('/api/players/:id', async (req, res) => {
  try {
    const player = await db.collection('players').findOne({ 
      player_id: req.params.id 
    });
    res.json(player);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/players', async (req, res) => {
  try {
    const result = await db.collection('players').insertOne(req.body);
    res.json({ success: true, id: result.insertedId });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.put('/api/players/:id', async (req, res) => {
  try {
    const result = await db.collection('players').updateOne(
      { player_id: req.params.id },
      { $set: req.body }
    );
    res.json({ success: true, modified: result.modifiedCount });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(3000, () => {
  console.log('Nexumi API server running on port 3000');
});
```

#### **Run the API Server:**
```bash
npm init -y
npm install express mongodb cors
node server.js
```

### **Method 2: Direct HTTP Requests**

Update your `DatabaseManager.gd` to use HTTP requests:

```gdscript
func _save_to_mongodb(collection: String, document_id: String, data: Dictionary):
  var url = "http://localhost:3000/api/" + collection + "/" + document_id
  var headers = ["Content-Type: application/json"]
  var json_data = JSON.stringify(data)
  
  http_request.request(url, headers, HTTPClient.METHOD_PUT, json_data)

func _load_from_mongodb(collection: String, document_id: String):
  var url = "http://localhost:3000/api/" + collection + "/" + document_id
  http_request.request(url, [], HTTPClient.METHOD_GET)
```

## 🛠️ **Development Setup**

### **1. Environment Configuration**

Create a `.env` file (don't commit to git):

```bash
# .env
MONGODB_URI=mongodb://localhost:27017
MONGODB_DATABASE=nexumi_game
MONGODB_USER=nexumi_app
MONGODB_PASSWORD=your_secure_password
API_PORT=3000
```

### **2. Docker Compose Setup**

Create `docker-compose.yml`:

```yaml
version: '3.8'
services:
  mongodb:
    image: mongo:latest
    container_name: nexumi-mongo
    restart: always
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password123
      MONGO_INITDB_DATABASE: nexumi_game
    volumes:
      - mongo-data:/data/db
      - ./scripts/init-mongo.js:/docker-entrypoint-initdb.d/init-mongo.js:ro

  api:
    build: ./api
    container_name: nexumi-api
    restart: always
    ports:
      - "3000:3000"
    environment:
      MONGODB_URI: mongodb://admin:password123@mongodb:27017
      MONGODB_DATABASE: nexumi_game
    depends_on:
      - mongodb

volumes:
  mongo-data:
```

### **3. Initialize Development Data**

Create `scripts/init-mongo.js`:

```javascript
// Initialize database with test data
db = db.getSiblingDB('nexumi_game');

// Create test player
db.players.insertOne({
  player_id: "test_player_1",
  username: "TestPlayer",
  level: 1,
  experience: 0,
  health: 100,
  max_health: 100,
  position: { x: 0, y: 0, world_id: "main_world" },
  inventory: [],
  equipped_items: {},
  skills: { mining: 1, crafting: 1, combat: 1 },
  achievements: [],
  currency: 100,
  created_at: new Date(),
  last_login: new Date()
});

// Create test world
db.worlds.insertOne({
  world_id: "main_world",
  name: "Main World",
  seed: 12345,
  settings: { difficulty: "normal", pvp_enabled: false },
  chunks: {},
  created_at: new Date()
});

print("Database initialized with test data");
```

## 🧪 **Testing Database Connection**

### **1. Test MongoDB Connection**

```bash
# Using mongosh
mongosh "mongodb://localhost:27017/nexumi_game"

# Test queries
db.players.find()
db.worlds.find()
```

### **2. Test API Endpoints**

```bash
# Test player creation
curl -X POST http://localhost:3000/api/players \
  -H "Content-Type: application/json" \
  -d '{
    "player_id": "test_123",
    "username": "TestUser",
    "level": 1,
    "health": 100
  }'

# Test player retrieval
curl http://localhost:3000/api/players/test_123
```

### **3. Test in Godot**

Add debug code to your game:

```gdscript
# In GameManager._ready()
func _test_database():
  if database_manager:
    # Test player creation
    var player_id = database_manager.create_new_player("TestPlayer")
    print("Created player: ", player_id)
    
    # Test data loading
    var player_data = database_manager.load_player_data(player_id)
    print("Loaded player: ", player_data)
```

## 📊 **Database Monitoring**

### **1. MongoDB Compass**

Download MongoDB Compass for visual database management:
- Website: https://www.mongodb.com/products/compass
- Connect using your connection string
- View and edit documents visually

### **2. Performance Monitoring**

```javascript
// Enable profiling
db.setProfilingLevel(2)

// View slow queries
db.system.profile.find().sort({ ts: -1 }).limit(5)

// Database statistics
db.stats()
db.players.stats()
```

### **3. Backup Strategy**

```bash
# Create backup
mongodump --db nexumi_game --out ./backups/

# Restore backup
mongorestore --db nexumi_game ./backups/nexumi_game/

# Automated backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
mongodump --db nexumi_game --out ./backups/backup_$DATE/
tar -czf ./backups/backup_$DATE.tar.gz ./backups/backup_$DATE/
rm -rf ./backups/backup_$DATE/
```

## 🔒 **Security Best Practices**

### **1. Authentication**
- Never use default passwords
- Use strong, unique passwords
- Enable authentication in production

### **2. Network Security**
- Use VPC/private networks
- Whitelist specific IP addresses
- Use SSL/TLS for connections

### **3. Data Validation**
- Use MongoDB schema validation
- Sanitize input data in API
- Implement rate limiting

### **4. Access Control**
```javascript
// Create roles with specific permissions
db.createRole({
  role: "gameDataManager",
  privileges: [
    { resource: { db: "nexumi_game", collection: "players" }, actions: ["find", "update", "insert"] },
    { resource: { db: "nexumi_game", collection: "worlds" }, actions: ["find", "update"] }
  ],
  roles: []
});
```

## 🚀 **Production Deployment**

### **1. MongoDB Atlas (Recommended)**
- Automatic backups
- Global clusters
- Built-in security
- Monitoring and alerts

### **2. Self-Hosted MongoDB**
- Use replica sets for high availability
- Configure sharding for large datasets
- Set up monitoring with tools like MongoDB Ops Manager

### **3. API Server Deployment**
- Use PM2 for Node.js process management
- Deploy behind nginx proxy
- Use environment variables for configuration
- Implement logging and error tracking

## 📋 **Quick Start Checklist**

- [ ] Install MongoDB (Atlas or local)
- [ ] Create database and collections
- [ ] Set up indexes for performance
- [ ] Create API server (optional)
- [ ] Test connection from Godot
- [ ] Configure backup strategy
- [ ] Set up monitoring
- [ ] Implement security measures

---

**Your Nexumi database is now ready to handle thousands of players! 🎮🗄️**

For additional help:
- MongoDB Documentation: https://docs.mongodb.com/
- Godot HTTP requests: https://docs.godotengine.org/en/stable/tutorials/networking/http_request_class.html
- MongoDB University (free courses): https://university.mongodb.com/ 