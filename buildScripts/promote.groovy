import modules

def moduleString = modules.getModules().join('\n')
def ant = new groovy.ant.AntBuilder()
pipeline {
    agent any
    tools {
        maven 'apache-maven-latest'
        jdk 'adoptopenjdk-hotspot-jdk8-latest'
    }
    parameters {
        string(description: 'The ID of the staging repository from the release build', name: 'stagingID')
        choice(choices: moduleString, description: 'Module', name: 'module')
    }

    stages {
        stage("Copy Dependencies") {
            steps {
                sh "ls -la ${pwd()}"
                script {
                    sh "ls -l; cp buildScripts/pom-template.xml buildScripts/pom.xml"
                    ant.replace(file: "buildScripts/pom.xml", token: '${stagingID}', value: "${stagingID}")
                }
                //git credentialsId: 'github-bot-ssh', url: "git@github.com:eclipse/${params.module}.git", branch: params.branch
            }
        }
        stage("Close Staging Repo") {
            steps {
                withCredentials([file(credentialsId: 'secret-subkeys.asc', variable: 'KEYRING')]) {
                    sh 'gpg --batch --import "${KEYRING}"'
                    sh 'for fpr in $(gpg --list-keys --with-colons  | awk -F: \'/fpr:/ {print $10}\' | sort -u); do echo -e "5\ny\n" |  gpg --batch --command-fd 0 --expert --edit-key ${fpr} trust; done'
                    echo 'mvn -DstagingRepositoryId="${stagingID}" ...'
                    echo "TODO..."
                }
            }
        }
        stage("Copy Release Contents") {
            steps {
                echo "TODO..."
            }
        }
    }
    post {
        always {
            echo "TODO..."
        }
    }
}
