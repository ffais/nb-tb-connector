def skipRemainingStages = false
pipeline {
  agent any
  environment {
    CHAT_ID = credentials('chatid')
    TG_TOKEN = credentials('tg_token')
    IP = credentials('platform-test-ip')
    INTIP = credentials('platform-test-int-ip')
    USR = credentials('platform-test-user')
  }
  stages {
    stage('Build') {
      steps {
        withCredentials(bindings: [sshUserPrivateKey(credentialsId: 'jk_dev', keyFileVariable: 'key')]) {
          script {
            rc = sh(script: "./build.sh", returnStatus: true)
            sh "echo \"exit code is : ${rc}\""
            if (rc != 0)
            {
                sh "echo 'exit code is NOT zero'"
                skipRemainingStages = true
            }
            else
            {
                sh "echo 'exit code is zero'"
            }
          }
        }
      }
    }
    stage('Test') {
      steps {
        echo 'Testing..'
      }
    }
    stage('Deploy') {
      steps {
          echo 'Deploying....'
        }
    }
  }
}
