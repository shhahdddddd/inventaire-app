<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckStore
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        
        if (!$user) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        // Get store_id from route parameters, request body, or query parameters
        $requestedStoreId = $request->route('store_id') ?? 
                           $request->input('store_id') ?? 
                           $request->query('store_id');

        // If a specific store is requested, verify the user belongs to that store
        if ($requestedStoreId && $user->store_id != $requestedStoreId) {
            return response()->json([
                'error' => 'Forbidden',
                'message' => 'Cross-store access denied. You can only access resources within your own store.'
            ], 403);
        }

        // Add store_id to the request for controllers to use
        $request->merge(['user_store_id' => $user->store_id]);

        return $next($request);
    }
}
