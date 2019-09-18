FROM python:3-stretch

LABEL name="aws-eb"
LABEL version="1.0.0"
LABEL repository="http://github.com/getslashdeploy/actions-aws-eb"
LABEL homepage="http://github.com/getslashdeploy/actions-aws-eb"

LABEL com.github.actions.name="GitHub Action for AWS EB"

ENV DOCKERVERSION=18.06.1-ce
RUN apt-get update && \
  apt-get install -y --no-install-recommends curl groff jq && \
  apt-get -y clean && apt-get -y autoclean && apt-get -y autoremove && \
  rm -rf /var/lib/apt/lists/* && \
  pip install --upgrade pip && \
  pip install setuptools awsebcli

COPY "entrypoint.sh" "/entrypoint.sh"
ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
