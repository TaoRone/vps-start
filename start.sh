#!/bin/bash

# 确保root用户运行 Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# 所有函数需要在选项之前声明


# 放开端口函数 Define a function to open ports
open_port() {
    # 安装iptables持久化文件
    apt-get update
    apt-get install -y iptables-persistent
    echo "请输入要放开的端口号: "
    read port

    # 检查输入是否为单个端口或连续端口范围
    if [[ "$port" =~ ^[0-9]+$ ]]; then
        # 单个端口
        sudo iptables -A INPUT -p tcp --dport $port -j ACCEPT
        sudo iptables -A INPUT -p udp --dport $port -j ACCEPT
        sudo ip6tables -A INPUT -p tcp --dport $port -j ACCEPT
        sudo ip6tables -A INPUT -p udp --dport $port -j ACCEPT
    elif [[ "$port" =~ ^[0-9]+:[0-9]+$ ]]; then
        # 端口范围
        IFS=':' read -ra RANGE <<< "$port"
        for ((i=${RANGE[0]}; i<=${RANGE[1]}; i++)); do
            sudo iptables -A INPUT -p tcp --dport $i -j ACCEPT
            sudo iptables -A INPUT -p udp --dport $i -j ACCEPT
            sudo ip6tables -A INPUT -p tcp --dport $i -j ACCEPT
            sudo ip6tables -A INPUT -p udp --dport $i -j ACCEPT
        done
    elif [[ "$port" =~ ^[0-9]+([[:space:]]+[0-9]+)*$ ]]; then
    # 用空格分割的多个端口
    # 使用 tr 替换所有连续的空白字符为单个空格
    port=$(echo $port | tr -s '[:space:]' ' ')
    for p in $port; do
        sudo iptables -A INPUT -p tcp --dport $p -j ACCEPT
        sudo iptables -A INPUT -p udp --dport $p -j ACCEPT
        sudo ip6tables -A INPUT -p tcp --dport $p -j ACCEPT
        sudo ip6tables -A INPUT -p udp --dport $p -j ACCEPT
    done
else
    echo "输入格式错误，请重新输入。"
    return 1
fi


    # 保存规则
    sudo iptables-save > /etc/iptables/rules.v4
    sudo ip6tables-save > /etc/iptables/rules.v6
    echo "端口 $port 已放开，并设置为开机自动生效。"
}




# 显示菜单 Display menu
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
    # 清除输入缓冲区中的任何残留数据
    read -r -t 0.1 -n 10000
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

