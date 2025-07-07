<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;
use Tymon\JWTAuth\Facades\JWTAuth;

/**
 * @OA\Info(
 *     title="Inventory API",
 *     version="1.0.0",
 *     description="API documentation for the Inventory system with JWT auth."
 * )
 * @OA\SecurityScheme(
 *     type="http",
 *     description="Login with email and password to get the authentication token",
 *     name="Token based Based",
 *     in="header",
 *     scheme="bearer",
 *     bearerFormat="JWT",
 *     securityScheme="bearerAuth",
 * )
 */
class AuthController extends Controller
{
    // ───── LOGIN ───────────────────────────────────────────────
    public function login(Request $request)
    {
        try {
            $request->validate([
                'username' => 'required|string',
                'password' => 'required|string',
            ]);

            $user = User::where('username', $request->username)->first();

            if (!$user || !Hash::check($request->password, $user->mot_de_passe)) {
                return response()->json(['error' => 'Unauthorized'], 401);
            }

            $token = JWTAuth::fromUser($user);

            return $this->respondWithToken($token);
        } catch (\Exception $e) {
            Log::error('Login error: ' . $e->getMessage());
            return response()->json([
                'error' => 'Login failed',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    // ───── REGISTER ────────────────────────────────────────────
    public function register(Request $request)
    {
        try {
            Log::info('Registration attempt', $request->all());
            $validated = $request->validate([
                'username' => 'required|string|max:100|unique:user,username',
                'password' => 'required|string|min:8',
                'store_name' => 'required|string|max:255',
            ]);

            // Check if this is the first user
            if (User::count() === 0) {
                // Create store
                $store = \App\Models\Store::create(['nom' => $validated['store_name']]);
                // Assign admin role (assume role_id=1 is admin, adjust as needed)
                $adminRoleId = 1;
                // Get the first station_source id as default
                $stationId = \App\Models\StationSource::first()->id ?? 1;
                $user = User::create([
                    'username' => $validated['username'],
                    'mot_de_passe' => Hash::make($validated['password']),
                    'store_id' => $store->id,
                    'role_id' => $adminRoleId,
                    'station_id' => $stationId,
                    'nom' => $validated['username'], // use username as name
                    'status' => 'active',
                ]);
                Log::info('First user created as admin', ['id' => $user->id]);
                $token = JWTAuth::fromUser($user);
                return response()->json([
                    'status' => 'success',
                    'message' => 'Admin user and store created successfully',
                    'user' => $user,
                    'authorisation' => [
                        'token' => $token,
                        'type' => 'bearer',
                    ]
                ], 201);
            } else {
                // All other registrations are denied
                return response()->json([
                    'status' => 'error',
                    'message' => 'Contact your admin for access'
                ], 403);
            }
        } catch (ValidationException $e) {
            return response()->json(['errors' => $e->errors()], 422);
        } catch (\Exception $e) {
            Log::error('REGISTRATION ERROR: ' . $e->getMessage());
            return response()->json([
                'error' => 'Registration failed',
                'message' => $e->getMessage() // For debugging only
            ], 500);
        }
    }

    // ───── LOGOUT / REFRESH / USER / ME ────────────────────────
    public function logout()
    {
        try {
            JWTAuth::invalidate(JWTAuth::getToken());
            return response()->json(['status' => 'success', 'message' => 'Successfully logged out']);
        } catch (\Exception $e) {
            Log::error('Logout error: ' . $e->getMessage());
            return response()->json([
                'error' => 'Logout failed',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function refresh()
    {
        try {
            $token = JWTAuth::refresh(JWTAuth::getToken());
            return $this->respondWithToken($token);
        } catch (\Exception $e) {
            Log::error('Token refresh error: ' . $e->getMessage());
            return response()->json([
                'error' => 'Token refresh failed',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    // route GET /user
    public function user()
    {
        try {
            $user = Auth::guard('api')->user();
            
            if (!$user) {
                return response()->json(['error' => 'User not authenticated'], 401);
            }
            
            // Load relationships safely
            try {
                $user = User::with(['role', 'store', 'station'])->find($user->id);
            } catch (\Exception $e) {
                Log::warning('Could not load user relationships: ' . $e->getMessage());
            }
            
            return response()->json([
                'id' => $user->id,
                'username' => $user->username,
                'nom' => $user->nom,
                'role' => $user->role,
                'store' => $user->store,
                'station' => $user->station,
                'store_id' => $user->store_id,
                'station_id' => $user->station_id,
                'role_id' => $user->role_id,
            ]);
        } catch (\Exception $e) {
            Log::error('Error in user method: ' . $e->getMessage());
            return response()->json([
                'error' => 'Failed to fetch user data',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function me()
    {
        try {
            $user = Auth::guard('api')->user();
            if (!$user) {
                return response()->json(['error' => 'User not authenticated'], 401);
            }
            return response()->json($user);
        } catch (\Exception $e) {
            Log::error('Error in me method: ' . $e->getMessage());
            return response()->json([
                'error' => 'Failed to fetch user data',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    // ───── ACTIVATE ────────────────────────────────────────────
    public function activate(Request $request)
    {
        try {
            $request->validate([
                'username' => 'required|string',
                'password' => 'required|string|min:8',
            ]);

            $user = User::where('username', $request->username)
                        ->where('status', 'pending')
                        ->first();

            if (!$user) {
                return response()->json([
                    'error' => 'User not found or already activated'
                ], 404);
            }

            $user->update([
                'mot_de_passe' => Hash::make($request->password),
                'status' => 'active'
            ]);

            $token = JWTAuth::fromUser($user);

            return response()->json([
                'status' => 'success',
                'message' => 'Account activated successfully',
                'authorisation' => [
                    'token' => $token,
                    'type' => 'bearer',
                ]
            ]);
        } catch (\Exception $e) {
            Log::error('Account activation error: ' . $e->getMessage());
            return response()->json([
                'error' => 'Account activation failed',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    // ───── TOKEN WRAPPER ───────────────────────────────────────
    protected function respondWithToken($token)
    {
        try {
            $ttl = config('jwt.ttl', 60); // Default to 60 minutes if not set
            return response()->json([
                'access_token' => $token,
                'token_type'   => 'bearer',
                'expires_in'   => $ttl * 60, // Convert to seconds
            ]);
        } catch (\Exception $e) {
            Log::error('Error creating token response: ' . $e->getMessage());
            return response()->json([
                'error' => 'Token generation failed',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}
?>
