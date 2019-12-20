pipeline {

  agent {
    label 'deployment-test'
  }

  options {
    timeout(time: 1, unit: 'HOURS')
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }

  parameters {
    choice(choices: '\nstable', name: 'UPGRADE_FROM', description: 'Upgrade from this repo.')
    choice(choices: 'stable\nbeta\nnightly', name: 'TARGET_RELEASE', description: 'Target release to test.')
    choice(choices: 'nightly\nv1.11.17\nv1.11.16\nv1.11.15', name: 'TESTSUITE_BRANCH', description: 'Testsuite branch.')
  }

  environment {
    UPGRADE_FROM = "${params.UPGRADE_FROM}"
    TARGET_RELEASE = "${params.TARGET_RELEASE}"
    TESTSUITE_BRANCH = "${params.TESTSUITE_BRANCH}"
    COMPOSE_PROJECT_NAME = "storm-deployment-test-${BUILD_TAG}"
    TTY_OPTS = "-T"
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
            echo "TESTSUITE_BRANCH=${env.TESTSUITE_BRANCH}"
            echo "TTY_OPTS=${env.TTY_OPTS}"
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
