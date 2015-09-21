import os


IN_PATH = 'testcases/input/'
OUT_PATH = 'testcases/output/'
VALID_FILES = ['1', '5', '6', '7', '8', '9', '11', '13',
               '14', '16', '18', '19', '20', '21']


os.system('make all')

for num in VALID_FILES:
    print '\nRunning test %s' %num
    os.system('java -cp lib/antlr.jar:classes/ Micro %stest%s.micro > test.out\
        && diff -b -B test.out %stest%s.out'
        %(IN_PATH, num, OUT_PATH, num))
