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
curl -O https://raw.githubusercontent.com/tu-usuario/tu-repo/main/ookla-optimize-interactive-v4.sh
chmod +x ookla-optimize-interactive-v4.sh
```

2. Ejecútalo como root:

```bash
./ookla-optimize-interactive-v4.sh
```

3. El script te preguntará paso a paso si deseas aplicar cada ajuste.

---

## 📷 Capturas de ejemplo

Puedes incluir capturas en la carpeta `/docs/` como esta:

```markdown
![captura](docs/screenshot-final.png)
```

---

## 📚 Basado en

- [Ookla – Optimizing Server Performance (PDF)](https://www.speedtest.net/enterprise)
- Linux kernel tuning best practices

---

## 💡 Requisitos

- Linux (Debian, Ubuntu, Proxmox, etc.)
- Acceso root
- `ethtool` y `iputils-ping` instalados

---

## 📦 Roadmap

- [x] Ajustes TCP interactivos
- [x] Validación de PMTUD
- [ ] Exportar reporte de auditoría (`.txt`)
- [ ] Modo no interactivo (`--auto`)
- [ ] Soporte multiinterfaz (bond0, ethX, etc.)

---

## ⚠️ Aviso

Este script modifica parámetros del sistema. Úsalo con precaución y revisa cada cambio si estás en producción.

---

## 🛠️ Autor

Creado por [Gabriel Paniagua Castro] con ayuda de ChatGPT v4 🚀
