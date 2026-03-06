import 'package:flutter/material.dart';
import '../models/orden_model.dart';
import '../services/historial_service.dart';
import '../core/app_theme.dart';

class HistorialScreen extends StatefulWidget {
  final int idTecnico;
  const HistorialScreen({super.key, required this.idTecnico});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  late Future<List<OrdenTrabajo>> _futureHistorial;

  String _searchQuery = "";
  String _mesFiltro = "Todos"; // 🔹 Ahora filtramos por el nombre del mes

  final List<String> _nombresMeses = [
    "Enero",
    "Febrero",
    "Marzo",
    "Abril",
    "Mayo",
    "Junio",
    "Julio",
    "Agosto",
    "Septiembre",
    "Octubre",
    "Noviembre",
    "Diciembre",
  ];

  @override
  void initState() {
    super.initState();
    _futureHistorial = HistorialService.getHistorial(widget.idTecnico);
  }

  // 🔹 MAGIA: Extrae solo los meses que existen en tu BD de Hostinger
  List<String> _obtenerMesesDisponibles(List<OrdenTrabajo> ordenes) {
    Set<int> mesesUnicos = {};
    for (var orden in ordenes) {
      if (orden.fecha != null && orden.fecha!.isNotEmpty) {
        try {
          DateTime date = DateTime.parse(orden.fecha!);
          mesesUnicos.add(date.month);
        } catch (e) {
          if (orden.fecha!.contains('/')) {
            List<String> partes = orden.fecha!.split('/');
            if (partes.length >= 2) {
              mesesUnicos.add(int.parse(partes[1]));
            }
          }
        }
      }
    }

    // Ordenamos los meses (ej. 2, 3) y los convertimos a texto ("Febrero", "Marzo")
    List<int> mesesOrdenados = mesesUnicos.toList()..sort();
    List<String> tabs = ["Todos"];
    tabs.addAll(mesesOrdenados.map((m) => _nombresMeses[m - 1]));

    return tabs;
  }

  // 🔹 Valida si la orden pertenece al mes seleccionado
  bool _coincideElMes(String? fecha) {
    if (_mesFiltro == "Todos") return true;
    if (fecha == null || fecha.isEmpty) return false;

    int mesDeLaOrden = 0;
    try {
      mesDeLaOrden = DateTime.parse(fecha).month;
    } catch (e) {
      if (fecha.contains('/')) {
        List<String> partes = fecha.split('/');
        if (partes.length >= 2) mesDeLaOrden = int.parse(partes[1]);
      }
    }

    if (mesDeLaOrden == 0) return true;
    return _nombresMeses[mesDeLaOrden - 1] == _mesFiltro;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.secondary,
        elevation: 0,
        title: const Text(
          "Historial de Trabajos",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<OrdenTrabajo>>(
        future: _futureHistorial,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _emptyState("No tienes trabajos en tu historial.");
          }

          final ordenes = snapshot.data!;
          final mesesDinamicos = _obtenerMesesDisponibles(
            ordenes,
          ); // 🔹 Generamos los botones

          // Aplicamos filtros de Texto y de Mes
          final filtradas = ordenes.where((orden) {
            final textoBusqueda = _searchQuery.toLowerCase();
            final coincideTexto =
                _searchQuery.isEmpty ||
                orden.cliente.toLowerCase().contains(textoBusqueda) ||
                orden.distrito.toLowerCase().contains(textoBusqueda) ||
                orden.tipoTrabajo.toLowerCase().contains(textoBusqueda);

            final coincideMes = _coincideElMes(orden.fecha);

            return coincideTexto && coincideMes;
          }).toList();

          return Column(
            children: [
              // 🔹 ZONA DE FILTROS
              Container(
                color: AppTheme.secondary,
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Column(
                  children: [
                    // Buscador
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextField(
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        style: const TextStyle(color: AppTheme.textDark),
                        decoration: InputDecoration(
                          hintText: "Buscar cliente, distrito o tarea...",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppTheme.primary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Carrusel de Meses Dinámico
                    SizedBox(
                      height: 35,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: mesesDinamicos.length,
                        itemBuilder: (context, index) {
                          String nombreMes = mesesDinamicos[index];
                          bool isSelected = _mesFiltro == nombreMes;

                          return GestureDetector(
                            onTap: () => setState(() => _mesFiltro = nombreMes),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primary
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : Colors.white.withOpacity(0.2),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                nombreMes,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 LISTA DE RESULTADOS
              Expanded(
                child: filtradas.isEmpty
                    ? _emptyState("No hay resultados para tu búsqueda.")
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: filtradas.length,
                        itemBuilder: (context, index) {
                          final orden = filtradas[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                // TODO: Navegar a la vista de formulario completado
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.verified_rounded,
                                        color: Colors.green,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 15),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            orden.tipoTrabajo,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            orden.cliente,
                                            style: const TextStyle(
                                              color: AppTheme.textLight,
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.calendar_today_rounded,
                                                  size: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  orden.fecha ?? "Sin fecha",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade700,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _emptyState(String mensaje) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          Text(
            mensaje,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
