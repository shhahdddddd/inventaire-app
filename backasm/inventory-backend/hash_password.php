<?php

require_once 'vendor/autoload.php';

// Bootstrap Laravel
$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\Hash;
use App\Models\User;

echo "=== Auto Password Hash Script ===\n\n";

// Get all users
$users = User::all();

if ($users->isEmpty()) {
    echo "No users found in the database.\n";
    exit(1);
}

echo "Found " . $users->count() . " user(s) in the database:\n\n";

foreach ($users as $user) {
    echo "User ID: " . $user->id . "\n";
    echo "Username: " . $user->username . "\n";
    echo "Name: " . $user->nom . "\n";
    echo "Current password: " . $user->mot_de_passe . "\n";
    
    // Check if password is already hashed (hashed passwords are typically 60+ characters)
    if (strlen($user->mot_de_passe) < 60) {
        echo "Password appears to be plain text. Hashing it...\n";
        
        // Hash the current password (assuming it's plain text)
        $plainPassword = $user->mot_de_passe;
        $hashedPassword = Hash::make($plainPassword);
        
        // Update the user
        $user->mot_de_passe = $hashedPassword;
        $user->save();
        
        echo "✓ Password hashed and updated successfully!\n";
        echo "Original password: {$plainPassword}\n";
        echo "New hash: " . substr($hashedPassword, 0, 20) . "...\n";
    } else {
        echo "✓ Password appears to be already hashed.\n";
    }
    
    echo "\n" . str_repeat("-", 50) . "\n\n";
}

echo "=== Password Hash Complete ===\n";
echo "You can now try logging in with your username and the original password.\n";
echo "The backend will hash the password you enter and compare it with the stored hash.\n"; 