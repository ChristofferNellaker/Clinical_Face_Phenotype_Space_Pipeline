import contextlib, os

@contextlib.contextmanager
def restore_curr_dir():
   curdir= os.getcwd()
   try: yield
   finally: os.chdir(curdir)



if __name__ == '__main__':
   print "getcwd before:", os.getcwd()
   with restore_curr_dir():
       os.chdir("test")
       print "getcwd during:", os.getcwd()

   print "getcwd after:", os.getcwd()
