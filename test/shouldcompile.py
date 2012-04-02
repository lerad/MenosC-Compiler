"""
shouldcompile: simple utility to test the return value of a program/compiler.
as the arguments it accepts the program/compiler(relative path) to test and list of directories/files, if the list is empty then it uses only the current working directory.
It travers through the specified directories looking for .c files. The each .c file is then used as the argument for the specified program/compiler to execute with. If the program/compiler returns 0 it is OK, otherwise FAILED, also the stderr output is printed. After it offers to retest the failed files again showing the whole output ie stdout + stderr.
usage example: python shouldcompile.py MenosC test
"""               
import os  
from os.path import *
from subprocess import *
import string
import sys
import getch


compiler = ""
totalcnt = 0
failedcnt = 0
failed_files = [];

"""
TEST_FILE
"""
def test_file(fpath,file):
  global totalcnt
  global failedcnt

  res = execute_test(compiler, fpath, True)
  ostring = printGREEN("OK")
  totalcnt += 1
  reswait = res.wait(); 
  if  reswait != 0:
     ostring = "[" + `failedcnt` + "]" + printRED("FAILED" + ": return code " + `reswait`)
     failedcnt += 1  
     failed_files.append(fpath)
  print string.ljust(printCYAN(file),25),ostring       


"""
EXECUTE_TEST
"""
def execute_test(compiler, filepath, omit_output):
  command = [compiler,filepath] 
  
  fnull = None

  if omit_output:
    fnull = open(os.devnull, 'w')
  return Popen(command,executable=compiler, stdout = fnull)




"""
EXTRACT_FILE
"""
def extract_file(arg, directory, files): 
  notprinted = True
  for file in files:       
    fpath = abspath(join(directory, file))       
    if isfile(fpath) and splitext(fpath)[1] == ".c":
      if notprinted:
	print "\n" + printBLUE( directory)
	notprinted = False   
      test_file(fpath,file)


"""
REPRINT FAILED
"""
def reprint_failed():

  print "run failed tests again[stdout+stderr]?"
  idx = 0
  options = "t(run test)/n(next)/[0-"+`failedcnt-1`+"]/l(list)/s(see test file)/q(quit)";
  while True:
    path = relpath(failed_files[idx])

    print `idx` + ":" + printYELLOW(path) + ':' + options
    #char = sys.stdin.read(1)
    fgetch = getch._Getch()
    char = fgetch()
    if char == "n":
     idx = (idx + 1) % failedcnt
    elif char == "q":
      break
    elif char == "t" :
      print "executing..."
      execute_test(compiler,failed_files[idx],False).wait()
      print "end"
    elif char == "l":
      i = 0
      print ""
      for f in failed_files:
        print `i` + ":" + printYELLOW(relpath(failed_files[i]))
        i += 1
      print ""

    elif char == "s":
      Popen(["cat","-n",  failed_files[idx]]).wait()
    else:
      print char
      if char.isdigit():
        tmp = int(char)
        if tmp < failedcnt and tmp >= 0:
          idx = tmp
        else:
          print "index out of bounds"        
      else:
        print "invaild input" 
    



"""
PRINT RED
"""
def printRED(msg):
  return '\033[1;31m'+msg+'\033[1;m'

"""
PRINT GREEN
"""
def printGREEN(msg):
  return '\033[1;32m'+msg+'\033[1;m'

"""
PRINT YELLOW
"""
def printCYAN(msg):
  return '\033[1;36m'+msg+'\033[1;m'

"""
PRINT BLUE
"""
def printBLUE(msg):
  return '\033[1;34m'+msg+'\033[1;m'

"""
PRINT YELLOW
"""
def printYELLOW(msg):
  return '\033[1;33m'+msg+'\033[1;m'


"""
MAIN
"""
if __name__ == "__main__":
    from sys import *
    if len(argv) < 2:
      print "usage tes_shouldcompile.py <compiler_executable> [list of directories...]"
      exit(1)              
    
    print '\nTESTING...'

    compiler = abspath(argv[1]);    
    print "compiler=" + printYELLOW(compiler);

    if len(argv) > 2:      
      for dir in argv[2::1]:        
        if isdir(dir):
          walk(normpath(dir),extract_file,None) #walking through list of directories
        else:
          if isfile(dir):
            test_file(abspath(dir),dir) #testing only one file
    else:                                                                    
      walk(".",extract_file,None) #walking thourgh current working directorya   


    print "\ndone!. Total tested files="+`totalcnt`+", failed =" + `failedcnt`+ ", "+ `((totalcnt-failedcnt)*100) / totalcnt`+ "% correct. \n"

    reprint_failed()#runs failed tested files to show full result



    
    
    
    
    
    
    
    
      
  











