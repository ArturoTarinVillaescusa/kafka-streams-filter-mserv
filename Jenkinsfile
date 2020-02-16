library changelog: false,
        identifier: 'common-library@master',
        retriever: modernSCM([$class: 'GitSCMSource',
            credentialsId: 'e3857e1a-0dab-450d-96e7-cc46ea72049d',
            id: '6dee8f6d-a4df-4f5a-890d-b6b0007ad575',
            remote: 'https://desreposrv.goldcar.es:8443/scm/ic/configuraciongradlemicroservicios_repo.git',
            traits: [headWildcardFilter(excludes: '', includes: 'master')]
        ])

pipeline {
    agent {
        label 'java8&&mssqlserver'
    }
    environment {
        ARTIFACTS = 'build/dist/*.zip'
        TESTS_RESULTS = 'build/test-results/test/*.xml'
        NEXUS_REPO = 'BigData'
    }
    stages {
        stage('Build && Unit Tests'){
            steps {
                script {
                    buildAndTests()
                }
            }
        }
        stage('Sonar Analysis') {
            steps {
                script {
                    sonarAnalysis('SonarQubeServer')
                }
            }
        }
        stage('Zip artifacts') {
            steps {
                script {
                    zip()
                }
            }
        }
    }
    post {
        always {
            discardBuilds()
            jacoco classPattern: '**/build/classes', exclusionPattern: '**/test'
            archiveArtifacts artifacts: "${ARTIFACTS}", fingerprint: true
            junit allowEmptyResults: true, testResults: "${TESTS_RESULTS}"
        }
        success {
            deliverNexus('d2b2e40e-3f8f-42ce-82b0-ae0a8dcac23a', "${ARTIFACTS}", "${NEXUS_REPO}")
        }
        changed {
            sendMailNotification()
        }
    }
}