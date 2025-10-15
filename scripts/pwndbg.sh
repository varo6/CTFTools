curl -qsL 'https://install.pwndbg.re' | sh -s -- -t pwndbg-gdb

wget -O ~/.gdbinit-gef.py https://gef.blah.cat/py

echo "source ~/.gdbinit-gef.py" >> ~/.gdbinit

source ~/.bashrc
