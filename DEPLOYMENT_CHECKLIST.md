# Deployment Checklist

## ✅ Pre-Deployment

### AWS EC2 Setup
- [ ] Launch EC2 instance (Amazon Linux 2023)
- [ ] Instance type: t2.medium or larger
- [ ] Storage: 15+ GB
- [ ] Security Group configured:
  - [ ] Port 22 (SSH)
  - [ ] Port 5000 (Flask API)
  - [ ] Port 8501 (Streamlit)
  - [ ] Port 8080 (Jenkins - optional)
- [ ] Key pair downloaded
- [ ] Elastic IP assigned (optional)

### Local Setup
- [ ] SSH key permissions fixed (`chmod 400 key.pem`)
- [ ] Can connect to EC2: `ssh -i key.pem ec2-user@YOUR-IP`

## 🚀 Deployment Steps

### Option 1: Automated Deployment

```bash
# 1. Connect to EC2
ssh -i key.pem ec2-user@YOUR-IP

# 2. Clone repository
git clone https://github.com/JibbranAli/devops-project-7.1.git
cd devops-project-7.1

# 3. Run setup
chmod +x scripts/*.sh
sudo ./scripts/setup.sh

# 4. Start services
./scripts/start.sh

# 5. Test
./scripts/test.sh
```

**Checklist:**
- [ ] Repository cloned
- [ ] Setup script completed
- [ ] Services started
- [ ] Tests passed

### Option 2: Jenkins Pipeline

```bash
# 1. Install Jenkins
sudo ./scripts/install_jenkins.sh

# 2. Access Jenkins
# Open: http://YOUR-IP:8080

# 3. Configure Pipeline
# - Create new Pipeline job
# - Point to GitHub repo
# - Use Jenkinsfile

# 4. Run Pipeline
# Click "Build Now"
```

**Checklist:**
- [ ] Jenkins installed
- [ ] Jenkins accessible
- [ ] Pipeline job created
- [ ] First build successful

## 🔍 Verification

### Check Services
```bash
# Container status
docker-compose ps

# Should show:
# - mlops-flask-api (Up)
# - mlops-streamlit-ui (Up)
```

- [ ] Flask API container running
- [ ] Streamlit UI container running

### Test API
```bash
# Health check
curl http://YOUR-IP:5000/health

# Should return: {"status": "healthy"}
```

- [ ] API health check passes

### Test Prediction
```bash
curl -X POST http://YOUR-IP:5000/predict \
  -H "Content-Type: application/json" \
  -d '{"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2}'

# Should return prediction
```

- [ ] Prediction endpoint works

### Test UI
```bash
# Open in browser
http://YOUR-IP:8501
```

- [ ] Streamlit UI loads
- [ ] Sliders work
- [ ] Predictions work

## 📊 Post-Deployment

### Documentation
- [ ] Note down URLs:
  - API: http://YOUR-IP:5000
  - UI: http://YOUR-IP:8501
  - Jenkins: http://YOUR-IP:8080
- [ ] Save Jenkins password
- [ ] Document any custom configurations

### Monitoring
- [ ] Check logs: `docker-compose logs`
- [ ] Monitor resource usage: `docker stats`
- [ ] Set up alerts (optional)

### Backup
- [ ] Backup model file: `app/model.pkl`
- [ ] Backup configuration files
- [ ] Document deployment process

## 🐛 Troubleshooting Checklist

### Services Won't Start
- [ ] Check Docker is running: `sudo systemctl status docker`
- [ ] Check logs: `docker-compose logs`
- [ ] Rebuild: `docker-compose build`
- [ ] Restart: `docker-compose restart`

### Can't Access from Browser
- [ ] Security Group ports open
- [ ] Using public IP (not localhost)
- [ ] Firewall configured: `sudo firewall-cmd --list-all`
- [ ] Services running: `docker-compose ps`

### Model Not Found
- [ ] Train model: `python3 app/train_model.py`
- [ ] Check file exists: `ls -lh app/model.pkl`
- [ ] Rebuild containers: `docker-compose build`

### Jenkins Issues
- [ ] Jenkins running: `sudo systemctl status jenkins`
- [ ] Jenkins user in docker group: `groups jenkins`
- [ ] Restart Jenkins: `sudo systemctl restart jenkins`

## 📝 Maintenance Checklist

### Daily
- [ ] Check service status
- [ ] Review logs for errors
- [ ] Monitor resource usage

### Weekly
- [ ] Update system packages
- [ ] Check for security updates
- [ ] Review application logs

### Monthly
- [ ] Backup model and data
- [ ] Review and update documentation
- [ ] Test disaster recovery

## 🔄 Update Checklist

### Code Updates
```bash
# 1. Pull latest code
git pull origin main

# 2. Retrain model (if needed)
python3 app/train_model.py

# 3. Rebuild and restart
docker-compose build
docker-compose up -d

# 4. Test
./scripts/test.sh
```

- [ ] Code updated
- [ ] Model retrained
- [ ] Containers rebuilt
- [ ] Tests passed

### Jenkins Updates
```bash
# Push to GitHub
git push origin main

# Jenkins will automatically:
# - Pull code
# - Train model
# - Build images
# - Deploy
```

- [ ] Code pushed to GitHub
- [ ] Jenkins build triggered
- [ ] Build successful
- [ ] Deployment verified

## ✅ Final Verification

### All Systems Go
- [ ] API responding: `curl http://YOUR-IP:5000/health`
- [ ] UI accessible: Open `http://YOUR-IP:8501`
- [ ] Predictions working: Test via UI and API
- [ ] Logs clean: `docker-compose logs | grep -i error`
- [ ] Resources normal: `docker stats`

### Documentation Complete
- [ ] README.md reviewed
- [ ] URLs documented
- [ ] Credentials saved
- [ ] Team notified

### Ready for Production
- [ ] All tests passing
- [ ] Performance acceptable
- [ ] Monitoring in place
- [ ] Backup configured
- [ ] Documentation complete

## 🎉 Success!

If all checkboxes are checked, your MLOps pipeline is successfully deployed!

**Access your application:**
- 🌐 Streamlit UI: http://YOUR-IP:8501
- 🔌 Flask API: http://YOUR-IP:5000
- 🔄 Jenkins: http://YOUR-IP:8080

**Next steps:**
1. Share with your team
2. Add to your portfolio
3. Customize for your needs
4. Scale as needed

---

**Need help?** Check [README.md](README.md) or [TROUBLESHOOTING.md](README.md#troubleshooting)
