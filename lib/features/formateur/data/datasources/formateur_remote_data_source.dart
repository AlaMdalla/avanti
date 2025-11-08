import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/formateur.dart';

abstract class FormateurRemoteDataSource {
  Future<List<Formateur>> fetchFormateurs();
  Future<List<Formateur>> getAllFormateurs();
  Future<void> addFormateur(Formateur formateur);
  Future<void> updateFormateur(Formateur formateur);
  Future<void> deleteFormateur(String id);
}

class FormateurRemoteDataSourceImpl implements FormateurRemoteDataSource {
  final SupabaseClient client;

  FormateurRemoteDataSourceImpl(this.client);

  @override
  Future<List<Formateur>> fetchFormateurs() async {
    try {
      final response = await client.from('formateur').select();
      return (response as List)
          .map((json) => Formateur.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Erreur lors de la récupération des formateurs : $e");
    }
  }

  @override
  Future<List<Formateur>> getAllFormateurs() {
    return fetchFormateurs();
  }

  @override
  Future<void> addFormateur(Formateur formateur) async {
    try {
      await client.from('formateur').insert([formateur.toJson()]);
    } catch (e) {
      throw Exception("Erreur lors de l'ajout du formateur : $e");
    }
  }

  @override
  Future<void> updateFormateur(Formateur formateur) async {
    try {
      await client
          .from('formateur')
          .update(formateur.toJson())
          .eq('id', formateur.id);
    } catch (e) {
      throw Exception("Erreur lors de la mise à jour du formateur : $e");
    }
  }

  @override
  Future<void> deleteFormateur(String id) async {
    try {
      await client.from('formateur').delete().eq('id', id);
    } catch (e) {
      throw Exception("Erreur lors de la suppression du formateur : $e");
    }
  }
}