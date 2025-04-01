# 🧠 Ookla Server Optimizer

**Versión interactiva y auditada para optimizar servidores Ookla (Speedtest) sobre Linux, compatible con Proxmox/KVM y máquinas físicas.**

Este script aplica todas las recomendaciones oficiales del documento **"Optimizing Server Performance – Ookla"**, incluyendo mejoras de red, ajustes de kernel, buffers TCP, offloads y verificación de MTU/PMTUD.

---

## ✅ ¿Qué hace el script?

- Detecta automáticamente la interfaz de red (por ejemplo: `ens18`)
- Verifica y aplica (si deseas):
  - Activación de `BBR` como algoritmo TCP
  - Cola de tráfico (`fq`) para BBR
  - Activación de GRO
  - Desactivación de `tcp_timestamps`
  - Activación de `tcp_sack`, `tcp_window_scaling`, `tcp_moderate_rcvbuf`
  - Ajuste de buffers `tcp_rmem` y `tcp_wmem` para tráfico de alto rendimiento
  - Aumento de `txqueuelen` a 10000
- Verifica:
  - MTU mínima de 1500
  - Funcionalidad de **PMTUD** con `ping -M do`

---

## 🧪 Cómo usar

1. Descarga el script:

```bash
curl -O https://raw.githubusercontent.com/gabrielpc1190/ooklaserver-optimizer/main/ookla-optimize-interactive-v4.sh
chmod +x ookla-optimize-interactive-v4.sh
