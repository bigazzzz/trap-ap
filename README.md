### Создание точки доступа с перехватом трафика

## Предисловие
Однажды мне пришлось сделать точку доступа для того, чтобы проинспектировать трафик одной мобильной приложухи. И был у меня старенький ноут Asus EEE PC c установленным Линуксом.
Итак - дано:
* eth0 c IP 192.168.1.100 подключен в роутер и глядит в Интернет;
* wlan0 с IP 192.168.2.1 должен раздавать WiFi с именем TRAP_AP по сетке 192.168.2.1/24;
* перехват трафика черeз thark.  
 
Писал, опираясь на [статью с Хабра](https://habr.com/ru/post/188274/). Спасибо за это товарищу @CRImer.
## Настраиваем наш интерфейс
Для начала пропишем информацию для WiFi интерфейса. Для этого нужно отредактировать файл /etc/network/interfaces
```
auto wlan0
iface wlan0 inet static
address 192.168.2.1
netmask 255.255.255.0
gateway 192.168.2.1
```
После рестартим интерфейс
```
ifdown wlan0
ifup wlan0
```
## Создаем точку доступа
Устанавливаем программу для создания точки доступа  
**sudo apt install -y hostapd**  
После установки запустим hostapd в режиме демона. В файле /etc/defaults/hostapd необходимо раскомментировать строчку DAEMON_CONF и прописать файл конфигурации точки.  
**DAEMON_CONF="/etc/hostapd/hostapd.conf"**  
Прописываем конфиг точки доступа.  
```
#Интерфейс, на котором будем поднимать WiFi
interface=wlan0
#Прописываем имя нашего WiFi
ssid=TRAP_AP
#Драйвер - стандартный
driver=nl80211
#Стандарт WiFi 802.11g. 802.11n требует дополнительных настроек.
hw_mode=g
#Канал WiFi
channel=6
#Отключаем блокировку по MAC-адресу. Говорят, лучше прописать. Я прописал.
macaddr_acl=0
#Настройки авторизации. Первая строчка содержит пароль к wifi.
wpa_passphrase=securepassword
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
auth_algs=1
```
Запускаем наш точку доступа  
**service hostapd restart**  
На этом этапе уже можно подключиться к сети WiFi, если прописать IP-адрес из сети 192.168.2.0/24 и шлюзом указать 192.168.2.1. Но это не слишком удобно, поэтому продолжаем продолжать.
## Устанавливаем DHCP-сервер
А заодно и свой DNS-сервер, что впрочем необязательно, но для моих целей идеально, чтобы я мог подменять запросы DNS. Устанавливаем dnsmasq  
**apt install -y dnsmasq**  
И полностью переписываем конфиг **/etc/dnsmasq**  
```

#Запускаем dnsmasq под определенным пользователем
user=dnsmasq
group=dnsmasq
#
# Настройки DNS
#
#Прописываем порт DNS
port=53
#Размер кэша для DNS-запросов
cache-size=1000
#DNS не запрашивает адреса без точки, как например localhost, main и т.д.
domain-needed
bogus-priv
#
# Настройка DHCP
#
#Интерфейс, на котором будет работать DHCP-сервер
interface=wlan0
#Интерфейс, на котором точно не должен работать DHCP-сервер
except-interface=enp3s0 
#Адреса выдаем из диапазона 192.168.2.10-192.168.2.50 на 12 часов
dhcp-range=192.168.2.10,192.168.2.50,12h
#DHCP-сервер в сети у нас один, отдаем ему авторитарные права
dhcp-authoritative
#DHCP-сервер будет работать только на тех интерфейсах, которые мы прописали
bind-interfaces
#Максимальное количество адресов, выдаваемых DHCP-сервером
dhcp-lease-max=100 
```
И рестартим наш сервер

**service dnsmasq restart**


На гитхабе выложен полный конфиг в файле [dnsmasq.conf.full](dnsmasq.conf.full), в котором расписаны огромное множество опций конфига.
