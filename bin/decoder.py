#!/bin/python3
from xml.dom import minidom
#this files takes a nmap xml output and makes a list of discovered devices that we discovered MAC for

#None if there isnt both layer 2 and 3 addresses ipv4/6'\t'mac address'\t'vendor if there is
#gonna put the addresses to the following ipv4,ipv6 mac
def output_str(addresses)->str:
    if(addresses.length < 2): 
        return None
    
    ipflag = False
    macflag = False
    
    output_string=""
    mac_address_and_vendor=""
    #iterate through all addresses (probably an ip and a mac)
    for address in addresses:
        addrtype = address.getAttribute('addrtype')
        addr = address.getAttribute('addr')

        if(addrtype == "ipv4" or addrtype == "ipv6"):
            if(ipflag):
                output_string = output_string + ',' + addr
            else:
                output_string = addr
            ipflag = True

        if(addrtype == "mac"):
            mac_address_and_vendor = addr + "\t" +address.getAttribute('vendor')
            macflag = True
    
        if (ipflag and macflag):
            output_string = output_string + "\t" + mac_address_and_vendor
            return output_string
    
    if (ipflag and macflag):
        output_string = output_string + "\t" + mac_address_and_vendor
        return output_string
    return None



try:
    file = minidom.parse("nmap_scan.xml")
except:
    print("nmap_scan.xml not found")
    exit(1)

models = file.getElementsByTagName('hosthint')

for model in models:
    
    address = model.getElementsByTagName('address')
    hostname = model.getElementsByTagName('hostnames')
    
    formatted_addr = output_str(address)
    if( formatted_addr != None):
        print(formatted_addr) 
