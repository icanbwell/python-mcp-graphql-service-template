# python-package-template
Cookiecutter template for creating a new Python Package

# Usage
1. Create a new github repo
2. Sync the github repo to your local machine.
3. `cd` into the folder
4. Install cookiecutter: `pip install -U cookiecutter`
5. Run cookiecutter:`cookiecutter -f https://github.com/imranq2/python-package-template.git -o ../`
6. This will ask you for the parameters.  Be sure to use your github repo name as the directory name
7. After generation is complete, run `make init` to set up your environment.
8. To automate the publishing of the package, set the PYPI secret in your github repo



