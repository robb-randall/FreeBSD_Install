#!/bin/sh

mkdir ~/bin
mkdir ~/Backups
mkdir ~/Desktop
mkdir ~/Documents
mkdir ~/Pictures
mkdir ~/Repositories
mkdir ~/Videos

cd ~/Repositories
git clone git@github.com:robb-randall/FreeBSD_Install.git ~/Repositories/FreeBSD_Install/
git clone git@github.com:robb-randall/CS399-Project.git ~/Repositories/CS399-Project/
git clone git@github.com:robb-randall/CS399.git ~/Repositories/CS399/
git clone git@github.com:robb-randall/mazebot.git ~/Repositories/mazebot/
git clone git@github.com:robb-randall/CrosswordSolver.git ~/Repositories/CrosswordSolver/
git clone git@github.com:robb-randall/owmo.git ~/Repositories/owmo/
git clone git@github.com:robb-randall/Oracle.git ~/Repositories/ORalce/

git clone git@bitbucket.org:robb-randall/coindesk.git ~/Repositories/coindesk/
git clone git@bitbucket.org:robb-randall/Books.git ~/Repositories/Books/
git clone git@bitbucket.org:robb-randall/project-euler.git ~/Repositories/ProjectEuler/

cd ~

ln -s ~/Repositories/Books/ ~/Books
ln -s ~/Repositories/FreeBSD_Install/bin ~/bin

### Go variables
cat >> ~/.profile <<EOL
# Golang variables
export GOROOT=/usr/local/bin/go 
export GOPATH=$HOME/go/
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
EOL
mkdir ~/go

### Take an initial backup
tar -zcvf ~/Backups/2020-07-02.tgz \
    --exclude ~/Backups \
    --exclude ~/Books \
    --exclude ~/Downloads \
    --exclude ~/Repositories \
    --exclude ~/go \
    --exclude ~/.gem \
    --exclude ~/.rvm \
    --exclude ~/.cache \
    ~