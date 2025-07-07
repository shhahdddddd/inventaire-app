<?php

namespace App\Http\Controllers;

use App\Models\Role;
use Illuminate\Http\Request;

class RoleController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        
        if (!$user) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        // Get roles for the user's store only
        $roles = Role::where('store_id', $user->store_id)
            ->orderBy('nom')
            ->get();

        return response()->json([
            'data' => $roles->map(function ($role) {
                return [
                    'id' => $role->id,
                    'nom' => $role->nom,
                    'description' => $role->description,
                    'store_id' => $role->store_id,
                ];
            })
        ]);
    }

    public function store(Request $request)
    {
        $admin = $request->user();
        
        // Only store admins can create roles
        if (!$admin->isAdmin()) {
            return response()->json([
                'error' => 'Forbidden',
                'message' => 'Only store administrators can create roles'
            ], 403);
        }

        $validated = $request->validate([
            'nom' => 'required|string|max:50',
            'description' => 'nullable|string',
        ]);

        // Check if role name already exists in this store
        $existingRole = Role::where('nom', $validated['nom'])
            ->where('store_id', $admin->store_id)
            ->first();
            
        if ($existingRole) {
            return response()->json([
                'error' => 'Role already exists',
                'message' => 'A role with this name already exists in your store'
            ], 400);
        }

        $role = Role::create([
            'nom' => $validated['nom'],
            'description' => $validated['description'],
            'store_id' => $admin->store_id,
        ]);

        return response()->json([
            'message' => 'Role created successfully',
            'role' => [
                'id' => $role->id,
                'nom' => $role->nom,
                'description' => $role->description,
                'store_id' => $role->store_id,
            ]
        ], 201);
    }

    public function show(Request $request, $id)
    {
        $user = $request->user();
        
        if (!$user) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        $role = Role::where('id', $id)
            ->where('store_id', $user->store_id)
            ->first();
        
        if (!$role) {
            return response()->json([
                'error' => 'Not Found',
                'message' => 'Role not found in your store'
            ], 404);
        }

        return response()->json([
            'role' => [
                'id' => $role->id,
                'nom' => $role->nom,
                'description' => $role->description,
                'store_id' => $role->store_id,
            ]
        ]);
    }

    public function update(Request $request, $id)
    {
        $admin = $request->user();
        
        // Only store admins can update roles
        if (!$admin->isAdmin()) {
            return response()->json([
                'error' => 'Forbidden',
                'message' => 'Only store administrators can update roles'
            ], 403);
        }

        $role = Role::where('id', $id)
            ->where('store_id', $admin->store_id)
            ->first();
        
        if (!$role) {
            return response()->json([
                'error' => 'Not Found',
                'message' => 'Role not found in your store'
            ], 404);
        }

        $validated = $request->validate([
            'nom' => 'sometimes|string|max:50',
            'description' => 'sometimes|string',
        ]);

        // Check if new name conflicts with existing role in this store
        if (isset($validated['nom']) && $validated['nom'] !== $role->nom) {
            $existingRole = Role::where('nom', $validated['nom'])
                ->where('store_id', $admin->store_id)
                ->where('id', '!=', $id)
                ->first();
                
            if ($existingRole) {
                return response()->json([
                    'error' => 'Role name conflict',
                    'message' => 'A role with this name already exists in your store'
                ], 400);
            }
        }

        $role->update($validated);

        return response()->json([
            'message' => 'Role updated successfully',
            'role' => [
                'id' => $role->id,
                'nom' => $role->nom,
                'description' => $role->description,
                'store_id' => $role->store_id,
            ]
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $admin = $request->user();
        
        // Only store admins can delete roles
        if (!$admin->isAdmin()) {
            return response()->json([
                'error' => 'Forbidden',
                'message' => 'Only store administrators can delete roles'
            ], 403);
        }

        $role = Role::where('id', $id)
            ->where('store_id', $admin->store_id)
            ->first();
        
        if (!$role) {
            return response()->json([
                'error' => 'Not Found',
                'message' => 'Role not found in your store'
            ], 404);
        }

        // Check if role is being used by any users
        $userCount = $role->users()->count();
        if ($userCount > 0) {
            return response()->json([
                'error' => 'Cannot delete role',
                'message' => "This role is assigned to {$userCount} user(s). Please reassign them before deleting the role."
            ], 400);
        }

        $role->delete();

        return response()->json([
            'message' => 'Role deleted successfully'
        ]);
    }
}
