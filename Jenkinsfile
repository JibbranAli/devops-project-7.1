pipeline {
    agent any
    
    environment {
        PROJECT_NAME = 'mlops-iris-classifier'
        FLASK_IMAGE = 'mlops-flask-api:latest'
        STREAMLIT_IMAGE = 'mlops-streamlit-ui:latest'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '📥 Checking out code from repository...'
                checkout scm
                sh 'ls -la'
            }
        }
        
        stage('Install Dependencies') {
            steps {
                echo '📦 Installing Python dependencies...'
                sh '''
                    python3 --version
                    pip3 install --user -r requirements.txt
                '''
            }
        }
        
        stage('Train Model') {
            steps {
                echo '🤖 Training ML model...'
                sh '''
                    python3 app/train_model.py
                    ls -lh app/model.pkl
                '''
            }
        }
        
        stage('Build Docker Images') {
            steps {
                echo '🐳 Building Docker images...'
                sh '''
                    # Build Flask API image
                    docker build -f docker/Dockerfile.flask -t ${FLASK_IMAGE} .
                    
                    # Build Streamlit UI image
                    docker build -f docker/Dockerfile.streamlit -t ${STREAMLIT_IMAGE} .
                    
                    # List images
                    docker images | grep mlops
                '''
            }
        }
        
        stage('Stop Old Containers') {
            steps {
                echo '🛑 Stopping old containers...'
                sh '''
                    docker-compose down || true
                    docker ps -a
                '''
            }
        }
        
        stage('Start New Containers') {
            steps {
                echo '🚀 Starting new containers...'
                sh '''
                    docker-compose up -d
                    sleep 10
                    docker-compose ps
                '''
            }
        }
        
        stage('Health Check') {
            steps {
                echo '❤️ Performing health checks...'
                sh '''
                    # Wait for services to be ready
                    echo "Waiting for Flask API..."
                    for i in {1..30}; do
                        if curl -f http://localhost:5000/health; then
                            echo "✅ Flask API is healthy"
                            break
                        fi
                        echo "Waiting... ($i/30)"
                        sleep 2
                    done
                    
                    # Check Streamlit (it takes longer to start)
                    echo "Waiting for Streamlit UI..."
                    sleep 10
                    
                    echo "✅ All services are running"
                '''
            }
        }
        
        stage('Run Tests') {
            steps {
                echo '🧪 Running tests...'
                sh '''
                    # Test API prediction
                    echo "Testing prediction endpoint..."
                    curl -X POST http://localhost:5000/predict \
                        -H "Content-Type: application/json" \
                        -d '{"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2}' \
                        | grep -q "prediction"
                    
                    echo "✅ Tests passed"
                '''
            }
        }
    }
    
    post {
        always {
            echo '📊 Pipeline execution completed'
            sh 'docker-compose ps || true'
        }
        
        success {
            echo '✅ Pipeline succeeded!'
            echo '🎉 Application deployed successfully'
            sh '''
                echo "=========================================="
                echo "Access your application:"
                echo "  Flask API:     http://$(hostname -I | awk '{print $1}'):5000"
                echo "  Streamlit UI:  http://$(hostname -I | awk '{print $1}'):8501"
                echo "=========================================="
            '''
        }
        
        failure {
            echo '❌ Pipeline failed!'
            sh 'docker-compose logs || true'
        }
    }
}
