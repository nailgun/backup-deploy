# Backup deploy scripts

## Usage

1. `# git clone git@github.com:nailgun/backup-deploy.git /etc/backup`
2. `# cd /etc/backup`
3. `# ./install.sh`
4. `# cp run.sh.example run.sh`
5. Edit run.sh
6. Make first backup: `# /etc/backup/run.sh`
7. Add `0 4 * * * root /etc/backup/run.sh >> /var/log/backup.log` to `/etc/crontab`
