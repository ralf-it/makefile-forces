from setuptools import setup, find_packages
from setuptools.command.install import install
import os

class CustomInstall(install):
    def run(self):
        # Call the standard install
        install.run(self)

        source_file = os.path.join(os.path.dirname(__file__), '.make/forces.mk')
        target_dir = os.path.join(os.path.expanduser('~'), '.local/include/make')
        target_file = os.path.join(target_dir, 'forces.mk')

        os.makedirs(target_dir, exist_ok=True)

        with open(source_file, 'rb') as src, open(target_file, 'wb') as dst:
            dst.write(src.read())

setup(
    name='makefile_forces',
    version=open('VERSION').read().strip(),
    packages=find_packages(),
    license_files=('LICENSE.md',),
    cmdclass={
        'install': CustomInstall,
    },
    # Include package data to ensure the Makefile is packaged
    package_data={
        '': ['.make/forces.mk'],
    },
    include_package_data=True,
)
