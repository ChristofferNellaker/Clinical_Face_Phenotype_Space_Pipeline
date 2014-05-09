################################################################################
#
#   sqlite_scheduler.py
#
#   Copyright (c) 10/01/2014 Christoffer Nellaker
#   #   Permission is hereby granted, free of charge, to any person obtaining a copy
#   of this software and associated documentation files (the "Software"), to deal
#   in the Software without restriction, including without limitation the rights
#   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#   copies of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions:
#   #   The above copyright notice and this permission notice shall be included in
#   all copies or substantial portions of the Software.
#   #   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#   THE SOFTWARE.
#################################################################################


from run_cmd import run_cmd
import os, sys, glob, time, subprocess, shlex


class sqlite_scheduler:
    def __init__(self, db_name, temp_request_dir, temp_ext, scheduler_file_ext):
        self.db_name = db_name
        self.temp_request_dir = temp_request_dir
        self.temp_ext = temp_ext
        self.scheduler_file_ext = scheduler_file_ext
    def __enter__(self):
        print self.db_name, self.temp_request_dir, self.temp_ext, self.scheduler_file_ext
        open(self.db_name+".deamon", "w")
        print "\n***Initialising sqlite database schedule deamon***\n"
        #run_cmd('nice -19 qsub -cwd -q fgu205.q -v BASH_ENV="~/.bashrc" -o /dev/null -e /dev/null -b yes python /home/chrisn/projects/sqlite_scheduler.py %s %s %s %s' % (self.db_name, self.temp_request_dir, self.temp_ext, self.scheduler_file_ext), "Sqlite deamon")
        subprocess.Popen(shlex.split('python sqlite_scheduler.py %s %s %s %s' % (self.db_name, self.temp_request_dir, self.temp_ext, self.scheduler_file_ext)))  
        return "Deamon running"
    def __exit__(self, db_name, temp_request_dir, temp_ext):
        #print db_name, temp_request_dir, temp_ext
        os.unlink(self.db_name+".deamon")
        try: os.unlink(self.db_name+self.scheduler_file_ext)
        except: pass
        for old_request in glob.glob(self.temp_request_dir+"/*"+self.temp_ext): os.unlink(old_request)
        print "\n*** Shutting sqlite database schedule deamon  ***\n"

def sqlite_shedule_deamon(db_name, temp_request_dir, temp_ext, scheduler_file_ext):
    while os.path.exists(db_name+".deamon"):
        request_list = glob.glob(temp_request_dir+"/*"+temp_ext)
        request_list.sort()
        for request in request_list:
            time.sleep(0.1)
            fh_scheduler = open(db_name+scheduler_file_ext, "w")
            fh_scheduler.write(os.path.split(request)[-1])
            fh_scheduler.close()
            while os.path.exists(request):
                pass

def sqlite_queue_wait(ssdf):
    pass
            
        
if __name__ == '__main__':
    try: db_name, temp_request_dir, temp_ext, scheduler_file_ext = sys.argv[1:]
    except:
        print "incorrect arguments to %s\n" % sys.argv[0]
        print sys.argv
        sys.exit("fail argv")
    sqlite_shedule_deamon(db_name, temp_request_dir, temp_ext, scheduler_file_ext)
