import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/orden_model.dart';
import '../core/app_theme.dart';
import '../widgets/custom_button.dart';

class DetalleScreen extends StatelessWidget {
  final OrdenTrabajo orden;
  const DetalleScreen({super.key, required this.orden});

  // 🔹 FUNCIONES DE ENLACE (URL LAUNCHER)
  Future<void> _llamar(String telefono) async {
    final Uri url = Uri.parse('tel:$telefono');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _abrirWhatsApp(String telefono) async {
    String numero = telefono.startsWith('51') ? telefono : '51$telefono';
    final Uri url = Uri.parse('https://wa.me/$numero');
    if (await canLaunchUrl(url))
      await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _abrirGoogleMaps(String coordenadas) async {
    final Uri url = Uri.parse(
      'http://googleusercontent.com/maps.google.com/?q=$coordenadas',
    );
    if (await canLaunchUrl(url))
      await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _abrirWaze(String coordenadas) async {
    final Uri url = Uri.parse(
      'https://waze.com/ul?ll=$coordenadas&navigate=yes',
    );
    if (await canLaunchUrl(url))
      await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    bool esAveria = orden.tipoTrabajo.toLowerCase().contains("averia");
    Color colorPrincipal = esAveria ? Colors.redAccent : AppTheme.secondary;
    IconData iconoPrincipal = esAveria
        ? Icons.warning_rounded
        : Icons.build_circle;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        elevation: 0,
        title: Text(
          "Orden #${orden.idOrden}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 🔹 CABECERA DE LA ORDEN
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 30,
              top: 10,
            ),
            decoration: BoxDecoration(
              color: colorPrincipal,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Icon(iconoPrincipal, size: 60, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  orden.tipoTrabajo.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    orden.estado,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔹 CONTENIDO DESLIZABLE
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Acciones Rápidas",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BotonAccion(
                        icono: Icons.call,
                        texto: "Llamar",
                        color: Colors.blue,
                        onTap: () => _llamar(orden.telefono ?? ""),
                      ),
                      _BotonAccion(
                        icono: Icons.message_rounded,
                        texto: "WhatsApp",
                        color: Colors.green,
                        onTap: () => _abrirWhatsApp(orden.telefono ?? ""),
                      ),
                      _BotonAccion(
                        icono: Icons.map_rounded,
                        texto: "Maps",
                        color: Colors.red,
                        onTap: () => _abrirGoogleMaps(orden.coordenadas ?? ""),
                      ),
                      _BotonAccion(
                        icono: Icons.navigation_rounded,
                        texto: "Waze",
                        color: Colors.lightBlue,
                        onTap: () => _abrirWaze(orden.coordenadas ?? ""),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Información del Cliente",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _ItemDato(
                          icono: Icons.person_outline,
                          titulo: "Cliente",
                          valor: orden.cliente,
                        ),
                        const Divider(height: 25, color: Colors.black12),
                        _ItemDato(
                          icono: Icons.location_on_outlined,
                          titulo: "Dirección",
                          valor:
                              "${orden.direccion ?? 'Sin calle'}, ${orden.distrito}",
                        ),
                        const Divider(height: 25, color: Colors.black12),
                        _ItemDato(
                          icono: Icons.turn_right_rounded,
                          titulo: "Referencia",
                          valor: orden.referencia ?? "Sin referencia",
                        ),
                        const Divider(height: 25, color: Colors.black12),
                        _ItemDato(
                          icono: Icons.calendar_month_outlined,
                          titulo: "Fecha Programada",
                          valor: orden.fecha ?? "No asignada",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  if (orden.estado != 'Finalizado')
                    CustomButton(
                      text: "INICIAR REPORTE TÉCNICO",
                      color: AppTheme.primary,
                      onPressed: () {
                        context.push('/formulario', extra: orden);
                      },
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonAccion extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color color;
  final VoidCallback onTap;

  const _BotonAccion({
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
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icono, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemDato extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _ItemDato({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 20, color: AppTheme.textLight),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
