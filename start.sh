#!/bin/bash

# 定义一个函数来放开端口
open_port() {
    echo "请输入要放开的端口号: "
    read port
    iptables -A INPUT -p tcp --dport $port -j ACCEPT
    iptables -A INPUT -p udp --dport $port -j ACCEPT
    ip6tables -A INPUT -p tcp --dport $port -j ACCEPT
    ip6tables -A INPUT -p udp --dport $port -j ACCEPT
    iptables-save > /etc/iptables/rules.v4
    ip6tables-save > /etc/iptables/rules.v6
    echo "端口 $port 已放开，并设置为开机自动生效。"
}


# 显示菜单
show_menu() {
    echo "1. 选项一"
    echo "2. 选项二"
    echo "3. 选项三"
    echo "4. 选项四"
    echo "5. 放开指定端口"
    echo "0. 退出"
}

# 主循环
while true; do
    show_menu
    read -p "请选择一个选项: " choice
    case $choice in
        1) echo "执行了选项一";;
        2) echo "执行了选项二";;
        3) echo "执行了选项三";;
        4) echo "执行了选项四";;
        5) open_port;;
        0) echo "退出程序"; break;;
        *) echo "无效选项，请重新输入";;
    esac
done

