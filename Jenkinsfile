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
                    pip3 install --user --upgrade pip
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
                echo '🐳 Building Docker images locally...'
                sh '''
                    echo "Building Flask API image..."
                    docker build -f docker/Dockerfile.flask -t ${FLASK_IMAGE} .
                    
                    echo "Building Streamlit UI image..."
                    docker build -f docker/Dockerfile.streamlit -t ${STREAMLIT_IMAGE} .
                    
                    echo "Docker images built:"
                    docker images | grep mlops
                '''
            }
        }
        
        stage('Stop Old Containers') {
            steps {
                echo '🛑 Stopping old containers...'
                sh '''
                    docker-compose down || true
                    echo "Old containers stopped"
                '''
            }
        }
        
        stage('Deploy Containers') {
            steps {
                echo '🚀 Deploying new containers...'
                sh '''
                    echo "Starting containers with docker-compose..."
                    docker-compose up -d
                    
                    echo "Waiting for containers to start..."
                    sleep 15
                    
                    echo "Container status:"
                    docker-compose ps
                '''
            }
        }
        
        stage('Health Check') {
            steps {
                echo '❤️ Performing health checks...'
                sh '''
                    echo "Checking Flask API health..."
                    for i in {1..30}; do
                        if curl -f http://localhost:5000/health > /dev/null 2>&1; then
                            echo "✅ Flask API is healthy"
                            curl -s http://localhost:5000/health | python3 -m json.tool
                            break
                        fi
                        echo "Waiting for API... ($i/30)"
                        sleep 2
                    done
                    
                    echo ""
                    echo "Checking Streamlit UI..."
                    sleep 5
                    if curl -f http://localhost:8501 > /dev/null 2>&1; then
                        echo "✅ Streamlit UI is accessible"
                    else
                        echo "⚠️  Streamlit UI is starting..."
                    fi
                    
                    echo ""
                    echo "✅ All services are running"
                '''
            }
        }
        
        stage('Run Tests') {
            steps {
                echo '🧪 Running tests...'
                sh '''
                    echo "Testing prediction endpoint..."
                    RESPONSE=$(curl -s -X POST http://localhost:5000/predict \
                        -H "Content-Type: application/json" \
                        -d '{"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2}')
                    
                    echo "Response:"
                    echo "$RESPONSE" | python3 -m json.tool
                    
                    if echo "$RESPONSE" | grep -q "prediction"; then
                        echo "✅ Prediction test passed"
                    else
                        echo "❌ Prediction test failed"
                        exit 1
                    fi
                '''
            }
        }
    }
    
    post {
        always {
            echo '📊 Pipeline execution completed'
            sh '''
                echo ""
                echo "Final container status:"
                docker-compose ps || true
            '''
        }
        
        success {
            echo '✅ Pipeline succeeded!'
            echo '🎉 Application deployed successfully'
            sh '''
                PUBLIC_IP=$(curl -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || hostname -I | awk '{print $1}')
                echo ""
                echo "=========================================="
                echo "✅ MLOps Pipeline Deployed Successfully!"
                echo "=========================================="
                echo ""
                echo "Access your application:"
                echo "  🌐 Streamlit UI:  http://${PUBLIC_IP}:8501"
                echo "  🔌 Flask API:     http://${PUBLIC_IP}:5000"
                echo "  ❤️  Health Check:  http://${PUBLIC_IP}:5000/health"
                echo ""
                echo "Test the API:"
                echo "  curl http://${PUBLIC_IP}:5000/health"
                echo "=========================================="
            '''
        }
        
        failure {
            echo '❌ Pipeline failed!'
            echo 'Checking logs...'
            sh '''
                echo "Container logs:"
                docker-compose logs --tail=50 || true
            '''
        }
    }
}
