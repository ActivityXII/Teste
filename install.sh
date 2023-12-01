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

mkdir -p /usr/src/asterisk
cd /usr/src/asterisk
clear
echo "Install source mp3"
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz /usr/src/
cd /usr/src/
tar xzvf asterisk-20-current.tar.gz /usr/src/asterisk
rm -rf asterisk-20-current.tar.gz
useradd -c 'Asterisk PBX' -d /var/lib/asterisk asterisk
mkdir /var/run/asterisk
chown -R asterisk:asterisk /var/run/asterisk
chown -R asterisk:asterisk /var/log/asterisk
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


pt-get purge --yes -qq --auto-remove > /dev/null
rm -rf /var/lib/apt/lists/*
mkdir -p /usr/src/asterisk
cd /usr/src/asterisk
curl -sL http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz | tar --strip-components 1 -xz
echo "Install source mp3"
./contrib/scripts/get_mp3_source.sh && \
contrib/scripts/install_prereq install && \
./configure --prefix=/usr --libdir=/usr/lib --with-pjproject-bundled --with-jansson-bundled --with-resample --with-ssl=ssl --with-srtp > /dev/null
: ${JOBS:=$(( $(nproc) + $(nproc) / 2 ))}