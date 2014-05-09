#!/usr/bin/env python
################################################################################
#
#   options.py
#
#
#   Copyright (C) 2007 Leo Goodstadt
#
#   This program is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; version 2
#   of the License
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#################################################################################

import sys, os
import optparse
from collections import defaultdict

def check_mandatory_options (options, mandatory_options, helpstr):
    """
    Check if specified mandatory options have b een defined
    """
    missing_options = []
    for o in mandatory_options:
        if not getattr(options, o):
            missing_options.append("--" + o)
            
    if not len(missing_options):
        return

    raise Exception("Missing mandatory parameter%s: %s.\n\n%s\n\n" % 
                    ("s" if len(missing_options) > 1 else "",
                     ", ".join(missing_options),
                     helpstr))

    


    
def get_option_strings (parser, options, logger=None):
    """
    Get options for programmes
        Returns long option names even if short ones were specified
        Returns options even if they were defaults
    """

    #
    #   Save option names and actions which were used for a particular variable 
    #   
    #
    dest_to_long_option = defaultdict(list)
    dest_to_action      = defaultdict(list)
    for option in parser._get_all_options():
        dest_to_long_option[option.dest].append(option._long_opts[0])
        dest_to_action[option.dest].append(option.action)

    full_option_strings = list()

    #
    #   go through full list of parameter values 
    #
    for opt_dest, opt_value in options.__dict__.iteritems():

        if  opt_value == None:
            continue

        # it will not be in list if just set willy-nilly in defaults
        if not opt_dest in dest_to_action:
            if logger:
                logger.warning ("%s is not a programme option but "
                                        "was specified in the list of defaults!!" % opt_dest)
            continue

        for action, long_opt in zip(dest_to_action[opt_dest], dest_to_long_option[opt_dest]):

            # write out option for store
            if action == "store":
                full_option_strings.append("%s '%s'" % (long_opt, str(opt_value)))
            elif action == "store_const":
                full_option_strings.append(long_opt)

            # write out full list for append
            elif action == "append":
                if opt_value and len(opt_value):
                    for val in opt_value:
                        full_option_strings.append("%s '%s'" % (long_opt, str(val)))
            elif action == "append_const":
                if opt_value and len(opt_value):
                    for val in opt_value:
                        full_option_strings.append(long_opt)

            # only specify boolean flag if required
            elif action == "store_true" and opt_value:
                full_option_strings.append(long_opt)
            elif action == "store_false" and not opt_value:
                full_option_strings.append(long_opt)


            elif action == "count" and opt_value:
                for i in range(opt_value):
                    full_option_strings.append(long_opt)
                # break because in case there are multiple count options all updating
                # this count variable. We do not want to double-count :-)
                break

    return full_option_strings

    
    

import unittest, os,sys
if __name__ == '__main__':
    exe_path = os.path.split(os.path.abspath(sys.argv[0]))[0]
    sys.path.append(os.path.abspath(os.path.join(exe_path,"..", "python_modules")))
    from SVGdraw import *
    import SVGdraw

class Testoptions(unittest.TestCase):

    #       self.assertEqual(self.seq, range(10))
    #       self.assert_(element in self.seq)
    #       self.assertRaises(ValueError, random.sample, self.seq, 20)



    def test_get_option_strings(self):
        """
            test get_option_strings()
        """
        from optparse import OptionParser
        parser = OptionParser(version="%prog 1.0")


        #
        #   exons
        # 

        parser.add_option("-t", "--test1", dest="test1",
                          type="string")
        parser.add_option("-a", "--testappend", dest="testappends",
                           action="append", 
                          type="string")
        parser.add_option("-b", "--testappendconst", dest="testappendconst",
                           action="append_const", const = "whatever")
        parser.add_option("-s", "--teststoreconst", dest="teststoreconst",
                           action="store_const", const = 3.0)
        parser.add_option("-y", "--testyes", dest="testbool",
                           action="store_true")
        parser.add_option("-n", "--testno", dest="testbool",
                           action="store_false")
        parser.add_option("-c", "--testcount", dest="testcounts",
                           action="count")
        parser.add_option("-C", "--testcount2", dest="testcounts",
                           action="count")

        parser.set_defaults(teststoreconst     = 5.0)

        args = "-t test_string -a 1 -a 2 -b -b -y -y -n -y -c -c -C".split()
        (options, args) = parser.parse_args(args)
        option_str = " ".join(sorted(get_option_strings(parser, options)))
        self.assertEqual(option_str,
                         "--test1 'test_string' --testappend '1' --testappend '2' " 
                          "--testappendconst --testappendconst --testcount " 
                         "--testcount --testcount --teststoreconst --testyes")

#
#   debug code not run if called as a module
#     
if __name__ == '__main__':
    if sys.argv.count("--debug"):
        sys.argv.remove("--debug")
    unittest.main()
    
    

    
