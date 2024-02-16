#! /usr/bin/bash

ip addr | grep 'inet .*' | cut -f6 -d' '
