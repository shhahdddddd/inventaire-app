<?php

require __DIR__.'/vendor/autoload.php';

use Illuminate\Database\Capsule\Manager as Capsule;

$capsule = new Capsule;
$capsule->addConnection([
    'driver'    => 'mysql',
    'host'      => getenv('DB_HOST') ?: '127.0.0.1',
    'database'  => getenv('DB_DATABASE') ?: 'your_db',
    'username'  => getenv('DB_USERNAME') ?: 'your_user',
    'password'  => getenv('DB_PASSWORD') ?: 'your_pass',
    'charset'   => 'utf8',
    'collation' => 'utf8_unicode_ci',
    'prefix'    => '',
]);
$capsule->setAsGlobal();
$capsule->bootEloquent();

$users = Capsule::table('user')->get();
foreach ($users as $user) {
    $mot_de_passe = $user->mot_de_passe;
    // If not already bcrypt (starts with $2y$), hash it
    if (strpos($mot_de_passe, '$2y$') !== 0) {
        Capsule::table('user')->where('id', $user->id)->update([
            'mot_de_passe' => password_hash($mot_de_passe, PASSWORD_BCRYPT)
        ]);
        echo "Updated user {$user->username}\n";
    }
}
echo "All plain text passwords are now hashed.\n";
