git clone https://github.com/pwndbg/pwndbg

cd pwndbg

./setup.sh

wget -O ~/.gdbinit-gef.py https://gef.blah.cat/py

echo "source ~/.gdbinit-gef.py" >> ~/.gdbinit

source ~/.bashrc
