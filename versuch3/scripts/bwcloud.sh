#!/bin/bash
sudo apt-get update
sudo apt-get upgrade

sudo apt-get install python3.7 pip3
sudo apt-get install traceroute
sudo apt-get install iperf3
sudo pip3 install cpunetlog
sudo pip3 install matplotlib
git clone https://github.com/owaldhorst-hka/CPUnetPLOT
git clone https://github.com/mininet/mininet
mininet/util/install.sh -a
mkdir scripts
sudo tee -a ~/.bashrc << EOF

sudo tee -a ~/.bashrc << EOF

### custom additions

# change prompt for mininet hosts
if [ ! -z \${SSH_CONNECTION+x} ]; then
  MyIP=\$(echo \$SSH_CONNECTION | awk '{print \$3}')

  case \$MyIP in
  "10.0.0.1")
    MyHostName="c1"
    ;;
  "10.0.0.2")
    MyHostName="c2"
    ;;
  "10.0.0.3")
    MyHostName="sv1"
    ;;
  *)
    MyHostName="unknown"
    ;;
  esac

  PS1="\e[01;32m\u@\$MyHostName:\e[m\e[01;34m\w\a\e[m\$ "
  PROMPT_COMMAND='echo -ne "\033]0;\$USER@\$MyHostName\007"'

  alias cnl_plot.py="echo \"Can't plot from an ssh session\""
fi

# add cpunetlog scripts to PATH
PATH=\$PATH:\$HOME/cpunetlog
EOF


sudo tee -a /etc/hosts << EOF

127.0.1.1 kn1-lab.net.fail
10.0.0.1 c1
10.0.0.2 c2
10.0.0.3 sv1
EOF

