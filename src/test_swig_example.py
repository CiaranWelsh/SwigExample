import os, glob
import unittest
import sys

sys.path += [
    r"D:\SwigExample\cmake-build-release\lib\site-packages"
]

import swig_example

class TestSwigExample(unittest.TestCase):

    def setUp(self) -> None:
        pass

    def test_create_a_foo(self):
        f = swig_example.Foo(3)
        print(f)
        print(type(f))

    def test_(self):
        print(dir(swig_example))
        m = swig_example.SpecialFooMap(["first", "second"], [1, 2])
        print(m)
        print(type(m))
        print(m["first"])

if __name__ == "__main__":
    unittest.main()
