# Database & Password Setup Explanation

## How the Database Works

### MongoDB Setup

The backend uses **MongoDB** (a NoSQL database) to store all data. Here's how it works:

1. **MongoDB Installation:**
   - You can install MongoDB locally on your computer
   - OR use MongoDB Atlas (cloud database - free tier available)
   - The connection string is in `backend/.env` file: `MONGODB_URI`

2. **Database Structure:**
   - When you start the backend, it automatically connects to MongoDB
   - The database name is `skillocity` (or whatever you set in MONGODB_URI)
   - Collections (like tables) are created automatically when you save data:
     - `users` - stores user accounts
     - `messages` - stores chat messages
     - `matches` - stores user matches

### How Passwords Work

**Important:** Passwords are NEVER stored in plain text!

1. **When You Sign Up:**
   ```
   User enters: "mypassword123"
   ↓
   Backend receives password
   ↓
   Backend hashes password using bcrypt
   ↓
   Hashed version stored: "$2a$10$xyz123..." (looks like random text)
   ↓
   Original password is discarded
   ```

2. **Password Hashing (in `backend/models/User.js`):**
   ```javascript
   // This runs automatically before saving
   userSchema.pre('save', async function(next) {
     if (!this.isModified('password')) return next();
     
     // Generate salt and hash password
     const salt = await bcrypt.genSalt(10);
     this.password = await bcrypt.hash(this.password, salt);
     next();
   });
   ```

3. **When You Login:**
   ```
   User enters: "mypassword123"
   ↓
   Backend finds user by email
   ↓
   Backend compares entered password with stored hash
   ↓
   bcrypt.compare() checks if they match
   ↓
   If match → Login successful
   If no match → Login failed
   ```

4. **Password Comparison (in `backend/models/User.js`):**
   ```javascript
   userSchema.methods.comparePassword = async function(candidatePassword) {
     return bcrypt.compare(candidatePassword, this.password);
   };
   ```

### Security Features

1. **Hashing Algorithm:** bcrypt (industry standard)
   - One-way encryption (can't reverse it)
   - Includes salt (random data) to prevent rainbow table attacks
   - Slow by design (prevents brute force attacks)

2. **Password Never Sent Back:**
   - When user data is returned, password is removed:
   ```javascript
   userSchema.methods.toJSON = function() {
     const userObject = this.toObject();
     delete userObject.password; // Remove password
     return userObject;
   };
   ```

3. **JWT Tokens:**
   - After login, you get a JWT token (not password)
   - Token is used for authentication
   - Token expires after 7 days (configurable)

## Example Flow

### Sign Up Flow:
```
1. User fills form: email="test@example.com", password="secret123", name="Test"
2. Frontend sends to: POST /api/auth/signup
3. Backend creates user:
   - Generates unique ID (UUID)
   - Hashes password: "secret123" → "$2a$10$xyz..."
   - Saves to MongoDB:
     {
       uid: "abc-123-def",
       email: "test@example.com",
       password: "$2a$10$xyz...",  // Hashed!
       name: "Test",
       ...
     }
4. Backend returns user (without password) + JWT token
5. Frontend stores token for future requests
```

### Login Flow:
```
1. User enters: email="test@example.com", password="secret123"
2. Frontend sends to: POST /api/auth/login
3. Backend:
   - Finds user by email
   - Compares: bcrypt.compare("secret123", storedHash)
   - If match → returns user + new JWT token
   - If no match → returns error
4. Frontend stores token
```

## Database Collections

### Users Collection:
```javascript
{
  _id: ObjectId("..."),
  uid: "abc-123-def",
  email: "user@example.com",
  password: "$2a$10$xyz...",  // Hashed!
  name: "John Doe",
  bio: "I love coding",
  skillsToTeach: ["JavaScript", "React"],
  skillsToLearn: ["Python", "AI"],
  photoUrl: "http://...",
  createdAt: ISODate("2024-01-01T00:00:00Z"),
  lastActive: ISODate("2024-01-01T00:00:00Z")
}
```

### Messages Collection:
```javascript
{
  _id: ObjectId("..."),
  senderId: "user1-uid",
  receiverId: "user2-uid",
  message: "Hello!",
  isRead: false,
  timestamp: ISODate("2024-01-01T00:00:00Z")
}
```

### Matches Collection:
```javascript
{
  _id: ObjectId("..."),
  matchId: "match-uuid",
  user1Id: "user1-uid",
  user2Id: "user2-uid",
  commonSkills: ["JavaScript", "React"],
  matchedAt: ISODate("2024-01-01T00:00:00Z")
}
```

## How to View Your Database

### Using MongoDB Compass (GUI):
1. Download [MongoDB Compass](https://www.mongodb.com/products/compass)
2. Connect to: `mongodb://localhost:27017`
3. Browse collections and see your data

### Using MongoDB Shell:
```bash
# Connect to MongoDB
mongosh

# Switch to database
use skillocity

# View users
db.users.find().pretty()

# View messages
db.messages.find().pretty()

# View matches
db.matches.find().pretty()
```

## Important Notes

1. **You Never See Passwords:**
   - Even developers can't see user passwords
   - Only hashed versions exist in database
   - If user forgets password, you must reset it (can't retrieve it)

2. **Database is Empty Initially:**
   - No data until users sign up
   - Collections created automatically
   - No manual setup needed

3. **MongoDB Atlas (Cloud):**
   - Free tier: 512MB storage
   - Connection string format:
     ```
     mongodb+srv://username:password@cluster.mongodb.net/skillocity
     ```
   - Update `MONGODB_URI` in `.env`

4. **Local MongoDB:**
   - Install from [mongodb.com](https://www.mongodb.com/try/download/community)
   - Default connection: `mongodb://localhost:27017/skillocity`
   - No username/password needed for local

## Summary

- ✅ Passwords are hashed (never stored in plain text)
- ✅ Database created automatically
- ✅ Collections created when needed
- ✅ Secure authentication with JWT tokens
- ✅ No manual database setup required

The system handles everything automatically - you just need MongoDB running!

