# Arguments

## Root directory where to install cmdstan
### Argument -d: Root directory where to install cmdstan, /tmp will have cmdstan installed in /tmp/cmdstan-2.24.1
### Default: $HOME ( home directory of the user )

## Version of cmdstan release to install
### Argument -v: Version of cmdstan to instal, example 2.24.1
### Default: latest ( latest release in github )

## OS
### Argument -os: linux distro. Possible values, one of: [debian, mac, opensuse, redhat, centos, ubuntu, fedora] 
### Required: Yes 
### Where: 
#### debian == ubuntu -> Will execute debian.sh 
#### redhat == centos == fedora -> Will execute rhel.sh 
#### mac -> Will execute mac.sh 
#### opensuse -> Will execute opensuse.sh 

# Example usage

`bash install.sh -d debian`
`bash install.sh -p /home/user -d debian`
`bash install.sh -p /home/user -d debian -v 2.24.1`
