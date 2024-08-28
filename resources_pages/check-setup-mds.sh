#!/usr/bin/env bash
# Checks that the correct version of all system programs and R & Python packages
# which are needed for the start of the MDS program are correctly installed.
# The version number represents <Year>.<Patch>
# since we usually iterate on the script once per year just before the semester starts.

# Use colors for headings for clarity
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# 0. Help message and OS info
echo ''
echo -e "${ORANGE}# MDS setup check 2024.1${NC}" | tee check-setup-mds.log
echo '' | tee -a check-setup-mds.log
echo 'If a program or package is marked as MISSING,'
echo 'this means that you are missing the required version of that program or package.'
echo 'Either it is not installed at all or the wrong version is installed.'
echo 'The required version is indicated with a number and an asterisk (*),'
echo 'e.g. 4.* means that all versions starting with 4 are accepted (4.0.1, 4.2.5, etc).'
echo ''
echo 'You can run the following commands to find out which version'
echo 'of a program or package is installed (if any):'
echo '```'
echo 'name_of_program --version  # For system programs'
echo 'conda list  # For Python packages'
echo 'R -q -e "as.data.frame(installed.packages()[,3])"  # For R packages'
echo '```'
echo ''
echo 'Checking program and package versions...'
echo -e "${ORANGE}## Operating system${NC}" >> check-setup-mds.log
if [[ "$(uname)" == 'Linux' ]]; then
    # sed is for alignment purposes
    sys_info=$(hostnamectl)
    os_version=$(grep "Operating" <<< $sys_info | sed 's/^[[:blank:]]*//')
    echo $os_version >> check-setup-mds.log
    grep "Architecture" <<< $sys_info | sed 's/^[[:blank:]]*//;s/:/:    /' >> check-setup-mds.log
    grep "Kernel" <<< $sys_info | sed 's/^[[:blank:]]*//;s/:/:          /' >> check-setup-mds.log
    file_browser="xdg-open"
    if ! $(grep -iq "22.04\|24.04" <<< $os_version); then
        echo '' >> check-setup-mds.log
        echo "MISSING You are recommended to use Ubuntu 22.04 or 24.04." >> check-setup-mds.log
    fi
elif [[ "$(uname)" == 'Darwin' ]]; then
    sw_vers >> check-setup-mds.log
    file_browser="open"
    if ! $(sw_vers | grep -iq "14.\|13.\|12.\|11.[4|5|6]"); then
        echo '' >> check-setup-mds.log
        echo "MISSING You need macOS Big Sur or greater (>=11.4)." >> check-setup-mds.log
    fi
elif [[ "$OSTYPE" == 'msys' ]]; then
    # wmic use some non-ASCII characters that we need grep (or sort or similar) to convert,
    # otherwise the logfile looks weird. There is also an additional newline at the end.
    os_edition=$(wmic os get caption | grep Micro | sed 's/\n//g')
    echo $os_edition >> check-setup-mds.log
    wmic os get osarchitecture | grep bit | sed 's/\n//g' >> check-setup-mds.log
    os_version_full=$(wmic os get version | grep -Eo '[0-9]+(\.[0-9]+){2}')
    echo $os_version_full >> check-setup-mds.log
    file_browser="explorer"

    os_version=${os_version_full%%.*}  # Major version (before the first dot)
    os_build=${os_version_full##*.}    # Build number (after the last dot)
    if [[ $os_version -eq 10 && $os_build -lt 19041 ]]; then
        echo '' >> check-setup-mds.log
        echo "MISSING You need Windows 10 or 11 with build number >= 10.0.19041. Please run Windows update and then try running this script again." >> check-setup-mds.log
    fi
else
    echo "Operating system verison could not be detected." >> check-setup-mds.log
fi
echo '' >> check-setup-mds.log

# 1. System programs
# Tries to run system programs and if successful greps their version string
# Currently marks both uninstalled and wrong verion number as MISSING
echo -e "${ORANGE}## System programs${NC}" >> check-setup-mds.log

# There is an esoteric case for .app programs on macOS where `--version` does not work.
# Also, not all programs are added to path,
# so easier to test the location of the executable than having students add it to PATH.
if [[ "$(uname)" == 'Darwin' ]]; then
    # psql is not added to path by default
    if ! [ -x "$(command -v /Library/PostgreSQL/16/bin/psql)" ]; then
        echo "MISSING   postgreSQL 16.*" >> check-setup-mds.log
    else
        echo "OK        "$(/Library/PostgreSQL/16/bin/psql --version) >> check-setup-mds.log
    fi

    # rstudio is installed as an .app
    if ! $(grep -iq "= \"2024\.04.*" <<< "$(mdls -name kMDItemVersion /Applications/RStudio.app)"); then
        echo "MISSING   rstudio 2024.04.*" >> check-setup-mds.log
    else
        # This is what is needed instead of --version
        installed_version_tmp=$(grep -io "= \"2024\.04.*" <<< "$(mdls -name kMDItemVersion /Applications/RStudio.app)")
        # Tidy strangely formatted version number
        installed_version=$(sed "s/= //;s/\"//g" <<< "$installed_version_tmp")
        echo "OK        "rstudio $installed_version >> check-setup-mds.log
    fi

    # Remove rstudio and psql from the programs to be tested using the normal --version test
    sys_progs=(R=4.* python=3.* conda="23\|22\|4.*" bash=3.* git=2.* make=3.* latex=3.* tlmgr=5.* \
        docker=27.* code=1.* quarto=1.*)
# psql and Rstudio are not on PATH in windows
elif [[ "$OSTYPE" == 'msys' ]]; then
    if ! [ -x "$(command -v '/c/Program Files/PostgreSQL/16/bin/psql')" ]; then
        echo "MISSING   psql 16.*" >> check-setup-mds.log
    else
        echo "OK        "$('/c/Program Files/PostgreSQL/16/bin/psql' --version) >> check-setup-mds.log
    fi
    # Rstudio on windows does not accept the --version flag when run interactively
    # so this section can only be troubleshot from the script
    if ! $(grep -iq "2024\.04.*" <<< "$('/c//Program Files/RStudio/rstudio' --version)"); then
        echo "MISSING   rstudio 2024.04*" >> check-setup-mds.log
    else
        echo "OK        rstudio "$('/c//Program Files/RStudio/rstudio' --version) >> check-setup-mds.log
    fi
    # tlmgr needs .bat appended on windows and it cannot be tested as an exectuable with `-x`
    if ! [ "$(command -v tlmgr.bat)" ]; then
        echo "MISSING   tlmgr 5.*" >> check-setup-mds.log
    else
        echo "OK        "$(tlmgr.bat --version | head -1) >> check-setup-mds.log
    fi
    # Remove rstudio from the programs to be tested using the normal --version test
    sys_progs=(R=4.* python=3.* conda="23\|22\|4.*" bash=4.* git=2.* make=4.* latex=3.* \
        docker=27.* code=1.* quarto=1.*)
else
    # For Linux everything is sane and consistent so all packages can be tested the same way
    sys_progs=(psql=16.* rstudio=2024\.04.* R=4.* python=3.* conda="23\|22\|4.*" bash=5.* \
        git=2.* make=4.* latex=3.* tlmgr=5.* docker=27.* code=1.* quarto=1.*)
    # Note that the single equal sign syntax in used for `sys_progs` is what we have in the install
    # instruction for conda, so I am using it for Python packagees so that we
    # can just paste in the same syntax as for the conda installations
    # instructions. Here, I use the same single `=` for the system packages
    # (and later for the R packages) for consistency.
fi

for sys_prog in ${sys_progs[@]}; do
    sys_prog_no_version=$(sed "s/=.*//" <<< "$sys_prog")
    regex_version=$(sed "s/.*=//" <<< "$sys_prog")
    # Check if the command exists and is is executable
    if ! [ -x "$(command -v $sys_prog_no_version)" ]; then
        # If the executable does not exist
        echo "MISSING   $sys_prog" >> check-setup-mds.log
    else
        # Check if the version regex string matches the installed version
        # Use `head` because `R --version` prints an essay...
        # Unfortunately (and inexplicably) R on windows and Python2 on macOS
        # prints version info to stderr instead of stdout
        # Therefore I use the `&>` redirect of both streams,
        # I don't like chopping of stderr with `head` like this,
        # but we should be able to tell if something is wrong from the first line
        # and troubleshoot from there
        if ! $(grep -iq "$regex_version" <<< "$($sys_prog_no_version --version &> >(head -1))"); then
            # If the version is wrong
            echo "MISSING   $sys_prog" >> check-setup-mds.log
        else
            # Since programs like rstudio and vscode don't print the program name with `--version`,
            # we need one extra step before logging
            installed_version=$(grep -io "$regex_version" <<< "$($sys_prog_no_version --version &> >(head -1))")
            echo "OK        "$sys_prog_no_version $installed_version >> check-setup-mds.log
        fi
    fi
done

# 2. Python packages
# Greps the `conda list` output for correct version numbers
# Currently marks both uninstalled and wrong verion number as MISSING
echo "" >> check-setup-mds.log
echo -e "${ORANGE}## Python packages${NC}" >> check-setup-mds.log
if ! [ -x "$(command -v conda)" ]; then  # Check that conda exists as an executable program
    echo "Please install 'conda' to check Python package versions." >> check-setup-mds.log
    echo "If 'conda' is installed already, make sure to run 'conda init'" >> check-setup-mds.log
    echo "if this was not chosen during the installation." >> check-setup-mds.log
    echo "In order to do this after the installation process," >> check-setup-mds.log
    echo "first run 'source <path to conda>/bin/activate' and then run 'conda init'." >> check-setup-mds.log
else
    py_pkgs=(otter-grader=5 pandas=2 nbconvert=7 playwright=1 jupyterlab=4 jupyterlab-git=0 jupyterlab-spellchecker=0)
    # installed_py_pkgs=$(pip freeze)
    installed_py_pkgs=$(conda list | tail -n +4 | tr -s " " "=" | cut -d "=" -f -2)
    for py_pkg in ${py_pkgs[@]}; do
        # py_pkg=$(sed "s/=/==/" <<< "$py_pkg")
        if ! $(grep -iq "$py_pkg" <<< $installed_py_pkgs); then
            echo "MISSING   ${py_pkg}.*" >> check-setup-mds.log
        else
            # Match the package name up until the first whitespace to get regexed versions
            # without getting all following packages contained in the string of all packages
            echo "OK        $(grep -io "${py_pkg}\S*" <<< $installed_py_pkgs)" >> check-setup-mds.log
        fi
    done
fi

# jupyterlab PDF and HTML generation
if ! [ -x "$(command -v jupyter)" ]; then  # Check that jupyter exists as an executable program
    echo "Please install 'jupyterlab' before testing PDF generation." >> check-setup-mds.log
else
    # Create an empty json-compatible notebook file for testing
    echo '{
     "cells": [
      {
       "cell_type": "code",
       "execution_count": null,
       "metadata": {},
       "outputs": [],
       "source": []
      }
     ],
     "metadata": {
      "kernelspec": {
       "display_name": "",
       "name": ""
      },
      "language_info": {
       "name": ""
      }
     },
     "nbformat": 4,
     "nbformat_minor": 4
    }' > mds-nbconvert-test.ipynb
    # Test PDF
    if ! jupyter nbconvert mds-nbconvert-test.ipynb --to pdf --log-level 'ERROR' &> jupyter-pdf-error.log; then
        echo 'MISSING   jupyterlab PDF-generation failed. Check that latex and jupyterlab are marked OK above, then read the detailed error message in the log file.' >> check-setup-mds.log
    else
        echo 'OK        jupyterlab PDF-generation was successful.' >> check-setup-mds.log
    fi
    # Test WebPDF
    # I don't want to automate any of the installation steps since it can be harder to troubleshoot then,
    # so we just output and error message telling students is the most probable cause of the failure.
    if ! [ -x "$(command -v playwright)" ]; then  # Check that playwright exists as an executable program
        echo 'MISSING   jupyterlab WebPDF-generation failed. It seems like you did not run `pip install "nbconvert[webpdf]"`.' >> check-setup-mds.log
    else
        # If the student didn't run `playwright install chromium`
        # then that command will try to download chromium,
        # which should always take more than 2s
        # so `timeout` will interupt it with exit code 1.
        # If chromium is already installed,
        # this command just returns an info message which should not take more than 2s.
        # ----
        # Unfortunately, apple has decided not to use gnu-coreutils,
        # so we need to use less reliable solution on macOS;
        # there might be corner cases where this breaks
        if [[ "$(uname)" == 'Darwin' ]]; then
            # The surrounding $() here is just to supress the alarm clock output
            # as redirection does not work.
            $(perl -e 'alarm shift; exec `playwright install chromium`' 2)
        else
            # Using the reliable `timeout` tool on Linux and Windows
            timeout 2s playwright install chromium &> /dev/null
        fi
        # `$?` stores the exit code of the last program that as executed
        # If the exit code is anything else than zero, it means that the above command failed,
        # i.e. chromium has not been installed via playwright yet
        if ! [ $? -eq "0" ]; then
            echo 'MISSING   jupyterlab WebPDF-generation failed. It seems like you have not run `playwright install chromium` to download chromium for jupyterlab WebPDF export.' >> check-setup-mds.log
        elif ! jupyter nbconvert mds-nbconvert-test.ipynb --to webpdf --log-level 'ERROR' &> jupyter-webpdf-error.log; then
            echo 'MISSING   jupyterlab WebPDF-generation failed. Check that jupyterlab, nbconvert, and playwright are marked OK above, then read the detailed error message in the log file.' >> check-setup-mds.log
        else
            echo 'OK        jupyterlab WebPDF-generation was successful.' >> check-setup-mds.log
        fi
    fi
    # Test HTML
    if ! jupyter nbconvert mds-nbconvert-test.ipynb --to html --log-level 'ERROR' &> jupyter-html-error.log; then
        echo 'MISSING   jupyterlab HTML-generation failed. Check that jupyterlab and nbconvert are marked OK above, then read the detailed error message in the log file.' >> check-setup-mds.log
    else
        echo 'OK        jupyterlab HTML-generation was successful.' >> check-setup-mds.log
    fi
    # -f makes sure `rm` succeeds even when the file does not exists
    rm -f mds-nbconvert-test.ipynb mds-nbconvert-test.pdf mds-nbconvert-test.html
fi

# 3. R packages
# Format R package output similar to above for python and grep for correct version numbers
# Currently marks both uninstalled and wrong verion number as MISSING
echo "" >> check-setup-mds.log
echo -e "${ORANGE}## R packages${NC}" >> check-setup-mds.log
if ! [ -x "$(command -v R)" ]; then  # Check that R exists as an executable program
    echo "Please install 'R' to check R package versions." >> check-setup-mds.log
else
    r_pkgs=(tidyverse=2 markdown=1 rmarkdown=2 renv=1 IRkernel=1 tinytex=0 janitor=2 gapminder=1 readxl=1 ottr=1 canlang=0)
    installed_r_pkgs=$(R -q -e "print(format(as.data.frame(installed.packages()[,c('Package', 'Version')]), justify='left'), row.names=FALSE)" | grep -v "^>" | tail -n +2 | sed 's/^ //;s/ *$//' | tr -s ' ' '=')
    for r_pkg in ${r_pkgs[@]}; do
        if ! $(grep -iq "$r_pkg" <<< $installed_r_pkgs); then
            echo "MISSING   $r_pkg.*" >> check-setup-mds.log
        else
            # Match the package name up until the first whitespace to get regexed versions
            # without getting all following packages contained in the string of all pacakges
            echo "OK        $(grep -io "${r_pkg}\S*" <<< $installed_r_pkgs)" >> check-setup-mds.log
        fi
    done
fi

# rmarkdown PDF and HTML generation
if ! [ -x "$(command -v R)" ]; then  # Check that R exists as an executable program
    echo "Please install 'R' before testing PDF and HTML generation." >> check-setup-mds.log
else
    # The find_pandoc command need to be run in the same R instance 
    # as at the rendering of the PDF and HTML docs,
    # so we define it once here and run it twice below
    # (plus one to explicitly check if pandoc was found
    # and give a more informative error message)
    find_pandoc_command="rmarkdown::find_pandoc(dir = c('/opt/quarto/bin/tools', '/usr/lib/rstudio/resources/app/bin/quarto/bin/tools', 'C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools', '/Applications/quarto/bin/tools/aarch64', '/Applications/quarto/bin/tools', '/Applications/RStudio.app/Contents/MacOS/quarto/bin/tools', '/Applications/RStudio.app/Contents/MacOS/quarto/bin/tools/aarch64', '/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools', '/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64'), cache = F)"
    pandoc_version=$(Rscript -e "cat(paste($find_pandoc_command[['version']]))")
    # Create an empty Rmd-file for testing
    touch mds-knit-pdf-test.Rmd
    if ! Rscript -e "$find_pandoc_command;rmarkdown::render('mds-knit-pdf-test.Rmd', output_format = 'pdf_document')" &> /dev/null; then
        echo "MISSING   rmarkdown PDF-generation failed. Check that quarto, rmarkdown, and latex are marked OK above." >> check-setup-mds.log
        if [ "$pandoc_version" = "0" ]; then
            echo "It seems that RMarkdown cannot find pandoc (should have been installed as part of quarto, check if 'quarto pandoc --version' works)" >> check-setup-mds.log
        fi
    else
        echo 'OK        rmarkdown PDF-generation was successful.' >> check-setup-mds.log
    fi
    if ! Rscript -e "$find_pandoc_command;rmarkdown::render('mds-knit-pdf-test.Rmd', output_format = 'html_document')" &> /dev/null; then
        echo "MISSING   rmarkdown HTML-generation failed. Check that quarto and rmarkdown are marked OK above." >> check-setup-mds.log
        if [ "$pandoc_version" = "0" ]; then
            echo "It seems that RMarkdown cannot find pandoc (should have been installed as part of quarto, check if 'quarto pandoc --version' works)" >> check-setup-mds.log
        fi
    else
        echo 'OK        rmarkdown HTML-generation was successful.' >> check-setup-mds.log
    fi
    # -f makes sure `rm` succeeds even when the file does not exists
    rm -f mds-knit-pdf-test.Rmd mds-knit-pdf-test.html mds-knit-pdf-test.pdf
fi

# 4. Ouput the saved file to stdout
# I am intentionally showing the entire output in the end,
# instead of progressively with `tee` throughout
# so that students have time to read the help message in the beginning.
tail -n +2 check-setup-mds.log  # `tail` to skip rows already echoed to stdout

# Output details about PDF and HTML creation errors
# This is outputted after all the package OK/MISSING info
# to separate the detailed error message from the overview of which packages installed correctly.
if [ -s jupyter-pdf-error.log ]; then
    echo '' >> check-setup-mds.log
    echo '======== You had the following errors during Jupyter PDF generation ========' >> check-setup-mds.log
    cat jupyter-pdf-error.log >> check-setup-mds.log
    echo '======== End of Jupyter PDF error ========' >> check-setup-mds.log
fi
if [ -s jupyter-webpdf-error.log ]; then
    echo '' >> check-setup-mds.log
    echo '======== You had the following errors during Jupyter WebPDF generation ========' >> check-setup-mds.log
    cat jupyter-webpdf-error.log >> check-setup-mds.log
    echo '======== End of Jupyter WebPDF error ========' >> check-setup-mds.log
fi
if [ -s jupyter-html-error.log ]; then
    echo '' >> check-setup-mds.log
    echo 'You had the following errors during Jupyter HTML generation:' >> check-setup-mds.log
    cat jupyter-html-error.log >> check-setup-mds.log
    echo '======== End of Jupyter HTML error ========' >> check-setup-mds.log
fi
# -f makes sure `rm` succeeds even when the file does not exists
rm -f jupyter-html-error.log jupyter-webpdf-error.log jupyter-pdf-error.log

# Student don't need to see this in stdout, but useful to have in the log-file
# env
echo '' >> check-setup-mds.log
echo -e "${ORANGE}## Environmental variables${NC}" >> check-setup-mds.log
env >> check-setup-mds.log

# .bash_profile
echo '' >> check-setup-mds.log
echo -e "${ORANGE}## Content of .bash_profile${NC}" >> check-setup-mds.log
if ! [ -f ~/.bash_profile ]; then
    echo "~/.bash_profile not found" >> check-setup-mds.log
else
    cat ~/.bash_profile >> check-setup-mds.log
fi

# .bashrc
echo '' >> check-setup-mds.log
echo -e "${ORANGE}## Content of .bashrc${NC}" >> check-setup-mds.log
if ! [ -f ~/.bashrc ]; then
    echo "~/.bashrc not found" >> check-setup-mds.log
else
    cat ~/.bashrc >> check-setup-mds.log
fi

echo
echo "The above output has been saved to the file $(pwd)/check-setup-mds.log"
echo "together with system configuration details and any detailed error messages about PDF and HTML generation."
echo "You can open this folder in your file browser by typing \`${file_browser} .\` (without the surrounding backticks)."
echo "Before sharing the log file, review that there is no SENSITIVE INFORMATION such as passwords or access tokens in it."
