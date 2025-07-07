<?php

namespace App\Http\Controllers;

use App\Models\Store;
use App\Models\User;
use App\Models\Role;
use Illuminate\Http\Request;

class StoreController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        
        if (!$user) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        // Users can only see their own store
        $store = Store::where('id', $user->store_id)
            ->with(['users' => function ($query) {
                $query->with(['role', 'station']);
            }])
            ->first();

        if (!$store) {
            return response()->json([
                'error' => 'Not Found',
                'message' => 'Store not found'
            ], 404);
        }

        return response()->json([
            'store' => [
                'id' => $store->id,
                'nom' => $store->nom,
                'address' => $store->address,
                'users_count' => $store->users->count(),
                'created_at' => $store->created_at,
            ]
        ]);
    }

    public function show(Request $request, $id)
    {
        $user = $request->user();
        
        if (!$user) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        // Users can only access their own store
        if ($user->store_id != $id) {
            return response()->json([
                'error' => 'Forbidden',
                'message' => 'You can only access your own store'
            ], 403);
        }

        $store = Store::where('id', $id)
            ->with(['users' => function ($query) {
                $query->with(['role', 'station']);
            }])
            ->first();

        if (!$store) {
            return response()->json([
                'error' => 'Not Found',
                'message' => 'Store not found'
            ], 404);
        }

        return response()->json([
            'store' => [
                'id' => $store->id,
                'nom' => $store->nom,
                'address' => $store->address,
                'users' => $store->users->map(function ($user) {
                    return [
                        'id' => $user->id,
                        'username' => $user->username,
                        'nom' => $user->nom,
                        'role' => $user->role ? [
                            'id' => $user->role->id,
                            'nom' => $user->role->nom
                        ] : null,
                        'station' => $user->station ? [
                            'id' => $user->station->id,
                            'nom' => $user->station->nom
                        ] : null,
                        'status' => $user->status,
                    ];
                }),
                'created_at' => $store->created_at,
            ]
        ]);
    }

    public function update(Request $request, $id)
    {
        $admin = $request->user();
        
        // Only store admins can update store information
        if (!$admin->isAdmin()) {
            return response()->json([
                'error' => 'Forbidden',
                'message' => 'Only store administrators can update store information'
            ], 403);
        }

        // Admins can only update their own store
        if ($admin->store_id != $id) {
            return response()->json([
                'error' => 'Forbidden',
                'message' => 'You can only update your own store'
            ], 403);
        }

        $store = Store::find($id);
        
        if (!$store) {
            return response()->json([
                'error' => 'Not Found',
                'message' => 'Store not found'
            ], 404);
        }

        $validated = $request->validate([
            'nom' => 'sometimes|string|max:255',
            'address' => 'sometimes|string|max:500',
        ]);

        $store->update($validated);

        return response()->json([
            'message' => 'Store updated successfully',
            'store' => [
                'id' => $store->id,
                'nom' => $store->nom,
                'address' => $store->address,
                'updated_at' => $store->updated_at,
            ]
        ]);
    }

    public function stats(Request $request)
    {
        $user = $request->user();
        
        if (!$user) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        // Only admins can view store statistics
        if (!$user->isAdmin()) {
            return response()->json([
                'error' => 'Forbidden',
                'message' => 'Only store administrators can view store statistics'
            ], 403);
        }

        $store = Store::where('id', $user->store_id)->first();
        
        if (!$store) {
            return response()->json([
                'error' => 'Not Found',
                'message' => 'Store not found'
            ], 404);
        }

        // Get user statistics by role
        $userStats = User::where('store_id', $user->store_id)
            ->with('role')
            ->get()
            ->groupBy('role.nom')
            ->map(function ($users, $roleName) {
                return [
                    'role' => $roleName,
                    'count' => $users->count(),
                    'users' => $users->map(function ($user) {
                        return [
                            'id' => $user->id,
                            'username' => $user->username,
                            'nom' => $user->nom,
                            'status' => $user->status,
                        ];
                    })
                ];
            })
            ->values();

        return response()->json([
            'store' => [
                'id' => $store->id,
                'nom' => $store->nom,
            ],
            'statistics' => [
                'total_users' => User::where('store_id', $user->store_id)->count(),
                'total_roles' => Role::where('store_id', $user->store_id)->count(),
                'users_by_role' => $userStats,
            ]
        ]);
    }
} 