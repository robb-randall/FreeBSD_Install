#!/bin/sh

mkdir ~/bin
mkdir ~/Backups
mkdir ~/Desktop
mkdir ~/Documents
mkdir ~/Downloads
mkdir ~/Music
mkdir ~/Pictures
mkdir ~/Repositories
mkdir ~/Videos

git clone git@github.com:robb-randall/FreeBSD_Install.git ~/Repositories/FreeBSD_Install/
git clone git@github.com:robb-randall/CS399-Project.git ~/Repositories/CS399-Project/
git clone git@github.com:robb-randall/CS399.git ~/Repositories/CS399/
git clone git@github.com:robb-randall/mazebot.git ~/Repositories/mazebot/
git clone git@github.com:robb-randall/CrosswordSolver.git ~/Repositories/CrosswordSolver/
git clone git@github.com:robb-randall/owmo.git ~/Repositories/owmo/
git clone git@github.com:robb-randall/Oracle.git ~/Repositories/Oralce/
git clone git@bitbucket.org:robb-randall/coindesk.git ~/Repositories/coindesk/
git clone git@bitbucket.org:robb-randall/Books.git ~/Repositories/Books/
git clone git@bitbucket.org:robb-randall/project-euler.git ~/Repositories/ProjectEuler/

cat > ~/bin/backup.tcsh <<EOL
#!/bin/tcsh -f

EOL
chmod +x ~/bin/backup.tcsh

cat > ~/.tcshrc <<EOL
## If interactive prompt:
if ($?prompt) then
    set prompt = "%m:%~> "
    set rmstar

    foreach $file ( $HOME/.tcshrc.d/*.config )
        source $file
    end

endif
EOL

mkdir ~/.tcshrc.d

cat > ~/.tcshrc.d/alias.conf <<EOL
alias cd        'cd \!* && ls'
alias ff        'find . -name '
alias hist      'history 20'
alias ll        'ls --color -lha'
alias m         more
alias today     "date '+%y%d%h'"
alias backup    "~/bin/backup.tcsh"
EOL

cat > ~/.tcshrc.d/history.conf <<EOL
set histfile = ~/.history
set history=500
set savehist=(500 merge)
set histdup=erase

alias precmd 'history -S; history -M'
EOL

touch ~/.history

source ~/.tcshrc