import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/orden_model.dart';
import '../services/orden_service.dart';
import '../core/app_theme.dart'; // 🔹 Importamos el sistema de diseño

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData; // 🔹 Datos reales de la BD
  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<OrdenTrabajo>> _futureOrdenes;

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  void _recargar() {
    setState(() {
      // 🔹 EL MOTOR INTACTO: Llamada real a tu PHP en Hostinger
      _futureOrdenes = OrdenService.getOrdenes(widget.userData['id']);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 ELIMINAMOS EL TAB CONTROLLER PARA UNA VISTA DIRECTA Y LIMPIA
    return Scaffold(
      backgroundColor: AppTheme.background, // Fondo gris corporativo
      appBar: AppBar(
        backgroundColor: AppTheme.secondary, // 🔹 Cabecera Azul Profundo
        elevation: 0,
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hola, ${widget.userData['nombre']}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Técnico de Campo",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _recargar,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 TÍTULO DE SECCIÓN ELEGANTE
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
            child: Text(
              "Tus tareas de hoy",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<OrdenTrabajo>>(
              future: _futureOrdenes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _emptyState();
                }

                // 🔹 PHP ya nos manda solo las pendientes, así que la mostramos directo
                final ordenes = snapshot.data!;
                return _listaOrdenes(ordenes);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Estado visual cuando no hay tareas
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          Text(
            "No tienes tareas asignadas",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "¡Tómate un café o recarga la pantalla!",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // 🔹 Lista de Tareas con Diseño Premium
  Widget _listaOrdenes(List<OrdenTrabajo> lista) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final orden = lista[index];
        bool esAveria = orden.tipoTrabajo.toLowerCase().contains("averia");

        // 🔹 Lógica de colores corporativos
        Color iconColor = esAveria ? Colors.redAccent : AppTheme.secondary;
        IconData iconData = esAveria
            ? Icons.warning_rounded
            : Icons.build_circle;

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20), // Bordes más suaves
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04), // Sombra muy sutil
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.push(
                '/detalle',
                extra: orden,
              ), // 🔹 Navegación intacta
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    // Icono con fondo translúcido (Muy moderno)
                    Container(
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(iconData, color: iconColor, size: 30),
                    ),
                    const SizedBox(width: 15),

                    // Textos descriptivos de la orden
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            orden.tipoTrabajo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 16,
                                color: AppTheme.textLight,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  orden.cliente,
                                  style: const TextStyle(
                                    color: AppTheme.textLight,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: AppTheme.textLight,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  orden.distrito,
                                  style: const TextStyle(
                                    color: AppTheme.textLight,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
