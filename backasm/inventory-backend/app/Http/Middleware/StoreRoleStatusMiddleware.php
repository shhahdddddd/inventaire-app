<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class StoreRoleStatusMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */
    public function handle(Request $request, Closure $next)
    {
        $user = Auth::user();
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }
        // 'status' is a virtual attribute for compatibility (always 'active')
        if ($user->status !== 'active') {
            return response()->json(['message' => 'Account not active'], 403);
        }
        // Optionally, enforce store scoping here for resource requests
        // Example: if ($request->route('store_id') && $request->route('store_id') != $user->store_id)
        //     return response()->json(['message' => 'Forbidden: Store mismatch'], 403);
        return $next($request);
    }
} 