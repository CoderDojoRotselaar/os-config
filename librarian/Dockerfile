FROM ubuntu

ENTRYPOINT ["/usr/local/bin/librarian-puppet"]
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y install puppet ruby rubygems rsync git && apt-get clean
RUN gem install librarian-puppet
RUN mkdir -m 777 /.puppet
WORKDIR /work
