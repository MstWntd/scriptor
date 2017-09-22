#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8

"""
Author       : waqask
Email        : waqas.khan@trueex.com
Version      : 0.1

Created      : 2017-08-25 15:29
Last Modified: 2017-08-25 15:30:28 UTC

Host Machine : r1-tome

Description  :
"""

import inspect
from time import gmtime, strftime

debug = True

def _log(lvl, msg):
    lvl = lvl.upper()

    ts = strftime('%Y-%m-%dT%H:%M:%S %Z', gmtime())
    sep = '\t'

    if debug == False and lvl == "DEBUG":
        return

    p_frame = ''
    if lvl == 'DEBUG':
        stack = inspect.stack()
        for s in reversed(stack[1:]):
            p_frame += s[3] + ':' + str(s[2]) + '->'
        p_frame = p_frame[:-2]
    else:
        p_frame = inspect.stack()[1][3]

    out = ts + sep + lvl + sep + p_frame + sep + msg

    print(out)



def main():
    _log("debug","waqas.py")

    a = "b

if __name__ == "__main__":
    main()
