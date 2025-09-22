sudo apt update
sudo apt install -y git python3 python3-pip python3-dev libgmp3-dev libmpc-dev libmpfr-dev build-essential
sudo apt install -y python3-sympy python3-requests gmpy2 python3-libnum

git clone https://github.com/RsaCtfTool/RsaCtfTool.git

cd RsaCtfTool

sudo python3 -m pip install -r requirements.txt --break-system-packages
sudo python3 setup.py install

cd ..
sudo rm -rf RsaCtfTool
