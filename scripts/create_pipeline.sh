#!/bin/bash
#
# Automated Jenkins Pipeline Creation Script
# Creates the MLOps pipeline in Jenkins automatically
#

set -e

# Get script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Change to project root
cd "$PROJECT_ROOT"

echo "╔════════════════════════════════════════════════════════╗"
echo "║                                                        ║"
echo "║     STEP 3: Automated Pipeline Creation               ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run with sudo: sudo bash scripts/create_pipeline.sh"
    exit 1
fi

# Get public IP
PUBLIC_IP=$(curl -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || curl -s https://api.ipify.org 2>/dev/null || hostname -I | awk '{print $1}')

echo "📍 Your IP: $PUBLIC_IP"
echo ""

# Check if Jenkins is running
if ! systemctl is-active --quiet jenkins; then
    echo "❌ Jenkins is not running!"
    echo "Start it with: sudo systemctl start jenkins"
    exit 1
fi

echo "✅ Jenkins is running at: http://${PUBLIC_IP}:8080"
echo ""

# Wait for Jenkins to be fully ready
echo "⏳ Waiting for Jenkins to be fully ready..."
for i in {1..30}; do
    if curl -s http://localhost:8080/login > /dev/null 2>&1; then
        echo "✅ Jenkins is ready"
        break
    fi
    sleep 2
done

echo ""
echo "════════════════════════════════════════════════════════"
echo "Jenkins Authentication Required"
echo "════════════════════════════════════════════════════════"
echo ""
echo "To create the pipeline automatically, we need Jenkins credentials."
echo ""
echo "📋 How to get your credentials:"
echo ""
echo "1. Open Jenkins: http://${PUBLIC_IP}:8080"
echo ""
echo "2. If this is your first time:"
echo "   - Use username: admin"
echo "   - Password: (the initial password you used during setup)"
echo ""
echo "3. If you created a custom user:"
echo "   - Use your username and password"
echo ""
echo "4. To get an API token (recommended):"
echo "   - Click your name (top right)"
echo "   - Click 'Configure'"
echo "   - Click 'Add new Token'"
echo "   - Click 'Generate'"
echo "   - Copy the token"
echo ""
echo "════════════════════════════════════════════════════════"
echo ""

# Ask for credentials
read -p "Enter Jenkins username [admin]: " JENKINS_USER
JENKINS_USER=${JENKINS_USER:-admin}

echo ""
echo "Enter Jenkins password or API token:"
echo "(Input will be hidden for security)"
read -s JENKINS_PASSWORD
echo ""

if [ -z "$JENKINS_PASSWORD" ]; then
    echo "❌ Password cannot be empty!"
    exit 1
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo "Creating Pipeline..."
echo "════════════════════════════════════════════════════════"
echo ""

# Test authentication
echo "[1/5] Testing Jenkins authentication..."
AUTH_TEST=$(curl -s -u "${JENKINS_USER}:${JENKINS_PASSWORD}" http://localhost:8080/api/json)

if echo "$AUTH_TEST" | grep -q "authenticated"; then
    echo "✅ Authentication successful"
elif echo "$AUTH_TEST" | grep -q "jobs"; then
    echo "✅ Authentication successful"
else
    echo "❌ Authentication failed!"
    echo "Please check your username and password/token"
    exit 1
fi

# Download Jenkins CLI
echo ""
echo "[2/5] Downloading Jenkins CLI..."
wget -q http://localhost:8080/jnlpJars/jenkins-cli.jar -O /tmp/jenkins-cli.jar
echo "✅ Jenkins CLI downloaded"

# Create pipeline configuration XML
echo ""
echo "[3/5] Creating pipeline configuration..."
cat > /tmp/mlops-pipeline-config.xml <<'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job">
  <description>MLOps Pipeline - Automated ML Model Deployment with Docker</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
      <triggers>
        <hudson.triggers.SCMTrigger>
          <spec>H/5 * * * *</spec>
          <ignorePostCommitHooks>false</ignorePostCommitHooks>
        </hudson.triggers.SCMTrigger>
      </triggers>
    </org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps">
    <scm class="hudson.plugins.git.GitSCM" plugin="git">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>https://github.com/JibbranAli/devops-project-7.1.git</url>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/main</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class="empty-list"/>
      <extensions/>
    </scm>
    <scriptPath>Jenkinsfile</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF

echo "✅ Pipeline configuration created"

# Check if job already exists
echo ""
echo "[4/5] Checking if pipeline already exists..."
JOB_EXISTS=$(curl -s -u "${JENKINS_USER}:${JENKINS_PASSWORD}" http://localhost:8080/job/mlops-pipeline/api/json 2>/dev/null || echo "")

if echo "$JOB_EXISTS" | grep -q "name"; then
    echo "⚠️  Pipeline 'mlops-pipeline' already exists"
    read -p "Do you want to delete and recreate it? (yes/no): " RECREATE
    
    if [ "$RECREATE" = "yes" ]; then
        echo "Deleting existing pipeline..."
        java -jar /tmp/jenkins-cli.jar -s http://localhost:8080/ -auth "${JENKINS_USER}:${JENKINS_PASSWORD}" delete-job mlops-pipeline 2>/dev/null || true
        echo "✅ Existing pipeline deleted"
    else
        echo "Keeping existing pipeline"
        echo ""
        echo "════════════════════════════════════════════════════════"
        echo "✅ Pipeline Already Exists!"
        echo "════════════════════════════════════════════════════════"
        echo ""
        echo "Access it at: http://${PUBLIC_IP}:8080/job/mlops-pipeline/"
        echo ""
        echo "To run the pipeline:"
        echo "  1. Open: http://${PUBLIC_IP}:8080/job/mlops-pipeline/"
        echo "  2. Click 'Build Now'"
        echo ""
        exit 0
    fi
fi

# Create the pipeline
echo ""
echo "[5/5] Creating Jenkins pipeline..."
CREATE_RESULT=$(java -jar /tmp/jenkins-cli.jar -s http://localhost:8080/ -auth "${JENKINS_USER}:${JENKINS_PASSWORD}" create-job mlops-pipeline < /tmp/mlops-pipeline-config.xml 2>&1)

if echo "$CREATE_RESULT" | grep -q "error"; then
    echo "❌ Failed to create pipeline"
    echo "Error: $CREATE_RESULT"
    exit 1
else
    echo "✅ Pipeline created successfully!"
fi

# Trigger first build
echo ""
echo "════════════════════════════════════════════════════════"
echo "Triggering First Build..."
echo "════════════════════════════════════════════════════════"
echo ""

read -p "Do you want to start the first build now? (yes/no): " START_BUILD

if [ "$START_BUILD" = "yes" ]; then
    echo "Starting build..."
    java -jar /tmp/jenkins-cli.jar -s http://localhost:8080/ -auth "${JENKINS_USER}:${JENKINS_PASSWORD}" build mlops-pipeline 2>/dev/null || true
    echo "✅ Build started!"
    echo ""
    echo "Monitor the build at:"
    echo "  http://${PUBLIC_IP}:8080/job/mlops-pipeline/"
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo "✅ Pipeline Creation Complete!"
echo "════════════════════════════════════════════════════════"
echo ""
echo "📋 Pipeline Details:"
echo "  Name: mlops-pipeline"
echo "  URL: http://${PUBLIC_IP}:8080/job/mlops-pipeline/"
echo "  Repository: https://github.com/JibbranAli/devops-project-7.1.git"
echo "  Branch: main"
echo "  Jenkinsfile: Jenkinsfile"
echo "  Polling: Every 5 minutes (H/5 * * * *)"
echo ""
echo "🎯 What the Pipeline Does:"
echo "  1. Pulls code from GitHub"
echo "  2. Installs Python dependencies"
echo "  3. Trains ML model"
echo "  4. Builds Docker images"
echo "  5. Stops old containers"
echo "  6. Deploys new containers"
echo "  7. Runs health checks"
echo "  8. Runs tests"
echo ""
echo "════════════════════════════════════════════════════════"
echo "Next Steps:"
echo "════════════════════════════════════════════════════════"
echo ""
echo "1. Monitor the build:"
echo "   http://${PUBLIC_IP}:8080/job/mlops-pipeline/"
echo ""
echo "2. Wait for build to complete (~5 minutes)"
echo ""
echo "3. After build completes, test deployment:"
echo "   bash scripts/test.sh"
echo ""
echo "4. Access your application:"
echo "   Streamlit UI: http://${PUBLIC_IP}:8501"
echo "   Flask API:    http://${PUBLIC_IP}:5000"
echo ""
echo "════════════════════════════════════════════════════════"

# Cleanup
rm -f /tmp/jenkins-cli.jar /tmp/mlops-pipeline-config.xml
