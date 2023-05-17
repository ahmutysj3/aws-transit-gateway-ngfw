(base) trace@vm:~$ aws ec2 describe-instances --instance-ids i-03e22804e0383be15
{
    "Reservations": [
        {
            "Groups": [],
            "Instances": [
                {
                    "AmiLaunchIndex": 0,
                    "ImageId": "ami-059d36a8887155edb",
                    "InstanceId": "i-03e22804e0383be15",
                    "InstanceType": "c6i.xlarge",
                    "KeyName": "trace_linux_vm",
                    "LaunchTime": "2023-05-17T21:48:34+00:00",
                    "Monitoring": {
                        "State": "disabled"
                    },
                    "Placement": {
                        "AvailabilityZone": "us-east-1a",
                        "GroupName": "",
                        "Tenancy": "default"
                    },
                    "PrivateDnsName": "ip-10-0-10-237.ec2.internal",
                    "PrivateIpAddress": "10.0.10.237",
                    "ProductCodes": [
                        {
                            "ProductCodeId": "2wqkpek696qhdeo7lbbjncqli",
                            "ProductCodeType": "marketplace"
                        }
                    ],
                    "PublicDnsName": "",
                    "PublicIpAddress": "3.236.30.16",
                    "State": {
                        "Code": 16,
                        "Name": "running"
                    },
                    "StateTransitionReason": "",
                    "SubnetId": "subnet-0ce9bb00f0f939239",
                    "VpcId": "vpc-0a3e750be374952a4",
                    "Architecture": "x86_64",
                    "BlockDeviceMappings": [
                        {
                            "DeviceName": "/dev/sda1",
                            "Ebs": {
                                "AttachTime": "2023-05-17T21:48:35+00:00",
                                "DeleteOnTermination": true,
                                "Status": "attached",
                                "VolumeId": "vol-02f9f6c5aed89ce52"
                            }
                        },
                        {
                            "DeviceName": "/dev/sdb",
                            "Ebs": {
                                "AttachTime": "2023-05-17T21:48:35+00:00",
                                "DeleteOnTermination": true,
                                "Status": "attached",
                                "VolumeId": "vol-0e27f2c495d73d4a3"
                            }
                        }
                    ],
                    "ClientToken": "a243a0f5-b9d9-41da-8c10-3434c8a32eae",
                    "EbsOptimized": true,
                    "EnaSupport": true,
                    "Hypervisor": "xen",
                    "NetworkInterfaces": [
                        {
                            "Association": {
                                "IpOwnerId": "amazon",
                                "PublicDnsName": "",
                                "PublicIp": "3.236.30.16"
                            },
                            "Attachment": {
                                "AttachTime": "2023-05-17T21:48:34+00:00",
                                "AttachmentId": "eni-attach-03359e6fc055623c9",
                                "DeleteOnTermination": true,
                                "DeviceIndex": 0,
                                "Status": "attached",
                                "NetworkCardIndex": 0
                            },
                            "Description": "",
                            "Groups": [
                                {
                                    "GroupName": "Fortinet FortiGate Next-Generation Firewall-7.4.0-AutogenByAWSMP--2",
                                    "GroupId": "sg-0d3b6cdca993200d5"
                                }
                            ],
                            "Ipv6Addresses": [],
                            "MacAddress": "02:6f:af:b6:61:91",
                            "NetworkInterfaceId": "eni-0402f0daac89d60ae",
                            "OwnerId": "561857689028",
                            "PrivateIpAddress": "10.0.10.237",
                            "PrivateIpAddresses": [
                                {
                                    "Association": {
                                        "IpOwnerId": "amazon",
                                        "PublicDnsName": "",
                                        "PublicIp": "3.236.30.16"
                                    },
                                    "Primary": true,
                                    "PrivateIpAddress": "10.0.10.237"
                                }
                            ],
                            "SourceDestCheck": true,
                            "Status": "in-use",
                            "SubnetId": "subnet-0ce9bb00f0f939239",
                            "VpcId": "vpc-0a3e750be374952a4",
                            "InterfaceType": "interface"
                        }
                    ],
                    "RootDeviceName": "/dev/sda1",
                    "RootDeviceType": "ebs",
                    "SecurityGroups": [
                        {
                            "GroupName": "Fortinet FortiGate Next-Generation Firewall-7.4.0-AutogenByAWSMP--2",
                            "GroupId": "sg-0d3b6cdca993200d5"
                        }
                    ],
                    "SourceDestCheck": true,
                    "Tags": [
                        {
                            "Key": "Name",
                            "Value": "fortigate_test_2"
                        }
                    ],
                    "VirtualizationType": "hvm",
                    "CpuOptions": {
                        "CoreCount": 2,
                        "ThreadsPerCore": 2
                    },
                    "CapacityReservationSpecification": {
                        "CapacityReservationPreference": "open"
                    },
                    "HibernationOptions": {
                        "Configured": false
                    },
                    "MetadataOptions": {
                        "State": "applied",
                        "HttpTokens": "optional",
                        "HttpPutResponseHopLimit": 1,
                        "HttpEndpoint": "enabled",
                        "HttpProtocolIpv6": "disabled",
                        "InstanceMetadataTags": "disabled"
                    },
                    "EnclaveOptions": {
                        "Enabled": false
                    },
                    "BootMode": "uefi-preferred",
                    "PlatformDetails": "Linux/UNIX",
                    "UsageOperation": "RunInstances",
                    "UsageOperationUpdateTime": "2023-05-17T21:48:34+00:00",
                    "PrivateDnsNameOptions": {
                        "HostnameType": "ip-name",
                        "EnableResourceNameDnsARecord": false,
                        "EnableResourceNameDnsAAAARecord": false
                    },
                    "MaintenanceOptions": {
                        "AutoRecovery": "default"
                    }
                }
            ],
            "OwnerId": "561857689028",
            "ReservationId": "r-0dd22151c8fec6636"
        }
    ]
}
