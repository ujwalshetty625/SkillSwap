# Where is Your Data Stored? 🤔

## Short Answer

**Your data is stored in MongoDB on YOUR computer** (or in the cloud if you use MongoDB Atlas).

You don't need to provide any passwords because:
- **Local MongoDB** (default) runs on your computer - no password needed
- The database is created automatically when you first use the app
- Everything is stored locally on your machine

## Detailed Explanation

### Option 1: Local MongoDB (Default - What You're Using)

**Location:** Your computer's hard drive

**Where exactly:**
- Windows: Usually `C:\data\db\` or `C:\Program Files\MongoDB\Server\data\db\`
- Mac: `/usr/local/var/mongodb/`
- Linux: `/var/lib/mongodb/`

**How it works:**
1. You install MongoDB on your computer (or it's already installed)
2. MongoDB runs as a service on your computer
3. The backend connects to `mongodb://localhost:27017` (your own computer)
4. No password needed - it's like a local file on your computer
5. Database name: `skillocity` (created automatically)

**Connection String in `.env`:**
```
MONGODB_URI=mongodb://localhost:27017/skillocity
```
This means: "Connect to MongoDB on this computer, use database called 'skillocity'"

### Option 2: MongoDB Atlas (Cloud - Optional)

**Location:** MongoDB's cloud servers

**If you want to use cloud storage:**
1. Go to [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas)
2. Create a free account
3. Create a free cluster
4. Get your connection string (looks like: `mongodb+srv://username:password@cluster.mongodb.net/skillocity`)
5. Update `MONGODB_URI` in `backend/.env`

**But you don't need this!** Local MongoDB works perfectly fine for development.

## What Data is Stored?

When you use the app, data is saved in these collections:

### 1. Users Collection
```javascript
{
  _id: "...",
  uid: "abc-123",
  email: "user@example.com",
  password: "$2a$10$xyz...",  // Hashed password
  name: "John Doe",
  bio: "I love coding",
  skillsToTeach: ["JavaScript"],
  skillsToLearn: ["Python"],
  photoUrl: "http://...",
  createdAt: "2024-01-01",
  lastActive: "2024-01-01"
}
```

### 2. Messages Collection
```javascript
{
  _id: "...",
  senderId: "user1-uid",
  receiverId: "user2-uid",
  message: "Hello!",
  timestamp: "2024-01-01"
}
```

### 3. Matches Collection
```javascript
{
  _id: "...",
  matchId: "match-123",
  user1Id: "user1-uid",
  user2Id: "user2-uid",
  commonSkills: ["JavaScript"],
  matchedAt: "2024-01-01"
}
```

## How to See Your Data

### Method 1: MongoDB Compass (Visual Tool)
1. Download [MongoDB Compass](https://www.mongodb.com/products/compass)
2. Connect to: `mongodb://localhost:27017`
3. Browse your `skillocity` database
4. See all users, messages, matches

### Method 2: Command Line
```bash
# Connect to MongoDB
mongosh

# Switch to your database
use skillocity

# See all users
db.users.find().pretty()

# See all messages
db.messages.find().pretty()

# See all matches
db.matches.find().pretty()
```

## Important Points

✅ **No password needed** for local MongoDB
✅ **Database created automatically** when you first save data
✅ **All data stored on YOUR computer** (unless you use Atlas)
✅ **You own all the data** - it's on your machine
✅ **No internet needed** for local MongoDB (after initial setup)

## File Storage

**Profile photos** are stored in:
- Location: `backend/uploads/` folder
- Format: `profile_userId_timestamp.jpg`
- Served at: `http://localhost:3000/uploads/filename.jpg`

## Summary

- **Database:** MongoDB on your computer (or cloud if you choose)
- **Location:** Your hard drive (local) or MongoDB servers (cloud)
- **Password:** Not needed for local MongoDB
- **Setup:** Automatic - just start MongoDB and the backend connects

Think of it like this:
- MongoDB = A filing cabinet on your computer
- Collections = Drawers in the cabinet
- Documents = Your data (users, messages, etc.)

You don't need to "give" passwords because the database is running on your own computer, just like any other app!

