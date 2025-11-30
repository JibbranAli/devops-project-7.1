# Project Structure

## 📁 Directory Layout

```
mlops-redesign/
│
├── app/                          # Application code
│   ├── train_model.py           # ML model training script
│   ├── flask_app.py             # Flask REST API
│   ├── streamlit_app.py         # Streamlit web UI
│   └── model.pkl                # Trained model (generated)
│
├── docker/                       # Docker configurations
│   ├── Dockerfile.flask         # Flask API container
│   └── Dockerfile.streamlit     # Streamlit UI container
│
├── scripts/                      # Automation scripts
│   ├── setup.sh                 # Complete automated setup
│   ├── start.sh                 # Start all services
│   ├── stop.sh                  # Stop all services
│   ├── test.sh                  # Run tests
│   └── install_jenkins.sh       # Install Jenkins
│
├── docker-compose.yml            # Container orchestration
├── Jenkinsfile                   # CI/CD pipeline definition
├── requirements.txt              # Python dependencies
├── .gitignore                    # Git ignore rules
├── .dockerignore                 # Docker ignore rules
├── README.md                     # Main documentation
├── QUICKSTART.md                 # Quick start guide
└── PROJECT_STRUCTURE.md          # This file
```

## 📄 File Descriptions

### Application Files

**app/train_model.py**
- Trains Random Forest classifier on Iris dataset
- Saves model as `model.pkl`
- Displays accuracy and metrics
- ~120 lines

**app/flask_app.py**
- REST API for predictions
- Endpoints: /, /health, /info, /predict
- Loads and serves the trained model
- ~200 lines

**app/streamlit_app.py**
- Interactive web interface
- Sliders for flower measurements
- Real-time predictions
- ~150 lines

### Docker Files

**docker/Dockerfile.flask**
- Flask API container definition
- Based on Python 3.9-slim
- Exposes port 5000

**docker/Dockerfile.streamlit**
- Streamlit UI container definition
- Based on Python 3.9-slim
- Exposes port 8501

**docker-compose.yml**
- Orchestrates both containers
- Sets up networking
- Defines health checks

### Scripts

**scripts/setup.sh**
- Complete automated installation
- Installs all dependencies
- Trains model
- Builds Docker images

**scripts/start.sh**
- Starts Docker containers
- Shows access URLs
- Displays status

**scripts/stop.sh**
- Stops all containers
- Cleans up resources

**scripts/test.sh**
- Tests all components
- Verifies API health
- Makes test predictions

**scripts/install_jenkins.sh**
- Installs Jenkins
- Configures for CI/CD
- Shows initial password

### CI/CD

**Jenkinsfile**
- Pipeline definition
- 8 stages: Checkout → Install → Train → Build → Stop → Start → Health → Test
- Automatic deployment

### Configuration

**requirements.txt**
- Python dependencies
- Flask, scikit-learn, streamlit, etc.

**.gitignore**
- Excludes Python cache, models, IDE files

**.dockerignore**
- Excludes unnecessary files from Docker images

## 🔄 Data Flow

```
1. User → Streamlit UI (port 8501)
2. Streamlit → Flask API (port 5000)
3. Flask → Trained Model (model.pkl)
4. Model → Prediction
5. Flask → JSON Response
6. Streamlit → Display Result
```

## 🏗️ Build Process

### Manual Build

```bash
1. Train model: python3 app/train_model.py
2. Build images: docker-compose build
3. Start services: docker-compose up -d
```

### Jenkins Build

```bash
1. Checkout code from GitHub
2. Install Python dependencies
3. Train ML model
4. Build Docker images
5. Stop old containers
6. Start new containers
7. Run health checks
8. Run tests
```

## 📊 Component Sizes

| Component | Lines of Code | Purpose |
|-----------|--------------|---------|
| train_model.py | ~120 | Train ML model |
| flask_app.py | ~200 | REST API |
| streamlit_app.py | ~150 | Web UI |
| Jenkinsfile | ~100 | CI/CD pipeline |
| setup.sh | ~80 | Automated setup |
| README.md | ~800 | Documentation |

**Total**: ~1,450 lines of code

## 🎯 Key Features

- ✅ Complete automation with scripts
- ✅ Docker containerization
- ✅ Jenkins CI/CD pipeline
- ✅ Health checks and monitoring
- ✅ Clean, simple architecture
- ✅ Comprehensive documentation
- ✅ Easy to understand and modify

## 🔧 Customization

### Change ML Model

Edit `app/train_model.py`:
- Change dataset
- Modify model parameters
- Add new features

### Modify API

Edit `app/flask_app.py`:
- Add new endpoints
- Change response format
- Add authentication

### Update UI

Edit `app/streamlit_app.py`:
- Change layout
- Add visualizations
- Modify styling

### Adjust Pipeline

Edit `Jenkinsfile`:
- Add new stages
- Modify build steps
- Add notifications

## 📚 Dependencies

### System Requirements
- Amazon Linux 2023 or RHEL
- 2+ GB RAM
- 10+ GB disk space

### Software Dependencies
- Python 3.9+
- Docker
- Docker Compose
- Git

### Python Packages
- flask (API framework)
- scikit-learn (ML library)
- streamlit (UI framework)
- numpy (numerical computing)
- joblib (model serialization)

## 🚀 Deployment Options

### Local Development
```bash
python3 app/flask_app.py  # Run API locally
streamlit run app/streamlit_app.py  # Run UI locally
```

### Docker (Recommended)
```bash
docker-compose up -d  # Run in containers
```

### Jenkins (Automated)
```bash
# Push to GitHub → Jenkins builds → Auto-deploy
```

## 📈 Scalability

Current setup is for single-server deployment. To scale:

1. **Load Balancer**: Add nginx for multiple API instances
2. **Database**: Store predictions in PostgreSQL
3. **Caching**: Add Redis for faster responses
4. **Monitoring**: Add Prometheus + Grafana
5. **Kubernetes**: Deploy on EKS for auto-scaling

## 🔒 Security Considerations

Current setup is for development/learning. For production:

1. Add API authentication (JWT tokens)
2. Enable HTTPS with SSL certificates
3. Restrict Security Group rules
4. Use secrets management (AWS Secrets Manager)
5. Add rate limiting
6. Enable CORS properly
7. Add input validation

## 📝 License

MIT License - Free to use for learning and development
