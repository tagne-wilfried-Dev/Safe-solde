# Safe-solde
Application mobile de gestion et suivi des actions financières personnelles. 


# CAHIER DES CHARGES : Application "$afe$olde"

**Version :** 1.1 

## 1. PRÉSENTATION DU PROJET

### 1.1 Contexte
Dans un contexte économique où la gestion rigoureuse des finances personnelles est essentielle, et où des systèmes d'épargne communautaires (comme les tontines) sont très répandus au Cameroun, il devient nécessaire de disposer d'un outil simple et rapide pour suivre ses flux monétaires.

### 1.2 Objectif de l'application
L'application **"$afe$olde"** a pour objectif de permettre à l'utilisateur de noter ses entrées d'argent (salaires, gains, cotisations tontines reçues) et ses sorties (loyer, transport, achats, cotisations tontines versées) afin d'avoir une vision claire de son solde financier en temps réel. Le nom évoque à la fois la sécurité (**safe**) et le suivi du montant disponible (**solde**).

### 1.3 Public Cible
*   Étudiants et jeunes travailleurs.
*   Membres de tontines.
*   Toute personne souhaitant digitaliser le suivi de son "carnet de dépenses".

---

## 2. SPÉCIFICATIONS FONCTIONNELLES (Le "Quoi")

L'application sera développée selon l'approche **MVP (Produit Minimum Viable)** pour garantir une livraison rapide et fonctionnelle.

### 2.1 Module de Tableau de Bord (Dashboard)
C'est l'écran principal de l'application. Il doit fournir une vue synthétique :
*   **Affichage du Solde Total :** Calcul automatique (Somme des Revenus - Somme des Dépenses).
*   **Résumé des Flux :** 
    *   Affichage du total cumulé des entrées (en vert).
    *   Affichage du total cumulé des sorties (en rouge).
*   **Accès Rapide :** Bouton d'action flottant (FAB) pour ajouter une nouvelle transaction.

### 2.2 Module de Gestion des Transactions
L'utilisateur doit pouvoir enregistrer chaque mouvement financier via un formulaire :
*   **Saisie du libellé :** Nom de la transaction (ex: "Tontine Mensuelle", "Achat Crédit").
*   **Saisie du montant :** Valeur numérique de la transaction.
*   **Sélection du type :** Choix entre "Entrée" (Revenu) ou "Sortie" (Dépense) via un menu déroulant ou des boutons.
*   **Date :** Enregistrement automatique de la date du jour.

### 2.3 Module d'Historique
L'application doit proposer une vue détaillée des opérations :
*   **Liste chronologique :** Affichage de toutes les transactions, de la plus récente à la plus ancienne.
*   **Indicateurs visuels :** Utilisation de couleurs (Vert pour entrée, Rouge pour sortie) pour une lecture rapide.
*   **Détails :** Affichage du libellé, de la date et du montant pour chaque ligne.

### 2.4 Persistance des Données
*   L'application doit être capable de sauvegarder les données localement afin que les informations ne soient pas perdues lors de la fermeture de l'application.

---

## 3. SPÉCIFICATIONS TECHNIQUES (Le "Comment")

### 3.1 Stack Technologique
*   **Langage :** Dart.
*   **Framework :** Flutter (pour un déploiement multiplateforme Android/iOS).
*   **Stockage de données :** `Shared Preferences` (ou `Hive` pour une gestion plus optimisée des listes).
*   **IDE :** VS Code ou Android Studio.

### 3.2 Architecture logicielle
L'application suivra une structure simple :
*   **UI Layer (Vue) :** Widgets Flutter pour l'interface utilisateur.
*   **Logic Layer (Logique) :** Fonctions de calcul du solde et gestion des listes.
*   **Data Layer (Données) :** Modèle de classe `Transaction` et service de stockage local.

---

## 4. EXIGENCES NON-FONCTIONNELLES

*   **Ergonomie (UX) :** L'interface doit être intuitive, avec un minimum de clics pour ajouter une dépense.
*   **Performance :** L'application doit être légère et se lancer rapidement.
*   **Disponibilité :** L'application doit fonctionner entièrement **hors-ligne** (Offline first).

---

## 5. PLANNING DE RÉALISATION (Roadmap)

| Phase | Activité | Livrable | Durée estimée |
| :--- | :--- | :--- | :--- |
| **Phase 1** | Configuration environnement & Design UI | Maquettes / Écrans vides | 2 jours |
| **Phase 2** | Développement du formulaire et de la logique de calcul | Application fonctionnelle (mémoire vive) | 3 jours |
| **Phase 3** | Implémentation du stockage local (Persistance) | Application avec sauvegarde | 2 jours |
| **Phase 4** | Tests, corrections de bugs et peaufinage design | Version finale (APK) | 2 jours |

---

## 6. CRITÈRES D'ACCEPTATION (Pour le Jury)

Le projet sera considéré comme réussi si :
1.  Le solde se met à jour automatiquement après l'ajout d'une transaction.
2.  L'historique affiche correctement la distinction entre entrées et sorties.
3.  Les données sont conservées après le redémarrage de l'application.
4.  L'interface est propre et respecte les codes visuels d'une application financière.
