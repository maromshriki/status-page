pipeline {
  agent any

  environment {
    IMAGE_NAME_WEB = "status-page-web"
    IMAGE_NAME_RQ = "status-page-rq"
    FILE_NAME = "Jenkinsfile"
    PRODUCTION_SERVER = "10.0.1.110"
    PRODUCTION_USER = "ec2-user"
    DEV_SERVER = "10.0.1.29"
    DEV_USER = "ubuntu"
    CICD_SERVER = "10.0.1.205"
    CICD_USER = "ec2-user"
    SSH_CREDENTIALS_ID_PROD = 'ssh-to-prod-server'
    SSH_CREDENTIALS_ID_DEV = 'ssh-to-dev-server'
    APP_NAME = "status-page"
    REMOTE_REGISTRY = "992382545251.dkr.ecr.us-east-1.amazonaws.com/msdw/statuspage-web"
    DEPLOY_ENV = "${BRANCH_NAME == 'main' ? 'production' : 'development'}"
  }

  stages {

    stage('Dev Build') {
      when { changeRequest() }
      steps {
        sshagent(credentials: ["$SSH_CREDENTIALS_ID_DEV"]) {
          sh 'docker-compose build'
          sh "ssh -t $DEV_USER@$DEV_SERVER 'cd /opt/status-page; docker-compose build'"
        }
      }
    }

    stage('Dev deploy to minikube cluster') {
      when { changeRequest() }
      steps {
        sshagent(credentials: ["$SSH_CREDENTIALS_ID_DEV"]) {
          sh "ssh -t $DEV_USER@$DEV_SERVER 'cd /opt/status-page/k82; kubectl apply -f .'"
        }
      }
    }

    stage('Dev Deploy to ecr with specific tagging') {
      when { changeRequest() }
      steps {
        sshagent(credentials: ["$SSH_CREDENTIALS_ID_DEV"]) {
          sh 'docker tag $IMAGE_NAME_WEB 992382545251.dkr.ecr.us-east-1.amazonaws.com/msdw/statuspage-web:pr-web-$CHANGE_ID'
          sh 'docker tag $IMAGE_NAME_RQ 992382545251.dkr.ecr.us-east-1.amazonaws.com/msdw/statuspage-web:pr-rq-$CHANGE_ID'
          sh 'docker push 992382545251.dkr.ecr.us-east-1.amazonaws.com/msdw/statuspage-web:pr-web-$CHANGE_ID'
          sh 'docker push 992382545251.dkr.ecr.us-east-1.amazonaws.com/msdw/statuspage-web:pr-web-$CHANGE_ID'
        }
      }
    }

    // Main branch stages
    stage('Main Build') {
      when { branch 'main' }
      steps {
        sh "mvn clean compile"
      }
    }

    stage('Main Test') {
      when { branch 'main' }
      steps {
        sh "mvn test"
      }
    }

    stage('Code Quality') {
      when { branch 'main' }
      steps {
        sh "mvn verify sonar:sonar"
      }
    }

    stage('Security Scan') {
      when { branch 'main' }
      steps {
        sh "echo Running security scan..."
      }
    }

    stage('Main Package') {
      when { branch 'main' }
      steps {
        sh "mvn package -DskipTests"
      }
    }

    stage('Docker Build & Push') {
      when { branch 'main' }
      steps {
        sh """
          docker build -t ${REMOTE_REGISTRY}/${APP_NAME}:${env.BUILD_NUMBER} .
          """
        }
      }
  }
}
        
