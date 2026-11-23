# pharmaflow

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Règles Firestore : validation des pharmaciens

Les règles sont dans `../firestore.rules` (projet `epharmacy-ci-steve-1d90d`).

Champs du profil `users/{uid}` :

- `role` : `patient`, `pharmacist` ou `admin`. Le rôle `admin` ne s'attribue qu'à la main (console Firebase ou Admin SDK), jamais à l'inscription.
- `status` (pharmaciens uniquement) : `pending` à l'inscription, puis `approved` après validation. Un patient n'a pas de `status` (absent ou `null`).
- `validatedBy` (uid du valideur) et `validatedAt` (horodatage serveur), posés lors de la validation.

Comportement :

- L'inscription d'un pharmacien doit écrire `status: 'pending'`. Toute inscription avec `approved`, `validatedBy`, `validatedAt` ou le rôle `admin` est refusée.
- Un pharmacien `pending` (ou sans `status`, comptes historiques) n'a aucun droit pharmacien : il ne lit et ne modifie que son propre profil (hors `role`, `status`, `validatedBy`, `validatedAt`), et il ne voit ni les commandes, ni les autres profils, ni l'écriture du catalogue.
- Seul un pharmacien `approved` ou un admin peut valider un pharmacien `pending` : la mise à jour ne doit toucher que `status: 'approved'`, `validatedBy: <son uid>` et `validatedAt: FieldValue.serverTimestamp()`.
- Liste des pharmaciens à valider (réservée au pharmacien validé et à l'admin) : `users` `where role == 'pharmacist'` `where status == 'pending'`.
- Personne ne peut changer son propre `role` ou `status`.
