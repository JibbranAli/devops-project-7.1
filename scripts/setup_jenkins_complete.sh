#!/bin/bash
#
# Complete Jenkins Setup with Pipeline Creation
# This script installs Jenkins, waits for initial setup, then creates the pipeline
#

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║                                                        ║"
echo "║     Jenkins Complete Setup & Pipeline Creation        ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run with sudo: sudo bash scripts/setup_jenkins_complete.sh"
    exit 1
fi

# Get public IP
PUBLIC_IP=$(curl -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || curl -s https://api.ipify.org 2>/dev/null || hostname -I | awk '{print $1}')

echo "📍 Your IP: $PUBLIC_IP"
echo ""

# Step 1: Install Jenkins if not already installed
if ! command -v jenkins &> /dev/null; then
    echo "════════════════════════════════════════════════════════"
    echo "STEP 1: Installing Jenkins"
    echo "════════════════════════════════════════════════════════"
    echo ""
    
    # Install Java
    echo "[1/4] Installing Java..."
    yum install -y java-17-amazon-corretto java-17-amazon-corretto-devel || \
    yum install -y java-11-amazon-corretto java-11-amazon-corretto-devel || \
    yum install -y java-11-openjdk java-11-openjdk-devel
    
    java -version
    
    # Add Jenkins repository
    echo ""
    echo "[2/4] Adding Jenkins repository..."
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    
    # Install Jenkins
    echo ""
    echo "[3/4] Installing Jenkins..."
    yum install -y jenkins
    
    # Add jenkins user to docker group
    usermod -aG docker jenkins
    
    # Start Jenkins
    echo ""
    echo "[4/4] Starting Jenkins..."
    systemctl daemon-reload
    systemctl start jenkins
    systemctl enable jenkins
    
    echo ""
    echo "✅ Jenkins installed successfully!"
else
    echo "✅ Jenkins already installed"
    systemctl start jenkins || true
fi

# Wait for Jenkins to initialize
echo ""
echo "════════════════════════════════════════════════════════"
echo "STEP 2: Waiting for Jenkins to Initialize"
echo "════════════════════════════════════════════════════════"
echo ""
echo "⏳ Waiting 30 seconds for Jenkins to start..."
sleep 30

# Get Jenkins initial password
JENKINS_PASSWORD=""
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    JENKINS_PASSWORD=$(cat /var/lib/jenkins/secrets/initialAdminPassword)
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo "STEP 3: Jenkins Initial Setup (MANUAL)"
echo "════════════════════════════════════════════════════════"
echo ""
echo "🌐 Open Jenkins in your browser:"
echo "   http://${PUBLIC_IP}:8080"
echo ""
echo "🔑 Initial Admin Password:"
echo "   ┌────────────────────────────────────────┐"
echo "   │  ${JENKINS_PASSWORD}  │"
echo "   └────────────────────────────────────────┘"
echo ""
echo "⚠️  COPY THIS PASSWORD NOW!"
echo ""
echo "📋 Follow these steps in Jenkins UI:"
echo "   1. Paste the password above"
echo "   2. Click 'Install suggested plugins' (wait 5-10 minutes)"
echo "   3. Create admin user (or click 'Skip and continue as admin')"
echo "   4. Keep default Jenkins URL"
echo "   5. Click 'Start using Jenkins'"
echo ""
echo "════════════════════════════════════════════════════════"
echo ""

# Wait for user to complete setup
read -p "✋ Press ENTER after you've completed the Jenkins setup above..."

echo ""
echo "════════════════════════════════════════════════════════"
echo "STEP 4: Creating MLOps Pipeline"
echo "════════════════════════════════════════════════════════"
echo ""

# Create Jenkins job configuration XML
cat > /tmp/mlops-pipeline-config.xml <<'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.40">
  <description>MLOps Pipeline - Automated ML Model Deployment</description>
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
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@2.90">
    <scm class="hudson.plugins.git.GitSCM" plugin="git@4.10.0">
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
      <submoduleCfg class="list"/>
      <extensions/>
    </scm>
    <scriptPath>Jenkinsfile</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF

# Create the job using Jenkins CLI
echo "Creating pipeline job..."

# Download Jenkins CLI
wget -q http://localhost:8080/jnlpJars/jenkins-cli.jar -O /tmp/jenkins-cli.jar

# Create the job
java -jar /tmp/jenkins-cli.jar -s http://localhost:8080/ -auth admin:admin create-job mlops-pipeline < /tmp/mlops-pipeline-config.xml 2>/dev/null || \
java -jar /tmp/jenkins-cli.jar -s http://localhost:8080/ create-job mlops-pipeline < /tmp/mlops-pipeline-config.xml 2>/dev/null || \
echo "⚠️  Could not create job automatically. Will provide manual instructions."

echo ""
echo "════════════════════════════════════════════════════════"
echo "✅ Setup Complete!"
echo "════════════════════════════════════════════════════════"
echo ""
echo "🌐 Jenkins URL: http://${PUBLIC_IP}:8080"
echo ""
echo "📋 If pipeline wasn't created automatically, create it manually:"
echo ""
echo "   1. Click 'New Item' in Jenkins"
echo "   2. Name: mlops-pipeline"
echo "   3. Type: Pipeline"
echo "   4. Click OK"
echo "   5. In 'Pipeline' section:"
echo "      - Definition: Pipeline script from SCM"
echo "      - SCM: Git"
echo "      - Repository URL: https://github.com/JibbranAli/devops-project-7.1.git"
echo "      - Branch: */main"
echo "      - Script Path: Jenkinsfile"
echo "   6. Click Save"
echo "   7. Click 'Build Now'"
echo ""
echo "🚀 The pipeline will:"
echo "   ✓ Pull code from GitHub"
echo "   ✓ Install Python dependencies"
echo "   ✓ Train ML model"
echo "   ✓ Build Docker images"
echo "   ✓ Deploy containers"
echo "   ✓ Run health checks"
echo ""
echo "════════════════════════════════════════════════════════"
