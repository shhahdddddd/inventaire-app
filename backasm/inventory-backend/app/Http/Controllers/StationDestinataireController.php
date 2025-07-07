<?php

namespace App\Http\Controllers;

use App\Models\StationDestinataire;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class StationDestinataireController extends Controller
{
    public function index()
    {
        $stations = StationDestinataire::all();
        return response()->json($stations);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nom' => 'required|string|max:100|unique:station_destinataires',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $station = StationDestinataire::create($request->all());
        return response()->json($station, 201);
    }

    public function show($id)
    {
        $station = StationDestinataire::find($id);
        if (!$station) {
            return response()->json(['message' => 'Station not found'], 404);
        }
        return response()->json($station);
    }

    public function update(Request $request, $id)
    {
        $station = StationDestinataire::find($id);
        if (!$station) {
            return response()->json(['message' => 'Station not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'nom' => 'required|string|max:100|unique:station_destinataires,nom,'.$id,
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $station->update($request->all());
        return response()->json($station);
    }

    public function destroy($id)
    {
        $station = StationDestinataire::find($id);
        if (!$station) {
            return response()->json(['message' => 'Station not found'], 404);
        }

        // Check if station is used in any transfer (optional)
        // We'll leave this as a TODO for now

        $station->delete();
        return response()->json(null, 204);
    }
}
