import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CreateProjectPage extends StatefulWidget {
  final User user;

  const CreateProjectPage({Key? key, required this.user}) : super(key: key);

  @override
  _CreateProjectPageState createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  String _projectName = '';
  String _projectDescription = ''; // Añadir esta línea
  DateTime _projectDueDate = DateTime.now().add(Duration(days: 7));
  List<Map<String, dynamic>> _tasks = [];
  Color _selectedColor = Colors.blue.shade200; // Color pastel por defecto
  String _selectedUserName = '';
  String _selectedUserPhotoURL = '';
  String _selectedUserInitials = '';
  String assignedToPhotoURL = ''; // Inicializa con un valor por defecto
  DateTime dueDate = DateTime.now().add(Duration(days: 1)); // Inicializa la fecha de finalización

  bool get _isFormValid {
    return _projectName.isNotEmpty &&
        _projectDueDate.isAfter(DateTime.now()) &&
        _tasks.length >= 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nuevo Proyecto',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: Text(
              'Guardar',
              style: TextStyle(
                color: Colors.blue[600],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con imagen decorativa
              Container(
                height: 160,
                width: double.infinity,
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[400]!, Colors.blue[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 20,
                      bottom: 20,
                      child: Icon(
                        Icons.rocket_launch,
                        size: 80,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Crear Nuevo Proyecto',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Define los detalles de tu proyecto',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido principal
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Información Básica'),
                    SizedBox(height: 16),
                    _buildTextField(
                      'Nombre del Proyecto',
                      Icons.work_outline,
                      onChanged: (value) => _projectName = value,
                    ),
                    SizedBox(height: 24),
                    _buildTextField(
                      'Descripción',
                      Icons.description_outlined,
                      maxLines: 3,
                      onChanged: (value) => _projectDescription = value,
                    ),
                    SizedBox(height: 32),
                    
                    _buildSectionTitle('Personalización'),
                    SizedBox(height: 16),
                    _buildColorPicker(),
                    SizedBox(height: 24),
                    _buildDatePicker(),
                    
                    SizedBox(height: 32),
                    _buildSectionTitle('Tareas del Proyecto'),
                    SizedBox(height: 16),
                    _buildAddTaskButton(),
                    SizedBox(height: 16),
                    _buildTasksList(),
                  ],
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextFormField(
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue[400]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es requerido';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildColorPicker() {
    List<Color> pastelColors = [
      Colors.blue.shade200,
      Colors.green.shade200,
      Colors.orange.shade200,
      Colors.purple.shade200,
      Colors.red.shade200,
      Colors.teal.shade200,
      Colors.indigo.shade200,
      Colors.pink.shade200,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color del proyecto',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
        ),
        SizedBox(height: 8),
        Container(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: pastelColors.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColor == color ? Colors.black : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _projectDueDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 365)),
        );
        if (picked != null && picked != _projectDueDate) {
          setState(() {
            _projectDueDate = picked;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.blue),
            SizedBox(width: 16),
            Text(
              'Fecha de Finalización',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            Spacer(),
            Text(
              DateFormat('dd/MM/yyyy').format(_projectDueDate),
              style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList() {
    return Container(
      height: 300,
      child: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Card(
            margin: EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(task['name'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prioridad: ${task['priority']}'),
                  Row(
                    children: [
                      Text('Asignado a: '),
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 12,
                        child: Text(
                          _getInitials(task['assignedToName']),
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 10,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          task['assignedToName'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Text('Fecha: ${DateFormat('dd/MM/yyyy').format(task['dueDate'])}'),
                  Text('Descripción: ${task['description']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      _addTask(
                        task: Map<String, dynamic>.from(task),
                        taskIndex: index
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _tasks.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _addTask({Map<String, dynamic>? task, int? taskIndex}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController nameController = TextEditingController(text: task?['name'] ?? '');
        String priority = task?['priority'] ?? 'Media';
        String assignedTo = task?['assignedTo'] ?? '';
        String assignedToName = task?['assignedToName'] ?? '';
        String assignedToPhotoURL = task?['assignedToPhotoURL'] ?? '';
        DateTime dueDate = task?['dueDate'] ?? DateTime.now().add(Duration(days: 1));
        final TextEditingController descriptionController = TextEditingController(text: task?['description'] ?? '');

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              task == null ? 'Agregar Nueva Tarea' : 'Editar Tarea', // Cambiar el título según el contexto
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.grey[600]),
                            onPressed: () => Navigator.of(context).pop(),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: InputDecoration(labelText: 'Nombre de la Tarea'),
                              ),
                              SizedBox(height: 24),
                              DropdownButtonFormField<String>(
                                value: priority,
                                items: ['Baja', 'Media', 'Alta'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setDialogState(() {
                                    priority = newValue!;
                                  });
                                },
                              ),
                              SizedBox(height: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                    child: Text('Seleccionar Usuario'),
                                    onPressed: () async {
                                      final selectedUser = await _showUserSelectionDialog(context);
                                      if (selectedUser != null) {
                                        setDialogState(() {
                                          assignedTo = selectedUser['id'];
                                          assignedToName = selectedUser['displayName'] ?? 'Usuario sin nombre';
                                          assignedToPhotoURL = selectedUser['photoURL'] ?? '';
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  if (assignedTo.isNotEmpty)
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.blue,
                                          radius: 16,
                                          child: Text(
                                            _getInitials(assignedToName),
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            assignedToName,
                                            style: TextStyle(color: Colors.grey[700]),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      final DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate: dueDate,
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(Duration(days: 365)),
                                      );
                                      if (picked != null && picked != dueDate) {
                                        setState(() {
                                          dueDate = picked;
                                        });
                                      }
                                    },
                                    child: Text('Seleccionar Fecha de Término de la Tarea'),
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16), // Espacio entre el botón y el texto
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(dueDate), // Muestra la fecha seleccionada
                                    style: TextStyle(color: Colors.grey[700], fontSize: 16),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24),
                              Text(
                                'Descripción',
                                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              TextField(
                                controller: descriptionController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey[300]!.withOpacity(0.5)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey[400]!.withOpacity(0.7)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey[300]!.withOpacity(0.5)),
                                  ),
                                ),
                                style: TextStyle(color: Colors.grey[700]),
                                maxLines: 3,
                                onChanged: (value) {
                                  descriptionController.text = value; // Capturar la descripción
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (nameController.text.isNotEmpty && assignedTo.isNotEmpty) {
                                final updatedTask = {
                                  'name': nameController.text,
                                  'priority': priority,
                                  'assignedTo': assignedTo,
                                  'assignedToName': assignedToName,
                                  'assignedToPhotoURL': assignedToPhotoURL,
                                  'dueDate': dueDate,
                                  'description': descriptionController.text,
                                  'createdAt': task != null ? task['createdAt'] : Timestamp.now(),
                                };

                                setState(() {
                                  if (taskIndex != null) {
                                    print("Actualizando tarea en índice: $taskIndex");
                                    print("Tarea anterior: ${_tasks[taskIndex]}");
                                    print("Tarea nueva: $updatedTask");
                                    _tasks[taskIndex] = updatedTask;
                                  } else {
                                    _tasks.add(updatedTask);
                                  }
                                });

                                Navigator.of(context).pop();
                              }
                            },
                            child: Text(taskIndex != null ? 'Actualizar' : 'Guardar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _showUserSelectionDialog(BuildContext context) async {
    final users = await _getUsers();
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Seleccionar Usuario',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  height: 300,
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: users.length,
                    itemBuilder: (BuildContext context, int index) {
                      final user = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            _getInitials(user['displayName'] ?? 'Usuario sin nombre'),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        title: Text(user['displayName'] ?? 'Usuario sin nombre'),
                        subtitle: Text(user['email'] ?? ''),
                        onTap: () => Navigator.of(context).pop(user),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getUsers() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('users').get();
    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _isFormValid) {
      _formKey.currentState!.save();

      // Mostrar el diálogo de carga
      showDialog(
        context: context,
        barrierDismissible: false, // No permitir cerrar el diálogo al tocar fuera
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(), // Indicador de carga
          );
        },
      );

      // Convertir el color a un string hexadecimal
      String colorString = '#${_selectedColor.value.toRadixString(16).substring(2)}';

      // Obtener todos los usuarios asignados a las tareas
      Set<String> assignedUsers = {widget.user.uid}; // Incluir al creador del proyecto
      for (var task in _tasks) {
        assignedUsers.add(task['assignedTo']);
      }

      // Crear el proyecto en Firestore con todos los usuarios como miembros
      final projectRef = await FirebaseFirestore.instance.collection('projects').add({
        'title': _projectName,
        'status': 'planning',
        'description': _projectDescription,
        'dueDate': Timestamp.fromDate(_projectDueDate),
        'createdAt': Timestamp.now(),
        'progress': 0,
        'ownerId': widget.user.uid,
        'members': assignedUsers.toList(), // Convertir el Set a List
        'color': colorString,
      });

      // Crear las tareas asociadas al proyecto
      List<String> taskIds = [];

      for (var task in _tasks) {
        final taskRef = await FirebaseFirestore.instance.collection('tasks').add({
          'title': task['name'],
          'status': 'pending',
          'description': task['description'],
          'dueDate': Timestamp.fromDate(task['dueDate']),
          'assignedTo': task['assignedTo'],
          'projectId': projectRef.id,
          'priority': task['priority'],
          'createdAt': task['createdAt'],
        });
        taskIds.add(taskRef.id);

        // Actualizar userTasks para el usuario asignado
        await FirebaseFirestore.instance.collection('userTasks').doc(task['assignedTo']).set({
          'tasks': FieldValue.arrayUnion([taskRef.id]),
        }, SetOptions(merge: true));
      }

      // Actualizar userProjects para todos los usuarios involucrados
      for (String userId in assignedUsers) {
        await FirebaseFirestore.instance.collection('userProjects').doc(userId).set({
          'projects': FieldValue.arrayUnion([projectRef.id]),
        }, SetOptions(merge: true));
      }

      // Actualizar taskSummaries para todos los usuarios involucrados
      final batch = FirebaseFirestore.instance.batch();
      
      for (String userId in assignedUsers) {
        final taskSummaryRef = FirebaseFirestore.instance.collection('taskSummaries').doc(userId);
        batch.set(taskSummaryRef, {
          'totalTasks': FieldValue.increment(_tasks.where((task) => task['assignedTo'] == userId).length),
          'pendingTasks': FieldValue.increment(_tasks.where((task) => task['assignedTo'] == userId).length),
          'myTasks': FieldValue.increment(_tasks.where((task) => task['assignedTo'] == userId).length),
          'assignedTasks': FieldValue.increment(_tasks.where((task) => task['assignedTo'] == userId).length),
          'inProgressTasks': FieldValue.increment(0),
          'completedTasks': FieldValue.increment(0),
          'overdueTasks': FieldValue.increment(0),
        }, SetOptions(merge: true));
      }

      await batch.commit();

      // Cerrar el diálogo de carga
      Navigator.of(context).pop(); // Cerrar el diálogo de carga

      // Volver a la página anterior
      Navigator.of(context).pop();
    }
  }

  Widget _buildAddTaskButton() {
    return ElevatedButton(
      onPressed: _addTask,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, color: Colors.white),
          SizedBox(width: 8),
          Text('Agregar Tarea', style: TextStyle(color: Colors.white)),
        ],
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    }
    return '';
  }
}
