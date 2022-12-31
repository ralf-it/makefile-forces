from setuptools import setup, find_packages
from setuptools.command.install import install
import os

class CustomInstall(install):

    def run(self):
        # Call the standard install
        install.run(self)
        pwd = os.getenv('INSTALL_DIR', None)

        if pwd:
            config_rdir = target_rdir = os.path.join(os.path.expanduser(pwd), ".make")
        else:
            config_rdir = os.path.join(os.path.expanduser('~'),'.make')
            target_rdir = os.path.join(os.path.expanduser('~'),'.local', 'include', 'make')

        target_dir = os.path.join(target_rdir, 'forces')

        os.makedirs(target_dir, exist_ok=True)
        # Write the target_dir value to the .make/FORCES file
        forces_file_path = os.path.join(config_rdir, 'FORCES')
        os.makedirs(os.path.dirname(forces_file_path), exist_ok=True)
        with open(forces_file_path, 'w') as f:
            f.write(target_dir)
            print(f">>> Wiring a FILE {forces_file_path} with PATH {target_dir}")

        # Assuming you want to include all files under the .make directory
        make_dir = os.path.join(os.path.dirname(__file__), 'forces')

        forces_dest_path = os.path.join(config_rdir, 'forces.mk')
        forces_src_path = os.path.join(make_dir, '.samples', 'forces.mk' )
        os.makedirs(os.path.dirname(forces_dest_path), exist_ok=True)
        with open(forces_src_path, 'rb') as src, open(forces_dest_path, 'wb') as dst:
            dst.write(src.read())
            print(f"--- Wiring a FILE {forces_dest_path}...")

        for root, dirs, files in os.walk(make_dir):
            for file in files:
                source_file = os.path.join(root, file)
                relative_path = os.path.relpath(root, make_dir)
                target_subdir = os.path.join(target_dir, relative_path)
                os.makedirs(target_subdir, exist_ok=True)
                target_file = os.path.join(target_subdir, file)

                with open(source_file, 'rb') as src, open(target_file, 'wb') as dst:
                    dst.write(src.read())
                    print(f"--- Wiring a FILE {target_file}...")

        target_file = os.path.join(target_dir, 'VERSION')
        with open(target_file, 'w') as f:
            f.write(open('VERSION').read().strip())
            print(f"--- Wiring a FILE {target_file}...")


def read_gitignore():
    gitignore_path = os.path.join(os.path.dirname(__file__), '.gitignore')
    if not os.path.exists(gitignore_path):
        return []
    with open(gitignore_path, 'r') as f:
        lines = f.readlines()
    patterns = [line.strip() for line in lines if line.strip() and not line.startswith('#')]
    return patterns

# List of all directories and files to be included
def package_files(directory):
    paths = []
    for (root, dirs, filenames) in os.walk(directory, topdown=True):
        for filename in filenames:
            f = os.path.join('./', root, filename)
            if not any(pattern in f for pattern in ignore_patterns):
                paths.append(f)
    return paths

ignore_patterns = read_gitignore()
extra_files = package_files('.make/forces')

print(extra_files)

setup(
    name='makefile_forces',
    version=open('VERSION').read().strip(),
    packages=find_packages(),
    license_files=('LICENSE.md',),
    cmdclass={
        'install': CustomInstall,
    },
    # Include package data
    package_data={
        '': extra_files,
    },
    include_package_data=True,
)
