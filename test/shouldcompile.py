"""
shouldcompile: simple utility to test the return value of a program/compiler.
as the arguments it accepts the program/compiler(relative path) to test and list of directories, if the list is empty then it uses only the current working directory.
It travers through the specified directories looking for .c files. The each .c file is then used as the argument for the specified program/compiler to execute with. If the program/compiler returns 0 it is OK, otherwise FAILED. 
"""               
import os  
from os.path import *
from subprocess import *
import string

compiler = ""
totalcnt = 0
failedcnt = 0

def test_file(fpath,file):
  global totalcnt           
  global failedcnt
  command = [compiler,fpath] 

  fnull = open(os.devnull, 'w')
  res = Popen(command,executable=compiler,stderr = fnull, stdout = fnull)
  ostring = "OK"
  totalcnt += 1
  reswait = res.wait(); 
  if  reswait != 0:
     ostring = "FAILED: return code " + `reswait`
     failedcnt += 1  
  print string.ljust(file,20),ostring         
   



def extract_file(arg, directory, files): 
  notprinted = True
  for file in files:       
    fpath = abspath(join(directory, file))       
    if isfile(fpath) and splitext(fpath)[1] == ".c":
      if notprinted:
        print "\n" + directory
        notprinted = False   
      test_file(fpath,file)
    


if __name__ == "__main__":
    from sys import *
                      
    if len(argv) < 2:
      print "usage tes_shouldcompile.py <compiler_executable> [list of directories...]"
      exit(1)              
    
    compiler = abspath(argv[1]);    
    print "compiler=" + compiler;
    if len(argv) > 2:
      
      for dir in argv[2::1]:        
        walk(normpath(dir),extract_file,None) #walking through list of directories
    else:                                                                    
      walk(".",extract_file,None) #walking thourgh current working directory
    print "\ndone!. Total tested files="+`totalcnt`+", failed tests=" + `failedcnt`+ ", "+ `((totalcnt-failedcnt)*100) / totalcnt`+ "% correct."
    
    
    
    
    
    
    
    
      
  










