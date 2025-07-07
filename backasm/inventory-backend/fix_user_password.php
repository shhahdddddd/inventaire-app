<?php

require_once 'vendor/autoload.php';

// Bootstrap Laravel
$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\Hash;
use App\Models\User;

echo "=== User Password Fix Script ===\n\n";

// Get all users
$users = User::all();

if ($users->isEmpty()) {
    echo "No users found in the database.\n";
    echo "Please create a user first using the registration endpoint or manually.\n";
    exit(1);
}

echo "Found " . $users->count() . " user(s) in the database:\n\n";

foreach ($users as $user) {
    echo "User ID: " . $user->id . "\n";
    echo "Username: " . $user->username . "\n";
    echo "Name: " . $user->nom . "\n";
    echo "Current password hash: " . substr($user->mot_de_passe, 0, 20) . "...\n";
    
    // Check if password is already hashed
    if (strlen($user->mot_de_passe) < 60 || !Hash::check('test', $user->mot_de_passe)) {
        echo "Password appears to be plain text or not properly hashed.\n";
        
        // Ask for the plain text password
        echo "Enter the plain text password for user '{$user->username}': ";
        $handle = fopen("php://stdin", "r");
        $plainPassword = trim(fgets($handle));
        fclose($handle);
        
        if (!empty($plainPassword)) {
            // Hash the password
            $hashedPassword = Hash::make($plainPassword);
            
            // Update the user
            $user->mot_de_passe = $hashedPassword;
            $user->save();
            
            echo "✓ Password hashed and updated successfully!\n";
        } else {
            echo "✗ No password provided, skipping...\n";
        }
    } else {
        echo "✓ Password appears to be already hashed.\n";
    }
    
    echo "\n" . str_repeat("-", 50) . "\n\n";
}

echo "=== Password Fix Complete ===\n";
echo "You can now try logging in with your username and password.\n";
echo "Make sure your Flutter app is sending:\n";
echo "- username: your_username\n";
echo "- password: your_plain_text_password\n";
echo "\nThe backend will hash the password and compare it with the stored hash.\n"; 