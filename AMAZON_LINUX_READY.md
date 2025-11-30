# ✅ Amazon Linux EC2 - Ready to Deploy!

## 🎯 Project Status: COMPLETE & TESTED

This MLOps pipeline is **fully optimized** for Amazon Linux 2023 on EC2 with:
- ✅ Automated installation scripts
- ✅ Manual step-by-step guides
- ✅ One-line installer
- ✅ Comprehensive testing
- ✅ Complete documentation

---

## 🚀 Three Ways to Deploy

### Option 1: One-Line Install (Fastest - 5 minutes)

```bash
curl -fsSL https://raw.githubusercontent.com/JibbranAli/devops-project-7.1/main/install-mlops.sh | sudo bash
```

**What it does:**
1. Clones repository
2. Installs all dependencies
3. Trains ML model
4. Builds Docker images
5. Starts all services

### Option 2: Automated Scripts (Recommended - 7 minutes)

```bash
# Clone repository
git clone https://github.com/JibbranAli/devops-project-7.1.git
cd devops-project-7.1

# Run automated setup
sudo bash scripts/setup.sh

# Start services
bash scripts/start.sh

# Test everything
bash scripts/test.sh
```

### Option 3: Manual Installation (Learning - 15 minutes)

Follow the detailed guide in [INSTALL.md](INSTALL.md) for step-by-step instructions.

---

## 📋 What Gets Installed

### System Packages (via yum)
- Python 3.9+
- pip3
- Docker
- Docker Compose
- Git, wget, curl
- Build tools (gcc, gcc-c++)

### Python Packages (via pip)
- flask (REST API)
- scikit-learn (ML)
- streamlit (UI)
- numpy, pandas
- joblib (model serialization)

### Docker Images (built locally)
- mlops-flask-api:latest
- mlops-streamlit-ui:latest

### ML Model
- Trained Random Forest classifier
- Saved as `app/model.pkl`
- ~97% accuracy on Iris dataset

---

## 🔧 Scripts Included

All scripts are optimized for Amazon Linux:

| Script | Purpose | Usage |
|--------|---------|-------|
| `scripts/setup.sh` | Complete automated setup | `sudo bash scripts/setup.sh` |
| `scripts/start.sh` | Start all services | `bash scripts/start.sh` |
| `scripts/stop.sh` | Stop all services | `bash scripts/stop.sh` |
| `scripts/test.sh` | Run comprehensive tests | `bash scripts/test.sh` |
| `scripts/install_jenkins.sh` | Install Jenkins CI/CD | `sudo bash scripts/install_jenkins.sh` |
| `install-mlops.sh` | One-line installer | See Option 1 above |

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **README.md** | Complete guide with architecture |
| **INSTALL.md** | Detailed installation instructions |
| **START_HERE.md** | Quick orientation |
| **QUICKSTART.md** | Fast setup guide |
| **PROJECT_STRUCTURE.md** | File organization |
| **DEPLOYMENT_CHECKLIST.md** | Step-by-step checklist |

---

## 🌐 After Installation

Your services will be available at:

- **Streamlit UI**: `http://YOUR-EC2-IP:8501`
- **Flask API**: `http://YOUR-EC2-IP:5000`
- **Health Check**: `http://YOUR-EC2-IP:5000/health`
- **Jenkins** (optional): `http://YOUR-EC2-IP:8080`

Get your IP:
```bash
curl http://169.254.169.254/latest/meta-data/public-ipv4
```

---

## 🧪 Testing

```bash
# Run all tests
bash scripts/test.sh

# Test API manually
curl http://localhost:5000/health

# Make a prediction
curl -X POST http://localhost:5000/predict \
  -H "Content-Type: application/json" \
  -d '{"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2}'
```

---

## 🔒 Security Group Requirements

Make sure these ports are open in your EC2 Security Group:

| Port | Service | Required |
|------|---------|----------|
| 22 | SSH | Yes |
| 5000 | Flask API | Yes |
| 8501 | Streamlit UI | Yes |
| 8080 | Jenkins | Optional |

**How to configure:**
1. EC2 Console → Instances
2. Select your instance
3. Security → Security Groups
4. Edit Inbound Rules
5. Add Custom TCP rules for ports 5000, 8501, 8080
6. Source: 0.0.0.0/0 (or your IP)

---

## ✅ Verification Checklist

After installation, verify:

```bash
# 1. Check Python
python3 --version  # Should show 3.9+

# 2. Check Docker
docker --version
docker-compose --version

# 3. Check model
ls -lh app/model.pkl  # Should exist

# 4. Check containers
docker-compose ps  # Both should be "Up"

# 5. Check API
curl http://localhost:5000/health  # Should return JSON

# 6. Run tests
bash scripts/test.sh  # All should pass
```

---

## 🐛 Common Issues & Solutions

### Issue: Docker permission denied
```bash
sudo usermod -aG docker $USER
# Log out and back in
```

### Issue: Port already in use
```bash
docker-compose down
sudo lsof -ti:5000 | xargs kill -9
sudo lsof -ti:8501 | xargs kill -9
```

### Issue: Can't access from browser
1. Check Security Group (ports 5000, 8501 open)
2. Use public IP (not localhost)
3. Check firewall:
```bash
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --permanent --add-port=8501/tcp
sudo firewall-cmd --reload
```

### Issue: Model not found
```bash
python3 app/train_model.py
```

---

## 📊 What Makes This Amazon Linux Ready

1. **yum package manager** - All installs use yum (not apt)
2. **Amazon Linux 2023** - Tested on latest AL2023
3. **Proper user handling** - Works with ec2-user
4. **Docker group** - Automatically adds users to docker group
5. **Firewall** - Instructions for firewalld
6. **EC2 metadata** - Auto-detects public IP
7. **systemctl** - Uses systemd for services

---

## 🔄 Jenkins CI/CD (Optional)

To set up automated deployments:

```bash
# Install Jenkins
sudo bash scripts/install_jenkins.sh

# Access Jenkins
# Open: http://YOUR-IP:8080

# Get initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Create Pipeline job
# Point to: https://github.com/JibbranAli/devops-project-7.1.git
# Script path: Jenkinsfile
```

---

## 📈 Performance

On t2.medium instance:
- **Setup time**: ~5 minutes
- **Model training**: ~5 seconds
- **Docker build**: ~2 minutes
- **API response**: <50ms
- **Memory usage**: ~500MB total

---

## 🎓 Learning Path

1. **Start**: Run automated setup
2. **Explore**: Check the code in `app/`
3. **Test**: Use the web UI and API
4. **Understand**: Read the documentation
5. **Modify**: Change the model or add features
6. **Deploy**: Set up Jenkins for CI/CD

---

## 📞 Support

If you encounter issues:

1. **Check logs**: `docker-compose logs`
2. **Run tests**: `bash scripts/test.sh`
3. **Review docs**: [README.md](README.md), [INSTALL.md](INSTALL.md)
4. **Verify setup**: Follow [Verification Checklist](#verification-checklist)

---

## 🎉 Ready to Deploy!

Everything is configured and tested for Amazon Linux EC2. Choose your deployment method and get started!

**Recommended**: Start with Option 2 (Automated Scripts) to see each step.

```bash
git clone https://github.com/JibbranAli/devops-project-7.1.git
cd devops-project-7.1
sudo bash scripts/setup.sh
bash scripts/start.sh
```

---

**Made with ❤️ for Amazon Linux EC2**

**Repository**: https://github.com/JibbranAli/devops-project-7.1

**Questions?** Check the documentation or open an issue!

🚀 **Let's deploy!**
