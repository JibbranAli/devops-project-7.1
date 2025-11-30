# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Option 1: One-Command Setup (Easiest)

```bash
curl -fsSL https://raw.githubusercontent.com/JibbranAli/devops-project-7.1/main/scripts/setup.sh | sudo bash
```

Then start the services:

```bash
./scripts/start.sh
```

### Option 2: Clone and Setup

```bash
# Clone repository
git clone https://github.com/JibbranAli/devops-project-7.1.git
cd devops-project-7.1

# Run setup
chmod +x scripts/*.sh
sudo ./scripts/setup.sh

# Start services
./scripts/start.sh
```

### Access Your Application

- **Streamlit UI**: http://YOUR-IP:8501
- **Flask API**: http://YOUR-IP:5000

### Test the API

```bash
curl -X POST http://YOUR-IP:5000/predict \
  -H "Content-Type: application/json" \
  -d '{"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2}'
```

## 🔧 Manual Setup

If you prefer step-by-step:

```bash
# 1. Install dependencies
sudo yum update -y
sudo yum install -y python3 python3-pip docker git
sudo systemctl start docker
sudo usermod -aG docker $USER

# 2. Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 3. Clone and setup
git clone https://github.com/JibbranAli/devops-project-7.1.git
cd devops-project-7.1
pip3 install --user -r requirements.txt

# 4. Train model
python3 app/train_model.py

# 5. Build and start
docker-compose build
docker-compose up -d
```

## 🔄 Jenkins Setup

```bash
# Install Jenkins
sudo ./scripts/install_jenkins.sh

# Access Jenkins at http://YOUR-IP:8080
# Create Pipeline job pointing to your GitHub repo
```

## 📝 Common Commands

```bash
# Start services
./scripts/start.sh

# Stop services
./scripts/stop.sh

# Run tests
./scripts/test.sh

# View logs
docker-compose logs -f

# Check status
docker-compose ps
```

## 🐛 Troubleshooting

**Services won't start?**
```bash
docker-compose down
docker-compose build
docker-compose up -d
```

**Model not found?**
```bash
python3 app/train_model.py
```

**Can't access from browser?**
- Check Security Group: Open ports 5000, 8501
- Check firewall: `sudo firewall-cmd --list-all`

For more help, see the main [README.md](README.md)
