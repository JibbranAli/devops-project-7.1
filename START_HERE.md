# 🚀 START HERE - Complete MLOps Pipeline

## Welcome! 👋

This is your **complete, production-ready MLOps pipeline** for Iris flower classification.

Everything is automated, documented, and ready to deploy!

---

## 🎯 What This Does

Trains a machine learning model and deploys it with:
- **Flask REST API** (port 5000) - For predictions
- **Streamlit Web UI** (port 8501) - For easy testing
- **Jenkins CI/CD** (port 8080) - For automation
- **Docker** - For containerization

---

## ⚡ Quick Start (Choose One)

### Option 1: Automated Setup (Recommended)

```bash
# On your EC2 instance:
git clone https://github.com/JibbranAli/devops-project-7.1.git
cd devops-project-7.1
chmod +x scripts/*.sh
sudo ./scripts/setup.sh
./scripts/start.sh
```

**Time**: 5 minutes ⏱️

### Option 2: Jenkins Pipeline

```bash
# Install Jenkins
sudo ./scripts/install_jenkins.sh

# Then create pipeline in Jenkins UI
# Point to: https://github.com/JibbranAli/devops-project-7.1.git
```

**Time**: 10 minutes initial setup, then automatic ⏱️

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **[README.md](README.md)** | Complete guide with everything |
| **[QUICKSTART.md](QUICKSTART.md)** | Fast setup instructions |
| **[PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)** | File organization |
| **[DEPLOYMENT_SUMMARY.md](DEPLOYMENT_SUMMARY.md)** | What you get |
| **[DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)** | Step-by-step checklist |

**Start with**: [README.md](README.md) for complete information

---

## 🏗️ Project Structure

```
mlops-redesign/
├── app/                    # Application code
│   ├── train_model.py     # Train ML model
│   ├── flask_app.py       # REST API
│   └── streamlit_app.py   # Web UI
│
├── docker/                 # Docker configs
│   ├── Dockerfile.flask
│   └── Dockerfile.streamlit
│
├── scripts/                # Automation
│   ├── setup.sh           # Complete setup
│   ├── start.sh           # Start services
│   ├── stop.sh            # Stop services
│   ├── test.sh            # Run tests
│   └── install_jenkins.sh # Jenkins setup
│
├── docker-compose.yml      # Container orchestration
├── Jenkinsfile            # CI/CD pipeline
└── requirements.txt       # Python dependencies
```

---

## 🎓 How It Works

```
1. Train Model
   ↓
2. Build Docker Images
   ↓
3. Start Containers
   ↓
4. Access via Browser
```

**User Flow:**
```
User → Streamlit UI → Flask API → ML Model → Prediction
```

---

## 🔧 Common Commands

```bash
# Start everything
./scripts/start.sh

# Stop everything
./scripts/stop.sh

# Run tests
./scripts/test.sh

# View logs
docker-compose logs -f

# Check status
docker-compose ps
```

---

## 🌐 Access URLs

After deployment:

- **Streamlit UI**: `http://YOUR-IP:8501`
- **Flask API**: `http://YOUR-IP:5000`
- **Jenkins**: `http://YOUR-IP:8080`

Replace `YOUR-IP` with your EC2 public IP.

---

## 🧪 Test the API

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

**Expected Response:**
```json
{
  "prediction": "Setosa",
  "confidence": 0.98
}
```

---

## ✅ Verification Checklist

After deployment, verify:

- [ ] Containers running: `docker-compose ps`
- [ ] API healthy: `curl http://YOUR-IP:5000/health`
- [ ] UI accessible: Open `http://YOUR-IP:8501` in browser
- [ ] Predictions work: Test via UI or API
- [ ] Tests pass: `./scripts/test.sh`

---

## 🐛 Troubleshooting

### Services won't start?
```bash
docker-compose down
docker-compose build
docker-compose up -d
```

### Model not found?
```bash
python3 app/train_model.py
```

### Can't access from browser?
- Check Security Group (ports 5000, 8501 open)
- Use public IP (not localhost)
- Check firewall: `sudo firewall-cmd --list-all`

**More help**: See [README.md](README.md#troubleshooting)

---

## 📊 What You Get

- ✅ **3 Python applications** (train, API, UI)
- ✅ **2 Docker containers** (Flask, Streamlit)
- ✅ **5 automation scripts** (setup, start, stop, test, Jenkins)
- ✅ **1 Jenkins pipeline** (complete CI/CD)
- ✅ **5 documentation files** (comprehensive guides)
- ✅ **Complete automation** (one command to deploy)

**Total**: 20 files, ~1,500 lines of code

---

## 🎯 Next Steps

### For Learning
1. Read [README.md](README.md)
2. Explore the code
3. Modify and experiment
4. Add new features

### For Deployment
1. Follow [QUICKSTART.md](QUICKSTART.md)
2. Use [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)
3. Set up Jenkins
4. Automate everything!

### For Production
1. Add authentication
2. Enable HTTPS
3. Add monitoring
4. Configure backups
5. Scale as needed

---

## 🌟 Key Features

- **Simple**: Easy to understand and modify
- **Complete**: Everything included
- **Automated**: One command deployment
- **Production-Ready**: Docker + CI/CD
- **Well-Documented**: Comprehensive guides
- **Tested**: Health checks included

---

## 📞 Need Help?

1. **Check Documentation**: [README.md](README.md)
2. **Run Tests**: `./scripts/test.sh`
3. **View Logs**: `docker-compose logs`
4. **GitHub Issues**: Open an issue on GitHub

---

## 🎉 Ready to Deploy?

### Automated Way (5 minutes)
```bash
sudo ./scripts/setup.sh && ./scripts/start.sh
```

### Manual Way (10 minutes)
Follow [README.md](README.md#manual-setup)

### Jenkins Way (Automatic)
Follow [README.md](README.md#jenkins-pipeline)

---

## 📝 Repository

**GitHub**: https://github.com/JibbranAli/devops-project-7.1

**Clone**:
```bash
git clone https://github.com/JibbranAli/devops-project-7.1.git
```

---

## ✨ Made With

- Python 3.9
- Flask (API)
- Streamlit (UI)
- scikit-learn (ML)
- Docker (Containers)
- Jenkins (CI/CD)

---

**Made with ❤️ for learning MLOps**

**Questions?** Read the [README.md](README.md) or open a GitHub issue!

🚀 **Let's deploy!**
