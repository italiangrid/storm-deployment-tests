pipeline {
  agent { label 'docker' }

  options {
    timeout(time: 1, unit: 'HOURS')
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }

  triggers { cron('@daily') }

  parameters {
    string(name: '', defaultValue: 'centos6', description: 'OS Platform')
  }

  stages {
    stage('run') {
      parallel {
        stage('update-from-umd') {
          environment {
            UPDATE_FROM="umd"
          }
          steps {
            container('docker-runner') {
              cleanWs notFailBuild: true
              checkout scm
              sh """
mkdir reports
cd docker
docker create network example
docker-compose up --build --abort-on-container-exit
cd ..
docker-compose logs --no-color storm >reports/storm.log
docker-compose logs --no-color testsuite >reports/storm-testsuite.log
docker cp testsuite:/home/tester/storm-testsuite/reports reports
"""
              archiveArtifacts 'reports/**'
            }
          }
        }
        stage('update-from-stable') {
          environment {
            UPDATE_FROM="stable"
          }
          steps {
            container('docker-runner') {
              cleanWs notFailBuild: true
              checkout scm
              sh """
mkdir reports
cd docker
docker create network example
docker-compose up --build --abort-on-container-exit
cd ..
docker-compose logs --no-color storm >reports/storm.log
docker-compose logs --no-color testsuite >reports/storm-testsuite.log
docker cp testsuite:/home/tester/storm-testsuite/reports reports
"""
              archiveArtifacts 'reports/**'
            }
          }
        }
        stage('clean-deployment') {
          environment {
            UPDATE_FROM=""
          }
          steps {
            container('docker-runner') {
              cleanWs notFailBuild: true
              checkout scm
              sh """
mkdir reports
cd docker
docker create network example
docker-compose up --build --abort-on-container-exit
cd ..
docker-compose logs --no-color storm >reports/storm.log
docker-compose logs --no-color testsuite >reports/storm-testsuite.log
docker cp testsuite:/home/tester/storm-testsuite/reports reports
"""
              archiveArtifacts 'reports/**'
            }
          }
        }
      }
    }
  }
  post {
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
