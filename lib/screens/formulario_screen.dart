import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signature/signature.dart';
import '../models/orden_model.dart';
import '../services/reporte_service.dart';
import '../core/app_theme.dart';
import '../widgets/custom_button.dart';

class FormularioScreen extends StatefulWidget {
  final OrdenTrabajo orden;
  const FormularioScreen({super.key, required this.orden});
  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();

  int _pasoActual = 1;
  bool get esInstalacion =>
      widget.orden.tipoTrabajo.toLowerCase() == 'instalacion';

  final _serieCtrl = TextEditingController();
  final _napCtrl = TextEditingController();
  final _potenciaCtrl = TextEditingController();
  final _metrosCtrl = TextEditingController();
  final _conectoresCtrl = TextEditingController();
  final _solucionCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  int _puertoSeleccionado = 1;

  XFile? _fotoFachada;
  XFile? _fotoEquipo;

  final SignatureController _firmaController = SignatureController(
    penStrokeWidth: 3,
    penColor: AppTheme.textDark,
    exportBackgroundColor: Colors.white,
  );

  String? _gpsLat;
  String? _gpsLon;
  bool _enviando = false;
  bool _gpsCargando = false;

  // 🔹 LÓGICA INTACTA (Fotos, GPS, Base64, Envío)
  Future<void> _tomarFoto(bool esFachada) async {
    if (!kIsWeb) {
      var status = await Permission.camera.request();
      if (status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Permiso de cámara denegado")),
          );
        }
        return;
      }
    }
    final picker = ImagePicker();
    final XFile? foto = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (foto != null) {
      setState(() {
        if (esFachada) {
          _fotoFachada = foto;
        } else {
          _fotoEquipo = foto;
        }
      });
    }
  }

  Future<void> _obtenerGPS() async {
    setState(() => _gpsCargando = true);
    if (!kIsWeb) {
      bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
      if (!servicioHabilitado) {
        setState(() => _gpsCargando = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Prende el GPS del celular")),
          );
        }
        return;
      }
    }
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _gpsLat = position.latitude.toString();
        _gpsLon = position.longitude.toString();
        _gpsCargando = false;
      });
    } catch (e) {
      setState(() => _gpsCargando = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error GPS: $e")));
      }
    }
  }

  Future<String?> _xfileToBase64(XFile? file) async {
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  void _finalizarOrden() async {
    if (_gpsLat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Captura la ubicación GPS primero"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_fotoFachada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Falta la foto de fachada"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _enviando = true);

    String? base64Fachada = await _xfileToBase64(_fotoFachada);
    String? base64Equipo = await _xfileToBase64(_fotoEquipo);
    String? base64Firma;
    if (_firmaController.isNotEmpty) {
      final firmabytes = await _firmaController.toPngBytes();
      if (firmabytes != null) base64Firma = base64Encode(firmabytes);
    }

    final datos = {
      "id_orden": widget.orden.idOrden,
      "potencia": double.tryParse(_potenciaCtrl.text) ?? 0.0,
      "metros": int.tryParse(_metrosCtrl.text) ?? 0,
      "conectores": int.tryParse(_conectoresCtrl.text) ?? 0,
      "observaciones": _obsCtrl.text,
      "lat": _gpsLat,
      "lon": _gpsLon,
      "foto_base64": base64Fachada ?? "",
      "foto_equipo_base64": base64Equipo ?? "",
      "firma_base64": base64Firma ?? "",
    };

    if (esInstalacion) {
      datos["serie"] = _serieCtrl.text;
      datos["nap"] = _napCtrl.text;
      datos["puerto"] = _puertoSeleccionado;
    } else {
      datos["solucion"] = _solucionCtrl.text;
    }

    final resp = await ReporteService.enviarReporte(datos);

    if (mounted) {
      setState(() => _enviando = false);
      if (resp['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Trabajo Completado Exitosamente!"),
            backgroundColor: Colors.green,
          ),
        );

        // 🔹 SOLUCIÓN AL ERROR ROJO:
        // En lugar de context.go() que enviaba un "1" y rompía el tipo de dato,
        // usamos pop() dos veces: Una para cerrar el formulario y otra para cerrar el detalle,
        // devolviendo al técnico limpiamente a la pantalla principal (Home).
        if (context.canPop()) context.pop(); // Cierra el Formulario
        if (context.canPop()) context.pop(); // Cierra la pantalla de Detalle
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resp['mensaje'] ?? "Error desconocido"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.secondary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _pasoActual == 1 ? "Datos Técnicos" : "Evidencias y Firma",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Paso $_pasoActual de 2",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () {
            if (_pasoActual == 2) {
              setState(() => _pasoActual = 1);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: _pasoActual == 1
            ? _pantallaDatosTecnicos()
            : _pantallaEvidencias(),
      ),
    );
  }

  // ==========================================================
  // PANTALLA 1: DATOS TÉCNICOS
  // ==========================================================
  Widget _pantallaDatosTecnicos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Complete los datos requeridos",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 20),

          if (esInstalacion) ...[
            _inputPremium(
              label: "Serie ONU *",
              hint: "Ej. 201210212101",
              controller: _serieCtrl,
              icon: Icons.router_rounded,
              requerido: true,
            ),
            _inputPremium(
              label: "Código Caja NAP *",
              hint: "Ej. NAP-04",
              controller: _napCtrl,
              icon: Icons.hub_rounded,
              requerido: true,
            ),

            const Padding(
              padding: EdgeInsets.only(bottom: 8, top: 10),
              child: Text(
                "Puerto NAP Asignado",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            _selectorPuertosPremium(),
            const SizedBox(height: 20),
          ] else ...[
            _inputPremium(
              label: "Solución Aplicada *",
              hint: "Describe qué reparaste...",
              controller: _solucionCtrl,
              icon: Icons.build_rounded,
              requerido: true,
              lineas: 2,
            ),
          ],

          _inputPremium(
            label: "Potencia Óptica (-dBm) *",
            hint: "Ej. 19.5",
            controller: _potenciaCtrl,
            icon: Icons.speed_rounded,
            num: true,
            requerido: true,
          ),

          Row(
            children: [
              Expanded(
                child: _inputPremium(
                  label: "Metros Cable",
                  hint: "Ej. 120",
                  controller: _metrosCtrl,
                  icon: Icons.cable_rounded,
                  num: true,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _inputPremium(
                  label: "Conectores",
                  hint: "Ej. 2",
                  controller: _conectoresCtrl,
                  icon: Icons.settings_input_component_rounded,
                  num: true,
                ),
              ),
            ],
          ),

          _inputPremium(
            label: "Observaciones",
            hint: "Anotaciones extra...",
            controller: _obsCtrl,
            icon: Icons.note_alt_rounded,
            lineas: 2,
          ),

          const SizedBox(height: 20),

          CustomButton(
            text: "CONTINUAR",
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() => _pasoActual = 2);
              }
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ==========================================================
  // PANTALLA 2: EVIDENCIAS Y FIRMA
  // ==========================================================
  Widget _pantallaEvidencias() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ubicación GPS",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 10),

          // 🔹 CAJA GPS PREMIUM
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _gpsLat == null
                  ? Colors.red.shade50
                  : Colors.green.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _gpsLat == null
                    ? Colors.red.shade200
                    : Colors.green.shade200,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.gps_fixed_rounded,
                    color: _gpsLat == null ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    _gpsLat == null
                        ? "Ubicación obligatoria"
                        : "GPS: $_gpsLat, $_gpsLon",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                      fontSize: _gpsLat == null ? 14 : 12,
                    ),
                  ),
                ),
                _gpsCargando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primary,
                        ),
                      )
                    : TextButton(
                        onPressed: _obtenerGPS,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          _gpsLat == null ? "CAPTURAR" : "REINTENTAR",
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
              ],
            ),
          ),

          const SizedBox(height: 25),
          const Text(
            "Evidencias Fotográficas",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _cajaFotoPremium(
                  "Fachada",
                  _fotoFachada,
                  () => _tomarFoto(true),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _cajaFotoPremium(
                  "Equipo",
                  _fotoEquipo,
                  () => _tomarFoto(false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Firma del Cliente",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              TextButton.icon(
                onPressed: () => _firmaController.clear(),
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 16,
                  color: Colors.red,
                ),
                label: const Text(
                  "Limpiar",
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            ],
          ),

          // 🔹 PIZARRA DE FIRMA
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300, width: 2),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Signature(
                controller: _firmaController,
                height: 160,
                backgroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 35),

          // 🔹 BOTÓN FINALIZAR
          CustomButton(
            text: "FINALIZAR TRABAJO",
            isLoading: _enviando,
            onPressed: _finalizarOrden,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ==========================================================
  // WIDGETS AUXILIARES (Diseño Premium)
  // ==========================================================
  Widget _inputPremium({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool num = false,
    int lineas = 1,
    bool requerido = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: num
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            maxLines: lineas,
            style: const TextStyle(fontSize: 15, color: AppTheme.textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: lineas == 1
                  ? Icon(icon, color: AppTheme.primary, size: 22)
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
            validator: requerido
                ? (v) => v == null || v.trim().isEmpty ? "Requerido" : null
                : null,
          ),
        ],
      ),
    );
  }

  Widget _selectorPuertosPremium() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(8, (index) {
        // Hasta 8 puertos
        int puerto = index + 1;
        bool seleccionado = _puertoSeleccionado == puerto;
        return GestureDetector(
          onTap: () => setState(() => _puertoSeleccionado = puerto),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: seleccionado ? AppTheme.primary : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: seleccionado ? AppTheme.primary : Colors.grey.shade300,
                width: seleccionado ? 2 : 1,
              ),
              boxShadow: seleccionado
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            alignment: Alignment.center,
            child: Text(
              puerto.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: seleccionado ? Colors.white : AppTheme.textDark,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _cajaFotoPremium(String titulo, XFile? archivo, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: AppTheme.primary.withOpacity(0.5),
            width: 1.5,
            style: BorderStyle.solid,
          ), // Borde Naranja sutil
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5),
          ],
        ),
        child: archivo == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppTheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const Text(
                    "Tocar para tomar",
                    style: TextStyle(color: AppTheme.textLight, fontSize: 11),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: kIsWeb
                    ? Image.network(
                        archivo.path,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Image.file(
                        File(archivo.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
              ),
      ),
    );
  }
}
