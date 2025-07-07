<?php

namespace App\Http\Controllers;

use App\Models\Famille;
use Illuminate\Http\Request;

class FamilleController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return Famille::all();
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validatedData = $request->validate([
            'name' => 'required|string|max:100',
            'designation' => 'required|string|max:100',
            'description' => 'nullable|string',
        ]);

        $famille = Famille::create($validatedData);

        return response()->json($famille, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Famille $famille)
    {
        return $famille;
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Famille $famille)
    {
        $validatedData = $request->validate([
            'name' => 'string|max:100',
            'designation' => 'string|max:100',
            'description' => 'nullable|string',
        ]);

        $famille->update($validatedData);

        return response()->json($famille);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Famille $famille)
    {
        $famille->delete();

        return response()->json(null, 204);
    }
}
