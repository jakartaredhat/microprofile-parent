# Script to close a staged repository

## Parameters
# MODULE
# STAGING_ID
# DRY_RUN
# LIST_REPOS

TOOLS_PREFIX='/opt/tools'
JAVA_PREFIX="${TOOLS_PREFIX}/java/oracle"
MVN_HOME="${TOOLS_PREFIX}/apache-maven/latest"
JAVA_HOME="${JAVA_PREFIX}/jdk-8/latest"
PATH="${MVN_HOME}/bin:${JAVA_HOME}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Nexus maven plugins
NEXUS_PLUGIN='org.sonatype.plugins:nexus-staging-maven-plugin:1.6.7'
NEXUS_PLUGIN_PARAMS='-DnexusUrl=https://oss.sonatype.org -DserverId=ossrh'

# Strip the microprofile- prefix from the module
MODULE=${MODULE#microprofile-}
echo MODULE="${MODULE}"
echo STAGING_ID="${STAGING_ID}"
echo VERSION="${VERSION}"
echo LIST_REPOS="${LIST_REPOS}"
echo DRY_RUN="${DRY_RUN}"

# First update the pom-template.xml to a pom
CMD='mvn -f buildScripts/pom-template.xml -Dmodule=${MODULE} -DstagingID=${STAGING_ID} -Dstaged.version=${VERSION} post-clean'
echo $CMD
$CMD

ls -l buildScripts

# Optionally list the staging repositories
if [[ ${LIST_REPOS} = "true" ]]; then
  echo '-[ List turned on ]----------------------------------------------------------'
  mvn ${NEXUS_PLUGIN_PARAMS} ${NEXUS_PLUGIN}:rc-list
fi

# If not DRY_RUN, close the given staging repository
if [[ ${DRY_RUN} != "true" ]]; then
  echo "Releasing repositoryID=$ID"
  echo mvn -DstagingRepositoryId="$ID" ${NEXUS_PLUGIN_PARAMS} ${NEXUS_PLUGIN}:rc-release
fi
