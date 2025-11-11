# Guide d'utilisation des Validateurs

Ce guide explique comment utiliser le système centralisé de validation des formulaires dans l'application Avanti.

## 📁 Emplacement

Les validateurs sont centralisés dans : `lib/core/utils/validators.dart`

## 🎯 Utilisation de base

### 1. Importer les validateurs

```dart
import 'package:avanti_mobile/core/utils/validators.dart';
```

### 2. Validation simple

```dart
TextFormField(
  controller: _titleController,
  decoration: const InputDecoration(labelText: 'Title'),
  validator: Validators.required,
)
```

### 3. Validations multiples combinées

```dart
TextFormField(
  controller: _nameController,
  decoration: const InputDecoration(labelText: 'Name'),
  validator: (v) => Validators.combine(v, [
    Validators.required,
    (val) => Validators.minLength(val, 3, fieldName: 'Name'),
    (val) => Validators.maxLength(val, 50, fieldName: 'Name'),
  ]),
)
```

## 📋 Validateurs disponibles

### Champs obligatoires

```dart
// Champ requis
Validators.required(value, fieldName: 'Title')

// Email requis
Validators.email(value)

// Téléphone requis
Validators.phone(value, required: true)

// Téléphone optionnel
Validators.phone(value, required: false)
```

### Longueur de texte

```dart
// Longueur minimale
Validators.minLength(value, 3, fieldName: 'Username')

// Longueur maximale
Validators.maxLength(value, 100, fieldName: 'Description')

// Combiné
validator: (v) => Validators.combine(v, [
  Validators.required,
  (val) => Validators.minLength(val, 3, fieldName: 'Name'),
  (val) => Validators.maxLength(val, 50, fieldName: 'Name'),
])
```

### Nombres

```dart
// Entier
Validators.integer(value, required: true, fieldName: 'Age')

// Décimal
Validators.decimal(value, required: true, fieldName: 'Price')

// Entier positif (> 0)
Validators.positiveInteger(value, fieldName: 'Quantity')

// Entier non négatif (>= 0)
Validators.nonNegativeInteger(value, fieldName: 'Count')

// Plage d'entiers
Validators.numberRange(value, min: 1, max: 100, fieldName: 'Age')

// Plage de décimaux
Validators.decimalRange(value, min: 0.01, max: 999.99, fieldName: 'Price')
```

### Formats spéciaux

```dart
// Email
Validators.email(value)

// URL
Validators.url(value, required: false)

// Téléphone
Validators.phone(value, required: false)

// Mot de passe (min 6 caractères)
Validators.password(value)

// Confirmation de mot de passe
Validators.confirmPassword(confirmValue, passwordValue)
```

### Caractères

```dart
// Lettres uniquement
Validators.alphabetic(value, fieldName: 'First Name')

// Lettres et chiffres uniquement
Validators.alphanumeric(value, fieldName: 'Username')
```

### Dates

```dart
// Date future
Validators.futureDate(dateValue, required: true)

// Date passée
Validators.pastDate(dateValue, required: true)
```

## 💡 Exemples pratiques

### Formulaire de profil

```dart
TextFormField(
  controller: _firstNameController,
  decoration: const InputDecoration(labelText: 'First Name'),
  validator: (v) => Validators.combine(v, [
    Validators.required,
    (val) => Validators.alphabetic(val, fieldName: 'First Name'),
    (val) => Validators.maxLength(val, 50, fieldName: 'First Name'),
  ]),
)

TextFormField(
  controller: _emailController,
  decoration: const InputDecoration(labelText: 'Email'),
  validator: Validators.email,
)

TextFormField(
  controller: _phoneController,
  decoration: const InputDecoration(labelText: 'Phone'),
  validator: (v) => Validators.phone(v, required: false),
)
```

### Formulaire de cours

```dart
TextFormField(
  controller: _titleController,
  decoration: const InputDecoration(labelText: 'Course Title'),
  validator: (v) => Validators.combine(v, [
    Validators.required,
    (val) => Validators.minLength(val, 3, fieldName: 'Title'),
    (val) => Validators.maxLength(val, 100, fieldName: 'Title'),
  ]),
)

TextFormField(
  controller: _descriptionController,
  decoration: const InputDecoration(labelText: 'Description'),
  maxLines: 3,
  validator: (v) => Validators.maxLength(v, 500, fieldName: 'Description'),
)
```

### Formulaire de quiz

```dart
TextFormField(
  controller: _timeLimitController,
  decoration: const InputDecoration(labelText: 'Time Limit (seconds)'),
  keyboardType: TextInputType.number,
  validator: (v) => Validators.nonNegativeInteger(v, fieldName: 'Time limit'),
)
```

### Formulaire d'événement

```dart
TextFormField(
  controller: _maxAttendeesController,
  decoration: const InputDecoration(labelText: 'Max Attendees'),
  keyboardType: TextInputType.number,
  validator: (v) => Validators.positiveInteger(v, required: false, fieldName: 'Max Attendees'),
)

TextFormField(
  controller: _eventLinkController,
  decoration: const InputDecoration(labelText: 'Event Link'),
  validator: (v) => Validators.url(v, required: false),
)
```

### Formulaire d'abonnement

```dart
TextFormField(
  controller: _priceController,
  decoration: const InputDecoration(labelText: 'Price'),
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  validator: (v) => Validators.combine(v, [
    Validators.required,
    (val) => Validators.decimalRange(val, min: 0.01, max: 999999.99, fieldName: 'Price'),
  ]),
)
```

## ✅ Bonnes pratiques

1. **Toujours utiliser `Validators.combine()`** pour plusieurs validations
2. **Spécifier `fieldName`** pour des messages d'erreur clairs
3. **Utiliser `required: false`** pour les champs optionnels
4. **Valider côté client ET serveur** pour une sécurité maximale
5. **Tester tous les cas limites** (vide, trop long, caractères spéciaux, etc.)

## 🔄 Migration des validateurs existants

### Avant (validateur personnalisé)
```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Title is required';
  }
  return null;
}
```

### Après (validateur centralisé)
```dart
validator: Validators.required
```

### Avant (validation complexe)
```dart
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Name is required';
  }
  if (value.trim().length < 3) {
    return 'Name must be at least 3 characters';
  }
  if (value.trim().length > 50) {
    return 'Name must not exceed 50 characters';
  }
  return null;
}
```

### Après (validateur centralisé)
```dart
validator: (v) => Validators.combine(v, [
  Validators.required,
  (val) => Validators.minLength(val, 3, fieldName: 'Name'),
  (val) => Validators.maxLength(val, 50, fieldName: 'Name'),
])
```

## 📊 État d'implémentation

### ✅ Formulaires mis à jour
- [x] EditProfileScreen
- [x] CourseFormScreen
- [x] QuizFormScreen
- [x] ModuleFormScreen
- [x] EventFormScreen
- [x] PlanFormScreen

### 📝 Formulaires restants à migrer
- [ ] InstructorFormScreen
- [ ] Autres formulaires de reclamation, blog, etc.

---

**Créé le :** 11 novembre 2025  
**Dernière mise à jour :** 11 novembre 2025
