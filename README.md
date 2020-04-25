Создание точки доступа с перехватом трафика

Однажды мне пришлось сделать точку доступа для того, чтобы проинспектировать трафик одной мобильной приложухи. И был у меня старенький ноут Asus EEE PC c установленным Линуксом.
Итак - дано:
* eth0 c IP 192.168.1.100 подключен в роутер и глядит в Интернет;
* wlan0 с IP 192.168.2.1 должен раздавать WiFi с именем TRAP_AP по сетке 192.168.2.1/24;
* перехват трафика черeз thark.
Писал, опираясь на статью с Хабра - https://habr.com/ru/post/188274/. Спасибо за это товарищу @CRImer.
Итак, устанавливаем программу, для создания точки доступа
*sudo apt install -y hostapd*
После установки запустим hostapd в режиме демона. В файле /etc/defaults/hostapd необходимо раскомментировать строчку DAEMON_CONF и прописать файл конфигурации точки.
*DAEMON_CONF="/etc/hostapd/hostapd.conf"*
Прописываем конфиг точки доступа.
'''
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
'''	
