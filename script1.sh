sudo apt update

sudo apt install git curl libssl-dev libreadline-dev zlib1g-dev autoconf bison build-essential libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev -y

curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash

echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc 

echo 'eval "$(rbenv init -)"' >> ~/.bashrc

source ~/.bashrc

rbenv install 2.7.2

rbenv global 2.7.2

sudo apt install -y nodejs

sudo apt install -y yarn

gem install rails -v 6.1.3.1

git clone https://github.com/Yokeshwer/billing.git

sudo apt install unzip -y

cd billing/

unzip Siva_V-billing-system-ec21edbdd0eb.zip 

mv Siva_V-billing-system-ec21edbdd0eb /home/ubuntu/

cd ..

cd Siva_V-billing-system-ec21edbdd0eb/

sudo apt-get install libpq-dev -y

bundle install

sudo apt-get install postgresql-client -y

sudo apt install npm

sudo apt install -y nodejs

sudo npm install --global yarn

sudo npm install -g webpack

rails assets:precompile

rails webpacker:compile


