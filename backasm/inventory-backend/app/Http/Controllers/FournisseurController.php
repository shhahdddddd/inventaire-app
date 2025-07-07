<?php

namespace App\Http\Controllers;

use App\Models\Fournisseur;
use Illuminate\Http\Request;

class FournisseurController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $user = $request->user();
        // Only show fournisseurs for the user's store
        $fournisseurs = Fournisseur::where('store_id', $user->store_id)->get();
        // RBAC: Only Admin, Purchasing Officer, Inventory Manager can view
        if (!($user->isAdmin() || $user->isPurchasingOfficer() || $user->isInventoryManager())) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        return response()->json($fournisseurs);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $user = $request->user();
        // Only Admin and Purchasing Officer can create
        if (!($user->isAdmin() || $user->isPurchasingOfficer())) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        $validatedData = $request->validate([
            'name' => 'required|string|max:255',
            'contact_nom' => 'required|string|max:255',
            'phone' => 'required|string|max:50',
            'email' => 'required|string|email|max:255|unique:fournisseurs',
            'address' => 'required|string',
        ]);
        $validatedData['store_id'] = $user->store_id;
        $fournisseur = Fournisseur::create($validatedData);
        return response()->json($fournisseur, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Fournisseur $fournisseur)
    {
        return $fournisseur;
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Fournisseur $fournisseur)
    {
        $validatedData = $request->validate([
            'name' => 'string|max:255',
            'contact_nom' => 'string|max:255',
            'phone' => 'string|max:50',
            'email' => 'string|email|max:255|unique:fournisseurs,email,' . $fournisseur->id,
            'address' => 'string',
        ]);

        $fournisseur->update($validatedData);

        return response()->json($fournisseur);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Fournisseur $fournisseur)
    {
        $fournisseur->delete();

        return response()->json(null, 204);
    }
}
