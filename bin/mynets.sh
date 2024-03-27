#! /usr/bin/bash
#shows all ip addreses for all interfaces
ip addr | grep 'inet .*' | cut -f6 -d' '
