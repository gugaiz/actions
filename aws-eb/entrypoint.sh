#!/bin/sh
#
# Deploys to AWS EB and report status to GitHub Deployment API
# Depends on https://github.com/unacast/actions/tree/master/github-deploy
#

# Respect AWS_DEFAULT_REGION if specified
[ -n "$AWS_DEFAULT_REGION" ] || export AWS_DEFAULT_REGION=us-east-1

# Respect AWS_DEFAULT_OUTPUT if specified
[ -n "$AWS_DEFAULT_OUTPUT" ] || export AWS_DEFAULT_OUTPUT=json

# Respect AWS_PROFILE if specific
[ -n "$AWS_PROFILE" ] || export AWS_PROFILE=eb-cli

AWS_CONFIG_FILE=${HOME}/.aws/config
AWS_CREDENTIALS_FILE=${HOME}/.aws/credentials

# Set deployment environment name
export GITHUB_ENVIRONMENT_NAME=`cat $GITHUB_EVENT_PATH | ${HOME}/bin/JSON.sh | grep '\["deployment","environment"]' | cut -f2 | sed -e 's/"//g'`

# Set up eb profile
mkdir ${HOME}/.aws
touch $AWS_CONFIG_FILE
touch $AWS_CREDENTIALS_FILE
chmod 600 $AWS_CONFIG_FILE
chmod 600 $AWS_CREDENTIALS_FILE

cat << EOF > $AWS_CONFIG_FILE
[profile ${AWS_PROFILE}]
output = ${AWS_DEFAULT_OUTPUT}
region = ${AWS_DEFAULT_REGION}
EOF

cat << EOF > $AWS_CREDENTIALS_FILE
[${AWS_PROFILE}]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOF

cat $AWS_CONFIG_FILE
ls -alh ${HOME}/.aws

# Pending
#${HOME}/bin/deployment-create-status pending

# Execute
output=$( sh -c "eb $*" )

# Failure
RESULT=$?
if [ 0 != "${RESULT}" ]; then
  echo "Failed '$*'! Exit code '${RESULT}' is not equal to 0"
  #${HOME}/bin/deployment-create-status failure
  echo "$output"
  exit ${RESULT}
fi

# Preserve output for consumption by downstream actions
echo "$output" > "${HOME}/${GITHUB_ACTION}.${AWS_DEFAULT_OUTPUT}"

# Write output to STDOUT
echo "$output"

# Success
#${HOME}/bin/deployment-create-status success

exit 0
