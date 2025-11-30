# MLOps Pipeline - Iris Flower Classification

A complete Machine Learning Operations (MLOps) pipeline that trains, deploys, and serves an Iris flower classification model using Flask API and Streamlit UI.

## 🎯 What This Project Does

This project automatically:
1. **Trains** a machine learning model on the Iris dataset
2. **Builds** Docker containers for the API and UI
3. **Deploys** a Flask REST API to serve predictions
4. **Launches** a Streamlit web interface for easy testing
5. **Monitors** everything with health checks

## 📋 Table of Contents

- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start (Automated)](#quick-start-automated)
- [Manual Setup](#manual-setup)
- [Using the Application](#using-the-application)
- [Jenkins Pipeline](#jenkins-pipeline)
- [Project Structure](#project-structure)
- [API Documentation](#api-documentation)
- [Troubleshooting](#troubleshooting)

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    EC2 Instance                         │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │              Jenkins Pipeline                     │  │
│  │  1. Pull Code → 2. Train Model → 3. Build Docker │  │
│  │  4. Deploy Containers → 5. Health Check          │  │
│  └──────────────────────────────────────────────────┘  │
│                          ↓                              │
│  ┌─────────────────┐  ┌─────────────────┐             │
│  │  Flask API      │  │  Streamlit UI   │             │
│  │  Port: 5000     │  │  Port: 8501     │             │
│  │  (Predictions)  │  │  (Web Interface)│             │
│  └─────────────────┘  └─────────────────┘             │
│           ↓                     ↓                       │
│  ┌──────────────────────────────────────┐              │
│  │     Trained ML Model (model.pkl)     │              │
│  │     Iris Classification Model        │              │
│  └──────────────────────────────────────┘              │
└─────────────────────────────────────────────────────────┘
```

### How It Works

1. **User** → Opens Streamlit UI in browser (port 8501)
2. **Streamlit** → Sends flower measurements to Flask API (port 5000)
3. **Flask API** → Loads trained model and makes prediction
4. **Model** → Returns flower species (Setosa, Versicolor, or Virginica)
5. **Result** → Displayed to user in Streamlit UI

---

## 📦 Prerequisites

### On EC2 Instance (Amazon Linux 2023)

You need:
- **Python 3.9+** (for running ML code)
- **Docker** (for containerization)
- **Docker Compose** (for managing containers)
- **Git** (for cloning repository)
- **Jenkins** (for automation - optional)

Don't worry! The automated setup installs everything for you.

---

## 🚀 Quick Start (Automated)

### Option 1: Complete Automated Setup (Recommended)

Run this single command to install everything and start the application:

```bash
curl -fsSL https://raw.githubusercontent.com/JibbranAli/devops-project-7.1/main/scripts/setup.sh | bash
```

This will:
- ✅ Install all dependencies (Python, Docker, Docker Compose)
- ✅ Clone the repository
- ✅ Train the ML model
- ✅ Build Docker images
- ✅ Start all services
- ✅ Show you the URLs to access

**Time:** ~5 minutes

### Option 2: Step-by-Step Automated

```bash
# 1. Clone the repository
git clone https://github.com/JibbranAli/devops-project-7.1.git
cd devops-project-7.1

# 2. Run automated setup
chmod +x scripts/*.sh
sudo ./scripts/setup.sh

# 3. Start the application
./scripts/start.sh
```

### Access Your Application

After setup completes, you'll see:

```
========================================
✅ MLOps Pipeline is Running!
========================================

Access your services:
  🌐 Streamlit UI:  http://YOUR-IP:8501
  🔌 Flask API:     http://YOUR-IP:5000
  ❤️  Health Check:  http://YOUR-IP:5000/health

Test the API:
  curl -X POST http://YOUR-IP:5000/predict \
    -H "Content-Type: application/json" \
    -d '{"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2}'
```

---

## 🔧 Manual Setup

If you prefer to understand each step:

### Step 1: Install Dependencies

```bash
# Update system
sudo yum update -y

# Install Python 3
sudo yum install -y python3 python3-pip git

# Install Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Log out and back in for docker group to take effect
```

### Step 2: Clone Repository

```bash
git clone https://github.com/JibbranAli/devops-project-7.1.git
cd devops-project-7.1
```

### Step 3: Install Python Dependencies

```bash
pip3 install --user -r requirements.txt
```

### Step 4: Train the Model

```bash
python3 app/train_model.py
```

This creates `app/model.pkl` - the trained machine learning model.

### Step 5: Build Docker Images

```bash
# Build Flask API image
docker build -f docker/Dockerfile.flask -t mlops-flask-api:latest .

# Build Streamlit UI image
docker build -f docker/Dockerfile.streamlit -t mlops-streamlit-ui:latest .
```

### Step 6: Start Services

```bash
docker-compose up -d
```

### Step 7: Verify Everything Works

```bash
# Check containers are running
docker-compose ps

# Test API health
curl http://localhost:5000/health

# Make a test prediction
curl -X POST http://localhost:5000/predict \
  -H "Content-Type: application/json" \
  -d '{"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2}'
```

---

## 🎨 Using the Application

### Web Interface (Streamlit)

1. Open your browser and go to: `http://YOUR-IP:8501`
2. You'll see sliders for flower measurements:
   - **Sepal Length** (4.0 - 8.0 cm)
   - **Sepal Width** (2.0 - 4.5 cm)
   - **Petal Length** (1.0 - 7.0 cm)
   - **Petal Width** (0.1 - 2.5 cm)
3. Adjust the sliders
4. Click **"Predict Flower Species"**
5. See the result: Setosa, Versicolor, or Virginica

### API (Flask)

#### Make a Prediction

```bash
curl -X POST http://YOUR-IP:5000/predict \
  -H "Content-Type: application/json" \
  -d '{
    "sepal_length": 5.1,
    "sepal_width": 3.5,
    "petal_length": 1.4,
    "petal_width": 0.2
  }'
```

**Response:**
```json
{
  "prediction": "Setosa",
  "prediction_id": 0,
  "confidence": 0.98,
  "timestamp": "2025-11-30T10:30:45"
}
```

#### Check Health

```bash
curl http://YOUR-IP:5000/health
```

**Response:**
```json
{
  "status": "healthy",
  "model_loaded": true,
  "timestamp": "2025-11-30T10:30:45"
}
```

---

## 🔄 Jenkins Pipeline

### What the Pipeline Does

The Jenkins pipeline automates the entire deployment:

```
Stage 1: Checkout Code
   ↓
Stage 2: Install Dependencies
   ↓
Stage 3: Train ML Model
   ↓
Stage 4: Build Docker Images
   ↓
Stage 5: Stop Old Containers
   ↓
Stage 6: Start New Containers
   ↓
Stage 7: Health Check
   ↓
Stage 8: Run Tests
```

### Setting Up Jenkins

#### 1. Install Jenkins

```bash
sudo ./scripts/install_jenkins.sh
```

#### 2. Access Jenkins

Open: `http://YOUR-IP:8080`

Get initial password:
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

#### 3. Create Pipeline Job

1. Click **"New Item"**
2. Enter name: `mlops-pipeline`
3. Select **"Pipeline"**
4. Click **OK**

#### 4. Configure Pipeline

In the job configuration:

**Pipeline Section:**
- Definition: `Pipeline script from SCM`
- SCM: `Git`
- Repository URL: `https://github.com/JibbranAli/devops-project-7.1.git`
- Branch: `*/main`
- Script Path: `Jenkinsfile`

Click **Save**

#### 5. Run Pipeline

Click **"Build Now"**

Watch the pipeline execute all stages automatically!

### Jenkins Pipeline Features

- ✅ **Automatic Deployment**: Push code → Jenkins builds → App updates
- ✅ **Health Checks**: Verifies services are running
- ✅ **Rollback**: Keeps old containers until new ones are healthy
- ✅ **Notifications**: Shows build status
- ✅ **Logs**: Complete logs of each stage

---

## 📁 Project Structure

```
mlops-redesign/
├── app/
│   ├── train_model.py          # Trains the ML model
│   ├── flask_app.py            # Flask API for predictions
│   ├── streamlit_app.py        # Streamlit web interface
│   └── model.pkl               # Trained model (generated)
│
├── docker/
│   ├── Dockerfile.flask        # Flask API container
│   └── Dockerfile.streamlit    # Streamlit UI container
│
├── scripts/
│   ├── setup.sh                # Complete automated setup
│   ├── start.sh                # Start services
│   ├── stop.sh                 # Stop services
│   ├── install_jenkins.sh      # Install Jenkins
│   └── test.sh                 # Run tests
│
├── docker-compose.yml          # Container orchestration
├── Jenkinsfile                 # Jenkins pipeline definition
├── requirements.txt            # Python dependencies
├── .gitignore                  # Git ignore rules
├── .dockerignore               # Docker ignore rules
└── README.md                   # This file
```

---

## 📚 API Documentation

### Endpoints

#### POST /predict

Make a prediction for iris flower species.

**Request:**
```json
{
  "sepal_length": 5.1,
  "sepal_width": 3.5,
  "petal_length": 1.4,
  "petal_width": 0.2
}
```

**Response:**
```json
{
  "prediction": "Setosa",
  "prediction_id": 0,
  "confidence": 0.98,
  "timestamp": "2025-11-30T10:30:45"
}
```

**Prediction IDs:**
- `0` = Setosa
- `1` = Versicolor
- `2` = Virginica

#### GET /health

Check if the API is running and model is loaded.

**Response:**
```json
{
  "status": "healthy",
  "model_loaded": true,
  "timestamp": "2025-11-30T10:30:45"
}
```

---

## 🐛 Troubleshooting

### Services Won't Start

```bash
# Check if containers are running
docker-compose ps

# View logs
docker-compose logs

# Restart services
docker-compose restart
```

### Model Not Found Error

```bash
# Train the model
python3 app/train_model.py

# Verify model exists
ls -lh app/model.pkl

# Rebuild containers
docker-compose build
docker-compose up -d
```

### Port Already in Use

```bash
# Stop existing services
docker-compose down

# Or kill specific port
sudo lsof -ti:5000 | xargs kill -9
sudo lsof -ti:8501 | xargs kill -9
```

### Can't Access from Browser

**Check 1: Services Running?**
```bash
docker-compose ps
```

**Check 2: Using Correct IP?**
```bash
curl http://169.254.169.254/latest/meta-data/public-ipv4
```

**Check 3: Security Group (AWS)**
- Open ports: 5000, 8501, 8080 (Jenkins)
- Source: 0.0.0.0/0 or your IP

**Check 4: Firewall**
```bash
sudo firewall-cmd --list-all
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --permanent --add-port=8501/tcp
sudo firewall-cmd --reload
```

### Docker Permission Denied

```bash
sudo usermod -aG docker $USER
# Log out and back in
```

### Jenkins Can't Build

```bash
# Add Jenkins to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

---

## 🎓 Understanding the ML Model

### What is the Iris Dataset?

The Iris dataset contains measurements of 150 iris flowers from 3 species:

- **Setosa**: Small flowers, short petals
- **Versicolor**: Medium flowers
- **Virginica**: Large flowers, long petals

### Features (Input)

Each flower has 4 measurements:
1. **Sepal Length** (cm)
2. **Sepal Width** (cm)
3. **Petal Length** (cm)
4. **Petal Width** (cm)

### Model

We use **Random Forest Classifier**:
- 100 decision trees
- Accuracy: ~97%
- Fast predictions: <10ms

### Example Predictions

**Setosa (Small flower):**
```json
{
  "sepal_length": 5.1,
  "sepal_width": 3.5,
  "petal_length": 1.4,
  "petal_width": 0.2
}
```

**Virginica (Large flower):**
```json
{
  "sepal_length": 6.5,
  "sepal_width": 3.0,
  "petal_length": 5.2,
  "petal_width": 2.0
}
```

---

## 🔄 Updating the Application

### Manual Update

```bash
# Pull latest code
git pull origin main

# Retrain model (if needed)
python3 app/train_model.py

# Rebuild and restart
docker-compose build
docker-compose up -d
```

### Automatic Update (Jenkins)

Just push to GitHub - Jenkins will automatically:
1. Detect the change
2. Pull new code
3. Retrain model
4. Rebuild containers
5. Deploy updates

---

## 📊 Monitoring

### Check Service Status

```bash
# Container status
docker-compose ps

# View logs
docker-compose logs -f

# Check resource usage
docker stats
```

### Health Checks

```bash
# API health
curl http://localhost:5000/health

# Test prediction
curl -X POST http://localhost:5000/predict \
  -H "Content-Type: application/json" \
  -d '{"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2}'
```

---

## 🛑 Stopping the Application

```bash
# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Stop and remove images
docker-compose down --rmi all
```

---

## 📝 License

MIT License - Feel free to use this project for learning and development!

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

---

## 📧 Support

If you encounter issues:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review logs: `docker-compose logs`
3. Open an issue on GitHub

---

**Made with ❤️ for learning MLOps**
