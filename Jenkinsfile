def imageName = 'mlabouardy/movies-loader'
def registry = '305929695733.dkr.ecr.eu-west-3.amazonaws.com'
def region = 'eu-west-3'

node('workers'){
    try {
        stage('Checkout'){
            checkout scm
            notifySlack('STARTED')
        }

        stage('Unit Tests'){
            def imageTest= docker.build("${imageName}-test", "-f Dockerfile.test .")
            imageTest.inside{
                sh "python test_main.py"
            }
        }

        stage('Build'){
            docker.build(imageName)
        }

        stage('Push'){
        sh "\$(aws ecr get-login --no-include-email --region ${region}) || true"
            docker.withRegistry("https://${registry}") {
                docker.image(imageName).push(commitID())

                if (env.BRANCH_NAME == 'develop') {
                    docker.image(imageName).push('develop')
                }
            }
        }

        stage('Deploy'){
            if(env.BRANCH_NAME == 'develop'){
                build job: "watchlist-deployment/${env.BRANCH_NAME}"
            }
        }
    } catch(e){
        currentBuild.result = 'FAILED'
        throw e
    } finally {
        notifySlack(currentBuild.result)
    }
}

def notifySlack(String buildStatus){
    buildStatus =  buildStatus ?: 'SUCCESSFUL'
    def colorCode = '#FF0000'

    if (buildStatus == 'STARTED') {
        colorCode = '#546e7a'
    } else if (buildStatus == 'SUCCESSFUL') {
        colorCode = '#2e7d32'
    } else {
        colorCode = '#c62828c'
    }

    slackSend (color: colorCode, message: "${env.JOB_NAME} build status: ${buildStatus}")
}


def commitID() {
    sh 'git rev-parse HEAD > .git/commitID'
    def commitID = readFile('.git/commitID').trim()
    sh 'rm .git/commitID'
    commitID
}