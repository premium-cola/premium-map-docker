FROM debian:7.5

ENV RAILS_ENV development

RUN apt-get update && apt-get dist-upgrade && apt-get install -y openssh-server tmux zsh man vim htop less most git wget ca-certificates curl ruby1.9.3 build-essential g++ libmysqlclient-dev libsqlite3-dev sudo
RUN gem install bundler

ADD sudoers /etc/sudoers

RUN groupadd app -g 3000 && useradd app -d /srv/app -u 3000 -g 3000 -s /bin/zsh -m && echo "app:app" | chpasswd

USER app
WORKDIR /srv/app
RUN git clone https://github.com/premium-cola/premium-map.git
ADD post-receive /srv/app/premium-map/.git/hooks/post-receive

WORKDIR /srv/app/premium-map
RUN git config receive.denyCurrentBranch ignore
RUN bundle install --path vendor/bundle
RUN bundle exec rake db:migrate

USER root
ADD initd_rails /etc/init.d/rails
RUN chmod +x /etc/init.d/rails && update-rc.d rails defaults

USER root
EXPOSE 3000
ENTRYPOINT exec /sbin/init
