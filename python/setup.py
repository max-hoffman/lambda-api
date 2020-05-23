from os.path import join, dirname, abspath
from setuptools import setup, find_packages

long_description = open('README.md').read()

def read_requirements(basename):
    reqs_file = join(dirname(abspath(__file__)), basename)
    with open(reqs_file) as f:
        return [req.strip() for req in f.readlines()]

def main():
    reqs = read_requirements("requirements.txt")
    test_reqs = read_requirements("test_requirements.txt")

    setup(
        name="api",
        version="0.1",
        package_dir={"api": "src"},
        package_data={
            "": ["*.txt", "*.rst"],
        },
        author="Max Hoffman",
        author_email="maximilian.wolfgang1@gmail.com",
        description="Lambda API cli",
        project_urls={
            "Source Code": "",
        },
        classifiers=[
            "License :: OSI Approved :: Python Software Foundation License",
            'Programming Language :: Python :: 3.7',
        ],
        install_requires=reqs,
        extras_require = {"test": test_reqs},
        long_description=long_description,
        long_description_content_type='text/markdown',
    )

if __name__=="__main__":
    main()
