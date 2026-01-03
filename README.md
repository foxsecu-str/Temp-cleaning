# README – Win11 Cache Cleanup (Intune & SCCM)

## 📌 Description

Ce script PowerShell permet le **nettoyage sécurisé des caches Windows 11**.
Il est conçu pour être utilisé :

* en **exécution manuelle**
* via **Microsoft Intune**
* via **SCCM (MECM)**

Le script est **safe par design**, loggé, et adapté aux environnements entreprise.

---

## 🎯 Objectifs

* Libérer de l’espace disque
* Résoudre des problèmes liés aux caches Windows
* Fournir un outil **standard, auditable et déployable en masse**
* Éviter toute action risquée (pas de tuning agressif)

---

## 🧠 Principes de fonctionnement

* 🔒 **Mode simulation par défaut**
* 🚨 **Mode production explicite**
* 🤖 **Mode silencieux** pour déploiements Intune / SCCM
* 🧾 **Logs systématiques**
* ❌ Aucune interaction utilisateur en mode déployé

---

## 🧹 Éléments nettoyés

### ✅ Inclus

* Temp utilisateur (`%TEMP%`)
* Temp système (`C:\Windows\Temp`)
* Cache Windows Update
* Cache Delivery Optimization
* Cache Microsoft Store
* Cache DNS
* Corbeille

### ❌ Exclus volontairement

* WinSxS
* Registre
* Profils utilisateurs
* Données applicatives critiques

👉 Le script privilégie la **stabilité** à l’agressivité.

---

## 📁 Logs

Les logs sont créés automatiquement dans :

```
C:\Temp
```

Nom du fichier :

```
Win11_CacheCleanup_YYYYMMDD_HHMMSS.log
```

Contenu :

* Date et heure d’exécution
* Mode (simulation / production / silencieux)
* Actions réalisées
* Erreurs éventuelles (fichiers verrouillés, accès refusé, etc.)

---

## ▶️ Exécution manuelle

### 🔒 Mode simulation (recommandé pour test)

```powershell
.\Win11_CacheCleanup.ps1
```

➡️ Aucun fichier n’est supprimé.

---

### 🚨 Mode production interactif

```powershell
.\Win11_CacheCleanup.ps1 -Prod
```

Une confirmation explicite est demandée :

```
Tapez NETTOYER pour continuer
```

---

## 🚀 Déploiement Intune

### Type

* Application Win32

### Commande d’installation

```powershell
powershell.exe -ExecutionPolicy Bypass -File Win11_CacheCleanup.ps1 -Prod -Silent
```

### Contexte

* Exécution **SYSTEM**
* Architecture **64 bits**

### Désinstallation

* Aucune (script one-shot)

---

## 🚀 Déploiement SCCM (MECM)

### Type de programme

* Script PowerShell

### Compte d’exécution

* **SYSTEM**

### Ligne de commande

```powershell
powershell.exe -ExecutionPolicy Bypass -File Win11_CacheCleanup.ps1 -Prod -Silent
```

### Remarques

* Script relançable
* Compatible maintenance planifiée

---

## 🛡️ Sécurité & bonnes pratiques

* Toujours tester **sans `-Prod`**
* Ne jamais retirer les garde-fous du script
* Vérifier les logs après déploiement
* Exécuter en SYSTEM pour un nettoyage complet

---

## 🔧 Évolutions possibles

* Nettoyage navigateurs (Edge / Chrome / Firefox)
* Rapport d’espace disque libéré
* Mode *light* / *full*
* Intégration RMM
* Version self-service utilisateur
* Signature du script (AppLocker / WDAC)
