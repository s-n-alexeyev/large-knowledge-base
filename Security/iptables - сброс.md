# Сбросить все правила в таблицах filter, nat и mangle:
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F

# Удалить все пользовательские цепочки:
sudo iptables -X
sudo iptables -t nat -X
sudo iptables -t mangle -X

# Установить политики по умолчанию (ACCEPT) для всех основных цепочек:
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT

# Проверить результат:
sudo iptables -L -n -v
sudo iptables -t nat -L -n -v