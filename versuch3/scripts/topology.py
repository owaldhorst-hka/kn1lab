#! /usr/bin/env python3

from mininet.net import Mininet
from mininet.cli import CLI
from mininet.log import lg
from mininet.topo import Topo
from mininet.link import TCLink
from mininet.node import OVSController


class MyTopo(Topo):
    def __init__(self):
        Topo.__init__(self)

        # create hosts
        lukas = self.addHost('lukas', ip='10.0.0.2/26')
        lisa = self.addHost('lisa', ip='10.0.0.3/26')
        ela = self.addHost('ela', ip='10.0.0.4/26')
        ben = self.addHost('ben', ip='10.0.0.5/26')
        elias = self.addHost('elias', ip='10.0.0.6/26')

        nas = self.addHost('nas', ip='10.0.1.2/29')

        # create switch
        sw1 = self.addSwitch('sw1')

        # create router
        r1 = self.addHost('r1', ip='10.0.0.1/26')

        # do the wiring
        # - hosts to switch
        self.addLink(lukas, sw1)
        self.addLink(lisa, sw1)
        self.addLink(ela, sw1)
        self.addLink(ben, sw1)
        self.addLink(elias, sw1)
        # - nas over router to switch
        self.addLink(r1, sw1)
        self.addLink(nas, r1)


# configuration
def conf(network):
    # router addresses
    network['r1'].cmd('ip addr add 10.0.0.1/26 dev r1-eth0')
    network['r1'].cmd('ip addr add 10.0.2.1/29 dev r1-eth1')
    network['r1'].cmd('sysctl net.ipv4.conf.all.forwarding=1')

    # client routing
    network['ela'].cmd('ip route add default via 10.0.0.1')
    network['lisa'].cmd('ip route add default via 10.0.0.1')
    network['ben'].cmd('ip route add default via 10.0.0.1')
    network['lukas'].cmd('ip route add default via 10.0.0.1')
    network['elias'].cmd('ip route add default via 10.0.0.1')

    network['nas'].cmd('ip route add default via 10.0.1.1')


def nettopo(**kwargs):
    topo = MyTopo()
    return Mininet(topo=topo, link=TCLink, controller = OVSController, **kwargs)


if __name__ == '__main__':
    lg.setLogLevel('info')
    net = nettopo()
    net.start()
    conf(net)
    CLI(net)
    net.stop()
