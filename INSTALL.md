# Installation Guide for Amazon Linux EC2

## 🚀 Quick Install (One Command)

```bash
curl -fsSL https://raw.githubusercontent.com/JibbranAli/devops-project-7.1/main/install-mlops.sh | sudo bash
```

This will:
1. Clone the repository
2. Install all dependencies
3. Train the ML model
4. Build Docker images
5. Start all services

**Time**: ~5 minutes

---

## 📋 Manual Installation

### Prerequisites

- Amazon Linux 2023 EC2 instance
- SSH access
- Security Group with ports 5000, 8501, 8080 open

### Step 1: Connect to EC2

```bash
ssh -i "your-key.pem" ec2-user@YOUR-EC2-IP
```

### Step 2: Clone Repository

```bash
git clone https://github.com/JibbranAli/devops-project-7.1.git
cd devops-project-7.1
```

### Step 3: Run Setup Script

```bash
sudo bash scripts/setup.sh
```

This installs:
- Python 3 and pip
- Docker and Docker Compose
- All Python dependencies
- Trains the ML model
- Builds Docker images

### Step 4: Start Services

```bash
bash scripts/start.sh
```

### Step 5: Verify Installation

```bash
bash scripts/test.sh
```

---

## 🔧 Manual Setup (Step-by-Step)

If you prefer to understand each step:

### 1. Update System

```bash
sudo yum update -y
```

### 2. Install Python 3

```bash
sudo yum install -y python3 python3-pip python3-devel gcc git wget curl
python3 --version
```

### 3. Install Docker

```bash
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

**Important**: Log out and back in for docker group to take effect!

### 4. Install Docker Compose

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version
```

### 5. Install Python Dependencies

```bash
pip3 install --user -r requirements.txt
```

### 6. Train ML Model

```bash
python3 app/train_model.py
```

This creates `app/model.pkl` - the trained model file.

### 7. Build Docker Images

```bash
docker-compose build
```

### 8. Start Services

```bash
docker-compose up -d
```

### 9. Verify Everything Works

```bash
# Check containers
docker-compose ps

# Test API
curl http://localhost:5000/health

# Make prediction
curl -X POST http://localhost:5000/predict \
  -H "Content-Type: application/json" \
  -d '{"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2}'
```

---

## 🌐 Access Your Application

Get your public IP:
```bash
curl http://169.254.169.254/latest/meta-data/public-ipv4
```

Then access:
- **Streamlit UI**: `http://YOUR-IP:8501`
- **Flask API**: `http://YOUR-IP:5000`
- **Health Check**: `http://YOUR-IP:5000/health`

---

## 🔒 Security Group Configuration

Make sure these ports are open in your EC2 Security Group:

| Port | Service | Protocol |
|------|---------|----------|
| 22 | SSH | TCP |
| 5000 | Flask API | TCP |
| 8501 | Streamlit UI | TCP |
| 8080 | Jenkins (optional) | TCP |

**To configure:**
1. Go to EC2 Console
2. Select your instance
3. Click Security → Security Groups
4. Edit Inbound Rules
5. Add rules for ports 5000, 8501, 8080
6. Source: 0.0.0.0/0 (or your IP for security)

---

## 🐛 Troubleshooting

### Docker Permission Denied

```bash
sudo usermod -aG docker $USER
# Log out and back in
```

### Services Won't Start

```bash
# Check Docker is running
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Rebuild containers
docker-compose down
docker-compose build
docker-compose up -d
```

### Model Not Found

```bash
python3 app/train_model.py
ls -lh app/model.pkl
```

### Can't Access from Browser

1. **Check Security Group**: Ports 5000, 8501 must be open
2. **Use Public IP**: Not localhost
3. **Check Firewall**:
   ```bash
   sudo firewall-cmd --list-all
   sudo firewall-cmd --permanent --add-port=5000/tcp
   sudo firewall-cmd --permanent --add-port=8501/tcp
   sudo firewall-cmd --reload
   ```

### Port Already in Use

```bash
# Stop existing services
docker-compose down

# Or kill specific port
sudo lsof -ti:5000 | xargs kill -9
sudo lsof -ti:8501 | xargs kill -9
```

---

## 📊 Verification Checklist

After installation, verify:

- [ ] Python 3 installed: `python3 --version`
- [ ] Docker installed: `docker --version`
- [ ] Docker Compose installed: `docker-compose --version`
- [ ] Python packages installed: `pip3 list | grep flask`
- [ ] Model trained: `ls -lh app/model.pkl`
- [ ] Docker images built: `docker images | grep mlops`
- [ ] Containers running: `docker-compose ps`
- [ ] API healthy: `curl http://localhost:5000/health`
- [ ] UI accessible: `curl http://localhost:8501`

---

## 🔄 Updating the Application

```bash
# Pull latest code
git pull origin main

# Retrain model (if needed)
python3 app/train_model.py

# Rebuild and restart
docker-compose build
docker-compose up -d
```

---

## 🛑 Uninstalling

```bash
# Stop and remove containers
docker-compose down -v

# Remove Docker images
docker rmi mlops-flask-api:latest mlops-streamlit-ui:latest

# Remove project directory
cd ..
rm -rf devops-project-7.1
```

---

## 📚 Next Steps

1. **Test the Application**: `bash scripts/test.sh`
2. **Set Up Jenkins**: `sudo bash scripts/install_jenkins.sh`
3. **Read Documentation**: Check `README.md`
4. **Customize**: Modify code for your needs

---

## 💡 Tips

- **View Logs**: `docker-compose logs -f`
- **Restart Services**: `docker-compose restart`
- **Check Status**: `docker-compose ps`
- **Stop Services**: `bash scripts/stop.sh`
- **Run Tests**: `bash scripts/test.sh`

---

## 📞 Need Help?

1. Check logs: `docker-compose logs`
2. Run tests: `bash scripts/test.sh`
3. Review [README.md](README.md)
4. Check [Troubleshooting](#troubleshooting) section

---

**Installation complete! Your MLOps pipeline is ready to use! 🎉**
