pipeline {
  agent { label 'docker' }

  options {
    timeout(time: 1, unit: 'HOURS')
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }

  triggers { cron('@daily') }

  parameters {
    choice(choices: '\nstable\numd', name: 'UPGRADE_FROM', description: '')
  }

  stages {
    stage('build') {
      steps {
        container('docker-runner') {
          script {
            cleanWs notFailBuild: true
            checkout scm
          }
          dir('docker') {
            sh 'docker-compose build'
          }
        }
      }
    }
    stage('run') {
      environment {
        UPGRADE_FROM="${params.UPGRADE_FROM}"
      }
      steps {
        container('docker-runner') {
          script {
            withCredentials([
              usernamePassword(credentialsId: 'a5ca708a-eca8-4fc0-83cd-eb3695f083a1', passwordVariable: 'CDMI_CLIENT_SECRET', usernameVariable: 'CDMI_CLIENT_ID'),
              usernamePassword(credentialsId: 'fa43a013-7c86-410f-8a8f-600b92706989', passwordVariable: 'IAM_USER_PASSWORD', usernameVariable: 'IAM_USER_NAME')
            ]) {
              sh """
    cd docker
    mkdir -p output/logs
    docker-compose down
    docker-compose up --no-color --abort-on-container-exit || true
    docker-compose logs --no-color storm >output/logs/storm.log
    docker-compose logs --no-color storm-testsuite >output/logs/storm-testsuite.log
    docker cp testsuite:/home/tester/storm-testsuite/reports output
    docker-compose down
    cd ..
"""
            }
          }
        }
      }
    }
  }
  post {
    always {
      archiveArtifacts 'docker/output/**'
      step([$class: 'RobotPublisher',
          disableArchiveOutput: false,
          logFileName: 'log.html',
          otherFiles: '*.png',
          outputFileName: 'output.xml',
          outputPath: "docker/output/reports",
          passThreshold: 100,
          reportFileName: 'report.html',
          unstableThreshold: 90])
    }
    failure {
      slackSend color: 'danger', message: "${env.JOB_NAME} - #${env.BUILD_ID} Failure (<${env.BUILD_URL}|Open>)"
    }
    changed {
      script{
        if('SUCCESS'.equals(currentBuild.result)) {
          slackSend color: 'good', message: "${env.JOB_NAME} - #${env.BUILD_ID} Back to normal (<${env.BUILD_URL}|Open>)"
        }
      }
    }
  }
}
