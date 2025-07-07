<?php

require_once 'vendor/autoload.php';

// Bootstrap Laravel
$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Hash;

echo "=== Login Test Script ===\n\n";

// Get all users
$users = User::all();

if ($users->isEmpty()) {
    echo "No users found in the database.\n";
    exit(1);
}

echo "Available users:\n";
foreach ($users as $user) {
    echo "- ID: {$user->id}, Username: {$user->username}, Name: {$user->nom}\n";
}

echo "\nEnter username to test: ";
$handle = fopen("php://stdin", "r");
$testUsername = trim(fgets($handle));
fclose($handle);

echo "Enter password to test: ";
$handle = fopen("php://stdin", "r");
$testPassword = trim(fgets($handle));
fclose($handle);

// Find the user
$user = User::where('username', $testUsername)->first();

if (!$user) {
    echo "✗ User with username '{$testUsername}' not found.\n";
    exit(1);
}

echo "\nFound user: {$user->nom} (ID: {$user->id})\n";
echo "Stored password hash: " . substr($user->mot_de_passe, 0, 20) . "...\n";

// Test password verification
if (Hash::check($testPassword, $user->mot_de_passe)) {
    echo "✓ Password verification successful!\n";
    echo "✓ Login should work with these credentials.\n";
    
    // Test the actual login method
    $credentials = [
        'username' => $testUsername,
        'password' => $testPassword
    ];
    
    if (auth()->attempt($credentials)) {
        echo "✓ Laravel auth()->attempt() successful!\n";
        $token = auth()->login($user);
        echo "✓ JWT token generated: " . substr($token, 0, 20) . "...\n";
    } else {
        echo "✗ Laravel auth()->attempt() failed.\n";
    }
} else {
    echo "✗ Password verification failed!\n";
    echo "✗ The password you entered doesn't match the stored hash.\n";
    echo "\nPossible issues:\n";
    echo "1. Password was not hashed when stored in database\n";
    echo "2. Wrong password entered\n";
    echo "3. Password was hashed with different method\n";
}

echo "\n=== Test Complete ===\n"; 