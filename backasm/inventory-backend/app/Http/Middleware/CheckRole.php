<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CheckRole
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @param  string  $roles  Comma-separated list of roles
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */
    public function handle(Request $request, Closure $next, ...$roles)
    {
        // Flatten the roles array in case multiple parameters are passed
        $allowedRoles = [];
        foreach ($roles as $role) {
            $allowedRoles = array_merge($allowedRoles, explode(',', $role));
        }
        
        // Clean up the roles array
        $allowedRoles = array_map('trim', $allowedRoles);
        $allowedRoles = array_filter($allowedRoles);

        if (!Auth::guard('api')->check()) {
            return response()->json([
                'error' => 'Unauthorized',
                'message' => 'Authentication required'
            ], 401);
        }

        $user = Auth::guard('api')->user();

        if (!$user->hasAnyRole($allowedRoles)) {
            return response()->json([
                'error' => 'Forbidden',
                'message' => 'Insufficient permissions. Required roles: ' . implode(', ', $allowedRoles)
            ], 403);
        }

        return $next($request);
    }
} 