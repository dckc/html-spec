#!/bin/env python
""" esis2xml.py -- convert output of nsgmls to XML
with a hack for external unparsed entities
"""

from string import split, replace
import re

import sys

def main():

    attrs = {}
    w = sys.stdout.write
    
    while 1:
        ln = sys.stdin.readline()
        if not ln: break

        ln = ln[:-1] # chop newline

        op = ln[0]
        
        if op == 'A':
            attr = split(ln[1:], ' ', 3)
            n, ty = attr[:2]
            if ty <> 'IMPLIED':
                attrs[n] = attr[2] #@@ unescape
        elif op == '(':
            #hmm.. use a SaxWriter?
            w("<%s" % ln[1:])
            for n in attrs.keys():
                w("\n%s = '%s'" % (n, attrs[n])) #@@ escape
            w("\n>")
            attrs = {}
        elif op == ')':
            w("</%s\n>" % ln[1:])
        elif op == '-':
            data = ln[1:]

            #unescape. @@more
            data = replace(data, "\\n", "\n")

            data = replace(data, "&", "&amp;")
            data = replace(data, "<", "&lt;")
            data = replace(data, ">", "&gt;")

            # replace \|[mdash ]\| by <char_:mdash/>
            data = re.sub(r'\\\|\[(\w+)\s*\]\\\|',
                          r'<char_:\1/>',
                          data)


            w(data)
        elif op == 's':
            sysid = ln[1:]
        elif op == 'E':
            w("<E_ f='%s' \n/>" % sysid) # other stuff? notation?
        elif op == 'p' or op == 'N' or op == 'f' or op == '&':
            pass # ignore other entity stuff, for now
        elif op == 'C':
            pass # just means 'OK'
        else:
            warn("unknown code [%s] in line [%s]" % (ln[0], ln))

def warn(*args):
    for a in args:
        sys.stderr.write("%s " % a)
    sys.stderr.write("\n")
    
if __name__ == "__main__":
    main()
