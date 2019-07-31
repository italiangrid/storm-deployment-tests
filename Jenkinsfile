pipeline {

  agent {
    label 'deployment-test'
  }

  options {
    timeout(time: 1, unit: 'HOURS')
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }

  parameters {
    choice(choices: '\nstable\nbeta\numd', name: 'UPGRADE_FROM', description: '')
    choice(choices: 'nightly\nbeta\nstable\numd', name: 'TARGET_RELEASE', description: '')
  }

  environment {
    TARGET_RELEASE = "${params.TARGET_RELEASE}"
    UPGRADE_FROM = "${params.UPGRADE_FROM}"
    COMPOSE_PROJECT_NAME = "storm-deployment-test-${BUILD_TAG}"
  }

  stages {
    stage('Run') {
      steps {
        script {
          withCredentials([
            usernamePassword(credentialsId: 'a5ca708a-eca8-4fc0-83cd-eb3695f083a1', passwordVariable: 'CDMI_CLIENT_SECRET', usernameVariable: 'CDMI_CLIENT_ID'),
            usernamePassword(credentialsId: 'fa43a013-7c86-410f-8a8f-600b92706989', passwordVariable: 'IAM_USER_PASSWORD', usernameVariable: 'IAM_USER_NAME')
          ]) {
            echo "UPGRADE_FROM=${env.UPGRADE_FROM}"
            echo "TARGET_RELEASE=${env.TARGET_RELEASE}"
            dir("docker") {
              sh "bash ./run.sh"
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
      slackSend channel: '#ci-deployment-tests', color: 'danger', message: "${env.JOB_NAME} - #${env.BUILD_ID} Failure (<${env.BUILD_URL}|Open>)"
    }
    changed {
      script {
        if ('SUCCESS'.equals(currentBuild.result)) {
          slackSend channel: '#ci-deployment-tests', color: 'good', message: "${env.JOB_NAME} - #${env.BUILD_ID} Back to normal (<${env.BUILD_URL}|Open>)"
        }
      }
    }
  }
}
