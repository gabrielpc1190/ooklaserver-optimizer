#!/bin/bash

ok="[✅]"
warn="[⚠️ ]"
done="[✔️]"
skip="[⏭️]"
fail="[❌]"

IFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo | head -n 1)

confirm_and_apply() {
  local message="$1"
  local apply_cmd="$2"
  local verify_cmd="$3"

  echo -ne "\n$message [y/N]: "
  read -r confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    eval "$apply_cmd"
    sleep 0.5
    echo -n " → Verificando... "
    result=$(eval "$verify_cmd")
    echo -e "$done Aplicado: $result"
  else
    echo -e "$skip Cambio omitido."
  fi
}

echo "==== Verificación Inicial para Servidor Ookla ===="
echo "Usando interfaz detectada: $IFACE"

# 1. TCP Congestion Control
cc=$(sysctl -n net.ipv4.tcp_congestion_control)
if [[ "$cc" != "bbr" ]]; then
  echo "$warn TCP Congestion Control: $cc (recomendado: bbr)"
  confirm_and_apply "¿Cambiar a BBR?" \
    "sysctl -w net.ipv4.tcp_congestion_control=bbr && echo 'net.ipv4.tcp_congestion_control=bbr' >> /etc/sysctl.conf" \
    "sysctl -n net.ipv4.tcp_congestion_control"
else
  echo "$ok TCP Congestion Control: $cc"
fi

# 2. default_qdisc
qdisc=$(sysctl -n net.core.default_qdisc 2>/dev/null || echo "N/D")
if [[ "$qdisc" != "fq" ]]; then
  echo "$warn default_qdisc: $qdisc (se recomienda 'fq')"
  confirm_and_apply "¿Cambiar default_qdisc a 'fq'?" \
    "sysctl -w net.core.default_qdisc=fq && echo 'net.core.default_qdisc=fq' >> /etc/sysctl.conf" \
    "sysctl -n net.core.default_qdisc"
else
  echo "$ok default_qdisc ya está en fq"
fi

# 3. GRO (Generic Receive Offload)
gro=$(ethtool -k $IFACE 2>/dev/null | grep "generic-receive-offload:" | awk '{print $2}')
if [[ "$gro" != "on" ]]; then
  echo "$warn GRO está en $gro (recomendado: on)"
  confirm_and_apply "¿Activar GRO en $IFACE?" \
    "ethtool -K $IFACE gro on" \
    "ethtool -k $IFACE | grep 'generic-receive-offload:' | awk '{print \$2}'"
else
  echo "$ok GRO activado"
fi

# 4. tcp_timestamps
tstmp=$(sysctl -n net.ipv4.tcp_timestamps)
if [[ "$tstmp" != "0" ]]; then
  echo "$warn tcp_timestamps está activado (recomendado: desactivado)"
  confirm_and_apply "¿Desactivar tcp_timestamps?" \
    "sysctl -w net.ipv4.tcp_timestamps=0 && echo 'net.ipv4.tcp_timestamps=0' >> /etc/sysctl.conf" \
    "sysctl -n net.ipv4.tcp_timestamps"
else
  echo "$ok tcp_timestamps desactivado"
fi

# 5. tcp_sack
sack=$(sysctl -n net.ipv4.tcp_sack)
if [[ "$sack" != "1" ]]; then
  echo "$warn tcp_sack está desactivado"
  confirm_and_apply "¿Activar tcp_sack?" \
    "sysctl -w net.ipv4.tcp_sack=1 && echo 'net.ipv4.tcp_sack=1' >> /etc/sysctl.conf" \
    "sysctl -n net.ipv4.tcp_sack"
else
  echo "$ok tcp_sack activado"
fi

# 6. tcp_window_scaling
wscaling=$(sysctl -n net.ipv4.tcp_window_scaling)
if [[ "$wscaling" != "1" ]]; then
  echo "$warn tcp_window_scaling está desactivado"
  confirm_and_apply "¿Activar tcp_window_scaling?" \
    "sysctl -w net.ipv4.tcp_window_scaling=1 && echo 'net.ipv4.tcp_window_scaling=1' >> /etc/sysctl.conf" \
    "sysctl -n net.ipv4.tcp_window_scaling"
else
  echo "$ok tcp_window_scaling activado"
fi

# 7. tcp_moderate_rcvbuf
moderate=$(sysctl -n net.ipv4.tcp_moderate_rcvbuf)
if [[ "$moderate" != "1" ]]; then
  echo "$warn tcp_moderate_rcvbuf está desactivado"
  confirm_and_apply "¿Activar tcp_moderate_rcvbuf?" \
    "sysctl -w net.ipv4.tcp_moderate_rcvbuf=1 && echo 'net.ipv4.tcp_moderate_rcvbuf=1' >> /etc/sysctl.conf" \
    "sysctl -n net.ipv4.tcp_moderate_rcvbuf"
else
  echo "$ok tcp_moderate_rcvbuf activado"
fi

# 8. tcp_rmem / tcp_wmem
rmem_actual_clean=$(sysctl -n net.ipv4.tcp_rmem | xargs)
rmem_recommended="4096 87380 67108864"
if [[ "$rmem_actual_clean" != "$rmem_recommended" ]]; then
  echo "$warn tcp_rmem actual: $rmem_actual (recomendado: $rmem_recommended)"
  confirm_and_apply "¿Ajustar tcp_rmem?" \
    "sysctl -w net.ipv4.tcp_rmem='$rmem_recommended' && echo 'net.ipv4.tcp_rmem=$rmem_recommended' >> /etc/sysctl.conf" \
    "sysctl -n net.ipv4.tcp_rmem"
else
  echo "$ok tcp_rmem ya está en $rmem_actual"
fi

wmem_actual_clean=$(sysctl -n net.ipv4.tcp_wmem | xargs)
wmem_recommended="4096 65536 67108864"
if [[ "$wmem_actual_clean" != "$wmem_recommended" ]]; then
  echo "$warn tcp_wmem actual: $wmem_actual (recomendado: $wmem_recommended)"
  confirm_and_apply "¿Ajustar tcp_wmem?" \
    "sysctl -w net.ipv4.tcp_wmem='$wmem_recommended' && echo 'net.ipv4.tcp_wmem=$wmem_recommended' >> /etc/sysctl.conf" \
    "sysctl -n net.ipv4.tcp_wmem"
else
  echo "$ok tcp_wmem ya está en $wmem_actual"
fi
echo "$ok tcp_rmem actual: $(sysctl -n net.ipv4.tcp_rmem)"
confirm_and_apply "¿Ajustar tcp_rmem?" \
  "sysctl -w net.ipv4.tcp_rmem='4096 87380 67108864' && echo 'net.ipv4.tcp_rmem=4096 87380 67108864' >> /etc/sysctl.conf" \
  "sysctl -n net.ipv4.tcp_rmem"

echo "$ok tcp_wmem actual: $(sysctl -n net.ipv4.tcp_wmem)"
confirm_and_apply "¿Ajustar tcp_wmem?" \
  "sysctl -w net.ipv4.tcp_wmem='4096 65536 67108864' && echo 'net.ipv4.tcp_wmem=4096 65536 67108864' >> /etc/sysctl.conf" \
  "sysctl -n net.ipv4.tcp_wmem"

# 9. txqueuelen
txq=$(cat /sys/class/net/$IFACE/tx_queue_len)
if [[ "$txq" -lt 10000 ]]; then
  echo "$warn txqueuelen actual: $txq (recomendado: 10000)"
  confirm_and_apply "¿Aumentar txqueuelen a 10000?" \
    "ip link set $IFACE txqueuelen 10000 && sed -i '/iface $IFACE/,/^$/s/^\(\s*\)/\1pre-up ip link set $IFACE txqueuelen 10000\n/' /etc/network/interfaces" \
    "cat /sys/class/net/$IFACE/tx_queue_len"
else
  echo "$ok txqueuelen: $txq"
fi

echo -e "\n$done Optimización interactiva finalizada."

# 10. Verificación MTU y prueba de PMTUD
echo ""
echo "==== Verificación de MTU y PMTUD ===="
mtu=$(ip link show $IFACE | grep -o 'mtu [0-9]*' | awk '{print $2}')
if [[ "$mtu" -lt 1500 ]]; then
  echo "$warn MTU en $IFACE es $mtu (recomendado: 1500)"
else
  echo "$ok MTU en $IFACE: $mtu"
fi

echo "→ Haciendo prueba PMTUD con ping sin fragmentación (-M do)..."
ping -M do -s 1472 -c 2 8.8.8.8 &>/dev/null
if [[ $? -eq 0 ]]; then
  echo "$ok PMTUD funcional (ICMP Fragmentation Needed permitido)"
else
  echo "$fail PMTUD podría estar bloqueado (ICMP filtrado o MTU menor en ruta)"
fi

echo -e "\n$done Optimización interactiva finalizada con verificación extendida."
