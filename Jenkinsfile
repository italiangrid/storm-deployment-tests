def label = "worker-${UUID.randomUUID().toString()}"

podTemplate(
    label: label,
    cloud: 'Kube mwdevel',
    nodeSelector: 'zone=ci-test',
    containers: [
        containerTemplate(
          name: 'storm-deployment-runner',
          image: 'italiangrid/kube-docker-runner:latest',
          command: 'cat',
          ttyEnabled: true,
          resourceRequestCpu: '500m',
          resourceLimitCpu: '900m',
          resourceRequestMemory: '3Gi',
          resourceLimitMemory: '4Gi'
        )
    ],
    volumes: [
        hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
        secretVolume(mountPath: '/home/jenkins/.docker', secretName: 'registry-auth-basic'),
        secretVolume(mountPath: '/home/jenkins/.ssh', secretName: 'jenkins-ssh-keys'),
        persistentVolumeClaim(mountPath: '/srv/scratch', claimName: 'scratch-area-claim', readOnly: false)
    ],
    imagePullSecrets: ['jenkins-docker-registry']
) {

    parameters {
        choice(choices: '\nstable\numd', name: 'UPGRADE_FROM', description: '')
        choice(choices: 'nightly\nstable\numd', name: 'TARGET_RELEASE', description: '')
    }

    node(label) {

        stage('build') {
            container('storm-deployment-runner') {
                script {
                    deleteDir()
                    checkout scm
                }
                dir('docker') {
                    sh 'docker-compose build'
                }
            }
        }

        try {
            stage('run') {
                environment {
                    TARGET_RELEASE="${params.TARGET_RELEASE}"
                    UPGRADE_FROM="${params.UPGRADE_FROM}"
                }
                container('storm-deployment-runner') {
                    script {
                        withCredentials([
                            usernamePassword(credentialsId: 'a5ca708a-eca8-4fc0-83cd-eb3695f083a1', passwordVariable: 'CDMI_CLIENT_SECRET', usernameVariable: 'CDMI_CLIENT_ID'),
                            usernamePassword(credentialsId: 'fa43a013-7c86-410f-8a8f-600b92706989', passwordVariable: 'IAM_USER_PASSWORD', usernameVariable: 'IAM_USER_NAME')
                        ]) {
                            sh """
cd docker
mkdir -p output/logs
mkdir -p output/var/log
mkdir -p output/etc
mkdir -p output/etc/sysconfig
docker-compose down
docker-compose up --no-color --abort-on-container-exit || true
docker-compose logs --no-color storm >output/logs/storm.log
docker-compose logs --no-color storm-testsuite >output/logs/storm-testsuite.log
docker cp testsuite:/home/tester/storm-testsuite/reports output
docker cp storm:/var/log/storm output/var/log
docker cp storm:/etc/storm output/etc
docker cp storm:/etc/sysconfig/storm-webdav output/etc/sysconfig
docker-compose down
cd ..
"""
                        }
                    }
                }
            }
        } catch (error) {

            slackSend color: 'danger', message: "${env.JOB_NAME} - #${env.BUILD_ID} Failure (<${env.BUILD_URL}|Open>)"

        } finally {
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
            script{
                if('SUCCESS'.equals(currentBuild.result)) {
                    slackSend color: 'good', message: "${env.JOB_NAME} - #${env.BUILD_ID} Back to normal (<${env.BUILD_URL}|Open>)"
                }
            }
        }
    }
}
