<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Role;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    public function index(Request $request)
    {
        try {
            $user = $request->user();
            
            if (!$user) {
                return response()->json(['error' => 'Unauthorized'], 401);
            }

            // Only store admins can view users in their store
            if (!$user->isAdmin()) {
                return response()->json([
                    'error' => 'Forbidden',
                    'message' => 'Only store administrators can view users'
                ], 403);
            }

            // Get users from the same store only
            $users = User::where('store_id', $user->store_id)
                ->with(['role', 'station', 'store'])
                ->paginate(20);
            
            return response()->json([
                'data' => $users->map(function ($user) {
                    return [
                        'id' => $user->id,
                        'username' => $user->username,
                        'nom' => $user->nom,
                        'role' => $user->role ? [
                            'id' => $user->role->id, 
                            'nom' => $user->role->nom,
                            'description' => $user->role->description
                        ] : null,
                        'station' => $user->station ? [
                            'id' => $user->station->id, 
                            'nom' => $user->station->nom
                        ] : null,
                        'store' => $user->store ? [
                            'id' => $user->store->id,
                            'nom' => $user->store->nom
                        ] : null,
                        'status' => $user->status,
                        'created_at' => $user->created_at,
                    ];
                }),
                'pagination' => [
                    'current_page' => $users->currentPage(),
                    'last_page' => $users->lastPage(),
                    'per_page' => $users->perPage(),
                    'total' => $users->total(),
                    'from' => $users->firstItem(),
                    'to' => $users->lastItem(),
                ]
            ]);
        } catch (\Exception $e) {
            \Log::error('Exception in UserController@index: ' . $e->getMessage());
            return response()->json(['error' => 'Server error'], 500);
        }
    }

    public function store(Request $request)
    {
        $admin = $request->user();
        
        // Only store admins can create users
        if (!$admin->isAdmin()) {
            return response()->json([
                'error' => 'Forbidden',
                'message' => 'Only store administrators can create users'
            ], 403);
        }

        $validated = $request->validate([
            'username' => 'required|string|unique:user,username',
            'mot_de_passe' => 'required|string|min:6',
            'role_id' => 'required|exists:role,id',
            'nom' => 'nullable|string|max:100',
            'station_id' => 'required|exists:station_source,id',
        ]);

        // Verify that the role belongs to the admin's store
        $role = Role::where('id', $validated['role_id'])
            ->where('store_id', $admin->store_id)
            ->first();
            
        if (!$role) {
            return response()->json([
                'error' => 'Invalid role',
                'message' => 'The selected role is not available in your store'
            ], 400);
        }

        $user = User::create([
            'username' => $validated['username'],
            'mot_de_passe' => Hash::make($validated['mot_de_passe']),
            'nom' => $validated['nom'] ?? $validated['username'],
            'store_id' => $admin->store_id,
            'station_id' => $validated['station_id'],
            'role_id' => $validated['role_id'],
        ]);

        return response()->json([
            'message' => 'User created successfully',
            'user' => $user->load(['role', 'station', 'store'])
        ], 201);
    }

    public function show(Request $request, $id)
    {
        $admin = $request->user();
        
        if (!$admin->isAdmin()) {
            return response()->json([
                'error' => 'Forbidden',
                'message' => 'Only store administrators can view user details'
            ], 403);
        }

        $user = User::where('store_id', $admin->store_id)
            ->with(['role', 'station', 'store'])
            ->find($id);
        
        if (!$user) {
            return response()->json([
                'error' => 'Not Found',
                'message' => 'User not found in your store'
            ], 404);
        }

        return response()->json([
            'user' => [
                'id' => $user->id,
                'username' => $user->username,
                'nom' => $user->nom,
                'role' => $user->role ? [
                    'id' => $user->role->id, 
                    'nom' => $user->role->nom,
                    'description' => $user->role->description
                ] : null,
                'station' => $user->station ? [
                    'id' => $user->station->id, 
                    'nom' => $user->station->nom
                ] : null,
                'store' => $user->store ? [
                    'id' => $user->store->id,
                    'nom' => $user->store->nom
                ] : null,
                'status' => $user->status,
                'created_at' => $user->created_at,
            ]
        ]);
    }

    public function update(Request $request, $id)
    {
        $admin = $request->user();
        
        // Only store admins can update users
        if (!$admin->isAdmin()) {
            return response()->json([
                'error' => 'Forbidden',
                'message' => 'Only store administrators can update users'
            ], 403);
        }

        $user = User::where('store_id', $admin->store_id)->find($id);
        
        if (!$user) {
            return response()->json([
                'error' => 'Not Found',
                'message' => 'User not found in your store'
            ], 404);
        }

        $validated = $request->validate([
            'username' => 'sometimes|string|unique:user,username,' . $id,
            'nom' => 'sometimes|string|max:100',
            'role_id' => 'sometimes|exists:role,id',
            'station_id' => 'sometimes|exists:station_source,id',
            'mot_de_passe' => 'sometimes|string|min:6',
        ]);

        // If role is being updated, verify it belongs to the admin's store
        if (isset($validated['role_id'])) {
            $role = Role::where('id', $validated['role_id'])
                ->where('store_id', $admin->store_id)
                ->first();
                
            if (!$role) {
                return response()->json([
                    'error' => 'Invalid role',
                    'message' => 'The selected role is not available in your store'
                ], 400);
            }
        }

        // Hash password if provided
        if (isset($validated['mot_de_passe'])) {
            $validated['mot_de_passe'] = Hash::make($validated['mot_de_passe']);
        }

        $user->update($validated);

        return response()->json([
            'message' => 'User updated successfully',
            'user' => $user->load(['role', 'station', 'store'])
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $admin = $request->user();
        
        // Only store admins can delete users
        if (!$admin->isAdmin()) {
            return response()->json([
                'error' => 'Forbidden',
                'message' => 'Only store administrators can delete users'
            ], 403);
        }

        $user = User::where('store_id', $admin->store_id)->find($id);
        
        if (!$user) {
            return response()->json([
                'error' => 'Not Found',
                'message' => 'User not found in your store'
            ], 404);
        }

        // Prevent admin from deleting themselves
        if ($user->id === $admin->id) {
            return response()->json([
                'error' => 'Cannot delete self',
                'message' => 'You cannot delete your own account'
            ], 400);
        }

        $user->delete();

        return response()->json([
            'message' => 'User deleted successfully'
        ]);
    }

    public function invite(Request $request)
    {
        $admin = $request->user();
        
        if (!$admin->isAdmin()) {
            return response()->json([
                'error' => 'Forbidden',
                'message' => 'Only store administrators can invite users'
            ], 403);
        }

        $validated = $request->validate([
            'username' => 'required|string|unique:user,username',
            'role_id' => 'required|exists:role,id',
            'nom' => 'nullable|string|max:100',
            'station_id' => 'required|exists:station_source,id',
        ]);

        // Verify that the role belongs to the admin's store
        $role = Role::where('id', $validated['role_id'])
            ->where('store_id', $admin->store_id)
            ->first();
            
        if (!$role) {
            return response()->json([
                'error' => 'Invalid role',
                'message' => 'The selected role is not available in your store'
            ], 400);
        }

        $user = User::create([
            'username' => $validated['username'],
            'mot_de_passe' => '', // Will be set on activation
            'nom' => $validated['nom'] ?? $validated['username'],
            'store_id' => $admin->store_id,
            'station_id' => $validated['station_id'],
            'role_id' => $validated['role_id'],
            'status' => 'pending',
        ]);

        // Generate activation token
        $activationToken = hash('sha256', $user->username . $user->created_at);
        
        // TODO: Send invitation email with activation link
        // For now, return the activation token in the response
        return response()->json([
            'message' => 'User invited successfully',
            'user' => $user->load(['role', 'station', 'store']),
            'activation_token' => $activationToken,
            'activation_url' => config('app.url') . '/activate?username=' . $user->username . '&token=' . $activationToken,
        ], 201);
    }
}
