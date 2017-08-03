#!/bin/bash

xo_branch="stable"
xo_server="https://github.com/vatesfr/xo-server"
xo_web="https://github.com/vatesfr/xo-web"

n_repo="https://raw.githubusercontent.com/visionmedia/n/master/bin/n"

yarn_repo="deb https://dl.yarnpkg.com/debian/ stable main"
node_source="https://deb.nodesource.com/setup_5.x"
yarn_gpg="https://dl.yarnpkg.com/debian/pubkey.gpg"

n_location="/usr/local/bin/n"

sudo apt-get install --yes nfs-common
cd /opt
curl -sL $node_source | sudo -E bash -
curl -sS $yarn_gpg | sudo apt-key add -
echo "$yarn_repo" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update
sudo apt-get install --yes nodejs yarn
curl -o $n_location $n_repo
sudo chmod +x $n_location
sudo n stable
sudo apt-get install --yes build-essential redis-server libpng-dev git python-minimal libvhdi-utils
git clone -b $xo_branch $xo_server
git clone -b $xo_branch $xo_web
cd xo-server
sudo npm install && npm run build
sudo cp sample.config.yaml .xo-server.yaml
sudo sed -i /mounts/a\\"    '/': '/opt/xo-web/dist'" .xo-server.yaml
cd /opt/xo-web
yarn install --force
cat > /etc/systemd/system/xo-server.service <<EOF
# systemd service for XO-Server.

[Unit]
Description= XO Server
After=network-online.target

[Service]
WorkingDirectory=/opt/xo-server/
ExecStart=/usr/local/bin/node ./bin/xo-server
Restart=always
SyslogIdentifier=xo-server

[Install]
WantedBy=multi-user.target
EOF

sudo chmod +x /etc/systemd/system/xo-server.service
sudo systemctl enable xo-server.service
sudo systemctl start xo-server.service
