# Laravel JWT Authentication & RBAC API Documentation

## Overview
This Laravel backend implements JWT authentication with Role-Based Access Control (RBAC) for a multi-station inventory management system.

## Authentication

### Login
**POST** `/api/login`
```json
{
    "username": "admin",
    "password": "password123"
}
```

**Response:**
```json
{
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "token_type": "bearer",
    "expires_in": 3600,
    "user": {
        "id": 1,
        "username": "admin",
        "nom": "Admin User",
        "role": {
            "id": 1,
            "nom": "admin"
        },
        "station": {
            "id": 1,
            "nom": "Main Station"
        },
        "station_id": 1,
        "store_id": 1
    }
}
```

### Get User Info
**GET** `/api/user`
**Headers:** `Authorization: Bearer <token>`

### Refresh Token
**POST** `/api/refresh`
**Headers:** `Authorization: Bearer <token>`

### Logout
**POST** `/api/logout`
**Headers:** `Authorization: Bearer <token>`

## Role-Based Access Control

### Available Roles
- `admin`: Full system access, user management
- `agent_achat`: Purchase management only
- `gestionnaire_stock`: Stock, inventory, transfers, articles
- `cashier`: Ticket scanning only

### Role Permissions

| Feature | Admin | Agent Achat | Gestionnaire Stock | Cashier |
|---------|-------|-------------|-------------------|---------|
| User Management | ✅ | ❌ | ❌ | ❌ |
| Articles | ✅ | ❌ | ✅ | ❌ |
| Familles | ✅ | ❌ | ✅ | ❌ |
| Marques | ✅ | ❌ | ✅ | ❌ |
| Fournisseurs | ✅ | ✅ | ❌ | ❌ |
| Transferts | ✅ | ❌ | ✅ | ❌ |
| Inventaires | ✅ | ❌ | ✅ | ❌ |
| Achats | ✅ | ✅ | ❌ | ❌ |

## User Management (Admin Only)

### List Users
**GET** `/api/users`
**Headers:** `Authorization: Bearer <token>`
**Middleware:** `role:admin`

**Response:**
```json
{
    "data": [
        {
            "id": 1,
            "username": "admin",
            "nom": "Admin User",
            "role": {"id": 1, "nom": "admin"},
            "station": {"id": 1, "nom": "Main Station"},
            "status": "active"
        }
    ],
    "pagination": {
        "current_page": 1,
        "last_page": 1,
        "per_page": 20,
        "total": 1,
        "from": 1,
        "to": 1
    }
}
```

### Create User
**POST** `/api/users`
**Headers:** `Authorization: Bearer <token>`
**Middleware:** `role:admin`

```json
{
    "username": "newuser",
    "mot_de_passe": "password123",
    "role_id": 2,
    "nom": "New User"
}
```

### Update User
**PUT** `/api/users/{id}`
**Headers:** `Authorization: Bearer <token>`
**Middleware:** `role:admin`

```json
{
    "username": "updateduser",
    "nom": "Updated User",
    "role_id": 3
}
```

## Protected Routes by Role

### Admin Routes
- All user management endpoints
- All system endpoints

### Agent Achat Routes
- `/api/fournisseurs/*`
- `/api/achats/*` (from achat_routes.php)

### Gestionnaire Stock Routes
- `/api/articles/*`
- `/api/familles/*`
- `/api/marques/*`
- `/api/transferts/*`
- `/api/inventaires/*`

### Cashier Routes
- Ticket scanning endpoints (to be implemented)

## Station-Based Access

- Users can only access data from their own station
- Admins can only manage users in their own station
- All operations are scoped to the user's station

## Error Responses

### Unauthorized (401)
```json
{
    "error": "Unauthorized",
    "message": "Authentication required"
}
```

### Forbidden (403)
```json
{
    "error": "Forbidden",
    "message": "Only administrators can view users"
}
```

### Validation Error (422)
```json
{
    "errors": {
        "username": ["The username field is required."]
    }
}
```

## CORS Configuration

The API supports cross-origin requests for mobile frontend access with the following headers:
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

## Testing

### Test Login
```bash
curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "password123"}'
```

### Test Protected Route
```bash
curl -X GET http://127.0.0.1:8000/api/users \
  -H "Authorization: Bearer <your_token>" \
  -H "Accept: application/json"
```

## Database Schema

### User Table
- `id` (Primary Key)
- `username` (Unique)
- `mot_de_passe` (Hashed)
- `nom`
- `role_id` (Foreign Key to role table)
- `station_id` (Foreign Key to station_source table)
- `store_id` (Foreign Key to store table)

### Role Table
- `id` (Primary Key)
- `nom` (admin, agent_achat, gestionnaire_stock, cashier)
- `description`
- `store_id`

### Station Tables
- `station_source`: Source stations
- `station_destinataire`: Destination stations 