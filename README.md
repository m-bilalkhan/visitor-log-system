# Who's Visiting - Visitor Log App

A modern, mobile-friendly visitor log application where people can sign in and view fellow visitors.

### Infrastructure Repo Link: [Link](https://github.com/m-bilalkhan/visitor-log-system-iac)

## Features

- 📝 Visitor sign-in form with name, email, location, and message
- 👥 Gallery view of all visitors
- 📊 Real-time visitor statistics
- 📱 Mobile-first responsive design
- 🎨 Modern UI with smooth animations
- ⚙️ CI/CD with GitHub Actions
- 🐳 Fully dockerized with Docker Compose

## DevOps & CI/CD

- **Continuous Integration:** Automated testing and linting on every push using [GitHub Actions](.github/workflows/ci.yml).
- **Continuous Deployment:** Easy deploy to cloud platforms.
- **Golden AMI:** Golden AMI creation using Hashicorp Packer for consistent, secure infrastructure images.
- **Monitoring & Health Checks:** `/api/health` endpoint for service health.

### DevOps Lifecycle

This project follows a modern DevOps lifecycle to ensure high quality and rapid delivery:

1. **Plan:** Define features, requirements, and improvements.
2. **Code:** Develop features and fixes using Git, with code reviews and collaboration.
3. **Build:** Automated builds and dependency management using Docker and CI pipelines.
4. **Release:** Build artifacts and Docker images are created and versioned.
5. **Deploy:** Automated deployment.
6. **Operate:** Application runs in a monitored environment with health checks and logging.
7. **Monitor:** Continuous monitoring, alerting, and feedback for improvement.

### Workflow Diagram

You can include your workflow diagrams here for visual reference:

![DevOps Workflow Diagram](/diagram.png)


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
