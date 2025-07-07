<?php

namespace App\Http\Controllers;

use App\Models\StationSource;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class StationSourceController extends Controller
{
    public function index()
    {
        $stations = StationSource::all();
        return response()->json($stations);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nom' => 'required|string|max:100|unique:station_sources',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $station = StationSource::create($request->all());
        return response()->json($station, 201);
    }

    public function show($id)
    {
        $station = StationSource::find($id);
        if (!$station) {
            return response()->json(['message' => 'Station not found'], 404);
        }
        return response()->json($station);
    }

    public function update(Request $request, $id)
    {
        $station = StationSource::find($id);
        if (!$station) {
            return response()->json(['message' => 'Station not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'nom' => 'required|string|max:100|unique:station_sources,nom,'.$id,
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
        $station = StationSource::find($id);
        if (!$station) {
            return response()->json(['message' => 'Station not found'], 404);
        }

        // Check if station is used in any transfer (optional)
        // We'll leave this as a TODO for now

        $station->delete();
        return response()->json(null, 204);
    }
}
