# Script to close a staged repository

TOOLS_PREFIX='/opt/tools'
JAVA_PREFIX="${TOOLS_PREFIX}/java/oracle"
MVN_HOME="${TOOLS_PREFIX}/apache-maven/latest"
JAVA_HOME="${JAVA_PREFIX}/jdk-8/latest"
PATH="${MVN_HOME}/bin:${JAVA_HOME}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Maven plugins
NEXUS_PLUGIN='org.sonatype.plugins:nexus-staging-maven-plugin:1.6.7'
NEXUS_PLUGIN_PARAMS='-DnexusUrl=https://oss.sonatype.org -DserverId=ossrh'

mvnq() {
    # filter out progress reports (-B) and download details
    mvn -B "$@" | grep -v '^\[INFO\] Download'
}

# List
if [[ ${LIST_REPOS} = "true" ]]; then
  echo '-[ List turned on ]----------------------------------------------------------'
  mvnq ${NEXUS_PLUGIN_PARAMS} ${NEXUS_PLUGIN}:rc-list
fi

# Release
if [[ ${DRY_RUN} != "true" ]]; then
  echo "Releasing repositoryID=$ID"
  mvnq -DstagingRepositoryId="$ID" ${NEXUS_PLUGIN_PARAMS} ${NEXUS_PLUGIN}:rc-release
fi
