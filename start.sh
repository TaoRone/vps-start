#!/bin/bash

# 检查是否以 root 权限运行
if [ "$(id -u)" != "0" ]; then
   echo "此脚本需要 root 权限运行。请使用 sudo 或以 root 用户运行。"
   exit 1
fi

# 安装 iptables-persistent
if ! dpkg -s iptables-persistent >/dev/null 2>&1; then
    apt-get update
    apt-get install -y iptables-persistent
fi

# 定义一个函数来添加规则
add_rules() {
    local protocol=$1
    local dport=$2
    iptables -A INPUT -p "$protocol" --dport "$dport" -j ACCEPT
    ip6tables -A INPUT -p "$protocol" --dport "$dport" -j ACCEPT
}

# 放开端口函数
open_port() {
    echo "请输入要放开的端口号: "
    read port

    # 检查输入是否为单个端口或连续端口范围
    if [[ "$port" =~ ^[0-9]+$ ]]; then
        add_rules tcp $port
        add_rules udp $port
    elif [[ "$port" =~ ^([0-9]+):([0-9]+)$ ]] && [[ "${BASH_REMATCH[1]}" -lt "${BASH_REMATCH[2]}" ]]; then
        for ((i=${BASH_REMATCH[1]}; i<=${BASH_REMATCH[2]}; i++)); do
            add_rules tcp $i
            add_rules udp $i
        done
    elif [[ "$port" =~ ^[0-9]+([[:space:]]+[0-9]+)*$ ]]; then
        port=$(echo $port | tr -s '[:space:]' ' ')
        for p in $port; do
            add_rules tcp $p
            add_rules udp $p
        done
    else
        echo "输入格式错误，请重新输入。"
        return 1
    fi

    # 保存规则
    iptables-save > /etc/iptables/rules.v4
    ip6tables-save > /etc/iptables/rules.v6
    echo "端口 $port 已放开，并设置为开机自动生效。"

    # 处理重复规则
    iptables-save | grep -v "^#" | sort | uniq -u | iptables-restore
    echo "重复的 iptables 规则已删除，仅保留了优先度最高的规则。"
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
