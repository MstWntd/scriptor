#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8

"""
Author       : waqask
Email        : waqas.khan@trueex.com
Version      : 0.1

Created      : 2017-04-10 15:02
Last Modified: 2017-04-11 11:28:09 UTC

Host Machine : r1-tome

Description  :
"""

import sys
import re

def tryint(s):
    try:
        return int(s)
    except:
        return s

def alphanum_key(s):
    """ Turn a string into a list of string and number chunks.
        "z23a" -> ["z", 23, "a"]
    """
    return [ tryint(c) for c in re.split('([0-9]+)', s) ]


def main():
    for line in sys.stdin:
        line = line.strip()
        if line == "":
            continue

        #print "[-%s-]" % line
        data = line.split('\x01')

        ts=data[0]
        fields = data[1:]
        fields.sort(key=alphanum_key)

        print ts
        for field in fields[1:]:
            print field
        print ""


if __name__ == "__main__":
    main()
