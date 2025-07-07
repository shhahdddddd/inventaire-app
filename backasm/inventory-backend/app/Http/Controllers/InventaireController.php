<?php

namespace App\Http\Controllers;

use App\Models\Inventaire;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class InventaireController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        // Only show inventaires for the user's store
        $inventaires = Inventaire::where('store_id', $user->store_id)
            ->with(['inventaireItems.article', 'stationSource', 'user'])
            ->get();
        // RBAC: Only Admin, Inventory Manager, Purchasing Officer can view
        if (!($user->isAdmin() || $user->isInventoryManager() || $user->isPurchasingOfficer())) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        return response()->json($inventaires);
    }

    public function store(Request $request)
    {
        $user = $request->user();
        // Only Admin and Inventory Manager can execute counts
        if (!($user->isAdmin() || $user->isInventoryManager())) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        $validator = Validator::make($request->all(), [
            'date_ouverture' => 'required|date',
            'station_id' => 'required|exists:station_sources,id',
            'user_id' => 'required|exists:users,id',
            'inventaire_items' => 'required|array|min:1',
            'inventaire_items.*.article_id' => 'required|exists:articles,id',
            'inventaire_items.*.qte_stock' => 'required|integer|min:0',
            'inventaire_items.*.quantite_relle' => 'required|integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $inventaire = Inventaire::create(array_merge(
            $request->only(['date_ouverture', 'station_id', 'user_id']),
            ['store_id' => $user->store_id]
        ));

        foreach ($request->inventaire_items as $item) {
            $inventaire->inventaireItems()->create($item);
        }

        return response()->json($inventaire->load(['inventaireItems.article', 'stationSource', 'user']), 201);
    }

    public function show($id)
    {
        $inventaire = Inventaire::with(['inventaireItems.article', 'stationSource', 'user'])->find($id);
        if (!$inventaire) {
            return response()->json(['message' => 'Inventaire not found'], 404);
        }
        return response()->json($inventaire);
    }

    public function update(Request $request, $id)
    {
        $inventaire = Inventaire::find($id);
        if (!$inventaire) {
            return response()->json(['message' => 'Inventaire not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'date_ouverture' => 'sometimes|date',
            'station_id' => 'sometimes|exists:station_sources,id',
            'user_id' => 'sometimes|exists:users,id',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $inventaire->update($request->only(['date_ouverture', 'station_id', 'user_id']));
        return response()->json($inventaire->load(['inventaireItems.article', 'stationSource', 'user']));
    }

    public function destroy($id)
    {
        $inventaire = Inventaire::find($id);
        if (!$inventaire) {
            return response()->json(['message' => 'Inventaire not found'], 404);
        }

        $inventaire->delete();
        return response()->json(['message' => 'Inventaire deleted successfully']);
    }
}
