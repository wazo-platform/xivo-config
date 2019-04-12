# -*- coding: utf-8 -*-
# Copyright 2015-2019 The Wazo Authors  (see the AUTHORS file)
# SPDX-License-Identifier: GPL-3.0+

import netifaces

from hamcrest import assert_that
from hamcrest import equal_to
from mock import Mock, patch
from unittest import TestCase

from . import xivo_create_config


class TestCreateConfig(TestCase):

    @patch('netifaces.ifaddresses')
    def test_load_config_dhcp(self, ifaddresses):

        class MockSession(Mock):
            active = 1
            pool_start = '10.0.0.1'
            pool_end = '10.0.0.250'
            network_interfaces = 'eth0'

        session = MockSession()
        ifaddresses.return_value = {
            netifaces.AF_INET: [
                {
                    'addr': '10.0.0.254',
                    'netmask': '255.255.255.0',
                }
            ]
        }

        result = xivo_create_config.load_config_dhcp(session)

        assert_that(result, equal_to({
            'dhcp_active': 1,
            'dhcp_network_interfaces': 'eth0',
            'dhcp_pool': '10.0.0.1 10.0.0.250',
            'dhcp_net4_ip': '10.0.0.254',
            'dhcp_net4_netmask': '255.255.255.0',
            'dhcp_net4_subnet': '10.0.0.0',
        }))

    def test_load_config_smtp(self):

        class MockSession(Mock):
            mydomain = 'me.example.com'
            origin = 'origin.example.com'
            relayhost = 'relay.example.com'
            fallback_relayhost = 'relay2.example.com'
            canonical = 'alice Alice.Alfirmon\nbob Bob.Broskeni'

        session = MockSession()
        result = xivo_create_config.load_config_smtp(session)

        assert_that(result, equal_to({
            'smtp_mydomain': 'me.example.com',
            'smtp_origin': 'origin.example.com',
            'smtp_relayhost': 'relay.example.com',
            'smtp_fallback_relayhost': 'relay2.example.com',
            'smtp_canonical': 'alice Alice.Alfirmon\nbob Bob.Broskeni',
        }))

    def test_load_config_smtp_when_empty(self):

        class MockSession(Mock):
            mydomain = ''
            origin = ''
            relayhost = ''
            fallback_relayhost = ''
            canonical = ''

        session = MockSession()
        result = xivo_create_config.load_config_smtp(session)

        assert_that(result, equal_to({
            'smtp_mydomain': None,
            'smtp_origin': '',
            'smtp_relayhost': '',
            'smtp_fallback_relayhost': '',
            'smtp_canonical': '',
        }))

    def test_load_config_provisioning(self):

        class MockSession(Mock):
            net4_ip = '127.0.0.1'
            http_port = 8667
            net4_ip_rest = '0.0.0.0'
            rest_port = 8667
            dhcp_integration = 1

        session = MockSession()
        result = xivo_create_config.load_config_provisioning(session)

        assert_that(result, equal_to({
            'provd_net4_ip': '127.0.0.1',
            'provd_http_port': '8667',
            'provd_rest_port': '8667',
            'provd_rest_net4_ip': '0.0.0.0',
            'provd_dhcp_integration': '1',
        }))

    def test_load_config_monitoring(self):

        class MockSession(Mock):
            maintenance = 0
            alert_emails = 'alice@example.com\r\nbob@example.com\r\ncharlie@example.com'
            dahdi_monitor_ports = '12'
            max_call_duration = 24

        session = MockSession()
        result = xivo_create_config.load_config_monitoring(session)

        assert_that(result, equal_to({
            'maintenance': False,
            'alert_emails': 'alice@example.com bob@example.com charlie@example.com',
            'dahdi_monitor_ports': '12',
            'max_call_duration': '24',
        }))

    def test_load_config_monitoring_when_empty(self):

        class MockSession(Mock):
            maintenance = 0
            alert_emails = ''
            dahdi_monitor_ports = ''
            max_call_duration = 0

        session = MockSession()
        result = xivo_create_config.load_config_monitoring(session)

        assert_that(result, equal_to({
            'maintenance': False,
            'alert_emails': None,
            'dahdi_monitor_ports': None,
            'max_call_duration': None,
        }))

    def test_load_config_resolvconf(self):

        class MockSession(Mock):
            hostname = 'myself'
            domain = 'example.com'
            nameserver1 = 'ns1.example.com'
            nameserver2 = 'ns2.example.com'
            nameserver3 = 'ns3.example.com'

        session = MockSession()
        result = xivo_create_config.load_config_resolvconf(session)

        assert_that(result, equal_to({
            'hostname': 'myself',
            'domain': 'example.com',
            'extra_dns_search': '',
            'nameservers': 'ns1.example.com ns2.example.com ns3.example.com'
        }))

    def test_load_config_resolvconf_when_empty(self):

        class MockSession(Mock):
            hostname = ''
            domain = ''
            nameserver1 = ''
            nameserver2 = ''
            nameserver3 = ''

        session = MockSession()
        result = xivo_create_config.load_config_resolvconf(session)

        assert_that(result, equal_to({
            'hostname': '',
            'domain': '',
            'extra_dns_search': '',
            'nameservers': ''
        }))

    def test_load_config_netiface(self):

        class MockSession(Mock):
            ifname = 'eth0'
            address = '10.1.1.1'
            netmask = '255.255.0.0'

        session = MockSession()
        result = xivo_create_config.load_config_netiface(session)

        assert_that(result, equal_to({
            'voip_ifaces': 'eth0',
            'net4_ip': '10.1.1.1',
            'net4_netmask': '255.255.0.0',
            'net4_subnet': '10.1.0.0'
        }))
