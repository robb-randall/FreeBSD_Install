mkdir Desktop
mkdir Pictures
mkdir Videos
mkdir Documents
mkdir Repositories

### Install RVM and configure to use with fish shell
curl -sSL https://get.rvm.io | bash
curl -L --create-dirs -o ~/.config/fish/functions/rvm.fish https://raw.github.com/lunks/fish-nuggets/master/functions/rvm.fish
echo "rvm default" >> ~/.config/fish/config.fish
. ~/.config/fish/config.fish
rvm install 2.7