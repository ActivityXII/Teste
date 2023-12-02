echo "Install packages"
DEBIAN_FRONTEND=noninteractive \
apt-get install -y \
  odbc-postgresql \
  apt-getitude \
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
echo
echo '----------- Install Asterisk 13 ----------'
echo
sleep 1
cd /usr/src
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz
clear
tar xzvf asterisk-20-current.tar.gz
rm -rf asterisk-20-current.tar.gz
cd asterisk-*
apt-get install passwd -y
echo $PATH
export PATH=$PATH:/usr/sbin:/sbin
useradd -c 'Asterisk PBX' -d /var/lib/asterisk asterisk
mkdir /var/run/asterisk
mkdir /var/log/asterisk
chown -R asterisk:asterisk /var/run/asterisk
chown -R asterisk:asterisk /var/log/asterisk
contrib/scripts/install_prereq install
make clean
./configure
make menuselect/menuselect menuselect-tree menuselect.makeopts && \
  menuselect/menuselect \
    --enable-category MENUSELECT_ADDONS \
    --enable-category MENUSELECT_CHANNELS \
    --enable-category MENUSELECT_APPS \
    --enable-category MENUSELECT_CDR \
    --enable-category MENUSELECT_FORMATS \
    --enable-category MENUSELECT_FUNCS \
    --enable-category MENUSELECT_PBX \
    --enable-category MENUSELECT_RES \
    --enable-category MENUSELECT_CEL \
    --enable-category MENUSELECT_CORE_SOUNDS \
    --enable-category MENUSELECT_EXTRA_SOUNDS \
    --enable-category MENUSELECT_MOH \
&& \
menuselect/menuselect \
    --enable BETTER_BACKTRACES \
    --enable DONT_OPTIMIZE \
    --enable app_confbridge \
    --enable cdr_pgsql \
    --enable cel_pgsql \
    --enable res_config_pgsql \
    --enable app_macro \
    --enable app_page \
    --enable binaural_rendering_in_bridge_softmix \
    --enable chan_motif \
    --enable codec_silk \
    --enable codec_opus \
    --enable format_mp3 \
    --enable res_ari \
    --enable res_chan_stats \
    --enable res_calendar \
    --enable res_calendar_caldav \
    --enable res_calendar_icalendar \
    --enable res_endpoint_stats \
    --enable res_fax \
    --enable res_fax_spandsp \
    --enable res_pktccops \
    --enable res_snmp \
    --enable res_srtp \
    --enable res_xmpp \
    --disable BUILD_NATIVE \
    --disable app_meetme \
    --disable app_ivrdemo \
    --disable app_saycounted \
    --disable app_skel \
    --disable cdr_sqlite3_custom \
    --disable cel_sqlite3_custom \
    --disable cdr_tds \
    --disable cel_tds \
    --disable cdr_radius \
    --disable cel_radius \
    --disable chan_alsa \
    --disable chan_console \
    --disable chan_mgcp \
    --disable chan_skinny \
    --disable chan_ooh323 \
    --disable chan_mobile \
    --disable chan_unistim \
    --disable res_ari_mailboxes \
    --disable res_digium_phone \
    --disable res_calendar_ews \
    --disable res_calendar_exchange \
    --disable res_stasis_mailbox \
    --disable res_mwi_external \
    --disable res_mwi_external_ami \
    --disable res_config_mysql \
    --disable res_config_ldap \
    --disable res_config_sqlite3 \
    --disable res_phoneprov \
    --disable res_pjsip_phoneprov_provider
contrib/scripts/get_mp3_source.sh
make
make install
make samples
make config

apt-get install -y iptables-services
rm -rf /etc/fail2ban
cd /tmp
git clone https://github.com/fail2ban/fail2ban.git
cd /tmp/fail2ban
python setup.py install
systemctl mask firewalld.service
systemctl enable iptables.service
systemctl enable ip6tables.service
systemctl stop firewalld.service
systemctl start iptables.service
systemctl start ip6tables.service
systemctl enable iptables
systemctl stop firewalld
chkconfig --levels 123456 firewalld off
echo
echo "Installing Fail2ban & Iptables"
echo
ssh_port=$(cat /etc/ssh/sshd_config | grep Port |  awk 'NR==1{print $2}')
iptables -F
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport $ssh_port -j ACCEPT
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -A INPUT -p udp -m udp --dport 3306 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 5060 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 10000:50000 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -I INPUT -j DROP -p udp --dport 5060 -m string --string "friendly-scanner" --algo bm
iptables -I INPUT -j DROP -p udp --dport 5060 -m string --string "sundayddr" --algo bm
iptables -I INPUT -j DROP -p udp --dport 5060 -m string --string "sipsak" --algo bm
iptables -I INPUT -j DROP -p udp --dport 5060 -m string --string "sipvicious" --algo bm
iptables -I INPUT -j DROP -p udp --dport 5060 -m string --string "iWar" --algo bm
iptables -A INPUT -j DROP -p udp --dport 5060 -m string --string "sipcli/" --algo bm
iptables -A INPUT -j DROP -p udp --dport 5060 -m string --string "VaxSIPUserAgent/" --algo bm
sudo apt-get update
sudo apt-get install ufw
sudo ufw allow 3306
sudo ufw enable
sudo ufw status