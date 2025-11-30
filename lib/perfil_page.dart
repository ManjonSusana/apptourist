import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'db_service.dart';

class PerfilPage extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const PerfilPage({super.key, required this.usuario});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _formKey = GlobalKey<FormState>();
  bool _editando = false;
  bool _guardando = false;
  
  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  late TextEditingController _bioController;
  
  String? _fotoPerfil;
  String? _lugaresPreferidos;
  String? _restaurantesPreferidos;
  String? _ambiente;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.usuario["nombre"] ?? "");
    _telefonoController = TextEditingController(text: widget.usuario["telefono"] ?? "");
    _bioController = TextEditingController(text: widget.usuario["bio"] ?? "");
    
    _fotoPerfil = widget.usuario["fotoPerfil"];
    _lugaresPreferidos = widget.usuario["lugaresPreferidos"];
    _restaurantesPreferidos = widget.usuario["restaurantesPreferidos"];
    _ambiente = widget.usuario["ambiente"];
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _fotoPerfil = image.path;
      });
    }
  }

  Future<void> _guardarPerfil() async {
    if (!_formKey.currentState!.validate()) return;
    if (_guardando) return; // Evitar múltiples guardados

    setState(() {
      _guardando = true;
    });

    try {
      final resultado = await DBService.instance.actualizarPerfil(
        usuarioId: widget.usuario["id"],
        fotoPerfil: _fotoPerfil,
        telefono: _telefonoController.text.trim(),
        bio: _bioController.text.trim(),
        lugaresPreferidos: _lugaresPreferidos,
        restaurantesPreferidos: _restaurantesPreferidos,
        ambiente: _ambiente,
      );

      print("✓ Perfil actualizado: $resultado filas");

      // Los datos ya están guardados en la base de datos
      // No necesitamos actualizar el objeto usuario en memoria

      if (mounted) {
        setState(() {
          _editando = false;
          _guardando = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Perfil actualizado exitosamente', style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Error al guardar: $e");
      if (mounted) {
        setState(() {
          _guardando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.usuario["nombre"] ?? "";
    final correo = widget.usuario["correo"] ?? "";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar con gradiente
          SliverAppBar(
            expandedHeight: 80,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFB89968), Color(0xFFA67C52)],
                  ),
                ),
                child: Center(
                  child: Text(
                    'Mi Perfil',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(_editando ? Icons.close : Icons.edit),
                onPressed: () {
                  setState(() {
                    _editando = !_editando;
                  });
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Foto de perfil
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _fotoPerfil != null
                              ? FileImage(File(_fotoPerfil!))
                              : null,
                          child: _fotoPerfil == null
                              ? Text(
                                  nombre.isNotEmpty ? nombre[0].toUpperCase() : "?",
                                  style: GoogleFonts.poppins(
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        if (_editando)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _seleccionarFoto,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade400,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Nombre
                    Text(
                      nombre,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Correo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          correo,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Información personal
                    _buildSeccionCard(
                      titulo: 'Información Personal',
                      icono: Icons.person,
                      children: [
                        _buildCampoTexto(
                          controller: _telefonoController,
                          label: 'Teléfono',
                          icon: Icons.phone,
                          habilitado: _editando,
                        ),
                        const SizedBox(height: 16),
                        _buildCampoTexto(
                          controller: _bioController,
                          label: 'Biografía',
                          icon: Icons.text_snippet,
                          habilitado: _editando,
                          maxLineas: 3,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Preferencias
                    _buildSeccionCard(
                      titulo: 'Preferencias',
                      icono: Icons.favorite,
                      children: [
                        _buildSelectorPreferencia(
                          label: 'Tipos de lugares favoritos',
                          icon: Icons.place,
                          opciones: ['Históricos', 'Naturales', 'Museos', 'Parques', 'Monumentos'],
                          valorActual: _lugaresPreferidos,
                          onChanged: _editando
                              ? (valor) => setState(() => _lugaresPreferidos = valor)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildSelectorPreferencia(
                          label: 'Tipo de comida favorita',
                          icon: Icons.restaurant,
                          opciones: ['Internacional', 'Tradicional', 'Vegetariana', 'Gourmet', 'Casual'],
                          valorActual: _restaurantesPreferidos,
                          onChanged: _editando
                              ? (valor) => setState(() => _restaurantesPreferidos = valor)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildSelectorPreferencia(
                          label: 'Ambiente preferido',
                          icon: Icons.wb_sunny,
                          opciones: ['Tranquilo', 'Animado', 'Romántico', 'Familiar', 'Premium'],
                          valorActual: _ambiente,
                          onChanged: _editando
                              ? (valor) => setState(() => _ambiente = valor)
                              : null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Botones
                    if (_editando)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _guardando ? null : _guardarPerfil,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: _guardando
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Guardando...',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Guardar Cambios',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Botón cerrar sesión
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            "/login",
                            (_) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Cerrar Sesión',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionCard({
    required String titulo,
    required IconData icono,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: Colors.orange.shade600),
              const SizedBox(width: 10),
              Text(
                titulo,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCampoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool habilitado,
    int maxLineas = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: habilitado,
      maxLines: maxLineas,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        prefixIcon: Icon(icon, color: Colors.orange.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange.shade600, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        filled: true,
        fillColor: habilitado ? Colors.white : Colors.grey[50],
      ),
    );
  }

  Widget _buildSelectorPreferencia({
    required String label,
    required IconData icon,
    required List<String> opciones,
    required String? valorActual,
    required void Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: valorActual,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        prefixIcon: Icon(icon, color: Colors.orange.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange.shade600, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        filled: true,
        fillColor: onChanged != null ? Colors.white : Colors.grey[50],
      ),
      items: opciones.map((opcion) {
        return DropdownMenuItem(
          value: opcion,
          child: Text(opcion, style: GoogleFonts.poppins()),
        );
      }).toList(),
      onChanged: onChanged,
      style: GoogleFonts.poppins(color: Colors.black87),
      dropdownColor: Colors.white,
    );
  }
}
