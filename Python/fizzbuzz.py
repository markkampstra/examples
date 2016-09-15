#!/usr/bin/python

# FizzBuzz by Mark Kampstra
#
# Write a program that prints the numbers from 1 to 100.
# But for multiples of 3 print "Fizz" instead of the number and for the multiples of five print "Buzz".
# For numbers which are multiple of both 3 and 5, print "FizzBuzz".
#

import string

class FizzBuzz:
  '''The FizzBuzz class'''

  def __init__(self):
    self.result = ""

  def do_fizz_buzz(self):
    # return the FizzBuzz sequence in a string
    # create an array with numbers 1 to 100
    numbers = range(1,101)

    # loop though the array of numbers and check whether to print 'Fizz', 'Buzz', 'FizzBuzz' or just the number
    for n in numbers:
      if n % 3 == 0:
        self.fizz()
      if n % 5 == 0:
        self.buzz()
      if (n % 3 != 0) and (n % 5 != 0):
        self.result += "%d" % (n)
      # add a space
      self.result += ' '

    return self.result[:-1] # remove trailing space and return


  def fizz(self):
    self.result += "Fizz"

  def buzz(self):
    self.result += "Buzz"

  def fizz_buzz_oneliner(self):
    # FizzBuzz in one line
    return string.join(["FizzBuzz" if x%15 == 0 else "Fizz" if x%3 == 0 else "Buzz" if x % 5 == 0 else str(x) for x in range(1,101)])

def main():
  fizz_buzz = FizzBuzz()
  result1 = fizz_buzz.do_fizz_buzz()
  result2 = fizz_buzz.fizz_buzz_oneliner()

  print 'FizzBuzz'
  print
  print 'do_fizz_buzz() result:'
  print result1
  print
  print 'fizz_buzz_oneliner result:'
  print result2
  if result1 == result2:
    print 'Both results are the same! \o/'
  else:
    print 'Oops, something is not right :\'('

if __name__ == "__main__":
  main()