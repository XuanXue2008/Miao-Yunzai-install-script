FROM node:16-bookworm
#创建install.sh 并向其中写入命令
RUN touch install.sh
#更换中科大镜像源
RUN echo "sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list" >> install.sh
#更新源
RUN echo "apt-get update" >> install.sh
#安装必要运行库
RUN echo "apt install apt-transport-https ca-certificates -y" >> install.sh
RUN echo "apt install wget,libc6-dev,gcc,g++,make,dpkg-dev -y" >> install.sh
RUN echo "apt install libgbm-dev -y" >> install.sh
RUN echo "apt install libxkbcommon-x11-0 -y" >> install.sh
RUN echo "apt install libgtk-3-0 -y" >> install.sh
RUN echo "apt install ca-certificates fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 lsb-release wget xdg-utils -y" >> install.sh
RUN echo "apt install libnss3-dev -y" >> install.sh
RUN echo "apt install libxss1 -y" >> install.sh
RUN echo "apt install libasound2 -y" >> install.sh
RUN echo "apt install git -y" >> install.sh
#克隆 libx264
RUN echo "git clone https://code.videolan.org/videolan/x264.git x264" >> install.sh
#下载 redis
RUN echo "wget https://download.redis.io/redis-stable.tar.gz" >> install.sh
#克隆 ffmpeg
RUN echo "git clone https://gitee.com/mirrors/ffmpeg.git ffmpeg" >> install.sh
#编译安装 libx264
RUN echo "cd x264" >> install.sh
RUN echo "./configure" >> install.sh
RUN echo "make && make install" >> install.sh
RUN echo "cd .." >> install.sh
#编译安装 redis
RUN echo "tar -xzvf redis-stable.tar.gz" >> install.sh
RUN echo "cd redis-stable" >> install.sh
RUN echo "make && make install" >> install.sh
RUN echo "cd .." >> install.sh
#编译安装 ffmpeg
RUN echo "cd ffmpeg" >> install.sh
RUN echo "./configure --enable-shared --enable-swscale --enable-gpl --enable-nonfree --enable-pic --prefix=/home/ffmpeg --enable-version3 --enable-postproc --enable-pthreads --enable-static --enable-libx264 --disable-x86asm" >> install.sh
RUN echo "make && make install" >> install.sh
RUN echo "cd .." >> install.sh
#克隆 Miao-Yunzai
RUN echo "git clone --depth=1 https://gitee.com/yoimiya-kokomi/Miao-Yunzai.git" >> install.sh
RUN echo "cd Miao-Yunzai" >> install.sh
#克隆 Miao-Yunzai 插件
RUN echo "git clone --depth=1 https://gitee.com/yoimiya-kokomi/miao-plugin.git ./plugins/miao-plugin/" >> install.sh
#安装 pnpm
RUN echo "npm --registry=https://registry.npmmirror.com install pnpm -g" >> install.sh
#设置 node.js插件源为国内源
RUN echo "pnpm config set registry https://registry.npmmirror.com" >> install.sh
#安装 node.js插件
RUN echo "pnpm install -P" >> install.sh
#安装 puppeteer chromium
RUN echo "node node_modules/puppeteer/install.js" >> install.sh
#启动 redis
RUN echo "redis-server --save 900 1 --save 300 10 --daemonize yes --ignore-warnings ARM64-COW-BUG" >> install.sh
RUN bash ./install.sh