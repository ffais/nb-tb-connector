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
        withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
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
      when {
                expression { !skipRemainingStages }
      }
      steps {
        echo 'Testing..'
        withCredentials(bindings: [sshUserPrivateKey(credentialsId: 'jk_dev', keyFileVariable: 'key')]) {
          withCredentials([file(credentialsId: 'nb-tb-connector-env', variable: 'env')]){
            withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
              script {
                rc = sh(script: "./test.sh", returnStatus: true)
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
      }
    }
    stage('Deploy') {
      when {
                expression { !skipRemainingStages }
      }
      steps {
        withCredentials(bindings: [sshUserPrivateKey(credentialsId: 'jk_dev', keyFileVariable: 'key')]) {
          script {
            rc = sh(script: "./deploy.sh", returnStatus: true)
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
  }
}
