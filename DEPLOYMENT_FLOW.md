# MLOps Deployment Flow

## Complete Step-by-Step Deployment Process

This guide shows the exact order of scripts to run for complete deployment.

---

## 📋 Prerequisites

- Amazon Linux 2023 EC2 instance
- SSH access
- Security Group with ports 22, 5000, 8501, 8080 open

---

## 🚀 Deployment Steps

### STEP 1: Initial Setup (5 minutes)

Install all dependencies, train model, and build Docker images.

```bash
# Clone repository
git clone https://github.com/JibbranAli/devops-project-7.1.git
cd devops-project-7.1

# Run setup script
sudo bash scripts/setup.sh
```

**What this does:**
- ✅ Installs Python 3, Docker, Docker Compose
- ✅ Installs Python packages
- ✅ Trains ML model (creates `app/model.pkl`)
- ✅ Builds Docker images locally
- ❌ Does NOT start containers (Jenkins will do this)

**Expected output:**
```
✅ Setup Complete!
Next Steps: Install Jenkins
```

---

### STEP 2: Install Jenkins (2 minutes)

Install Jenkins and get the initial password.

```bash
sudo bash scripts/setup_jenkins.sh
```

**What this does:**
- ✅ Installs Java
- ✅ Installs Jenkins
- ✅ Starts Jenkins service
- ✅ Shows initial admin password

**Expected output:**
```
🔑 Initial Admin Password:
   abc123def456...

Open Jenkins: http://YOUR-IP:8080
```

**Manual Steps Required:**
1. Open `http://YOUR-IP:8080` in browser
2. Paste the password shown
3. Click "Install suggested plugins"
4. Wait 5-10 minutes for plugins to install
5. Create admin user (or skip)
6. Click "Start using Jenkins"

---

### STEP 3: Create Pipeline (2 minutes)

Create the Jenkins pipeline that will build and deploy everything.

```bash
sudo bash scripts/create_pipeline.sh
```

**What this does:**
- ✅ Verifies Jenkins is running
- ✅ Shows step-by-step instructions to create pipeline

**Manual Steps Required:**

1. In Jenkins, click **"New Item"**
2. Name: `mlops-pipeline`
3. Type: **Pipeline**
4. Click **OK**
5. Configure:
   - **Description**: MLOps Pipeline for Iris Classification
   - **Build Triggers**: Check "Poll SCM", Schedule: `H/5 * * * *`
   - **Pipeline**:
     - Definition: **Pipeline script from SCM**
     - SCM: **Git**
     - Repository URL: `https://github.com/JibbranAli/devops-project-7.1.git`
     - Branch: `*/main`
     - Script Path: `Jenkinsfile`
6. Click **Save**
7. Click **"Build Now"**

**Pipeline Stages:**
```
Stage 1: Checkout Code ✓
Stage 2: Install Dependencies ✓
Stage 3: Train Model ✓
Stage 4: Build Docker Images ✓
Stage 5: Stop Old Containers ✓
Stage 6: Deploy Containers ✓
Stage 7: Health Checks ✓
Stage 8: Run Tests ✓
```

**Wait for pipeline to complete** (~5 minutes for first run)

---

### STEP 4: Test Everything (1 minute)

Verify the deployment is working correctly.

```bash
bash scripts/test.sh
```

**What this does:**
- ✅ Checks if containers are running
- ✅ Tests API health endpoint
- ✅ Makes test prediction
- ✅ Verifies Streamlit UI

**Expected output:**
```
✅ All Tests Passed!

Your application is working correctly!
  Streamlit UI: http://YOUR-IP:8501
  Flask API:    http://YOUR-IP:5000
```

---

## 📊 Complete Flow Summary

```
┌─────────────────────────────────────────────────────────┐
│  STEP 1: sudo bash scripts/setup.sh                     │
│  ├─ Install dependencies                                │
│  ├─ Train ML model                                      │
│  └─ Build Docker images                                 │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  STEP 2: sudo bash scripts/setup_jenkins.sh             │
│  ├─ Install Jenkins                                     │
│  ├─ Show initial password                               │
│  └─ Manual: Complete Jenkins setup in browser           │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  STEP 3: sudo bash scripts/create_pipeline.sh           │
│  ├─ Show pipeline creation instructions                 │
│  └─ Manual: Create pipeline in Jenkins UI               │
│                                                          │
│  Then: Click "Build Now" in Jenkins                     │
│  ├─ Jenkins pulls code                                  │
│  ├─ Jenkins builds Docker images                        │
│  ├─ Jenkins deploys containers                          │
│  └─ Jenkins runs tests                                  │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  STEP 4: bash scripts/test.sh                           │
│  ├─ Verify containers running                           │
│  ├─ Test API                                            │
│  └─ Confirm deployment success                          │
└─────────────────────────────────────────────────────────┘
                         ↓
                   ✅ COMPLETE!
```

---

## 🌐 Access Your Application

After all steps complete:

- **Streamlit UI**: `http://YOUR-IP:8501`
- **Flask API**: `http://YOUR-IP:5000`
- **Jenkins**: `http://YOUR-IP:8080`

---

## 🔄 Making Changes

After initial deployment, when you push code to GitHub:

1. Jenkins automatically detects changes (every 5 minutes)
2. Pipeline runs automatically
3. New Docker images are built
4. Containers are redeployed
5. Tests run automatically

**Or manually trigger:**
- Go to Jenkins → mlops-pipeline → Click "Build Now"

---

## 🐛 Troubleshooting

### Setup fails at Step 1
```bash
# Check logs
cat /var/log/messages | grep -i error

# Retry setup
sudo bash scripts/setup.sh
```

### Jenkins won't start
```bash
# Check Jenkins status
sudo systemctl status jenkins

# Restart Jenkins
sudo systemctl restart jenkins

# Check logs
sudo journalctl -u jenkins -n 50
```

### Pipeline fails
```bash
# Check Jenkins console output
# Go to Jenkins → mlops-pipeline → Last build → Console Output

# Check Docker
docker ps -a
docker-compose logs

# Restart pipeline
# Click "Build Now" in Jenkins
```

### Containers not running
```bash
# Check Docker
docker-compose ps
docker-compose logs

# Manually start
docker-compose up -d

# Check again
bash scripts/test.sh
```

---

## 📝 Quick Reference

| Step | Command | Time | Manual Steps |
|------|---------|------|--------------|
| 1 | `sudo bash scripts/setup.sh` | 5 min | None |
| 2 | `sudo bash scripts/setup_jenkins.sh` | 2 min | Browser setup |
| 3 | `sudo bash scripts/create_pipeline.sh` | 2 min | Create pipeline |
| 4 | `bash scripts/test.sh` | 1 min | None |

**Total Time**: ~10 minutes (+ 5 min for first pipeline run)

---

## ✅ Success Criteria

You know deployment is successful when:

- ✅ All 4 scripts complete without errors
- ✅ Jenkins pipeline shows all stages green
- ✅ `docker-compose ps` shows 2 containers "Up"
- ✅ `bash scripts/test.sh` shows "All Tests Passed"
- ✅ You can access Streamlit UI in browser
- ✅ API returns predictions

---

**Made with ❤️ for Amazon Linux EC2**
