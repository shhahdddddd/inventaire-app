# Multi-Store RBAC System API Documentation

## Overview

This system implements a complete multi-store, role-based access control (RBAC) system where each store has its own admin and users can only access resources within their own store.

## System Architecture

### 1. Store-Based Isolation
- Each store has its own set of users, roles, and resources
- Users can only access resources within their own store
- Cross-store access is blocked by middleware

### 2. Role-Based Access Control (RBAC)

#### A. ADMIN
- **Full access** to all modules: Inventaire, Tickets/Rayons, Articles, Achats, Bons de transfert
- **User management:** Can create/delete users and roles
- **Store management:** Can manage only their own store

#### B. GESTIONNAIRE DE STOCK
- **Inventaire:** Can count and adjust
- **Articles:** Full CRUD
- **Bons de transfert:** Can create/validate
- **Achats:** Read-only
- **Tickets/Rayons:** No access

#### C. CAISSIER (CASHIER)
- **Tickets/Rayons:** Can create/modify tickets, handle returns
- **Articles:** Read-only (stock consultation)
- **No access:** Achats, Transferts, Inventaire

#### D. AGENT D'ACHAT (Employé standard)
- **Articles:** Scan only
- **Tickets/Rayons:** Read-only
- **Inventaire:** Can participate in counts
- **No access:** Achats, Transferts

## User Registration & Management

### 1. First User = Admin
- The first user to register becomes the system-wide admin
- Must provide store name and address during registration
- System automatically creates:
  - Store record
  - Default station
  - Admin role for the store
  - Other default roles (gestionnaire de stock, caissier, agent d'achat)

### 2. Subsequent Users
- All other users must be invited by an admin
- Registration is blocked for non-first users
- Invited users receive activation tokens

## API Endpoints

### Authentication

#### POST /api/register
**First user registration (creates store and admin)**
```json
{
    "username": "admin",
    "password": "admin123",
    "store_name": "My Store",
    "store_address": "123 Main Street"
}
```

**Response:**
```json
{
    "status": "success",
    "message": "Admin user and store created successfully",
    "user": {
        "id": 1,
        "username": "admin",
        "role": {"id": 1, "nom": "admin"},
        "store": {"id": 1, "nom": "My Store"}
    },
    "authorisation": {
        "token": "jwt_token_here",
        "type": "bearer"
    }
}
```

#### POST /api/login
**User login**
```json
{
    "username": "admin",
    "password": "admin123"
}
```

#### POST /api/activate
**Activate invited user**
```json
{
    "username": "invited_user",
    "activation_token": "token_from_invitation",
    "password": "new_password"
}
```

### User Management (Admin Only)

#### GET /api/users
**Get all users in the admin's store**
- Requires: `role:admin`
- Returns: Paginated list of users with roles and stations

#### POST /api/users
**Create new user**
- Requires: `role:admin`
```json
{
    "username": "newuser",
    "mot_de_passe": "password123",
    "role_id": 2,
    "nom": "New User",
    "station_id": 1
}
```

#### POST /api/users/invite
**Invite a new user**
- Requires: `role:admin`
```json
{
    "username": "invited_user",
    "role_id": 2,
    "nom": "Invited User",
    "station_id": 1
}
```

**Response includes activation token:**
```json
{
    "message": "User invited successfully",
    "activation_token": "hash_token",
    "activation_url": "http://localhost:8000/activate?username=invited_user&token=hash_token"
}
```

#### PUT /api/users/{id}
**Update user**
- Requires: `role:admin`
- Can only update users in the same store

#### DELETE /api/users/{id}
**Delete user**
- Requires: `role:admin`
- Cannot delete self

### Role Management (Admin Only)

#### GET /api/roles
**Get all roles in the admin's store**
- Requires: `role:admin`

#### POST /api/roles
**Create new role**
- Requires: `role:admin`
```json
{
    "nom": "custom_role",
    "description": "Custom role description"
}
```

#### PUT /api/roles/{id}
**Update role**
- Requires: `role:admin`

#### DELETE /api/roles/{id}
**Delete role**
- Requires: `role:admin`
- Cannot delete if role is assigned to users

### Store Management

#### GET /api/stores
**Get current user's store info**

#### GET /api/stores/{id}
**Get store details with users**
- Can only access own store

#### PUT /api/stores/{id}
**Update store info**
- Requires: `role:admin`
- Can only update own store

#### GET /api/stores/{id}/stats
**Get store statistics**
- Requires: `role:admin`
- Shows user count by role

## Middleware

### 1. CheckStore Middleware
- Applied to all authenticated routes
- Prevents cross-store access
- Adds `user_store_id` to request

### 2. CheckRole Middleware
- Protects routes based on user roles
- Usage: `role:admin`, `role:gestionnaire de stock`, etc.

## Database Structure

### Key Tables
- `store`: Stores with name and address
- `user`: Users with store_id, role_id, station_id
- `role`: Roles with store_id (store-specific roles)
- `station_source`: Stations within stores

### Relationships
- Store has many Users
- Store has many Roles
- User belongs to Store, Role, and Station
- Role belongs to Store

## Security Features

### 1. Store Isolation
- All queries filtered by `store_id`
- Cross-store access blocked
- Users can only see/manage their own store

### 2. Role-Based Access
- Routes protected by role middleware
- Controllers check user roles before actions
- Different permissions per role

### 3. User Invitation System
- Only admins can create users
- Invited users get activation tokens
- Pending users cannot log in

## Testing the System

### 1. Create First Admin
```bash
curl -X POST http://localhost:8000/api/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin123",
    "store_name": "Test Store",
    "store_address": "123 Test Street"
  }'
```

### 2. Login as Admin
```bash
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin123"
  }'
```

### 3. Invite a User
```bash
curl -X POST http://localhost:8000/api/users/invite \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "cashier1",
    "role_id": 3,
    "nom": "Cashier One",
    "station_id": 1
  }'
```

### 4. Activate Invited User
```bash
curl -X POST http://localhost:8000/api/activate \
  -H "Content-Type: application/json" \
  -d '{
    "username": "cashier1",
    "activation_token": "TOKEN_FROM_INVITATION",
    "password": "cashier123"
  }'
```

## Frontend Integration

### Flutter App Updates Needed
1. Update login to handle store-based user info
2. Add user management screens for admins
3. Implement role-based UI (show/hide features based on role)
4. Add invitation flow for admins
5. Add activation flow for invited users

### Key API Calls for Frontend
- `/api/register` - First user setup
- `/api/login` - User authentication
- `/api/users` - User management (admin only)
- `/api/roles` - Role management (admin only)
- `/api/stores` - Store information
- `/api/activate` - User activation

## Next Steps

1. **Email Integration**: Implement proper email sending for invitations
2. **Token Management**: Add proper token storage and expiration
3. **Audit Logging**: Add logging for all user actions
4. **Password Policies**: Implement password strength requirements
5. **Session Management**: Add session timeout and refresh tokens
6. **API Rate Limiting**: Add rate limiting for security
7. **Frontend Development**: Update Flutter app to use new API structure 