# 🔄 Flux d'authentification et modèle de données

> Documentation visuelle du système d'authentification.

---

## 1️⃣ Flux d'authentification

```mermaid
sequenceDiagram
    autonumber
    participant U as Utilisateur
    participant F as Flutter
    participant A as API Rust
    participant DB as PostgreSQL

    Note over U,DB: 1 - INSCRIPTION
    U->>F: Remplit le formulaire
    F->>A: POST /api/auth/register
    A->>DB: Verifie si email existe
    DB-->>A: OK (libre)
    A->>A: Hash password (Argon2)
    A->>DB: INSERT INTO users
    DB-->>A: User cree
    A->>A: Genere JWT
    A-->>F: 201 + access_token
    F-->>U: Dashboard

    Note over U,DB: 2 - CONNEXION
    U->>F: Email + password
    F->>A: POST /api/auth/login
    A->>DB: SELECT user
    DB-->>A: User + password_hash
    A->>A: Verifie Argon2
    A-->>F: 200 + access_token
    F-->>U: Dashboard

    Note over U,DB: 3 - REQUETE PROTEGEE
    F->>A: GET /api/dashboard + Bearer token
    A->>A: Middleware decode JWT
    alt Token valide
        A-->>F: 200 + donnees
    else Token invalide ou expire
        A-->>F: 401 Unauthorized
    end
```

### 📖 Légende

| Étape | Description |
|-------|-------------|
| **Inscription** | L'utilisateur crée un compte, le mot de passe est haché avec **Argon2** avant stockage. |
| **Connexion** | L'utilisateur envoie email + password, le serveur vérifie le hash et génère un **JWT**. |
| **Requête protégée** | Le client envoie le JWT dans `Authorization: Bearer <token>`. Le middleware vérifie. |

---

## 2️⃣ Modèle de données

```mermaid
erDiagram
    USERS {
        uuid id PK
        text email UK
        text username
        text password_hash
        text role
        timestamptz created_at
    }
```

### 📋 Détails des colonnes

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | UUID | Clé primaire (sécurité : non énumérable) |
| `email` | TEXT UNIQUE | Email de connexion, indexé |
| `username` | TEXT | Nom d'affichage |
| `password_hash` | TEXT | Hash Argon2id |
| `role` | TEXT | `user` ou `admin` |
| `created_at` | TIMESTAMPTZ | Date de création |

---

## 🛡️ Niveaux d'accès

```mermaid
graph LR
    Public[🌍 Public: register + login]
    Auth[🔐 Authentifie: dashboard]
    Admin[👑 Admin: gestion utilisateurs]
    Public -->|JWT| Auth
    Auth -->|role admin| Admin
    style Public fill:#e8f5e9,stroke:#4caf50
    style Auth fill:#fff3e0,stroke:#ff9800
    style Admin fill:#ffebee,stroke:#f44336
```

---

## 📚 Voir aussi

- [README.md](./README.md) — Vue d'ensemble du projet