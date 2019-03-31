#!/usr/bin/python

import sys

from mininet.net import Mininet
from mininet.cli import CLI
from mininet.log import lg
from mininet.node import Node
from mininet.topolib import TreeTopo
from mininet.util import waitListening
from mininet.topo import Topo
from mininet.link import TCLink

class MyTopo(Topo):
    def __init__(self):
        Topo.__init__(self)

        # create hosts
        lukas = self.addHost('lukas', ip='10.0.0.2/24')
        lisa = self.addHost('lisa', ip='10.0.0.3/24')
        ela = self.addHost('ela', ip='10.0.0.4/24')
        ben = self.addHost('ben', ip='10.0.0.5/24')
        elias = self.addHost('elias', ip='10.0.0.6/24')

        nas = self.addHost('nas', ip='10.0.3.2/24')

        # create switch
        sw1 = self.addSwitch('sw1')
        
        # create router
        r1 = self.addHost('r1', mac='00:00:00:00:01:00', ip='10.0.0.1/24')

        # do the wiring
        ## hosts to switch
        self.addLink(lukas, sw1)
        self.addLink(lisa, sw1)
        self.addLink(ela, sw1)
        self.addLink(ben, sw1)
        self.addLink(elias, sw1)
        ## nas over router to switch
        self.addLink(r1, sw1)
        self.addLink(nas, r1)

# configuration
def conf(net):
    # router interfaces
    net['r1'].cmd('ifconfig r1-eth0 0')
    net['r1'].cmd('ifconfig r1-eth1 0')
    net['r1'].cmd('ifconfig r1-eth0 hw ether 00:00:00:00:01:01')
    net['r1'].cmd('ifconfig r1-eth1 hw ether 00:00:00:00:01:02')

    # router addresses
    net['r1'].cmd('ip addr add 10.0.0.1/24 brd + dev r1-eth0')
    net['r1'].cmd('ip addr add 10.0.2.1/24 brd + dev r1-eth1')
    net['r1'].cmd('echo 1 > /proc/sys/net/ipv4/ip_forward')

    # router routing
    net['r1'].cmd('ip route add 10.0.0.0/24 dev r1-eth0')
    net['r1'].cmd('ip route add 10.0.3.0/24 dev r1-eth1')

    # client routing
    net['ela'].cmd('ip route add default via 10.0.0.1')
    net['lisa'].cmd('ip route add default via 10.0.0.1')
    net['ben'].cmd('ip route add default via 10.0.0.1')
    net['lukas'].cmd('ip route add default via 10.0.0.1')
    net['elias'].cmd('ip route add default via 10.0.0.1')

    net['nas'].cmd('ip route add default via 10.0.3.1')

def NetTopo(**kwargs):
    topo = MyTopo()
    return Mininet(topo=topo, link=TCLink, **kwargs)

if __name__ == '__main__':
    lg.setLogLevel('info')
    net = NetTopo()
    net.start()
    conf(net)
    CLI(net)
    net.stop()
