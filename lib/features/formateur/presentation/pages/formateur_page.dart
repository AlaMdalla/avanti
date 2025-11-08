import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/formateur_bloc.dart';
import '../bloc/formateur_state.dart';
import '../bloc/formateur_event.dart';

class FormateurPage extends StatelessWidget {
  const FormateurPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Charger les formateurs au démarrage
    return BlocListener<FormateurBloc, FormateurState>(
      listener: (context, state) {
        // Logique supplémentaire si nécessaire
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Liste des Formateurs'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // ✅ Recharger les formateurs
                context.read<FormateurBloc>().add(LoadFormateurs());
              },
            ),
          ],
        ),
        body: BlocBuilder<FormateurBloc, FormateurState>(
          builder: (context, state) {
            // ✅ Charger les données au premier build
            if (state is FormateurInitial) {
              context.read<FormateurBloc>().add(LoadFormateurs());
            }

            if (state is FormateurLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FormateurLoaded) {
              if (state.formateurs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucun formateur trouvé',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<FormateurBloc>().add(LoadFormateurs());
                },
                child: ListView.builder(
                  itemCount: state.formateurs.length,
                  itemBuilder: (context, index) {
                    final f = state.formateurs[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(
                          f.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Spécialité: ${f.speciality}'),
                            Text('Email: ${f.email}'),
                            if (f.address != null && f.address!.isNotEmpty)
                              Text('Adresse: ${f.address}'),
                          ],
                        ),
                        trailing: Text(
                          f.createdAt != null 
                              ? f.createdAt!.toString().substring(0, 10)
                              : 'N/A',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (state is FormateurError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur : ${state.message}',
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<FormateurBloc>().add(LoadFormateurs());
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/add-formateur');
          },
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }
}