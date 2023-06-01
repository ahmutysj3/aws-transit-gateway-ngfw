config system global
    set hostname ${fgt_id}
    set alias ${fgt_id}
end
config system interface
    edit port1                            
        set alias OUTSIDE
        set vdom "root"
        set mode dhcp
        set type physical
        set allowaccess ping https ssh fgfm
        set snmp-index 1
        set mtu-override enable
        set mtu 9001
    next
    edit port2                            
        set alias INSIDE
        set vdom "root"
        set mode dhcp
        set type physical
        set defaultgw disable
        set allowaccess ping
        set snmp-index 2
        set mtu-override enable
        set mtu 9001
    next
    edit port3                           
        set alias HEARTBEAT
        set vdom "root"
        set mode dhcp
        set type physical
        set defaultgw disable
        set allowaccess ping
        set snmp-index 3
        set mtu-override enable
        set mtu 9001
    next
    edit port4                           
        set alias MANAGEMENT
        set vdom "root"
        set mode dhcp
        set type physical
        set defaultgw disable
        set allowaccess ping https ssh fgfm
        set snmp-index 4
        set mtu-override enable
        set mtu 9001
    next
    edit "naf.root"
        set vdom "root"
        set type tunnel
        set src-check disable
        set snmp-index 5
    next
    edit "l2t.root"
        set vdom "root"
        set type tunnel
        set snmp-index 6
    next
    edit "ssl.root"
        set vdom "root"
        set type tunnel
        set alias "SSL VPN interface"
        set snmp-index 7
    next
    edit "fortilink"
        set vdom "root"
        set fortilink enable
        set ip ${outside_gw} ${outside_gw_netmask}
        set allowaccess ping fabric
        set type aggregate
        set lldp-reception enable
        set lldp-transmission enable
        set snmp-index 8
    next
end
config system accprofile
    edit "${net_name}_terraform_admin"
        set secfabgrp read-write
        set ftviewgrp read-write
        set authgrp read-write
        set sysgrp read-write
        set netgrp read-write
        set loggrp read-write
        set fwgrp read-write
        set vpngrp read-write
        set utmgrp read-write
        set wanoptgrp read-write
        set wifi read-write
    next
end
config firewall internet-service-name
    edit "Amazon-AWS"
        set internet-service-id 393320
    next
    edit "Amazon-AWS.Route53"
        set internet-service-id 393473
    next
    edit "Amazon-AWS.S3"
        set internet-service-id 393474
    next
    edit "Amazon-AWS.EC2"
        set internet-service-id 393477
    next
    edit "Amazon-AWS.API.Gateway"
        set internet-service-id 393478
    next
    edit "Fortinet-Web"
        set internet-service-id 1245185
    next
    edit "Fortinet-FortiGuard"
        set internet-service-id 1245324
    next
    edit "Fortinet-FortiCloud"
        set internet-service-id 1245326
    next
end
config router static
    edit 1
        set device port1
        set gateway ${outside_gw}
    next
    edit 2
        set device port2
        set gateway ${inside_gw}
        set dst ${supernet}
    next
end
config firewall address
    edit toSpoke1
        set subnet ${spoke1_cidr}
    next
    edit toSpoke2
        set subnet ${spoke2_cidr}
    next
    edit toSpoke3
        set subnet ${spoke3_cidr}
    next
    edit toMgmt
        set subnet ${mgmt_cidr}
    next
    edit Supernet
        set subnet ${supernet}
    next
end
    config firewall addrgrp
        edit to-WEST
            set member toSpoke1 toSpoke2 toSpoke3 toMgmt
end
config firewall policy
    edit 1
        set name East-West
        set srcintf port2
        set dstintf port2
        set srcaddr all
        set dstaddr to-WEST
        set action accept
        set schedule always
        set service ALL
        set logtraffic all
    next
    edit 2
        set name South-North
        set srcintf port2
        set dstintf port1
        set srcaddr Supernet
        set dstaddr all
        set action accept
        set schedule always
        set service ALL
        set logtraffic all
        set nat enable
    next
end