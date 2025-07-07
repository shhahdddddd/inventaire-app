<?php

namespace App\Http\Controllers;

use App\Models\Marque;
use Illuminate\Http\Request;

class MarqueController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return Marque::all();
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

        $marque = Marque::create($validatedData);

        return response()->json($marque, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Marque $marque)
    {
        return $marque;
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Marque $marque)
    {
        $validatedData = $request->validate([
            'name' => 'string|max:100',
            'designation' => 'string|max:100',
            'description' => 'nullable|string',
        ]);

        $marque->update($validatedData);

        return response()->json($marque);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Marque $marque)
    {
        $marque->delete();

        return response()->json(null, 204);
    }
}
