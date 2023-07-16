apt-get update
apt install apt-transport-https ca-certificates -y
apt install libgbm-dev -y
apt install libxkbcommon-x11-0 -y
apt install libgtk-3-0 -y
apt install ca-certificates fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 lsb-release wget xdg-utils -y
apt install libnss3-dev -y
apt install libxss1 -y
apt install libasound2 -y
apt install git -y
git clone https://code.videolan.org/videolan/x264.git x264
wget https://mirrors.huaweicloud.com/redis/redis-7.0.9.tar.gz
git clone https://gitee.com/mirrors/ffmpeg.git ffmpeg
cd x264
./configure
make && make install
cd ..
tar -xzvf redis-7.0.9.tar.gz
cd redis-7.0.9
make && make install
cd ..
cd ffmpeg
./configure --enable-shared --enable-swscale --enable-gpl --enable-nonfree --enable-pic --prefix=/home/ffmpeg --enable-version3 --enable-postproc --enable-pthreads --enable-static --enable-libx264 --disable-x86asm
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
