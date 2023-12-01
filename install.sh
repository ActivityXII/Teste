set -ueo pipefail
apt update
apt install libpcap0.8 libpcap0.8-dev libpcap-dev passwd -y
echo $PATH
export PATH=$PATH:/usr/sbin:/sbin
echo "Update System"
DEBIAN_FRONTEND=noninteractive \
apt-get update -qq

echo "Install packages"
DEBIAN_FRONTEND=noninteractive \
apt-get install --yes -qq --no-install-recommends --no-install-suggests \
  odbc-postgresql \
  aptitude \
  mpg123 \
  sox \
  make \
  gcc \
  g++ \
  unixodbc \
  unixodbc-dev \
  wget \
  iputils-ping \
  vim \
  autoconf \
  binutils-dev \
  build-essential \
  ca-certificates \
  curl \
  ffmpeg \
  figlet \
  automake \
  sudo \
  file \
  libcurl4-openssl-dev \
  libedit-dev \
  libgsm1-dev \
  libogg-dev \
  libpopt-dev \
  libresample1-dev \
  libspandsp-dev \
  libspeex-dev \
  libspeexdsp-dev \
  libsqlite3-dev \
  libsrtp2-dev \
  libssl-dev \
  libvorbis-dev \
  libxml2-dev \
  libxslt1-dev \
  lsof \
  tcpdump \
  iftop \
  odbcinst \
  portaudio19-dev \
  procps \
  unixodbc \
  unixodbc-dev \
  uuid \
  uuid-dev \
  xmlstarlet \
  bzip2 \
  subversion \
  git \
  cmake \
  libtool \
  libpcap-dev \
> /dev/null

rm -rf asterisk*
clear
cd /usr/src/
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz
tar xzvf asterisk-20-current.tar.gz
rm -rf asterisk-20-current.tar.gz
mv asterisk* asterisk
cd /usr/src/asterisk
useradd -c 'Asterisk PBX' -d /var/lib/asterisk asterisk
mkdir /var/run/asterisk
chown -R asterisk:asterisk /var/run/asterisk
contrib/scripts/install_prereq install
make clean
./configure
make menuselect.makeopts
menuselect/menuselect --enable res_config_mysql  menuselect.makeopts
menuselect/menuselect --enable format_mp3  menuselect.makeopts
menuselect/menuselect --enable codec_opus  menuselect.makeopts
menuselect/menuselect --enable codec_silk  menuselect.makeopts
menuselect/menuselect --enable codec_siren7  menuselect.makeopts
menuselect/menuselect --enable codec_siren14  menuselect.makeopts
contrib/scripts/get_mp3_source.sh
make
make install
make samples
make config

  cd /usr/src && \
  mkdir bcg729 && \
  curl -fSL --connect-timeout 30 https://github.com/BelledonneCommunications/bcg729/archive/1.1.1.tar.gz | tar xz --strip 1 -C bcg729 && \
  cd bcg729 && \
  cmake . -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_PREFIX_PATH=/usr && \
  make && \
  make install && \
  cd /usr/src && \
  mkdir asterisk-g72x && \
  curl -fSL --connect-timeout 30 https://bitbucket.org/arkadi/asterisk-g72x/get/master.tar.gz | tar xz --strip 1 -C asterisk-g72x && \
  cd asterisk-g72x && \
  ./autogen.sh && \
  ./configure --prefix=/usr --with-bcg729 --enable-penryn && \
  make && \
  make install && \
  cd /usr/src && \
  mkdir sngrep && \
  curl -fSL --connect-timeout 30 https://github.com/irontec/sngrep/archive/v1.6.0.tar.gz | tar xz --strip 1 -C sngrep && \
  cd sngrep && \
  apt install libpcap0.8 libpcap0.8-dev libpcap-dev -y && \
  ./bootstrap.sh && \
  ./configure --prefix=/usr && \
  make && \
  make install && \

sed -i -E 's/^;(run)(user|group)/\1\2/' /etc/asterisk/asterisk.conf

mkdir -p /usr/src/codecs/opus
cd /usr/src/codecs/opus
curl -sL http://downloads.digium.com/pub/telephony/codec_opus/asterisk-16.0/x86-64/codec_opus-16.0_current-x86_64.tar.gz | tar xz --strip 1 
cp *.so /usr/lib/asterisk/modules/
cp codec_opus_config-en_US.xml /var/lib/asterisk/documentation/

mkdir -p /etc/asterisk/ \
         /var/spool/asterisk/fax

sudo usermod -aG audio,dialout asterisk
sudo chown -R asterisk.asterisk /etc/asterisk
sudo chown -R asterisk.asterisk /var/{lib,log,spool}/asterisk
sudo chown -R asterisk.asterisk /usr/lib/asterisk
chmod -R 750 /var/spool/asterisk

cd /
rm -rf /usr/src/codecs