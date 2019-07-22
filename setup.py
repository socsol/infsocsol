from setuptools import setup, find_packages

setup(name="infsocsol",
      version="3.0.1",
      packages=find_packages(),
      install_requires=[
          'matlabengineforpython',
          'matplotlib',
          'oct2py',
          'pandas',
          'tables',
          'pytest',
          'scipy'
      ])

