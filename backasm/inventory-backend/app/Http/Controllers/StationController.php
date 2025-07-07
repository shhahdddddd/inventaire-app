<?php

namespace App\Http\Controllers;

use App\Models\StationSource;
use Illuminate\Http\Request;

class StationController extends Controller
{
    public function index()
    {
        $stations = StationSource::all();
        return response()->json($stations);
    }
}
