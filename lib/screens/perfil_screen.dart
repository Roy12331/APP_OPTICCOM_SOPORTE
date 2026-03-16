import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_theme.dart';
import '../widgets/custom_button.dart';

class PerfilScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  const PerfilScreen({super.key, required this.userData});

  void _cerrarSesion(BuildContext context) {
    context.go('/');
  }

  // 🔹 LÓGICA DE CONTACTO A SOPORTE
  Future<void> _contactarSoporte(BuildContext context) async {
    const String numeroCentral =
        "999888777"; // ⚠️ CAMBIA ESTO POR EL NÚMERO REAL DE OPTICCOM

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Soporte Central",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "¿Cómo deseas contactar a la base?",
                  style: TextStyle(color: AppTheme.textLight),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _BotonSoporte(
                      icono: Icons.call,
                      texto: "Llamada",
                      color: Colors.blue,
                      onTap: () async {
                        final Uri url = Uri.parse('tel:$numeroCentral');
                        if (await canLaunchUrl(url)) await launchUrl(url);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                    _BotonSoporte(
                      icono: Icons.message_rounded,
                      texto: "WhatsApp",
                      color: Colors.green,
                      onTap: () async {
                        final Uri url = Uri.parse(
                          'https://wa.me/51$numeroCentral',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔹 LÓGICA DE MANUALES (Formato Nativo y Rápido)
  void _mostrarManuales(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que ocupe más espacio en pantalla
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7, // Ocupa el 70% de la pantalla
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 15, bottom: 10),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Text(
                  "Manuales y Protocolos",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    children: const [
                      _AcordeonManual(
                        titulo: "1. Protocolo de Seguridad (EPP)",
                        icono: Icons.security_rounded,
                        contenido:
                            "• Uso obligatorio de casco, guantes dieléctricos y lentes de seguridad.\n• Para trabajos en altura, revisar el arnés y línea de vida antes de subir al poste.\n• Señalizar la zona de trabajo con conos si hay tránsito vehicular.",
                      ),
                      _AcordeonManual(
                        titulo: "2. Instalación de Conector Mecánico",
                        icono: Icons.cable_rounded,
                        contenido:
                            "1. Pelar el cable drop (chaqueta exterior) aprox. 5cm.\n2. Limpiar la fibra con alcohol isopropílico al 99%.\n3. Usar la cortadora (cleaver) a la medida exacta del conector.\n4. Insertar la fibra suavemente hasta que haga la curva de tensión.\n5. Asegurar la bota del conector.",
                      ),
                      _AcordeonManual(
                        titulo: "3. Parámetros Ópticos",
                        icono: Icons.speed_rounded,
                        contenido:
                            "• Potencia ideal en roseta: Entre -18 dBm y -24 dBm.\n• Potencia marginal: -25 dBm a -27 dBm (Revisar empalmes o curvaturas).\n• Falla (LOS): Mayor a -28 dBm o sin luz.",
                      ),
                      _AcordeonManual(
                        titulo: "4. Configuración Básica de ONU",
                        icono: Icons.router_rounded,
                        contenido:
                            "1. Conectar por cable LAN o WiFi (IP por defecto: 192.168.1.1).\n2. Ingresar credenciales de administrador.\n3. Configurar WAN en modo PPPoE con el usuario y contraseña brindados por Soporte.\n4. Configurar nombre de WiFi (SSID) y contraseña solicitada por el cliente.",
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 DATOS DINÁMICOS DESDE LA BD
    final String nombre = userData['nombre']?.toString() ?? 'Usuario';
    final String rol = userData['rol']?.toString() ?? 'Técnico';
    final String idUsuario = userData['id']?.toString() ?? '0';

    // Generador de iniciales
    final String iniciales = nombre.length >= 2
        ? nombre.substring(0, 2).toUpperCase()
        : 'TC';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.secondary,
        elevation: 0,
        title: const Text(
          "Mi Perfil",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 CABECERA DEL PERFIL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 40, top: 20),
              decoration: const BoxDecoration(
                color: AppTheme.secondary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primary,
                      child: Text(
                        iniciales,
                        style: const TextStyle(
                          fontSize: 35,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // 🔹 ETIQUETA DINÁMICA DE ROL E ID
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${rol.toUpperCase()} | ID: $idUsuario",
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 🔹 MENÚ DE HERRAMIENTAS REALES
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Herramientas Operativas",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 15),

                  _MenuItem(
                    icono: Icons.menu_book_rounded,
                    titulo: "Manuales y Protocolos",
                    subtitulo: "Seguridad, empalmes y equipos",
                    onTap: () => _mostrarManuales(context),
                  ),
                  _MenuItem(
                    icono: Icons.support_agent_rounded,
                    titulo: "Soporte Central",
                    subtitulo: "Contactar a la base (Llamada / WhatsApp)",
                    onTap: () => _contactarSoporte(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // 🔹 BOTÓN DE CERRAR SESIÓN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomButton(
                text: "CERRAR SESIÓN",
                color: Colors.redAccent,
                onPressed: () => _cerrarSesion(context),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// WIDGETS AUXILIARES
// ==========================================================

class _MenuItem extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.secondary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icono, color: AppTheme.secondary),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppTheme.textDark,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitulo,
            style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _BotonSoporte extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color color;
  final VoidCallback onTap;

  const _BotonSoporte({
    required this.icono,
    required this.texto,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icono, color: color, size: 32),
          ),
          const SizedBox(height: 10),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _AcordeonManual extends StatelessWidget {
  final String titulo;
  final String contenido;
  final IconData icono;

  const _AcordeonManual({
    required this.titulo,
    required this.contenido,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        leading: Icon(icono, color: AppTheme.primary),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        iconColor: AppTheme.primary,
        collapsedIconColor: Colors.grey,
        childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        children: [
          Text(
            contenido,
            style: const TextStyle(
              color: AppTheme.textLight,
              height: 1.5,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
