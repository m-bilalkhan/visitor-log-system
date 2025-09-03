# Who's Visiting - Visitor Log App

A modern, mobile-friendly visitor log application where people can sign in and view fellow visitors.

## Features

- 📝 Visitor sign-in form with name, email, location, and message
- 👥 Gallery view of all visitors
- 📊 Real-time visitor statistics
- 📱 Mobile-first responsive design
- 🎨 Modern UI with smooth animations
- 🐳 Fully dockerized with Docker Compose

## Quick Start with Docker

### Prerequisites

- Docker
- Docker Compose

### Running the Application

1. Clone the repository and navigate to the project directory

2. Start the entire application stack:
   ```bash
   docker-compose up -d
   ```

3. The application will be available at:
   - Frontend: http://localhost
   - Backend API: http://localhost:3001
   - Database: localhost:5432

4. To stop the application:
   ```bash
   docker-compose down
   ```

5. To stop and remove all data:
   ```bash
   docker-compose down -v
   ```

### Development Mode

For development with hot reloading:

```bash
# Start only the database
docker-compose -f docker-compose.dev.yml up database -d

# Run backend and frontend locally
npm install
npm run dev:full
```

## Manual Setup Instructions (Alternative)

### Prerequisites

- Node.js (v16 or higher)
- PostgreSQL database

### Database Setup

1. Create a PostgreSQL database named `visitor_log`
2. Run the SQL commands in `server/database.sql` to create the required tables
3. Update the database connection details in `.env`

### Environment Variables

Create a `.env` file and update with your database credentials:

```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=visitor_log
DB_USER=your_username
DB_PASSWORD=your_password
PORT=3001
```

### Running the Application

1. Install dependencies:
   ```bash
   npm install
   ```

2. Start both frontend and backend:
   ```bash
   npm run dev:full
   ```

   Or run them separately:
   ```bash
   # Terminal 1 - Backend
   npm run server
   
   # Terminal 2 - Frontend
   npm run dev
   ```

3. Open http://localhost:5173 in your browser

## Docker Services

- **Frontend**: Nginx serving the built React app on port 80
- **Backend**: Node.js/Express API server on port 3001
- **Database**: PostgreSQL 15 on port 5432

The database is automatically initialized with the required schema on first startup.

## API Endpoints

- `GET /api/visitors` - Get all visitors
- `POST /api/visitors` - Create a new visitor
- `GET /api/health` - Health check

## Database Schema

```sql
CREATE TABLE visitors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    location VARCHAR(255),
    message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```