<?php

return [
    'default' => 'default',
    'documentations' => [
        'default' => [
            'api' => [
                'title' => 'Laravel Inventory API',
            ],
            'routes' => [
                'api' => 'api/documentation',
            ],
            'paths' => [
                'docs_json' => 'api-docs.json',
                'docs_yaml' => 'api-docs.yaml',
                'annotations' => [
                    base_path('app'),
                    base_path('routes'),
                ],
            ],
        ],
    ],
    'generate_always' => env('L5_SWAGGER_GENERATE_ALWAYS', false),
    'swagger_version' => env('L5_SWAGGER_SWAGGER_VERSION', '3.0'),
    'proxy' => false,
    'additional_config_url' => null,
    'operations_sort' => null,
    'validator_url' => null,
];
