curl -sL https://rpm.nodesource.com/setup_18.x | bash -

yum -y update
yum install pango.x86_64 libXcomposite.x86_64 libXcursor.x86_64 libXdamage.x86_64 libXext.x86_64 libXi.x86_64 libXtst.x86_64 cups-libs.x86_64 libXScrnSaver.x86_64 libXrandr.x86_64 GConf2.x86_64 alsa-lib.x86_64 atk.x86_64 gtk3.x86_64 -y
yum install yum-utils -y
yum install git -y
yum install wget -y
yum install gcc gcc-c++ -y
yum install make -y
yum install curl -y
yum install nodejs npm -y

wget http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
tar xf yasm-1.3.0.tar.gz
cd yasm-1.3.0/
./configure --prefix=/usr/local
make -j12 && make install
cd ..
git clone https://code.videolan.org/videolan/x264.git x264
wget https://mirrors.huaweicloud.com/redis/redis-7.0.9.tar.gz
git clone https://gitee.com/mirrors/ffmpeg.git ffmpeg
cd x264
./configure --disable-asm
make && make install
cd ..
tar -xzvf redis-7.0.9.tar.gz
cd redis-7.0.9
make && make install
cd ..
cd ffmpeg
./configure
make && make install
cd ..
git clone --depth=1 https://gitee.com/yoimiya-kokomi/Miao-Yunzai.git
cd Miao-Yunzai
git clone --depth=1 https://gitee.com/yoimiya-kokomi/miao-plugin.git ./plugins/miao-plugin/
npm --registry=https://registry.npmmirror.com install pnpm -g
pnpm config set registry https://registry.npmmirror.com
pnpm install -P
node node_modules/puppeteer/install.js
redis-server --save 900 1 --save 300 10 --daemonize yes --ignore-warnings ARM64-COW-BUG
