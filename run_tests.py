import glob
import os
import sys


IN_PATH = 'testcases/input/'
OUT_PATH = 'testcases/output/'


try:
    os.system('make all')
except:
    print 'Error compiling project. Exiting...'
    sys.exit(1)
input_files = []
for infile in os.listdir(IN_PATH):
    if infile[0] != '.':
        input_files.append(infile)

input_files = sorted(input_files)
new_filelist = []
new_filelist.append(input_files[0])
new_filelist.append(input_files[11])
new_filelist.append(input_files[15])

for i in range(16, len(input_files)):
    new_filelist.append(input_files[i])
for i in range(1,11):
    new_filelist.append(input_files[i])
for i in range(12, 14):
    new_filelist.append(input_files[i])

test_num = 1
for filename in new_filelist:
    print 'Running test %s' %str(test_num)
    os.system('java -cp lib/antlr.jar:classes/ Micro %s%s > test.out\
        && diff -b -B test.out %stest%s.out'
        %(IN_PATH, filename, OUT_PATH, str(test_num)))
    test_num += 1
