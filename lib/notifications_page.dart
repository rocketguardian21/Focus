import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsPage extends StatefulWidget {
  final User user;

  const NotificationsPage({Key? key, required this.user}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _activityLog = [];
  DateTime? _lastChecked;

  @override
  void initState() {
    super.initState();
    _loadRecentChanges();
  }

  Future<void> _loadRecentChanges() async {
    setState(() => _activityLog.clear());
    
    try {
      // Cargar proyectos modificados
      final projectsQuery = await FirebaseFirestore.instance
          .collection('projects')
          .where('members', arrayContains: widget.user.uid)
          .get();

      for (var project in projectsQuery.docs) {
        var projectData = project.data();
        
        // Obtener información del dueño
        var ownerDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(projectData['ownerId'])
            .get();
        var ownerData = ownerDoc.data() ?? {};

        // Cargar tareas del proyecto
        final tasksQuery = await FirebaseFirestore.instance
            .collection('tasks')
            .where('projectId', isEqualTo: project.id)
            .get();

        List<Map<String, dynamic>> activities = [];

        // Agregar proyecto como actividad
        activities.add({
          'type': 'project',
          'title': projectData['title'],
          'owner': ownerData['displayName'] ?? 'Usuario desconocido',
          'date': projectData['dueDate'],
          'description': projectData['description'],
          'status': projectData['status'],
          'projectId': project.id,
          'timestamp': projectData['dueDate'],
        });

        // Agregar tareas y sus actividades
        for (var task in tasksQuery.docs) {
          var taskData = task.data();
          
          var assigneeDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(taskData['assignedTo'])
              .get();
          var assigneeData = assigneeDoc.data() ?? {};

          // Agregar la tarea como actividad
          activities.add({
            'type': 'task',
            'projectTitle': projectData['title'],
            'taskTitle': taskData['title'],
            'assignee': assigneeData['displayName'] ?? 'Usuario desconocido',
            'date': taskData['createdAt'],
            'status': taskData['status'],
            'statusHistory': taskData['statusHistory'] ?? [],
            'comments': taskData['comments'] ?? [],
            'description': taskData['description'],
            'timestamp': taskData['createdAt'],
          });
        }

        _activityLog.addAll(activities);
      }

      // Ordenar todas las actividades por fecha
      _activityLog.sort((a, b) {
        Timestamp timestampA = a['timestamp'] as Timestamp;
        Timestamp timestampB = b['timestamp'] as Timestamp;
        return timestampB.compareTo(timestampA);
      });

      setState(() {
        _lastChecked = DateTime.now();
      });
    } catch (e) {
      print('Error al cargar actividades: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las actividades')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header con gradiente
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4A00E0),
                  Color(0xFF8E2DE2),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 32,
              left: 24,
              right: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Actividad Reciente',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh_rounded, color: Colors.white),
                      onPressed: _loadRecentChanges,
                    ),
                  ],
                ),
                if (_lastChecked != null) ...[
                  SizedBox(height: 8),
                  Text(
                    'Última actualización: ${_formatDateTime(_lastChecked!)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Lista de actividades
          Expanded(
            child: _activityLog.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No hay actividades para mostrar',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadRecentChanges,
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _activityLog.length,
                      itemBuilder: (context, index) {
                        return _buildActivityCard(_activityLog[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final bool isProject = activity['type'] == 'project';
    final Color cardColor = isProject ? Colors.blue : Colors.green;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cardColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: cardColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isProject ? Icons.folder_rounded : Icons.task_alt_rounded,
            color: cardColor,
            size: 24,
          ),
        ),
        title: Text(
          isProject ? activity['title'] : activity['taskTitle'],
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Text(
          isProject
              ? 'Creado por: ${activity['owner']}'
              : 'Asignado a: ${activity['assignee']} en ${activity['projectTitle']}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Estado', activity['status']),
                SizedBox(height: 8),
                _buildInfoRow('Descripción', activity['description']),
                
                // Mostrar historial de estados si existe
                if (!isProject && (activity['statusHistory'] as List).isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text(
                    'Historial de Estados',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  ...(activity['statusHistory'] as List).map((statusChange) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.history, size: 16, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            '${statusChange['status']} - ',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          Text(
                            _formatDate(statusChange['timestamp']),
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],

                // Mostrar comentarios si existen
                if (!isProject && (activity['comments'] as List).isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text(
                    'Comentarios',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  ...(activity['comments'] as List).map((comment) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                comment['userName'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                _formatDate(comment['timestamp']),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            comment['text'],
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
                
                SizedBox(height: 8),
                _buildInfoRow('Fecha', _formatDate(activity['date'])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

