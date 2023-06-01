config system global
    set hostname ${fgt_id}
end
config system interface
    edit port1                            
        set alias OUTSIDE
        set mode static
        set ip ${fgt_outside_ip}
        set allowaccess ping https ssh fgfm
        set mtu-override enable
        set mtu 9001
    next
    edit port2
        set alias INSIDE
        set mode static
        set ip ${fgt_inside_ip}
        set allowaccess ping 
        set mtu-override enable
        set mtu 9001
    next
    edit port3
        set alias HEARTBEAT
        set mode static
        set ip ${fgt_heartbeat_ip}
        set allowaccess ping 
        set mtu-override enable
        set mtu 9001
    next
    edit port4
        set alias MGMT
        set mode static
        set ip ${fgt_mgmt_ip}
        set allowaccess ping https ssh
        set mtu-override enable
        set mtu 9001
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
        set dst {supernet}
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
        set srcaddr all
        set dstaddr to-WEST
        set dstaddr-negate enable
        set action accept
        set schedule always
        set service ALL
        set logtraffic all
        set nat enable
    next
    edit 3
        set name Mgmt-Access
        set srcintf port1
        set dstintf port1
        set srcaddr all
        set dstaddr all
        set action accept
        set schedule always
        set service ALL
        set logtraffic all
    next
end
config ha-mgmt-interface
    edit 1
        set interface port4
        set gateway ${mgmt_gw}
    next
end
config system vdom-exception
    edit 1
        set object system.interface
    next
    edit 2
        set object router.static
    next
    edit 3
        set object firewall.vip
    next
end