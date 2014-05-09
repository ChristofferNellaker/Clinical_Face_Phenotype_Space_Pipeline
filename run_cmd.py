#!/usr/bin/env python
"""

    run_cmd.py
    [--log_file PATH]
    [--verbose]

"""

################################################################################
#
#   run_cmd
#
#
#   Copyright (c) 12/3/2009 Leo Goodstadt
#   
#   Permission is hereby granted, free of charge, to any person obtaining a copy
#   of this software and associated documentation files (the "Software"), to deal
#   in the Software without restriction, including without limitation the rights
#   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#   copies of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions:
#   
#   The above copyright notice and this permission notice shall be included in
#   all copies or substantial portions of the Software.
#   
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#   THE SOFTWARE.
#################################################################################

import sys, os
from collections import defaultdict
try:
    from lg_program_logging import MESSAGE
except:
    MESSAGE=15


#88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

#   Functions        


#88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

from contextlib import contextmanager
import time, threading

import subprocess, fcntl

def _readerthread(fh, buffer, output_file):
    """
    thread call back for non-blocking reading of stdout/stderr from child process
    """

    #
    #   stop thread from waiting on IO
    # 
    fd = fh.fileno()
    fl = fcntl.fcntl(fd, fcntl.F_GETFL)
    fcntl.fcntl(fd, fcntl.F_SETFL, fl | os.O_NONBLOCK)

    s= "dummy"
    while len(s):
        try: 
            s= fh.read()
        except: 
            # sleep a little bit. Delays response imperceptibly. Stop CPU hogging
            time.sleep(0.01)
            continue
        if buffer != None:
            buffer.append(s)
        if output_file != None:
            output_file.write(s)


#_________________________________________________________________________________________

#   run_cmd

#_________________________________________________________________________________________
@contextmanager
def ignore_mutex():
    print "<%s>"
    yield
    print "</%s>"

def run_cmd (cmd,   msg, 
                    logging_mutex       = ignore_mutex(), 
                    logger              = None, 
                    queue_cmd_prefix    = None, 
                    job_name            = None, 
                    cwd                 = None, 
                    stdout_file_name    = None, 
                    stdin_file_name     = None,
                    print_stderr        = True,
                    exception_type      = None,
                    **extra_params):
    """
    Runs command either locally or on queue

    Queue commands need queue_cmd_prefix
    
    If stdin_file_name is specified, that will be used to pipe input into the command
    If stdout_file_name is specified, output will be piped into that command.
    
    If print_stderr is set, anything printed by the child process to STDERR will be forwarded
        to the STDERR of the caller (i.e. printed to the console immediately)
        
    msg is a short descriptive name for the task used for indicating success or failure, 
        e.g. "list files" => "Failed to list files"
        
    extra_params are passed through unchanged to subprocess.Popen.
        e.g. run_cmd(..., shell = False)
        
        
    The function returns two strings for the stdout and stderr of the child.
        If stdout_file_name is specified, the assumption is that the STDOUT output
        is too large to be saved separately to the returned string (which
        will be empty.)
    
    """
    # 
    #   Runs specified command on cluster queue
    # 
    if queue_cmd_prefix:
        run_cmd_str = queue_cmd_prefix.format(job_name = job_name, cmd = cmd)
    else:
        run_cmd_str = cmd

    #   
    #   parameters for subprocess.popen
    # 
    params = {  "shell"  : True}
    if cwd:
        params["cwd"] = cwd
    #
    #   stdout and stderr are always piped
    # 
    params["stderr"] = subprocess.PIPE 
    params["stdout"] = subprocess.PIPE
    #   stdin may be a pipe all a file
    if stdin_file_name:
        params["stdin"] = open(stdin_file_name)
    else:
        params["stdin"] = subprocess.PIPE
        
        
    #
    #   override with extra custom parameters 
    #         
    params.update(extra_params)
    
    #
    #   remove parameter from previous version of this function
    #     
    if params.has_key("nostderr"):
        sys.stderr.write("\n\n" + "8" * 80 + "\n\n  WARNING:\n\t"+
                            "run_cmd.run_cmd(...) no longer takes the parameter <nostderr>\n\n"+
                         "8" * 80 + "\n\n")
        del params["nostderr"]
    
    #
    #   run process
    # 
    process = subprocess.Popen(run_cmd_str, **params)
    

    #
    #   send stdout to a thread with the _readerthread()
    #       This will save either to a file or to a list of strings
    # 
    stdout_strs, stdout_file = [], None
    if stdout_file_name:
        stdout_file = open(stdout_file_name, 'w')
        stdout_thread = threading.Thread(target=_readerthread, args=(process.stdout, None, stdout_file))
    else:
        stdout_thread = threading.Thread(target=_readerthread, args=(process.stdout, stdout_strs, None))
    

    #
    #   send stderr to a thread with the _readerthread()
    #       This will both print to stderr and save the error output
    # 
    stderr_strs = []
    stderr_thread = threading.Thread(target=_readerthread, args=(process.stderr, stderr_strs, 
                                                                    sys.stderr if print_stderr else None))
    stdout_thread.setDaemon(True)
    stderr_thread.setDaemon(True)
    stdout_thread.start()
    stderr_thread.start()
    stdout_thread.join()
    stderr_thread.join()

    process.wait()

    # 
    # check if succeeded
    # 
    stdout_strs = "".join(stdout_strs)
    stderr_strs = "".join(stderr_strs)

    if process.returncode == 0:
        if logger:
            with logging_mutex:
                logger.info("Completed %s" % (msg))
        return stdout_strs, stderr_strs

    #
    #   Failed: throw
    # 
    err_str = "returned %s\n%s\n%s\n" % (process.returncode, stdout_strs, stderr_strs)
    if logger:
        with logging_mutex:
            logger.log(MESSAGE, "Failed job:")
            logger.log(MESSAGE, "           cmds = '%s'" % run_cmd_str)
            logger.log(MESSAGE, "           %s" % err_str)
    if exception_type == None:
        exception_type = Exception
    if msg:
        msg = " to %s" % msg
    raise exception_type("Failed%s\ncmds = '%s'\n  %s" % (msg, run_cmd_str, err_str))


#88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

#   Testing


#88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
import unittest
class Test_run_cmd(unittest.TestCase):

    #       self.assertEqual(self.seq, range(10))
    #       self.assert_(element in self.seq)
    #       self.assertRaises(ValueError, random.sample, self.seq, 20)



    def test_function(self):
        """
            test 
        """
        stdout_str, stderr_str = run_cmd ("/net/cpp-group/Leo/bin/src/python_modules/test/test_run_cmd/slow_run_cmd.py", "list",
                                            shell = False, print_stderr = True)
        print ">>%s<<\n??%s??\n" % (stdout_str, stderr_str)

#
#   debug code not run if called as a module
#     
if __name__ == '__main__':
    if sys.argv.count("--debug"):
        sys.argv.remove("--debug")
    unittest.main()
