<?php

namespace App\Http\Controllers;

use App\Models\InventaireItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class InventaireItemController extends Controller
{
    public function index(Request $request, $inventaire_id)
    {
        $user = $request->user();
        $inventaire = \App\Models\Inventaire::where('id', $inventaire_id)->where('store_id', $user->store_id)->first();
        if (!$inventaire) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        // RBAC: Only Admin, Inventory Manager, Purchasing Officer can view
        if (!($user->isAdmin() || $user->isInventoryManager() || $user->isPurchasingOfficer())) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        $items = InventaireItem::with('article')->where('inventaire_id', $inventaire_id)->get();
        return response()->json($items);
    }

    public function show($inventaire_id, $id)
    {
        $item = InventaireItem::with('article')->where('inventaire_id', $inventaire_id)->find($id);
        if (!$item) {
            return response()->json(['message' => 'Item not found'], 404);
        }
        return response()->json($item);
    }

    public function store(Request $request, $inventaire_id)
    {
        $user = $request->user();
        $inventaire = \App\Models\Inventaire::where('id', $inventaire_id)->where('store_id', $user->store_id)->first();
        if (!$inventaire) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        // Only Admin and Inventory Manager can add items
        if (!($user->isAdmin() || $user->isInventoryManager())) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        $validator = \Validator::make($request->all(), [
            'article_id' => 'required|exists:articles,id',
            'quantite_comptee' => 'required|integer|min:0',
            'quantite_reelle' => 'required|integer|min:0',
        ]);
        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }
        $item = new InventaireItem($request->all());
        $item->inventaire_id = $inventaire_id;
        $item->save();
        return response()->json($item->load('article'), 201);
    }

    public function update(Request $request, $inventaire_id, $id)
    {
        $item = InventaireItem::where('inventaire_id', $inventaire_id)->find($id);
        if (!$item) {
            return response()->json(['message' => 'Item not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'article_id' => 'sometimes|exists:articles,id',
            'quantite_comptee' => 'sometimes|integer|min:0',
            'quantite_reelle' => 'sometimes|integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $item->update($request->all());
        return response()->json($item->load('article'));
    }

    public function destroy($inventaire_id, $id)
    {
        $item = InventaireItem::where('inventaire_id', $inventaire_id)->find($id);
        if (!$item) {
            return response()->json(['message' => 'Item not found'], 404);
        }

        $item->delete();
        return response()->json(['message' => 'Item deleted successfully']);
    }
}
